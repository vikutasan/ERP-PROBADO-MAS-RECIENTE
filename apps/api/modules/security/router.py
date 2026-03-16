from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from core.database import get_db
from . import schemas, service

router = APIRouter()


@router.post("/employees", response_model=schemas.EmployeeResponse, status_code=201)
async def crear_empleado(datos: schemas.EmployeeCreate, db: AsyncSession = Depends(get_db)):
    return await service.crear_empleado(db, datos)


@router.get("/employees", response_model=List[schemas.EmployeeResponse])
async def listar_empleados(db: AsyncSession = Depends(get_db)):
    return await service.listar_empleados(db)


@router.post("/employees/validate-pin", response_model=schemas.PINValidateResponse)
async def validar_pin(datos: schemas.PINValidateRequest, db: AsyncSession = Depends(get_db)):
    return await service.validar_pin(db, datos.pin)


@router.put("/employees/{empleado_id}", response_model=schemas.EmployeeResponse)
async def actualizar_empleado(
    empleado_id: int, datos: schemas.EmployeeUpdate, db: AsyncSession = Depends(get_db)
):
    return await service.actualizar_empleado(db, empleado_id, datos)


@router.patch("/employees/{empleado_id}/deactivate")
async def desactivar_empleado(empleado_id: int, db: AsyncSession = Depends(get_db)):
    return await service.desactivar_empleado(db, empleado_id)
