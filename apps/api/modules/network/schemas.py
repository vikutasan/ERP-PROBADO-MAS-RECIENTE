from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class NetworkIncidentCreate(BaseModel):
    terminal_id: str
    incident_type: str
    user_logged: Optional[str] = None
    details: Optional[str] = None

class NetworkIncidentResponse(BaseModel):
    id: int
    terminal_id: str
    incident_type: str
    user_logged: Optional[str] = None
    details: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True
