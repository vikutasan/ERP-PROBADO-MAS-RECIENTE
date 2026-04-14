"""
MÓDULO: delivery_settings/models.py
MISIÓN: Configuración de parámetros de reparto definidos por el administrador.
Incluye días inhábiles, horarios disponibles y tarifas por distancia.
"""
from sqlalchemy import Column, Integer, String, Float, Boolean, JSON
from core.database import Base


class DeliverySettings(Base):
    __tablename__ = "delivery_settings"

    id = Column(Integer, primary_key=True, index=True)

    # Días inhábiles para entregas (ej: ["Sunday", "Monday"])
    closed_days = Column(JSON, nullable=False, default=list)

    # Horario de apertura y cierre (ej: "08:00", "20:00")
    open_time = Column(String, nullable=False, default="08:00")
    close_time = Column(String, nullable=False, default="20:00")

    # Tarifas por tramo de distancia (lista de reglas)
    # Formato: [{ "min_km": 0, "max_km": 3, "fee": 30.0 }, ...]
    distance_tiers = Column(JSON, nullable=False, default=list)

    # Tiempo mínimo de anticipación para aceptar pedido (horas)
    min_lead_time_hours = Column(Integer, nullable=False, default=2)

    # Solo debe existir UN registro activo
    is_active = Column(Boolean, default=True)
