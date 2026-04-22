
import asyncio
from sqlalchemy import text
from core.database import engine

async def check_equipment_table():
    try:
        async with engine.connect() as conn:
            result = await conn.execute(text("SELECT count(*) FROM production_equipment"))
            count = result.scalar()
            print(f"Table 'production_equipment' exists and has {count} records.")
    except Exception as e:
        print(f"Error checking 'production_equipment' table: {e}")

if __name__ == "__main__":
    asyncio.run(check_equipment_table())
