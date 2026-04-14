"""
MÓDULO: delivery_settings/router.py
MISIÓN: Endpoints REST para leer y actualizar parámetros del Gestor de Reparto.
"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from core.database import get_db

from .schemas import DeliverySettingsRead, DeliverySettingsUpdate
from . import service

router = APIRouter()


@router.get("/", response_model=DeliverySettingsRead)
async def get_settings(db: AsyncSession = Depends(get_db)):
    """Retorna la configuración activa de reparto (o la crea con defaults)."""
    return await service.get_or_create_settings(db)


@router.patch("/", response_model=DeliverySettingsRead)
async def update_settings(data: DeliverySettingsUpdate, db: AsyncSession = Depends(get_db)):
    """Actualiza los parámetros desde el Gestor de Parámetros de Reparto."""
    return await service.update_settings(db, data)
