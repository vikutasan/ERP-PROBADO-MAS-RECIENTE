import asyncio
import sys
import os
import json

sys.path.append(os.getcwd())

from core.database import AsyncSessionLocal
from modules.production.models import Dough
from modules.catalog.models import Product, Category, ProductTechnicalSheet
from sqlalchemy import select

async def verify_all_doughs():
    async with AsyncSessionLocal() as db:
        res = await db.execute(select(Dough))
        doughs = res.scalars().all()
        for d in doughs:
            if d.production_process and len(d.production_process) > 0:
                print(f"Dough: {d.name} | Step 1: {d.production_process[0].get('nombre')}")
                if d.production_process[0].get('subpasos') and len(d.production_process[0]['subpasos']) > 0:
                    sp = d.production_process[0]['subpasos'][0]
                    print(f"  Substep 1: {sp.get('instruccionVoz')}")
                    print(f"  Trigger: {sp.get('triggerInicio')}")
                    print(f"  Dependency: {sp.get('dependenciaPasoPrevio')}")
            else:
                print(f"Dough: {d.name} | NO PROCESS")

if __name__ == "__main__":
    asyncio.run(verify_all_doughs())
