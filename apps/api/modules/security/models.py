from sqlalchemy import Column, Integer, String, Boolean
from core.database import Base


class Employee(Base):
    """
    Representa un empleado del sistema con acceso al POS.
    Cada empleado tiene un PIN único para autenticarse como cajero.
    """
    __tablename__ = "employees"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    employee_code = Column(String, unique=True, nullable=False, index=True)  # PIN de acceso
    role = Column(String, nullable=False, default="CAJERO")  # CAJERO, SUPERVISOR, ADMIN
    is_active = Column(Boolean, default=True)
