from pydantic import BaseModel, ConfigDict
from typing import Optional, List
from datetime import datetime
from modules.catalog.schemas import ProductResponse

# --- Ticket Item ---
class TicketItemBase(BaseModel):
    product_id: int
    quantity: int = 1

class TicketItemCreate(TicketItemBase):
    pass

class TicketItemResponse(TicketItemBase):
    id: int
    unit_price: float
    subtotal: float
    product: Optional[ProductResponse] = None
    model_config = ConfigDict(from_attributes=True)

# --- Ticket ---
class TicketBase(BaseModel):
    account_num: str
    session_id: int

class TicketCreate(TicketBase):
    items: List[TicketItemCreate]

class TicketResponse(TicketBase):
    id: int
    total: float
    status: str
    created_at: datetime
    items: List[TicketItemResponse] = []
    model_config = ConfigDict(from_attributes=True)

# --- Terminal Session ---
class TerminalSessionBase(BaseModel):
    terminal_id: str

class TerminalSessionCreate(TerminalSessionBase):
    pass

class TerminalSessionResponse(TerminalSessionBase):
    id: int
    opened_at: datetime
    closed_at: Optional[datetime] = None
    is_active: bool
    model_config = ConfigDict(from_attributes=True)
