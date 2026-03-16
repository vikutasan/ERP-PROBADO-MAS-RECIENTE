from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from fastapi import HTTPException

from . import models, schemas


async def crear_empleado(db: AsyncSession, datos: schemas.EmployeeCreate) -> models.Employee:
    """Crea un nuevo empleado con su PIN de acceso."""
    empleado_existente = await db.execute(
        select(models.Employee).where(models.Employee.employee_code == datos.employee_code)
    )
    if empleado_existente.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="El código de empleado ya existe")

    nuevo_empleado = models.Employee(
        name=datos.name,
        employee_code=datos.employee_code,
        role=datos.role,
    )
    db.add(nuevo_empleado)
    await db.commit()
    await db.refresh(nuevo_empleado)
    return nuevo_empleado


async def listar_empleados(db: AsyncSession) -> list[models.Employee]:
    """Devuelve todos los empleados activos del sistema."""
    resultado = await db.execute(
        select(models.Employee).where(models.Employee.is_active == True)
    )
    return resultado.scalars().all()


async def validar_pin(db: AsyncSession, pin: str) -> schemas.PINValidateResponse:
    """
    Valida el PIN ingresado por el cajero.
    Devuelve el nombre y rol si el PIN es correcto, o error 401 si no lo es.
    """
    resultado = await db.execute(
        select(models.Employee).where(
            models.Employee.employee_code == pin,
            models.Employee.is_active == True,
        )
    )
    empleado = resultado.scalar_one_or_none()
    if not empleado:
        raise HTTPException(status_code=401, detail="PIN incorrecto o empleado inactivo")

    return schemas.PINValidateResponse(
        id=empleado.id,
        name=empleado.name,
        role=empleado.role,
    )


async def actualizar_empleado(
    db: AsyncSession, empleado_id: int, datos: schemas.EmployeeUpdate
) -> models.Employee:
    """Actualiza los datos de un empleado existente."""
    resultado = await db.execute(
        select(models.Employee).where(models.Employee.id == empleado_id)
    )
    empleado = resultado.scalar_one_or_none()
    if not empleado:
        raise HTTPException(status_code=404, detail="Empleado no encontrado")

    if datos.name is not None:
        empleado.name = datos.name
    if datos.employee_code is not None:
        empleado.employee_code = datos.employee_code
    if datos.role is not None:
        empleado.role = datos.role

    await db.commit()
    await db.refresh(empleado)
    return empleado


async def desactivar_empleado(db: AsyncSession, empleado_id: int) -> dict:
    """Desactiva un empleado (nunca se borra de la BD para conservar historial)."""
    resultado = await db.execute(
        select(models.Employee).where(models.Employee.id == empleado_id)
    )
    empleado = resultado.scalar_one_or_none()
    if not empleado:
        raise HTTPException(status_code=404, detail="Empleado no encontrado")

    empleado.is_active = False
    await db.commit()
    return {"message": f"Empleado {empleado.name} desactivado correctamente"}
