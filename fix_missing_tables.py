import asyncio
import sys
from sqlalchemy import text

# Intentamos importar el motor de base de datos del ERP
sys.path.append('C:\\Users\\servidor1\\.gemini\\antigravity\\scratch\\ERP-R-DE-RICO\\apps\\api')
try:
    from core.database import engine
except ImportError:
    print("Error: No se pudo encontrar el motor de base de datos en la ruta especificada.")
    sys.exit(1)

async def fix():
    async with engine.begin() as conn:
        print("Verificando existencia de la tabla 'product_technical_sheets'...")
        
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS product_technical_sheets (
            id SERIAL PRIMARY KEY,
            product_id INTEGER UNIQUE NOT NULL REFERENCES products(id),
            primary_mass_id INTEGER REFERENCES doughs(id),
            primary_mass_grams DOUBLE PRECISION,
            secondary_mass_id INTEGER REFERENCES doughs(id),
            secondary_mass_grams DOUBLE PRECISION,
            tertiary_mass_id INTEGER REFERENCES doughs(id),
            tertiary_mass_grams DOUBLE PRECISION,
            weight_per_piece DOUBLE PRECISION,
            baking_temp_top DOUBLE PRECISION,
            baking_temp_bottom DOUBLE PRECISION,
            baking_time_min INTEGER,
            steam_seconds INTEGER,
            scoring_type VARCHAR,
            forming_procedure TEXT,
            bom_extra JSONB,
            preparation_time_min INTEGER,
            order_lead_time_hours INTEGER,
            recipe_procedure TEXT,
            modifiers JSONB,
            provider VARCHAR,
            original_barcode VARCHAR,
            unit_measure VARCHAR,
            min_stock INTEGER,
            max_stock INTEGER
        );
        """
        
        try:
            await conn.execute(text(create_table_sql))
            print("✅ Tabla 'product_technical_sheets' creada o verificada exitosamente.")
        except Exception as e:
            print(f"❌ Error al crear la tabla: {str(e)}")

if __name__ == "__main__":
    asyncio.run(fix())
