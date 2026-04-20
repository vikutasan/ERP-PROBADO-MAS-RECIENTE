"""
MÓDULO: orders/schemas.py
MISIÓN: Contratos de datos (Pydantic) para crear y leer pedidos.
"""
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from modules.pos.schemas import TicketResponse


class OrderCreate(BaseModel):
    ticket_id: int
    delivery_type: str = "PICKUP"           # PICKUP | DOMICILIO
    customer_name: Optional[str] = None
    customer_phone: Optional[str] = None
    earliest_ready_at: Optional[datetime] = None
    committed_at: Optional[datetime] = None
    packaging_type: str = "PROPIO"          # PROPIO | VENTA
    delivery_address: Optional[str] = None
    delivery_lat: Optional[float] = None
    delivery_lng: Optional[float] = None
    delivery_distance_km: Optional[float] = None
    delivery_fee: Optional[float] = 0.0
    notes: Optional[str] = None


class OrderUpdate(BaseModel):
    status: Optional[str] = None
    committed_at: Optional[datetime] = None
    customer_name: Optional[str] = None
    customer_phone: Optional[str] = None
    packaging_type: Optional[str] = None
    delivery_address: Optional[str] = None
    delivery_lat: Optional[float] = None
    delivery_lng: Optional[float] = None
    delivery_distance_km: Optional[float] = None
    delivery_fee: Optional[float] = None
    notes: Optional[str] = None


class OrderRead(BaseModel):
    id: int
    ticket_id: int
    delivery_type: str
    status: str
    customer_name: Optional[str]
    customer_phone: Optional[str]
    earliest_ready_at: Optional[datetime]
    committed_at: Optional[datetime]
    packaging_type: str
    delivery_address: Optional[str]
    delivery_lat: Optional[float]
    delivery_lng: Optional[float]
    delivery_distance_km: Optional[float]
    delivery_fee: Optional[float]
    created_at: datetime
    notes: Optional[str]

    ticket: Optional[TicketResponse] = None

    class Config:
        from_attributes = True
