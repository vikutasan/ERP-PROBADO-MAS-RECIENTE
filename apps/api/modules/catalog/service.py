from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from . import models, schemas

class CatalogService:
    async def get_categories(self, db: AsyncSession):
        result = await db.execute(select(models.Category))
        return result.scalars().all()

    async def create_category(self, db: AsyncSession, category: schemas.CategoryCreate):
        db_category = models.Category(**category.model_dump())
        db.add(db_category)
        await db.commit()
        await db.refresh(db_category)
        return db_category

    async def get_products(self, db: AsyncSession, category_id: int = None):
        query = select(models.Product).options(selectinload(models.Product.category))
        if category_id:
            query = query.where(models.Product.category_id == category_id)
        result = await db.execute(query)
        return result.scalars().all()

    async def create_product(self, db: AsyncSession, product: schemas.ProductCreate):
        db_product = models.Product(**product.model_dump())
        db.add(db_product)
        await db.commit()
        # Refrescar con la relación cargada para evitar error de lazy loading en el response
        await db.refresh(db_product)
        # Hacemos un select con selectinload para devolverlo completo
        result = await db.execute(
            select(models.Product).options(selectinload(models.Product.category)).where(models.Product.id == db_product.id)
        )
        return result.scalar_one()

catalog_service = CatalogService()
