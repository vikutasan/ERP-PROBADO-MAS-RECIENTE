"""
MÓDULO: delivery_settings/service.py
MISIÓN: Lógica para leer y actualizar el único registro de parámetros de reparto.
Patrón Singleton: siempre existe exactamente 1 registro activo.
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from .models import DeliverySettings
from .schemas import DeliverySettingsUpdate

# Configuración por defecto para la primera instalación
_DEFAULT = {
    "closed_days": ["Sunday"],
    "open_time": "08:00",
    "close_time": "20:00",
    "distance_tiers": [
        {"min_km": 0, "max_km": 3, "fee": 30.0},
        {"min_km": 3, "max_km": 6, "fee": 50.0},
        {"min_km": 6, "max_km": 10, "fee": 80.0},
    ],
    "min_lead_time_hours": 2,
}


async def get_or_create_settings(db: AsyncSession) -> DeliverySettings:
    """Recupera la config activa o crea una con valores por defecto."""
    result = await db.execute(
        select(DeliverySettings).where(DeliverySettings.is_active == True)
    )
    settings = result.scalar_one_or_none()
    if settings:
        return settings

    settings = DeliverySettings(**_DEFAULT)
    db.add(settings)
    await db.commit()
    await db.refresh(settings)
    return settings


async def update_settings(db: AsyncSession, data: DeliverySettingsUpdate) -> DeliverySettings:
    """Actualiza los parámetros de reparto activos."""
    settings = await get_or_create_settings(db)

    for field, value in data.model_dump(exclude_unset=True).items():
        # Serializar los tiers (Pydantic objects → dict)
        if field == "distance_tiers" and value:
            value = [t.model_dump() if hasattr(t, "model_dump") else t for t in value]
        setattr(settings, field, value)

    await db.commit()
    await db.refresh(settings)
    return settings
