from typing import Optional, List
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from sqlalchemy import delete, text
from fastapi import HTTPException
from . import models, schemas
from modules.catalog.models import Product
from modules.security.models import Employee, SecurityProfile
from modules.orders.models import Order

class POSService:
    _last_gc_time = None  # Throttle para garbage collection (1x por minuto máximo)
    async def create_session(self, db: AsyncSession, session: schemas.TerminalSessionCreate):
        db_session = models.TerminalSession(**session.model_dump())
        db.add(db_session)
        await db.commit()
        await db.refresh(db_session)
        return db_session

    async def get_active_session(self, db: AsyncSession, terminal_id: str):
        result = await db.execute(
            select(models.TerminalSession)
            .where(models.TerminalSession.terminal_id == terminal_id)
            .where(models.TerminalSession.is_active == True)
        )
        return result.scalars().first()

    async def create_ticket(self, db: AsyncSession, ticket: schemas.TicketCreate):
        """Crea o actualiza un ticket, aplicando validaciones y reglas de negocio."""
        # 1. Validar productos y calcular totales
        db_items, total = await self._get_items_and_total(db, ticket.items)

        # 2. Buscar/Crear cabecera de ticket
        db_ticket = await self._upsert_ticket_header(db, ticket, total)

        # 3. Persistir movimientos de artículos
        await self._sync_ticket_items(db, db_ticket.id, db_items)
        
        await db.commit()

        # 4. PUENTE POS → PRODUCCIÓN: Si es un PEDIDO pagado, crear Order en PostgreSQL
        if db_ticket.order_type == "PEDIDO" and db_ticket.status == "PAID":
            await self._create_order_from_ticket(db, db_ticket)

        return await self._get_full_ticket(db, db_ticket.id)

    async def _get_items_and_total(self, db: AsyncSession, items: List[schemas.TicketItemCreate]):
        """Valida stock/existencia y calcula el valor total del carrito."""
        total = 0.0
        db_items = []
        for item in items:
            product = await db.get(Product, item.product_id)
            if not product:
                raise HTTPException(status_code=404, detail=f"Product {item.product_id} not found")
            if not product.active:
                raise HTTPException(status_code=400, detail=f"Product {product.name} is inactive")
            
            subtotal = product.price * item.quantity
            total += subtotal
            db_items.append(models.TicketItem(
                product_id=product.id,
                quantity=item.quantity,
                unit_price=product.price,
                subtotal=subtotal
            ))
        return db_items, total

    async def _upsert_ticket_header(self, db: AsyncSession, ticket: schemas.TicketCreate, total: float):
        """Encuentra un ticket existente o inicializa uno nuevo.
        Usa FOR UPDATE para bloquear la fila y evitar race conditions entre auto-save y cobro.
        v4.0: Implementa bloqueo optimista con campo `version`."""
        result = await db.execute(
            select(models.Ticket)
            .where(models.Ticket.account_num == ticket.account_num)
            .with_for_update()
        )
        db_ticket = result.scalars().first()

        if db_ticket:
            if db_ticket.status == "PAID":
                raise HTTPException(
                    status_code=400, 
                    detail=f"El folio {ticket.account_num} ya ha sido pagado y no puede modificarse."
                )
            # Obtener el terminal_id de la petición entrante para verificaciones
            req_terminal_id = None
            if ticket.session_id:
                session = await db.get(models.TerminalSession, ticket.session_id)
                req_terminal_id = session.terminal_id if session else None

            # BLOQUEO OPTIMISTA v4.0: Si el cliente envía una versión, validar que coincida
            if ticket.version is not None and ticket.version != db_ticket.version:
                # BYPASS v4.4: Falsos positivos por timeout de red ("Hora Pico")
                # Si la petición viene de la MISMA terminal que ya es dueña del ticket, 
                # es un reintento idempotente tras un fallo de red. Se perdona el conflicto.
                if req_terminal_id and req_terminal_id == db_ticket.terminal_id:
                    import logging
                    logging.getLogger("pos.optimistic_lock").info(
                        f"Bypass de version para {ticket.account_num} en {req_terminal_id}. Retry de red perdonado."
                    )
                else:
                    raise HTTPException(
                        status_code=409,
                        detail=f"Conflicto de versión en folio {ticket.account_num}. "
                               f"Versión del cliente: {ticket.version}, versión actual: {db_ticket.version}. "
                               f"Otro usuario modificó esta cuenta. Recupere la cuenta del Pizarrón e intente de nuevo."
                    )
            return await self._update_ticket_fields(db, db_ticket, ticket, total)
        
        return await self._initialize_new_ticket(db, ticket, total)

    async def _update_ticket_fields(self, db: AsyncSession, db_ticket: models.Ticket, ticket: schemas.TicketCreate, total: float):
        """Actualiza campos de un ticket existente.
        v4.0: Incrementa version en cada update para bloqueo optimista."""
        db_ticket.total = total
        db_ticket.status = ticket.status
        db_ticket.payment_details = ticket.payment_details
        db_ticket.cash_session_id = ticket.cash_session_id
        
        db_ticket.order_type = ticket.order_type
        db_ticket.order_status = ticket.order_status
        db_ticket.delivery_type = ticket.delivery_type
        db_ticket.customer_name = ticket.customer_name
        db_ticket.customer_phone = ticket.customer_phone
        db_ticket.committed_at = ticket.committed_at.replace(tzinfo=None) if ticket.committed_at else None
        db_ticket.packaging_type = ticket.packaging_type
        db_ticket.delivery_address = ticket.delivery_address
        db_ticket.order_notes = ticket.order_notes
        
        if ticket.status == "PAID" and ticket.cashed_by_id:
            db_ticket.cashed_by_id = ticket.cashed_by_id
        
        if ticket.captured_by_id:
            db_ticket.captured_by_id = ticket.captured_by_id

        # Asegurar que la terminal actual se convierte en la dueña del ticket
        if ticket.session_id:
            session = await db.get(models.TerminalSession, ticket.session_id)
            if session:
                db_ticket.terminal_id = session.terminal_id

        # v4.0 BLOQUEO OPTIMISTA: Incrementar versión en cada update
        db_ticket.version = (db_ticket.version or 1) + 1
            
        return db_ticket

    async def _initialize_new_ticket(self, db: AsyncSession, ticket: schemas.TicketCreate, total: float):
        """Crea una nueva instancia de Ticket validando la sesión de terminal."""
        session = await db.get(models.TerminalSession, ticket.session_id)
        if not session or not session.is_active:
            raise HTTPException(status_code=400, detail="Terminal session invalid or inactive")
        
        db_ticket = models.Ticket(
            account_num=ticket.account_num,
            session_id=ticket.session_id,
            terminal_id=session.terminal_id,  # Campo directo — nunca más depender de la relación
            total=total,
            status=ticket.status or "OPEN",
            payment_details=ticket.payment_details,
            cash_session_id=ticket.cash_session_id,
            captured_by_id=ticket.captured_by_id,
            cashed_by_id=ticket.cashed_by_id if ticket.status == "PAID" else None,
            order_type=ticket.order_type,
            order_status=ticket.order_status,
            delivery_type=ticket.delivery_type,
            customer_name=ticket.customer_name,
            customer_phone=ticket.customer_phone,
            committed_at=ticket.committed_at.replace(tzinfo=None) if ticket.committed_at else None,
            packaging_type=ticket.packaging_type,
            delivery_address=ticket.delivery_address,
            order_notes=ticket.order_notes
        )
        db.add(db_ticket)
        await db.flush()
        return db_ticket

    async def _sync_ticket_items(self, db: AsyncSession, ticket_id: int, db_items: List[models.TicketItem]):
        """
        Sincronización inteligente de items: preserva IDs existentes.
        - Productos que ya estaban → actualiza qty/precio
        - Productos nuevos → inserta
        - Productos que ya no están → elimina
        
        v3.0: Incluye detección anti-downgrade para auditoría.
        """
        import logging
        logger = logging.getLogger("pos.ticket_sync")

        # Obtener items actuales del ticket
        existing_result = await db.execute(
            select(models.TicketItem).where(models.TicketItem.ticket_id == ticket_id)
        )
        existing_items = {item.product_id: item for item in existing_result.scalars().all()}
        
        # v3.0 ANTI-DOWNGRADE: Detectar reducciones drásticas de items (señal de stale closure)
        old_count = len(existing_items)
        new_count = len(db_items)
        if old_count > 0 and new_count > 0 and new_count < old_count:
            old_total = sum(item.subtotal for item in existing_items.values())
            new_total = sum(item.subtotal for item in db_items)
            drop_pct = ((old_total - new_total) / old_total * 100) if old_total > 0 else 0
            if drop_pct > 50:
                logger.warning(
                    f"⚠️ ANTI-DOWNGRADE: Ticket #{ticket_id} — Items: {old_count}→{new_count}, "
                    f"Total: ${old_total:.2f}→${new_total:.2f} (caída {drop_pct:.0f}%%). "
                    f"Posible stale closure. Revisar si es intencional."
                )

        new_product_ids = set()
        for new_item in db_items:
            new_product_ids.add(new_item.product_id)
            
            if new_item.product_id in existing_items:
                # Actualizar item existente (preserva su ID)
                old = existing_items[new_item.product_id]
                old.quantity = new_item.quantity
                old.unit_price = new_item.unit_price
                old.subtotal = new_item.subtotal
            else:
                # Insertar item nuevo
                new_item.ticket_id = ticket_id
                db.add(new_item)
        
        # Eliminar items que ya no están en el carrito
        for pid, old_item in existing_items.items():
            if pid not in new_product_ids:
                await db.delete(old_item)

    async def _get_full_ticket(self, db: AsyncSession, ticket_id: int):
        """Recupera un ticket con CARGA ANSIOSA de todas las relaciones para evitar MissingGreenlet."""
        result = await db.execute(
            select(models.Ticket)
            .options(
                selectinload(models.Ticket.items).selectinload(models.TicketItem.product).selectinload(Product.category),
                selectinload(models.Ticket.items).selectinload(models.TicketItem.product).selectinload(Product.technical_sheet),
                selectinload(models.Ticket.session),
                selectinload(models.Ticket.captured_by).selectinload(Employee.profile),
                selectinload(models.Ticket.cashed_by).selectinload(Employee.profile)
            )
            .where(models.Ticket.id == ticket_id)
        )
        ticket_obj = result.scalar_one()
        return self._populate_flat_fields(ticket_obj)

    def _populate_flat_fields(self, ticket_obj: models.Ticket):
        """Puebla campos calculados o nombres planos para el frontend."""
        # Prioridad: campo directo > relación > fallback
        if not ticket_obj.terminal_id:
            ticket_obj.terminal_id = ticket_obj.session.terminal_id if ticket_obj.session else "UNKNOWN"
        ticket_obj.captured_by_name = ticket_obj.captured_by.name if ticket_obj.captured_by else "SISTEMA"
        
        if ticket_obj.status == "OPEN":
            ticket_obj.cashed_by_name = "--- PENDIENTE ---"
        else:
            ticket_obj.cashed_by_name = ticket_obj.cashed_by.name if ticket_obj.cashed_by else "SISTEMA/AUTO"
            
        return ticket_obj

    async def _create_order_from_ticket(self, db: AsyncSession, ticket: models.Ticket):
        """
        PUENTE POS → PRODUCCIÓN (PostgreSQL, NO RAM).
        Crea un registro en la tabla 'orders' cuando se paga un pedido.
        Protección de idempotencia: si ya existe un Order para este ticket, no duplica.
        """
        # Verificar que no exista ya (idempotencia)
        existing = await db.execute(
            select(Order).where(Order.ticket_id == ticket.id)
        )
        if existing.scalar_one_or_none():
            return  # Ya existe, no duplicar

        order = Order(
            ticket_id=ticket.id,
            delivery_type=ticket.delivery_type or "PICKUP",
            status="PAGADO",  # Primer estado de producción
            customer_name=ticket.customer_name,
            customer_phone=ticket.customer_phone,
            committed_at=ticket.committed_at,
            packaging_type=ticket.packaging_type or "PROPIO",
            delivery_address=ticket.delivery_address,
            notes=ticket.order_notes,
        )
        db.add(order)
        await db.commit()


    async def get_open_tickets(self, db: AsyncSession):
        """Obtiene todos los tickets en estado OPEN."""
        result = await db.execute(
            select(models.Ticket)
            .options(
                selectinload(models.Ticket.items).selectinload(models.TicketItem.product).selectinload(Product.category),
                selectinload(models.Ticket.items).selectinload(models.TicketItem.product).selectinload(Product.technical_sheet),
                selectinload(models.Ticket.session),
                selectinload(models.Ticket.captured_by).selectinload(Employee.profile),
                selectinload(models.Ticket.cashed_by).selectinload(Employee.profile)
            )
            .where(models.Ticket.status == "OPEN")
            .where(models.Ticket.total > 0)
            .order_by(models.Ticket.created_at.desc())
        )
        tickets = result.scalars().all()
        return [self._populate_flat_fields(t) for t in tickets]

    async def get_tickets(self, db: AsyncSession, terminal_id: str = None, status: str = None, search: str = None, limit: int = 100):
        """
        SERIALIZACIÓN UNIFICADA: Usa el MISMO patrón de carga ansiosa y
        _populate_flat_fields() que _get_full_ticket() para garantizar
        paridad absoluta entre Crear Ticket y Listar en Auditoría.
        """
        query = select(models.Ticket).options(
            selectinload(models.Ticket.items).selectinload(models.TicketItem.product).selectinload(Product.category),
            selectinload(models.Ticket.items).selectinload(models.TicketItem.product).selectinload(Product.technical_sheet),
            selectinload(models.Ticket.session),
            selectinload(models.Ticket.captured_by).selectinload(Employee.profile),
            selectinload(models.Ticket.cashed_by).selectinload(Employee.profile)
        )
        
        if terminal_id:
            # Usar campo directo si existe, sino fallback a join
            query = query.where(models.Ticket.terminal_id == terminal_id)
        if status:
            query = query.where(models.Ticket.status == status)
        if search:
            query = query.where(models.Ticket.account_num.ilike(f"%{search}%"))
            
        query = query.order_by(models.Ticket.created_at.desc()).limit(limit)
        
        result = await db.execute(query)
        tickets = result.scalars().all()
        
        # Usar la MISMA función de población que _get_full_ticket
        return [self._populate_flat_fields(t) for t in tickets]

    async def reserve_ticket(self, db: AsyncSession, terminal_id: str, captured_by_id: int = None):
        """Reserva un ticket vacío o genera uno nuevo con ID correlativo.
        Ahora acepta captured_by_id para trazabilidad desde el primer instante."""
        session = await self.get_active_session(db, terminal_id)
        if not session:
            raise HTTPException(status_code=400, detail="No active session for terminal")

        # 0. Garbage Collection de tickets huérfanos (throttled a 1x por minuto)
        await self._cleanup_stale_empty_tickets(db, terminal_id)

        # 1. Intentar reciclar un ticket vacío (cross-session para el mismo terminal)
        recycled = await self._find_empty_ticket(db, terminal_id)
        if recycled:
            # Asignar capturista desde el momento de la reserva
            if captured_by_id and not recycled.captured_by_id:
                recycled.captured_by_id = captured_by_id
                await db.flush()
            return await self._get_full_ticket(db, recycled.id)

        # 2. Generar ticket nuevo con folio automático
        new_ticket = await self._generate_consecutive_ticket(db, session.id, terminal_id, captured_by_id)
        return await self._get_full_ticket(db, new_ticket.id)

    async def _find_empty_ticket(self, db: AsyncSession, terminal_id: str):
        """
        Busca un ticket abierto sin items ni monto para el MISMO TERMINAL (cross-session).
        Usa FOR UPDATE SKIP LOCKED para evitar que dos terminales reciclen el mismo ticket.
        """
        result = await db.execute(
            select(models.Ticket)
            .options(selectinload(models.Ticket.items))
            .where(models.Ticket.terminal_id == terminal_id)
            .where(models.Ticket.status == "OPEN")
            .where(models.Ticket.total == 0.0)
            .with_for_update(skip_locked=True)
            .limit(5)
        )
        tickets = result.scalars().all()
        for t in tickets:
            if len(t.items) == 0:
                return t
        return None

    async def _cleanup_stale_empty_tickets(self, db: AsyncSession, terminal_id: str):
        """
        Garbage Collector: elimina tickets vacíos huérfanos con más de 24 horas.
        Throttled a máximo 1 ejecución por minuto para no degradar rendimiento.
        """
        now = datetime.utcnow()
        if POSService._last_gc_time and (now - POSService._last_gc_time) < timedelta(minutes=1):
            return  # Throttle: no ejecutar más de 1x por minuto
        POSService._last_gc_time = now

        try:
            cutoff = now - timedelta(hours=24)
            stale = await db.execute(
                select(models.Ticket)
                .options(selectinload(models.Ticket.items))
                .where(models.Ticket.status == "OPEN")
                .where(models.Ticket.total == 0.0)
                .where(models.Ticket.created_at < cutoff)
                .limit(20)
            )
            deleted_count = 0
            for t in stale.scalars().all():
                if len(t.items) == 0:
                    await db.delete(t)
                    deleted_count += 1
            if deleted_count > 0:
                await db.flush()
                print(f"🧹 GC: Eliminados {deleted_count} tickets vacíos huérfanos (>24h)")
        except Exception as e:
            print(f"⚠️ GC: Error limpiando tickets vacíos: {e}")

    async def _ensure_folio_sequence(self, db: AsyncSession):
        """
        Crea la secuencia PostgreSQL 'ticket_folio_seq' si no existe.
        La inicializa con el folio más alto actualmente en la tabla tickets.
        Esta secuencia es ATÓMICA a nivel de base de datos:
        incluso 100 terminales pidiendo folio al mismo instante recibirán valores únicos.
        """
        try:
            # Verificar si la secuencia ya existe
            check = await db.execute(text("SELECT 1 FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'ticket_folio_seq'"))
            if check.scalar():
                return  # Ya existe, no hacer nada
            
            # Encontrar el folio numérico más alto para inicializar la secuencia
            all_tickets = await db.execute(select(models.Ticket.account_num))
            all_nums = all_tickets.scalars().all()
            max_num = 0
            for acn in all_nums:
                if acn and acn.startswith('V'):
                    try:
                        num = int(acn[1:])
                        if num > max_num:
                            max_num = num
                    except ValueError:
                        continue
            
            start_val = max_num + 1
            await db.execute(text(f"CREATE SEQUENCE ticket_folio_seq START WITH {start_val}"))
            await db.commit()
            print(f"✅ Secuencia ticket_folio_seq creada, iniciando en {start_val}")
        except Exception as e:
            print(f"⚠️ Error creando secuencia (puede que ya exista): {e}")
            await db.rollback()

    async def _generate_consecutive_ticket(self, db: AsyncSession, session_id: int, terminal_id: str = None, captured_by_id: int = None):
        """
        Crea un ticket nuevo con folio atómico usando SECUENCIA de PostgreSQL.
        Garantía: NUNCA dos terminales obtendrán el mismo folio, sin importar la concurrencia.
        Ahora incluye terminal_id directo y captured_by_id desde la creación.
        """
        await self._ensure_folio_sequence(db)
        
        for attempt in range(3):
            try:
                result = await db.execute(text("SELECT nextval('ticket_folio_seq')"))
                next_num = result.scalar()
                account_num = f"V{next_num:04d}"
                
                db_ticket = models.Ticket(
                    account_num=account_num,
                    session_id=session_id,
                    terminal_id=terminal_id,
                    captured_by_id=captured_by_id,
                    total=0.0,
                    status="OPEN"
                )
                db.add(db_ticket)
                await db.commit()
                await db.refresh(db_ticket)
                return db_ticket
            except Exception as e:
                await db.rollback()
                error_msg = str(e).lower()
                if "unique" in error_msg or "duplicate" in error_msg:
                    print(f"⚠️ Colisión en folio {account_num} (intento {attempt+1}/3). Avanzando secuencia...")
                    continue
                raise
        
        raise HTTPException(status_code=500, detail="No se pudo generar un folio único después de 3 intentos")

    async def upload_training_images(self, payload: schemas.VisionTrainingUpload):
        import os
        import base64
        import time
        from pathlib import Path
        
        base_dir = Path("apps/api/static/training")
        base_dir.mkdir(parents=True, exist_ok=True)
        
        safe_sku = "".join(c for c in payload.sku if c.isalnum() or c in ("-", "_")).rstrip()
        sku_dir = base_dir / safe_sku
        sku_dir.mkdir(parents=True, exist_ok=True)
        
        saved_files = []
        for i, b64_str in enumerate(payload.images):
            try:
                if "," in b64_str:
                    b64_str = b64_str.split(",")[1]
                
                img_data = base64.b64decode(b64_str)
                filename = f"train_{int(time.time())}_{i}.jpg"
                file_path = sku_dir / filename
                
                with open(file_path, "wb") as f:
                    f.write(img_data)
                
                saved_files.append(str(file_path))
            except Exception as e:
                print(f"Error guardando imagen {i} para SKU {payload.sku}: {e}")
            
        return {"sku": payload.sku, "count": len(saved_files), "path": str(sku_dir)}

    async def predict_vision(self, payload: schemas.VisionPredictionRequest):
        import time
        import base64
        import cv2
        import numpy as np
        from pathlib import Path

        start_time = time.time()
        
        # 1. Decodificar imagen de la cámara
        try:
            b64_str = payload.image
            if "," in b64_str:
                b64_str = b64_str.split(",")[1]
            img_data = base64.b64decode(b64_str)
            nparr = np.frombuffer(img_data, np.uint8)
            frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if frame is None:
                raise ValueError("Could not decode image")
        except Exception as e:
            return schemas.VisionPredictionResponse(detections=[], engine="local", latency_ms=(time.time()-start_time)*1000)

        # 2. Inicializar detector ORB (Rápido y local)
        orb = cv2.ORB_create(nfeatures=500)
        kp_frame, des_frame = orb.detectAndCompute(frame, None)
        
        if des_frame is None:
            return schemas.VisionPredictionResponse(detections=[], engine="local", latency_ms=(time.time()-start_time)*1000)

        # 3. Escanear dataset local
        base_dir = Path("apps/api/static/training")
        if not base_dir.exists():
            return schemas.VisionPredictionResponse(detections=[], engine="local", latency_ms=(time.time()-start_time)*1000)

        best_sku = None
        best_score = 0.0
        
        # BFMatcher para comparar características de forma cruda
        bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)

        for sku_path in base_dir.iterdir():
            if not sku_path.is_dir(): continue
            
            sku_name = sku_path.name
            sku_max_matches = 0
            
            # Revisar hasta 3 fotos de entrenamiento por SKU para máxima velocidad
            train_images = list(sku_path.glob("*.jpg"))
            for img_file in train_images[:3]:
                train_img = cv2.imread(str(img_file), cv2.IMREAD_COLOR)
                if train_img is None: continue
                
                kp_train, des_train = orb.detectAndCompute(train_img, None)
                if des_train is None: continue
                
                matches = bf.match(des_frame, des_train)
                # Contamos coincidencias de buena calidad (distancia baja)
                good_matches = len([m for m in matches if m.distance < 45])
                
                if good_matches > sku_max_matches:
                    sku_max_matches = good_matches
            
            # Normalización heurística del score
            score = sku_max_matches / 40.0 # Umbral de 40 puntos para considerarlo sólido
            if score > best_score:
                best_score = score
                best_sku = sku_name

        detections = []
        # Umbral de confianza mínimo para evitar falsos positivos
        if best_sku and best_score > 0.35:
            # Limpiamos el SKU (guiones por espacios) para que coincida con el nombre del producto
            detections.append(schemas.VisionDetection(
                label=best_sku.replace("_", " ").upper(), 
                qty=1, 
                confidence=min(best_score, 1.0)
            ))

        return schemas.VisionPredictionResponse(
            detections=detections,
            engine="local",
            latency_ms=(time.time() - start_time) * 1000
        )

pos_service = POSService()
