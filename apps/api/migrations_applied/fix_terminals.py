import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy import text

async def fix():
    e = create_async_engine('postgresql+asyncpg://user:password@db:5432/rderico')
    async with AsyncSession(e) as s:
        v = '[{"id":"T6","name":"Terminal 6","icon":"🖥️"},{"id":"T5","name":"Terminal 5","icon":"🖥️"},{"id":"T4","name":"Terminal 4","icon":"🖥️"},{"id":"T3","name":"Terminal 3","icon":"🖥️"},{"id":"T2","name":"Terminal 2","icon":"🖥️"},{"id":"CAJA","name":"CAJA","icon":"/assets/pos_register.png"}]'
        await s.execute(text("UPDATE system_settings SET value=:v WHERE key='pos_terminals_config'"), {'v': v})
        await s.commit()
        print('FIXED OK')
    await e.dispose()

asyncio.run(fix())
