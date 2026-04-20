"""
MÓDULO: orders/router.py
MISIÓN: Endpoints REST para pedidos. Principio KISS: verbos claros, respuestas simples.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from core.database import get_db

from .schemas import OrderCreate, OrderUpdate, OrderRead
from . import service

router = APIRouter()


@router.post("/", response_model=OrderRead)
async def create_order(data: OrderCreate, db: AsyncSession = Depends(get_db)):
    """Crea un pedido tentativo al guardar la Programación del Pedido."""
    return await service.create_order(db, data)


@router.get("/by-ticket/{ticket_id}", response_model=OrderRead)
async def get_by_ticket(ticket_id: int, db: AsyncSession = Depends(get_db)):
    """Recupera el pedido de un ticket para mostrar en checkout y ticket impreso."""
    order = await service.get_order_by_ticket(db, ticket_id)
    if not order:
        raise HTTPException(status_code=404, detail="Este ticket no tiene pedido asociado")
    return order


@router.get("/pendientes", response_model=list[OrderRead])
async def get_pending(db: AsyncSession = Depends(get_db)):
    """Suite 'Pedidos Pendientes' en Gestión de Producción."""
    return await service.get_pending_orders(db)


@router.get("/pickup-despacho", response_model=list[OrderRead])
async def get_pickup_despacho(db: AsyncSession = Depends(get_db)):
    """Módulo 'Gestor de Pickup' — pedidos en zona de despacho por recolección."""
    return await service.get_pickup_orders(db)


@router.get("/repartos", response_model=list[OrderRead])
async def get_repartos(db: AsyncSession = Depends(get_db)):
    """Módulo 'Gestor de Repartos' — pedidos en zona de despacho por domicilio."""
    return await service.get_reparto_orders(db)


@router.patch("/{order_id}", response_model=OrderRead)
async def update_order(order_id: int, data: OrderUpdate, db: AsyncSession = Depends(get_db)):
    """Actualiza estado, fecha compromiso, datos de entrega, etc."""
    order = await service.update_order(db, order_id, data)
    if not order:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    return order
