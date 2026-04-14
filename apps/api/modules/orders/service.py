"""
MÓDULO: orders/service.py
MISIÓN: Lógica de negocio para crear, actualizar y consultar pedidos.
Cada función hace UNA sola cosa (SRP).
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from datetime import datetime

from .models import Order
from .schemas import OrderCreate, OrderUpdate


async def create_order(db: AsyncSession, data: OrderCreate) -> Order:
    """Crea un pedido TENTATIVO vinculado a un ticket existente."""
    order = Order(**data.model_dump())
    db.add(order)
    await db.commit()
    await db.refresh(order)
    return order


async def get_order_by_ticket(db: AsyncSession, ticket_id: int) -> Order | None:
    """Recupera el pedido asociado a un ticket, si existe."""
    result = await db.execute(
        select(Order).where(Order.ticket_id == ticket_id)
    )
    return result.scalar_one_or_none()


async def get_pending_orders(db: AsyncSession) -> list[Order]:
    """
    Retorna pedidos en estado TENTATIVO, PAGADO o EN_PRODUCCION.
    Usado por la suite 'Pedidos Pendientes' en Gestión de Producción.
    """
    result = await db.execute(
        select(Order)
        .where(Order.status.in_(["TENTATIVO", "PAGADO", "EN_PRODUCCION"]))
        .order_by(Order.committed_at.asc())
    )
    return result.scalars().all()


async def get_pickup_orders(db: AsyncSession) -> list[Order]:
    """
    Retorna pedidos PICKUP listos o en producción.
    Usado por el módulo 'Gestor de Entregas de Pickup'.
    """
    result = await db.execute(
        select(Order)
        .where(
            Order.delivery_type == "PICKUP",
            Order.status.in_(["PAGADO", "EN_PRODUCCION", "LISTO"])
        )
        .order_by(Order.committed_at.asc())
    )
    return result.scalars().all()


async def update_order(db: AsyncSession, order_id: int, data: OrderUpdate) -> Order | None:
    """Actualiza campos de un pedido existente. Retorna None si no existe."""
    result = await db.execute(select(Order).where(Order.id == order_id))
    order = result.scalar_one_or_none()
    if not order:
        return None

    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(order, field, value)

    order.updated_at = datetime.utcnow()
    await db.commit()
    await db.refresh(order)
    return order
