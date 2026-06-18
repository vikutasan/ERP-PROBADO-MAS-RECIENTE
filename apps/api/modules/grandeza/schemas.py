"""
MÓDULO: grandeza/schemas.py
Schemas Pydantic para validación de datos del módulo Reparto Pan Grandeza.
"""
from pydantic import BaseModel, ConfigDict
from typing import Optional, List
from datetime import datetime, date


# ─── Configuración de Producto Grandeza ───────────────────────────────────────

class GrandezaProductConfigCreate(BaseModel):
    product_id: int
    is_enabled: bool = True
    b2b_price: float

class GrandezaProductConfigUpdate(BaseModel):
    is_enabled: Optional[bool] = None
    b2b_price: Optional[float] = None

class GrandezaProductConfigResponse(BaseModel):
    id: int
    product_id: int
    is_enabled: bool
    b2b_price: float
    # Campos del producto anidado (para la vista)
    product_name: Optional[str] = None
    product_sku: Optional[str] = None
    product_price: Optional[float] = None  # Precio tienda
    order_lead_time_hours: Optional[float] = 0.0
    model_config = ConfigDict(from_attributes=True)


# ─── Clientes Grandeza ────────────────────────────────────────────────────────

class GrandezaClientCreate(BaseModel):
    name: str
    business_name: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    google_maps_url: Optional[str] = None
    facade_photo_url: Optional[str] = None
    notes: Optional[str] = None

class GrandezaClientUpdate(BaseModel):
    name: Optional[str] = None
    business_name: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    google_maps_url: Optional[str] = None
    facade_photo_url: Optional[str] = None
    notes: Optional[str] = None
    active: Optional[bool] = None

class GrandezaRouteSlotResponse(BaseModel):
    id: int
    day_of_week: str
    visit_order: int
    model_config = ConfigDict(from_attributes=True)

class GrandezaClientResponse(BaseModel):
    id: int
    name: str
    business_name: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    google_maps_url: Optional[str] = None
    facade_photo_url: Optional[str] = None
    notes: Optional[str] = None
    active: bool
    route_slots: List[GrandezaRouteSlotResponse] = []
    model_config = ConfigDict(from_attributes=True)


# ─── Route Slots ──────────────────────────────────────────────────────────────

class GrandezaRouteSlotCreate(BaseModel):
    client_id: int
    day_of_week: str  # LUNES, MARTES, etc.
    visit_order: int

class GrandezaRouteSlotUpdate(BaseModel):
    day_of_week: Optional[str] = None
    visit_order: Optional[int] = None


# ─── Jornadas ─────────────────────────────────────────────────────────────────

class GrandezaJourneyCreate(BaseModel):
    journey_date: date
    cash_fund: float = 0.0
    driver_user_id: Optional[int] = None

class GrandezaJourneyUpdate(BaseModel):
    status: Optional[str] = None
    cash_fund: Optional[float] = None
    cash_received: Optional[float] = None
    exchange_pieces_received: Optional[int] = None
    fresh_leftover_received: Optional[int] = None
    feedback_notes: Optional[str] = None
    driver_user_id: Optional[int] = None

class GrandezaInventoryCreate(BaseModel):
    product_id: int
    inventory_type: str  # INITIAL | FINAL
    fresh_qty: int = 0
    exchange_qty: int = 0
    received_qty: int = 0

class GrandezaInventoryResponse(BaseModel):
    id: int
    product_id: int
    inventory_type: str
    fresh_qty: int
    exchange_qty: int
    received_qty: int
    model_config = ConfigDict(from_attributes=True)

class GrandezaJourneyResponse(BaseModel):
    id: int
    journey_date: date
    status: str
    cash_fund: float
    cash_expected: Optional[float] = None
    cash_received: Optional[float] = None
    exchange_pieces_expected: Optional[int] = None
    exchange_pieces_received: Optional[int] = None
    fresh_leftover_expected: Optional[int] = None
    fresh_leftover_received: Optional[int] = None
    driver_user_id: Optional[int] = None
    feedback_notes: Optional[str] = None
    dispatched_at: Optional[datetime] = None
    model_config = ConfigDict(from_attributes=True)


# ─── Visitas ──────────────────────────────────────────────────────────────────

class GrandezaVisitItemCreate(BaseModel):
    product_id: int
    exchange_qty: int = 0
    suggested_fresh_qty: int = 0
    actual_fresh_qty: int = 0
    missing_qty: int = 0
    unit_price: float = 0.0

class GrandezaVisitItemResponse(BaseModel):
    id: int
    product_id: int
    exchange_qty: int
    suggested_fresh_qty: int
    actual_fresh_qty: int
    missing_qty: int
    unit_price: float
    model_config = ConfigDict(from_attributes=True)

class GrandezaVisitCreate(BaseModel):
    client_id: Optional[int] = None
    visit_order: int
    visit_type: str = "PROGRAMADA"
    ext_client_name: Optional[str] = None
    items: List[GrandezaVisitItemCreate] = []
    sale_amount: float = 0.0
    payment_received: float = 0.0
    change_given: float = 0.0
    total_exchange_amount: float = 0.0
    total_fresh_amount: float = 0.0
    incident_notes: Optional[str] = None

class GrandezaVisitUpdate(BaseModel):
    status: Optional[str] = None
    payment_received: Optional[float] = None
    incident_notes: Optional[str] = None

class GrandezaVisitResponse(BaseModel):
    id: int
    journey_id: int
    client_id: Optional[int] = None
    visit_order: int
    visit_type: str
    status: str
    arrived_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    total_exchange_amount: float
    total_fresh_amount: float
    sale_amount: float
    payment_received: float
    change_given: float
    incident_notes: Optional[str] = None
    ext_client_name: Optional[str] = None
    items: List[GrandezaVisitItemResponse] = []
    model_config = ConfigDict(from_attributes=True)


# ─── GPS ──────────────────────────────────────────────────────────────────────

class GrandezaDriverLocationCreate(BaseModel):
    lat: float
    lng: float
    accuracy: Optional[float] = None

class GrandezaDriverLocationResponse(BaseModel):
    id: int
    lat: float
    lng: float
    accuracy: Optional[float] = None
    recorded_at: datetime
    model_config = ConfigDict(from_attributes=True)


# ─── Settings ─────────────────────────────────────────────────────────────────

class GrandezaSettingResponse(BaseModel):
    id: int
    key: str
    value: Optional[str] = None
    description: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)

class GrandezaSettingUpdate(BaseModel):
    value: str


# ─── Pedidos Grandeza ─────────────────────────────────────────────────────────

class GrandezaOrderCreate(BaseModel):
    client_id: Optional[int] = None
    client_name: Optional[str] = None
    items: list  # [{product_id, product_name, qty, unit_price}]
    total_amount: float
    advance_payment: float = 0.0
    payment_method: str = "EFECTIVO"
    delivery_date: date
    delivery_time: Optional[str] = None
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
    advance_payment: float
    balance_due: float = 0.0
    payment_method: str
    payment_status: str
    delivery_date: date
    delivery_time: Optional[str] = None
    status: str
    delivery_journey_id: Optional[int] = None
    notes: Optional[str] = None
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)
