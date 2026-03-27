import asyncio
from core.database import engine, Base
from modules.security.models import SecurityProfile, Employee
# Necesito importar todos los modelos para que Base los reconozca
from modules.catalog.models import Category, Product
from modules.pos.models import Ticket, TerminalSession
from modules.cash.models import CashSession, CashMovement
from modules.settings.models import SystemSetting
from modules.production.models import Dough, DoughBatchConfig, DoughIngredient, DoughProcedureStep, DoughProductRelation

async def create_tables():
    print("Sincronizando modelos de Producción...")
    async with engine.begin() as conn:
        # Forzar recreación de tablas de producción para actualizar columnas
        from sqlalchemy import text
        await conn.execute(text("DROP TABLE IF EXISTS dough_product_relations CASCADE"))
        await conn.execute(text("DROP TABLE IF EXISTS dough_procedure_steps CASCADE"))
        await conn.execute(text("DROP TABLE IF EXISTS dough_ingredients CASCADE"))
        await conn.execute(text("DROP TABLE IF EXISTS dough_batch_configs CASCADE"))
        await conn.execute(text("DROP TABLE IF EXISTS doughs CASCADE"))
        
        await conn.run_sync(Base.metadata.create_all)
    print("Tablas sincronizadas exitosamente.")

if __name__ == "__main__":
    asyncio.run(create_tables())
