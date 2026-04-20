from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import date, datetime

class DailyContextCreate(BaseModel):
    target_date: date
    is_atypical: bool = False
    weather_condition: Optional[str] = None
    holiday_name: Optional[str] = None
    notes: Optional[str] = None
    temperature_c: Optional[float] = None

class DailyContextRead(DailyContextCreate):
    id: int

    class Config:
        from_attributes = True

# Schemas para el motor SQL de consultas
class TopProductRead(BaseModel):
    product_id: int
    product_name: str
    category_name: Optional[str]
    total_quantity: int
    total_revenue: float
    margin_percentage: float
    margin_absolute: float

class DailyAverageRead(BaseModel):
    day_of_week: int # 0=Lunes, 6=Domingo
    day_name: str
    avg_tickets: float
    avg_items_sold: float
    avg_revenue: float

class CustomQueryPayload(BaseModel):
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    product_ids: Optional[List[int]] = None
    category_ids: Optional[List[int]] = None
    weekdays: Optional[List[int]] = None # 0-6
    exclude_atypical: bool = False
