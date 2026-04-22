from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from core.database import get_db
from . import schemas, service

router = APIRouter()

@router.get("/doughs", response_model=list[schemas.DoughResponse])
async def list_doughs(db: AsyncSession = Depends(get_db)):
    """List all dough recipes"""
    return await service.list_doughs(db)

@router.post("/doughs", response_model=schemas.DoughResponse)
async def create_dough(dough: schemas.DoughCreate, db: AsyncSession = Depends(get_db)):
    """Create a new dough and its related entities"""
    return await service.create_dough(db, dough)

@router.get("/doughs/{dough_id}", response_model=schemas.DoughResponse)
async def get_dough(dough_id: int, db: AsyncSession = Depends(get_db)):
    dough = await service.get_dough(db, dough_id)
    if not dough:
        raise HTTPException(status_code=404, detail="Dough not found")
    return dough

@router.put("/doughs/{dough_id}", response_model=schemas.DoughResponse)
async def update_dough(dough_id: int, dough: schemas.DoughCreate, db: AsyncSession = Depends(get_db)):
    updated = await service.update_dough(db, dough_id, dough)
    if not updated:
        raise HTTPException(status_code=404, detail="Dough not found")
    return updated

@router.post("/doughs/reorder")
async def reorder_doughs(req: schemas.DoughReorderRequest, db: AsyncSession = Depends(get_db)):
    """Reorder doughs based on the provided list of IDs"""
    await service.reorder_doughs(db, req.order)
    return {"status": "ok"}

# --- Equipment Endpoints ---
@router.get("/equipment", response_model=list[schemas.ProductionEquipmentResponse])
async def list_equipment(db: AsyncSession = Depends(get_db)):
    return await service.list_equipment(db)

@router.post("/equipment", response_model=schemas.ProductionEquipmentResponse)
async def create_equipment(equip: schemas.ProductionEquipmentCreate, db: AsyncSession = Depends(get_db)):
    return await service.create_equipment(db, equip)

@router.put("/equipment/{equip_id}", response_model=schemas.ProductionEquipmentResponse)
async def update_equipment(equip_id: int, equip: schemas.ProductionEquipmentUpdate, db: AsyncSession = Depends(get_db)):
    updated = await service.update_equipment(db, equip_id, equip)
    if not updated:
        raise HTTPException(status_code=404, detail="Equipment not found")
    return updated

@router.delete("/equipment/{equip_id}")
async def delete_equipment(equip_id: int, db: AsyncSession = Depends(get_db)):
    deleted = await service.delete_equipment(db, equip_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Equipment not found")
    return {"status": "ok"}
