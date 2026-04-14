"""
MÓDULO: delivery_settings/schemas.py
MISIÓN: Contratos Pydantic para leer y actualizar los parámetros de reparto.
"""
from pydantic import BaseModel
from typing import Optional


class DistanceTier(BaseModel):
    min_km: float
    max_km: float
    fee: float


class DeliverySettingsUpdate(BaseModel):
    closed_days: Optional[list[str]] = None        # Ej: ["Sunday", "Saturday"]
    open_time: Optional[str] = None                # Ej: "08:00"
    close_time: Optional[str] = None               # Ej: "20:00"
    distance_tiers: Optional[list[DistanceTier]] = None
    min_lead_time_hours: Optional[int] = None


class DeliverySettingsRead(BaseModel):
    id: int
    closed_days: list
    open_time: str
    close_time: str
    distance_tiers: list
    min_lead_time_hours: int
    is_active: bool

    class Config:
        from_attributes = True
