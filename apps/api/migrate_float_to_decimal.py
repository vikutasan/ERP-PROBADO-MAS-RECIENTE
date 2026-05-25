"""
FASE 1 — Migración FLOAT → DECIMAL (Numeric 12,2)
Basado en análisis del POS SISYTEC que usa DECIMAL para todos los montos monetarios.

Ejecutar dentro del contenedor:
  docker exec rderico-api-dev python migrate_float_to_decimal.py

Este script altera las columnas Float a Numeric(12,2) en PostgreSQL.
Es seguro ejecutar múltiples veces (idempotente).
"""
import asyncio
from sqlalchemy import text
from core.database import async_engine

ALTERATIONS = [
    # --- tickets ---
    "ALTER TABLE tickets ALTER COLUMN total TYPE NUMERIC(12,2) USING total::NUMERIC(12,2);",
    # --- ticket_items ---
    "ALTER TABLE ticket_items ALTER COLUMN unit_price TYPE NUMERIC(12,2) USING unit_price::NUMERIC(12,2);",
    "ALTER TABLE ticket_items ALTER COLUMN subtotal TYPE NUMERIC(12,2) USING subtotal::NUMERIC(12,2);",
    # --- products ---
    "ALTER TABLE products ALTER COLUMN price TYPE NUMERIC(12,2) USING price::NUMERIC(12,2);",
    "ALTER TABLE products ALTER COLUMN cost TYPE NUMERIC(12,2) USING cost::NUMERIC(12,2);",
    # --- cash_sessions ---
    "ALTER TABLE cash_sessions ALTER COLUMN opening_float TYPE NUMERIC(12,2) USING opening_float::NUMERIC(12,2);",
    "ALTER TABLE cash_sessions ALTER COLUMN physical_cash TYPE NUMERIC(12,2) USING physical_cash::NUMERIC(12,2);",
    "ALTER TABLE cash_sessions ALTER COLUMN physical_credit TYPE NUMERIC(12,2) USING physical_credit::NUMERIC(12,2);",
    "ALTER TABLE cash_sessions ALTER COLUMN physical_debit TYPE NUMERIC(12,2) USING physical_debit::NUMERIC(12,2);",
    # --- cash_movements ---
    "ALTER TABLE cash_movements ALTER COLUMN amount TYPE NUMERIC(12,2) USING amount::NUMERIC(12,2);",
]

async def migrate():
    print("=" * 60)
    print("FASE 1: Migración FLOAT → DECIMAL (Numeric 12,2)")
    print("=" * 60)
    
    async with async_engine.begin() as conn:
        for sql in ALTERATIONS:
            table_col = sql.split("ALTER COLUMN ")[1].split(" TYPE")[0]
            table = sql.split("ALTER TABLE ")[1].split(" ALTER")[0]
            try:
                await conn.execute(text(sql))
                print(f"  ✅ {table}.{table_col} → NUMERIC(12,2)")
            except Exception as e:
                print(f"  ⚠️  {table}.{table_col} — {e}")
    
    # Verificación
    async with async_engine.begin() as conn:
        result = await conn.execute(text("""
            SELECT table_name, column_name, data_type, numeric_precision, numeric_scale
            FROM information_schema.columns
            WHERE (table_name, column_name) IN (
                ('tickets', 'total'),
                ('ticket_items', 'unit_price'),
                ('ticket_items', 'subtotal'),
                ('products', 'price'),
                ('products', 'cost'),
                ('cash_sessions', 'opening_float'),
                ('cash_sessions', 'physical_cash'),
                ('cash_sessions', 'physical_credit'),
                ('cash_sessions', 'physical_debit'),
                ('cash_movements', 'amount')
            )
            ORDER BY table_name, column_name
        """))
        rows = result.fetchall()
        
        print("\n" + "=" * 60)
        print("VERIFICACIÓN:")
        print("=" * 60)
        all_ok = True
        for row in rows:
            status = "✅" if row[2] == "numeric" else "❌ AÚN ES " + row[2]
            if row[2] != "numeric":
                all_ok = False
            print(f"  {status} {row[0]}.{row[1]} = {row[2]}({row[3]},{row[4]})")
        
        if all_ok:
            print("\n🎉 MIGRACIÓN COMPLETADA EXITOSAMENTE — Todos los campos monetarios son DECIMAL")
        else:
            print("\n⚠️  ALGUNOS CAMPOS NO SE MIGRARON — Revisa los errores arriba")

if __name__ == "__main__":
    asyncio.run(migrate())
