"""
Script de migración: Poblar terminal_id directo en tickets históricos.
Ejecutar UNA VEZ después de agregar la columna terminal_id al modelo Ticket.

Uso:
  docker exec -it <api_container> python migrate_terminal_id.py

O desde el host:
  python migrate_terminal_id.py
"""
import asyncio
import sys
import os

# Agregar el directorio de la API al path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'apps', 'api'))

from sqlalchemy import text
from core.database import engine, async_session

async def migrate():
    async with async_session() as db:
        # 1. Agregar columna si no existe (idempotente)
        try:
            await db.execute(text("""
                ALTER TABLE tickets ADD COLUMN IF NOT EXISTS terminal_id VARCHAR;
            """))
            await db.commit()
            print("✅ Columna terminal_id verificada/creada")
        except Exception as e:
            print(f"⚠️ Error creando columna (puede que ya exista): {e}")
            await db.rollback()

        # 2. Crear índice si no existe
        try:
            await db.execute(text("""
                CREATE INDEX IF NOT EXISTS ix_tickets_terminal_id ON tickets (terminal_id);
            """))
            await db.commit()
            print("✅ Índice ix_tickets_terminal_id verificado/creado")
        except Exception as e:
            print(f"⚠️ Error creando índice: {e}")
            await db.rollback()

        # 3. Poblar terminal_id desde terminal_sessions para tickets existentes
        result = await db.execute(text("""
            UPDATE tickets t
            SET terminal_id = ts.terminal_id
            FROM terminal_sessions ts
            WHERE t.session_id = ts.id
              AND t.terminal_id IS NULL;
        """))
        updated = result.rowcount
        await db.commit()
        print(f"✅ {updated} tickets históricos actualizados con terminal_id directo")

        # 4. Verificar resultado
        orphans = await db.execute(text("""
            SELECT COUNT(*) FROM tickets WHERE terminal_id IS NULL;
        """))
        orphan_count = orphans.scalar()
        if orphan_count > 0:
            print(f"⚠️ {orphan_count} tickets sin terminal_id (probablemente sin session_id)")
        else:
            print("✅ Todos los tickets tienen terminal_id asignado")

        print("\n🎯 Migración completada exitosamente")

if __name__ == "__main__":
    asyncio.run(migrate())
