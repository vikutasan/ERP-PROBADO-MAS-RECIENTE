"""
Script de despliegue: Agrega Visitas, Pedidos y Sugerencias al módulo Grandeza.
Se ejecuta dentro del contenedor API para inyectar código y reiniciar.
"""
import os

BASE = "/app/modules/grandeza"

# ─── 1. Agregar modelo GrandezaOrder a models.py ─────────────────────────────

models_addition = '''

class GrandezaOrder(Base):
    """
    Pedido levantado desde la ruta de reparto Pan Grandeza.
    Independiente del sistema de pedidos POS (no requiere ticket_id).
    Aparece en la suite 'Pedidos en Producción' como PEDIDO REPARTO PAN GRANDEZA.
    """
    __tablename__ = "grandeza_orders"

    id = Column(Integer, primary_key=True, index=True)
    client_id = Column(Integer, ForeignKey("grandeza_clients.id"), nullable=True)
    client_name = Column(String, nullable=True)  # Snapshot o nombre manual
    
    # Productos del pedido (JSON: [{product_id, product_name, qty, unit_price}])
    items = Column(JSON, nullable=False, default=[])
    
    # Financieros
    total_amount = Column(Float, default=0.0)
    payment_method = Column(String, default="EFECTIVO")  # EFECTIVO | TRANSFERENCIA
    payment_status = Column(String, default="PAGADO")    # PAGADO (obligatorio para procesar)
    
    # Programación de entrega
    delivery_date = Column(Date, nullable=False)  # Día en que se entregará
    
    # Estado de producción
    status = Column(String, default="PAGADO")
    # PAGADO → EN_PRODUCCION → LISTO → EN_RUTA → ENTREGADO | CANCELADO
    
    # Vinculación con jornada de entrega (se llena cuando se incluye en la ruta)
    delivery_journey_id = Column(Integer, ForeignKey("grandeza_journeys.id"), nullable=True)
    
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
'''

with open(os.path.join(BASE, "models.py"), "r") as f:
    content = f.read()

if "GrandezaOrder" not in content:
    # Need to add Date import if not present
    if "from datetime import" in content and "date" not in content.split("from datetime import")[1].split("\n")[0].lower():
        content = content.replace("from datetime import datetime", "from datetime import datetime, date")
    if "JSON" not in content.split("from sqlalchemy import")[1].split("\n")[0]:
        content = content.replace(
            "from sqlalchemy import Column, Integer, String, Float, Boolean, Text, ForeignKey, DateTime, Date",
            "from sqlalchemy import Column, Integer, String, Float, Boolean, Text, ForeignKey, DateTime, Date, JSON"
        )
        # Try alternate import style
        if "JSON" not in content:
            old_import = content.split("from sqlalchemy import")[1].split("\n")[0]
            if "JSON" not in old_import:
                content = content.replace(
                    f"from sqlalchemy import{old_import}",
                    f"from sqlalchemy import{old_import.rstrip()}, JSON"
                )
    content += models_addition
    with open(os.path.join(BASE, "models.py"), "w") as f:
        f.write(content)
    print("✅ GrandezaOrder model added")
else:
    print("⏭️ GrandezaOrder already exists")


# ─── 2. Agregar schemas ──────────────────────────────────────────────────────

schemas_addition = '''

# ─── Pedidos Grandeza ─────────────────────────────────────────────────────────

class GrandezaOrderCreate(BaseModel):
    client_id: Optional[int] = None
    client_name: Optional[str] = None
    items: list  # [{product_id, product_name, qty, unit_price}]
    total_amount: float
    payment_method: str = "EFECTIVO"
    delivery_date: date
    notes: Optional[str] = None

class GrandezaOrderUpdate(BaseModel):
    status: Optional[str] = None
    delivery_journey_id: Optional[int] = None
    notes: Optional[str] = None

class GrandezaOrderResponse(BaseModel):
    id: int
    client_id: Optional[int] = None
    client_name: Optional[str] = None
    items: list
    total_amount: float
    payment_method: str
    payment_status: str
    delivery_date: date
    status: str
    delivery_journey_id: Optional[int] = None
    notes: Optional[str] = None
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)
'''

with open(os.path.join(BASE, "schemas.py"), "r") as f:
    content = f.read()

if "GrandezaOrderCreate" not in content:
    content += schemas_addition
    with open(os.path.join(BASE, "schemas.py"), "w") as f:
        f.write(content)
    print("✅ Order schemas added")
else:
    print("⏭️ Order schemas already exist")


# ─── 3. Agregar servicios de visitas, sugerencias y pedidos ──────────────────

service_addition = '''

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
        """Calcula promedio de piezas frescas vendidas por producto en las últimas 10 visitas."""
        from sqlalchemy import func
        stmt = (
            select(
                GrandezaVisitItem.product_id,
                func.avg(GrandezaVisitItem.actual_fresh_qty).label("avg_qty"),
                func.count(GrandezaVisitItem.id).label("visit_count")
            )
            .join(GrandezaVisit, GrandezaVisitItem.visit_id == GrandezaVisit.id)
            .where(GrandezaVisit.client_id == client_id)
            .where(GrandezaVisit.status == "COMPLETADA")
            .group_by(GrandezaVisitItem.product_id)
        )
        result = await db.execute(stmt)
        rows = result.all()
        return [
            {"product_id": r.product_id, "suggested_qty": round(r.avg_qty), "visit_count": r.visit_count}
            for r in rows
        ]

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
'''

with open(os.path.join(BASE, "service.py"), "r") as f:
    content = f.read()

if "get_visits" not in content:
    # Insert before the last line (grandeza_service = GrandezaService())
    content = content.replace(
        "\ngrandeza_service = GrandezaService()\n",
        service_addition + "\n\ngrandeza_service = GrandezaService()\n"
    )
    with open(os.path.join(BASE, "service.py"), "w") as f:
        f.write(content)
    print("✅ Visit/Order/Suggestion services added")
else:
    print("⏭️ Services already exist")


# ─── 4. Agregar rutas al router ──────────────────────────────────────────────

router_addition = '''

# ─── Visitas ──────────────────────────────────────────────────────────────────

@router.get("/journeys/{journey_id}/visits")
async def get_visits(journey_id: int, db: AsyncSession = Depends(get_db)):
    return await grandeza_service.get_visits(db, journey_id)

@router.post("/journeys/{journey_id}/visits")
async def create_visit(journey_id: int, data: schemas.GrandezaVisitCreate, db: AsyncSession = Depends(get_db)):
    visit = await grandeza_service.create_visit(db, journey_id, data.model_dump())
    return visit

@router.post("/visits/{visit_id}/items")
async def set_visit_items(visit_id: int, items: List[schemas.GrandezaVisitItemCreate], db: AsyncSession = Depends(get_db)):
    await grandeza_service.set_visit_items(db, visit_id, [i.model_dump() for i in items])
    return {"message": "Items guardados"}

@router.patch("/visits/{visit_id}")
async def update_visit(visit_id: int, data: schemas.GrandezaVisitUpdate, db: AsyncSession = Depends(get_db)):
    visit = await grandeza_service.update_visit(db, visit_id, data.model_dump(exclude_unset=True))
    if not visit:
        raise HTTPException(status_code=404, detail="Visita no encontrada")
    return {"message": "Visita actualizada"}


# ─── Sugerencias ──────────────────────────────────────────────────────────────

@router.get("/clients/{client_id}/suggestions")
async def get_suggestions(client_id: int, db: AsyncSession = Depends(get_db)):
    return await grandeza_service.get_client_suggestions(db, client_id)


# ─── Pedidos Grandeza ─────────────────────────────────────────────────────────

@router.get("/orders")
async def get_grandeza_orders(status: str = None, db: AsyncSession = Depends(get_db)):
    return await grandeza_service.get_grandeza_orders(db, status)

@router.post("/orders")
async def create_grandeza_order(data: schemas.GrandezaOrderCreate, db: AsyncSession = Depends(get_db)):
    order = await grandeza_service.create_grandeza_order(db, data.model_dump())
    return order

@router.patch("/orders/{order_id}")
async def update_grandeza_order(order_id: int, data: schemas.GrandezaOrderUpdate, db: AsyncSession = Depends(get_db)):
    order = await grandeza_service.update_grandeza_order(db, order_id, data.model_dump(exclude_unset=True))
    if not order:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    return order
'''

with open(os.path.join(BASE, "router.py"), "r") as f:
    content = f.read()

if "get_visits" not in content:
    content += router_addition
    with open(os.path.join(BASE, "router.py"), "w") as f:
        f.write(content)
    print("✅ Visit/Order/Suggestion routes added")
else:
    print("⏭️ Routes already exist")


print("\n🎉 Deploy completo. Reinicia el API para aplicar cambios.")
