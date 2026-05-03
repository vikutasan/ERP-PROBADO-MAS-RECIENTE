import asyncio
import sys
import os
import json

sys.path.append(os.getcwd())

from core.database import AsyncSessionLocal
from modules.production.models import Dough
from modules.catalog.models import Product, Category, ProductTechnicalSheet
from sqlalchemy import select

async def inspect_dough(dough_id):
    async with AsyncSessionLocal() as db:
        res = await db.execute(select(Dough).where(Dough.id == dough_id))
        dough = res.scalar_one_or_none()
        if dough:
            print(f"Name: {dough.name}")
            print(f"Process: {json.dumps(dough.production_process, indent=2)}")
        else:
            print("Dough not found")

if __name__ == "__main__":
    dough_id = int(sys.argv[1])
    asyncio.run(inspect_dough(dough_id))
