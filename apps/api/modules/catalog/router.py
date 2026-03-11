from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from core.database import get_db
from . import schemas
from .service import catalog_service

router = APIRouter()

@router.get("/categories", response_model=List[schemas.CategoryResponse])
async def read_categories(db: AsyncSession = Depends(get_db)):
    return await catalog_service.get_categories(db)

@router.post("/categories", response_model=schemas.CategoryResponse)
async def create_category(category: schemas.CategoryCreate, db: AsyncSession = Depends(get_db)):
    return await catalog_service.create_category(db, category)

@router.get("/products", response_model=List[schemas.ProductResponse])
async def read_products(category_id: int = None, db: AsyncSession = Depends(get_db)):
    return await catalog_service.get_products(db, category_id=category_id)

@router.post("/products", response_model=schemas.ProductResponse)
async def create_product(product: schemas.ProductCreate, db: AsyncSession = Depends(get_db)):
    return await catalog_service.create_product(db, product)
