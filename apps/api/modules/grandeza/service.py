"""
MÓDULO: grandeza/service.py
Servicios de negocio para el módulo Reparto Pan Grandeza.
Fase 0: Solo operaciones CRUD base. La lógica inteligente se agrega en fases posteriores.
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from sqlalchemy.orm import selectinload
from typing import List, Optional
from datetime import date

from .models import (
    GrandezaProductConfig, GrandezaClient, GrandezaRouteSlot,
    GrandezaJourney, GrandezaInventory, GrandezaVisit, GrandezaVisitItem,
    GrandezaDriverLocation, GrandezaSettings
)
from modules.catalog.models import Product


class GrandezaService:

    # ─── Productos Grandeza ───────────────────────────────────────────────

    async def get_grandeza_products(self, db: AsyncSession):
        """Lista todos los productos habilitados para Grandeza con su info del catálogo."""
        stmt = (
            select(GrandezaProductConfig)
            .options(selectinload(GrandezaProductConfig.product))
            .where(GrandezaProductConfig.is_enabled == True)
            .order_by(GrandezaProductConfig.id)
        )
        result = await db.execute(stmt)
        configs = result.scalars().all()
        
        # Enriquecer con datos del producto
        response = []
        for cfg in configs:
            data = {
                "id": cfg.id,
                "product_id": cfg.product_id,
                "is_enabled": cfg.is_enabled,
                "b2b_price": cfg.b2b_price,
                "product_name": cfg.product.name if cfg.product else None,
                "product_sku": cfg.product.sku if cfg.product else None,
                "product_price": cfg.product.price if cfg.product else None,
            }
            response.append(data)
        return response

    async def upsert_grandeza_product(self, db: AsyncSession, product_id: int, b2b_price: float, is_enabled: bool = True):
        """Crear o actualizar la configuración Grandeza de un producto."""
        stmt = select(GrandezaProductConfig).where(GrandezaProductConfig.product_id == product_id)
        result = await db.execute(stmt)
        config = result.scalar_one_or_none()
        
        if config:
            config.b2b_price = b2b_price
            config.is_enabled = is_enabled
        else:
            config = GrandezaProductConfig(product_id=product_id, b2b_price=b2b_price, is_enabled=is_enabled)
            db.add(config)
        
        await db.flush()
        return config

    async def disable_grandeza_product(self, db: AsyncSession, product_id: int):
        """Deshabilitar un producto del módulo Grandeza (no lo borra, solo lo marca)."""
        stmt = select(GrandezaProductConfig).where(GrandezaProductConfig.product_id == product_id)
        result = await db.execute(stmt)
        config = result.scalar_one_or_none()
        if config:
            config.is_enabled = False
            await db.flush()
        return config

    # ─── Clientes ─────────────────────────────────────────────────────────

    async def get_clients(self, db: AsyncSession, active_only: bool = True):
        """Lista clientes con sus slots de ruta."""
        stmt = select(GrandezaClient).options(selectinload(GrandezaClient.route_slots))
        if active_only:
            stmt = stmt.where(GrandezaClient.active == True)
        stmt = stmt.order_by(GrandezaClient.name)
        result = await db.execute(stmt)
        return result.scalars().all()

    async def get_client(self, db: AsyncSession, client_id: int):
        """Obtener un cliente por ID."""
        stmt = (
            select(GrandezaClient)
            .options(selectinload(GrandezaClient.route_slots))
            .where(GrandezaClient.id == client_id)
        )
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    async def create_client(self, db: AsyncSession, data: dict):
        client = GrandezaClient(**data)
        db.add(client)
        await db.flush()
        return await self.get_client(db, client.id)

    async def update_client(self, db: AsyncSession, client_id: int, data: dict):
        client = await self.get_client(db, client_id)
        if not client:
            return None
        for key, value in data.items():
            if value is not None and hasattr(client, key):
                setattr(client, key, value)
        await db.flush()
        return client

    # ─── Route Slots ──────────────────────────────────────────────────────

    async def get_route_by_day(self, db: AsyncSession, day_of_week: str):
        """Obtener la ruta de un día específico con clientes ordenados."""
        stmt = (
            select(GrandezaRouteSlot)
            .options(selectinload(GrandezaRouteSlot.client))
            .where(GrandezaRouteSlot.day_of_week == day_of_week.upper())
            .order_by(GrandezaRouteSlot.visit_order)
        )
        result = await db.execute(stmt)
        return result.scalars().all()

    async def set_route_slots(self, db: AsyncSession, day_of_week: str, slots: list):
        """Reemplazar la ruta completa de un día (para reordenar o cambiar clientes)."""
        # Eliminar slots existentes para ese día
        await db.execute(
            delete(GrandezaRouteSlot).where(GrandezaRouteSlot.day_of_week == day_of_week.upper())
        )
        # Crear nuevos slots
        for i, slot_data in enumerate(slots):
            slot = GrandezaRouteSlot(
                client_id=slot_data["client_id"],
                day_of_week=day_of_week.upper(),
                visit_order=i + 1
            )
            db.add(slot)
        await db.flush()

    # ─── Jornadas ─────────────────────────────────────────────────────────

    async def get_journey_by_date(self, db: AsyncSession, journey_date: date):
        """Obtener la jornada de una fecha específica."""
        stmt = (
            select(GrandezaJourney)
            .where(GrandezaJourney.journey_date == journey_date)
        )
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    async def create_journey(self, db: AsyncSession, data: dict):
        journey = GrandezaJourney(**data)
        db.add(journey)
        await db.flush()
        return journey

    async def update_journey(self, db: AsyncSession, journey_id: int, data: dict):
        stmt = select(GrandezaJourney).where(GrandezaJourney.id == journey_id)
        result = await db.execute(stmt)
        journey = result.scalar_one_or_none()
        if not journey:
            return None
            
        from datetime import datetime
        if data.get("status") == "EN_RUTA" and journey.status != "EN_RUTA" and not journey.dispatched_at:
            journey.dispatched_at = datetime.utcnow()
            
        for key, value in data.items():
            if value is not None and hasattr(journey, key):
                setattr(journey, key, value)
        await db.flush()
        return journey

    # ─── Inventario ───────────────────────────────────────────────────────

    async def set_inventory(self, db: AsyncSession, journey_id: int, inventory_type: str, items: list):
        """Establecer inventario (inicial o final) para una jornada."""
        # Eliminar registros existentes de ese tipo
        await db.execute(
            delete(GrandezaInventory).where(
                GrandezaInventory.journey_id == journey_id,
                GrandezaInventory.inventory_type == inventory_type
            )
        )
        for item in items:
            record = GrandezaInventory(
                journey_id=journey_id,
                product_id=item["product_id"],
                inventory_type=inventory_type,
                fresh_qty=item.get("fresh_qty", 0),
                exchange_qty=item.get("exchange_qty", 0),
                received_qty=item.get("received_qty", 0),
            )
            db.add(record)
        await db.flush()

    async def get_inventory(self, db: AsyncSession, journey_id: int, inventory_type: str = None):
        stmt = select(GrandezaInventory).where(GrandezaInventory.journey_id == journey_id)
        if inventory_type:
            stmt = stmt.where(GrandezaInventory.inventory_type == inventory_type)
        result = await db.execute(stmt)
        return result.scalars().all()

    # ─── GPS ──────────────────────────────────────────────────────────────

    async def record_location(self, db: AsyncSession, journey_id: int, lat: float, lng: float, accuracy: float = None):
        location = GrandezaDriverLocation(
            journey_id=journey_id,
            lat=lat,
            lng=lng,
            accuracy=accuracy
        )
        db.add(location)
        await db.flush()
        return location

    async def get_locations(self, db: AsyncSession, journey_id: int):
        stmt = (
            select(GrandezaDriverLocation)
            .where(GrandezaDriverLocation.journey_id == journey_id)
            .order_by(GrandezaDriverLocation.recorded_at)
        )
        result = await db.execute(stmt)
        return result.scalars().all()

    # ─── Settings ─────────────────────────────────────────────────────────

    async def get_settings(self, db: AsyncSession):
        stmt = select(GrandezaSettings).order_by(GrandezaSettings.key)
        result = await db.execute(stmt)
        return result.scalars().all()

    async def upsert_setting(self, db: AsyncSession, key: str, value: str, description: str = None):
        stmt = select(GrandezaSettings).where(GrandezaSettings.key == key)
        result = await db.execute(stmt)
        setting = result.scalar_one_or_none()
        if setting:
            setting.value = value
        else:
            setting = GrandezaSettings(key=key, value=value, description=description)
            db.add(setting)
        await db.flush()
        return setting



    # ─── Visitas (CRUD) ───────────────────────────────────────────────────

    async def get_visits(self, db: AsyncSession, journey_id: int):
        stmt = (
            select(GrandezaVisit)
            .options(selectinload(GrandezaVisit.items), selectinload(GrandezaVisit.client))
            .where(GrandezaVisit.journey_id == journey_id)
            .order_by(GrandezaVisit.visit_order)
        )
        result = await db.execute(stmt)
        visits = result.scalars().all()
        response = []
        for v in visits:
            vd = {
                "id": v.id, "journey_id": v.journey_id, "client_id": v.client_id,
                "visit_order": v.visit_order, "visit_type": v.visit_type, "status": v.status,
                "arrived_at": str(v.arrived_at) if v.arrived_at else None,
                "completed_at": str(v.completed_at) if v.completed_at else None,
                "total_exchange_amount": v.total_exchange_amount,
                "total_fresh_amount": v.total_fresh_amount,
                "sale_amount": v.sale_amount,
                "payment_received": v.payment_received,
                "change_given": v.change_given,
                "incident_notes": v.incident_notes,
                "ext_client_name": v.ext_client_name,
                "client_name": v.client.name if v.client else v.ext_client_name,
                "items": [
                    {"id": it.id, "product_id": it.product_id, "exchange_qty": it.exchange_qty,
                     "suggested_fresh_qty": it.suggested_fresh_qty, "actual_fresh_qty": it.actual_fresh_qty,
                     "missing_qty": it.missing_qty, "unit_price": it.unit_price}
                    for it in v.items
                ]
            }
            response.append(vd)
        return response

    async def create_visit(self, db: AsyncSession, journey_id: int, data: dict):
        from datetime import datetime
        visit = GrandezaVisit(
            journey_id=journey_id,
            client_id=data.get("client_id"),
            visit_order=data.get("visit_order", 0),
            visit_type=data.get("visit_type", "PROGRAMADA"),
            status="COMPLETADA",
            arrived_at=datetime.utcnow(),
            completed_at=datetime.utcnow(),
            total_exchange_amount=data.get("total_exchange_amount", 0),
            total_fresh_amount=data.get("total_fresh_amount", 0),
            sale_amount=data.get("sale_amount", 0),
            payment_received=data.get("payment_received", 0),
            change_given=data.get("change_given", 0),
            incident_notes=data.get("incident_notes"),
            ext_client_name=data.get("ext_client_name"),
        )
        db.add(visit)
        await db.flush()
        
        # Guardar items
        for item_data in data.get("items", []):
            item = GrandezaVisitItem(
                visit_id=visit.id,
                product_id=item_data["product_id"],
                exchange_qty=item_data.get("exchange_qty", 0),
                suggested_fresh_qty=item_data.get("suggested_fresh_qty", 0),
                actual_fresh_qty=item_data.get("actual_fresh_qty", 0),
                missing_qty=item_data.get("missing_qty", 0),
                unit_price=item_data.get("unit_price", 0),
            )
            db.add(item)
        await db.flush()
        return {"id": visit.id, "status": "COMPLETADA"}

    async def set_visit_items(self, db: AsyncSession, visit_id: int, items: list):
        await db.execute(delete(GrandezaVisitItem).where(GrandezaVisitItem.visit_id == visit_id))
        for item_data in items:
            item = GrandezaVisitItem(visit_id=visit_id, **item_data)
            db.add(item)
        await db.flush()

    async def update_visit(self, db: AsyncSession, visit_id: int, data: dict):
        stmt = select(GrandezaVisit).where(GrandezaVisit.id == visit_id)
        result = await db.execute(stmt)
        visit = result.scalar_one_or_none()
        if not visit:
            return None
        for key, value in data.items():
            if value is not None and hasattr(visit, key):
                setattr(visit, key, value)
        await db.flush()
        return visit

    # ─── Sugerencias ──────────────────────────────────────────────────────

    async def get_client_suggestions(self, db: AsyncSession, client_id: int):
        """Calcula promedio de piezas vendidas netas (frescas - cambios) por producto en las últimas 3 visitas."""
        # 1. Obtener las últimas 3 visitas completadas
        visit_stmt = (
            select(GrandezaVisit)
            .where(GrandezaVisit.client_id == client_id)
            .where(GrandezaVisit.status == "COMPLETADA")
            .order_by(GrandezaVisit.created_at.desc())
            .limit(3)
            .options(selectinload(GrandezaVisit.items))
        )
        visit_result = await db.execute(visit_stmt)
        last_visits = visit_result.scalars().all()

        if not last_visits:
            return []

        # 2. Agrupar items por producto
        from collections import defaultdict
        product_sales = defaultdict(list)
        
        for v in last_visits:
            for item in v.items:
                net_sale = max(0, (item.actual_fresh_qty or 0) - (item.exchange_qty or 0))
                product_sales[item.product_id].append(net_sale)

        # 3. Calcular promedios
        suggestions = []
        import math
        for pid, sales in product_sales.items():
            if not sales: continue
            avg = sum(sales) / len(sales)
            suggestions.append({
                "product_id": pid,
                "suggested_qty": math.ceil(avg), # Redondeo hacia arriba por seguridad de inventario
                "visit_count": len(sales)
            })

        return suggestions

    # ─── Pedidos Grandeza ─────────────────────────────────────────────────

    async def get_grandeza_orders(self, db: AsyncSession, status: str = None):
        from .models import GrandezaOrder
        stmt = select(GrandezaOrder).order_by(GrandezaOrder.delivery_date)
        if status:
            stmt = stmt.where(GrandezaOrder.status == status)
        result = await db.execute(stmt)
        orders = result.scalars().all()
        return [
            {
                "id": o.id, "client_id": o.client_id, "client_name": o.client_name,
                "items": o.items, "total_amount": o.total_amount,
                "payment_method": o.payment_method, "payment_status": o.payment_status,
                "delivery_date": str(o.delivery_date), "status": o.status,
                "delivery_journey_id": o.delivery_journey_id,
                "notes": o.notes, "created_at": str(o.created_at)
            }
            for o in orders
        ]

    async def create_grandeza_order(self, db: AsyncSession, data: dict):
        from .models import GrandezaOrder
        order = GrandezaOrder(
            client_id=data.get("client_id"),
            client_name=data.get("client_name"),
            items=data.get("items", []),
            total_amount=data.get("total_amount", 0),
            payment_method=data.get("payment_method", "EFECTIVO"),
            payment_status="PAGADO",
            delivery_date=data["delivery_date"],
            status="PAGADO",
            notes=data.get("notes"),
        )
        db.add(order)
        await db.flush()
        return {"id": order.id, "status": "PAGADO", "delivery_date": str(order.delivery_date)}

    async def update_grandeza_order(self, db: AsyncSession, order_id: int, data: dict):
        from .models import GrandezaOrder
        stmt = select(GrandezaOrder).where(GrandezaOrder.id == order_id)
        result = await db.execute(stmt)
        order = result.scalar_one_or_none()
        if not order:
            return None
        for key, value in data.items():
            if value is not None and hasattr(order, key):
                setattr(order, key, value)
        await db.flush()
        return order


grandeza_service = GrandezaService()
