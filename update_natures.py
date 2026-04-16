import asyncio
from core.database import AsyncSessionLocal
from sqlalchemy.future import select
from modules.catalog.models import Product, Category
from sqlalchemy.orm import selectinload

async def run_update():
    async with AsyncSessionLocal() as db:
        result = await db.execute(select(Product).options(selectinload(Product.category)))
        products = result.scalars().all()
        
        updated_count = 0
        
        for p in products:
            c_name = p.category.name.upper() if p.category else ''
            p_name = p.name.upper()
            
            # --- 1. PREPARADO AL MOMENTO ---
            if 'AGUAS Y MALTEADAS' in c_name:
                p.nature = 'PREPARADO AL MOMENTO'
                
            # --- 2. REVENTA ---
            elif any(x in c_name for x in ['LACTEOS', 'SOUVENIRS', 'PALETAS', 'HELADOS', 'CAFES Y CHOCOLATES']):
                p.nature = 'REVENTA'
                
            # --- 3. EMPAQUE ---
            elif 'EMPAQUE Y PAN BLANCO' in c_name and any(x in p_name for x in ['CAJA', 'CHAROLA', 'BOLSA']):
                p.nature = 'EMPAQUE'
                
            # --- 4. MANUFACTURADO ---
            else:
                p.nature = 'MANUFACTURADO'
                
            db.add(p)
            updated_count += 1
            
        await db.commit()
        print(f"Update completed successfully! {updated_count} products updated.")

asyncio.run(run_update())
