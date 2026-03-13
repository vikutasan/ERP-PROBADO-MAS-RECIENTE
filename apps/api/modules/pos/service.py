from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from fastapi import HTTPException
from . import models, schemas
from modules.catalog.models import Product

class POSService:
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
        # 1. Validar Sesión
        session = await db.get(models.TerminalSession, ticket.session_id)
        if not session or not session.is_active:
            raise HTTPException(status_code=400, detail="Terminal session invalid or inactive")

        # 2. Calcular Totales y Validar Productos
        total = 0.0
        db_items = []
        for item in ticket.items:
            product = await db.get(Product, item.product_id)
            if not product:
                raise HTTPException(status_code=404, detail=f"Product {item.product_id} not found")
            if not product.active:
                raise HTTPException(status_code=400, detail=f"Product {product.name} is inactive")
            
            subtotal = product.price * item.quantity
            total += subtotal
            
            db_item = models.TicketItem(
                product_id=product.id,
                quantity=item.quantity,
                unit_price=product.price,
                subtotal=subtotal
            )
            db_items.append(db_item)

        # 3. Guardar o Actualizar Ticket
        result = await db.execute(
            select(models.Ticket).where(models.Ticket.account_num == ticket.account_num)
        )
        db_ticket = result.scalars().first()

        if db_ticket:
            # Si el ticket ya existe, actualizamos total y estatus
            db_ticket.total = total
            db_ticket.status = ticket.status or "PAID"
            # Eliminamos items anteriores para reemplazarlos (simplifica la lógica de actualización)
            await db.execute(
                models.TicketItem.__table__.delete().where(models.TicketItem.ticket_id == db_ticket.id)
            )
        else:
            # Si no existe, creamos uno nuevo
            db_ticket = models.Ticket(
                account_num=ticket.account_num,
                session_id=ticket.session_id,
                total=total,
                status=ticket.status or "PAID"
            )
            db.add(db_ticket)
            await db.flush() # Para obtener db_ticket.id
        
        for db_item in db_items:
            db_item.ticket_id = db_ticket.id
            db.add(db_item)
            
        await db.commit()
        
        # Recuperar el ticket con todas las relaciones cargadas para la respuesta
        result = await db.execute(
            select(models.Ticket)
            .options(
                selectinload(models.Ticket.items)
                .selectinload(models.TicketItem.product)
                .selectinload(Product.category),
                selectinload(models.Ticket.session)
            )
            .where(models.Ticket.id == db_ticket.id)
        )
        ticket_obj = result.scalar_one()
        ticket_obj.terminal_id = ticket_obj.session.terminal_id
        return ticket_obj

    async def get_open_tickets(self, db: AsyncSession):
        result = await db.execute(
            select(models.Ticket)
            .options(
                selectinload(models.Ticket.items)
                .selectinload(models.TicketItem.product)
                .selectinload(Product.category),
                selectinload(models.Ticket.session)
            )
            .where(models.Ticket.status == "OPEN")
            .order_by(models.Ticket.created_at.desc())
        )
        tickets = result.scalars().all()
        for t in tickets:
            t.terminal_id = t.session.terminal_id
        return tickets

pos_service = POSService()
