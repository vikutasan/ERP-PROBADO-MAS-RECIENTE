from pydantic import BaseModel, ConfigDict
from typing import Optional


# --- Creación de Empleado ---
class EmployeeCreate(BaseModel):
    name: str
    employee_code: str  # PIN de 4-6 dígitos
    role: str = "CAJERO"


# --- Actualización de Empleado ---
class EmployeeUpdate(BaseModel):
    name: Optional[str] = None
    employee_code: Optional[str] = None
    role: Optional[str] = None


# --- Respuesta de Empleado ---
class EmployeeResponse(BaseModel):
    id: int
    name: str
    employee_code: str
    role: str
    is_active: bool
    model_config = ConfigDict(from_attributes=True)


# --- Validación de PIN ---
class PINValidateRequest(BaseModel):
    pin: str


class PINValidateResponse(BaseModel):
    id: int
    name: str
    role: str
