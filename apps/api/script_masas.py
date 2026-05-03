import asyncio
import sys
import os

# Añadir el directorio actual al path para importar módulos locales
sys.path.append(os.getcwd())

from core.database import AsyncSessionLocal
from modules.production.models import Dough
from modules.catalog.models import Product, Category, ProductTechnicalSheet
from sqlalchemy import select

async def list_doughs():
    async with AsyncSessionLocal() as db:
        res = await db.execute(select(Dough))
        doughs = res.scalars().all()
        for d in doughs:
            print(f"ID: {d.id} | Name: {d.name} | Code: {d.code}")

if __name__ == "__main__":
    asyncio.run(list_doughs())
