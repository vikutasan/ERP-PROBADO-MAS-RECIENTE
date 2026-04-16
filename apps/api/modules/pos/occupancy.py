"""
occupancy.py - Candados Persistentes de Terminal (PostgreSQL)

Reemplaza completamente el diccionario en RAM (_locks) que se perdía
con cada reinicio de container/uvicorn, causando expulsiones fantasma.

Todas las funciones son ASYNC y requieren una sesión de base de datos.
"""
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import delete, func
from .models import TerminalLock


async def _purge_stale_locks(db: AsyncSession, ttl_minutes: int = 15):
    """Elimina candados cuyo timestamp supere el TTL."""
    cutoff = datetime.utcnow() - timedelta(minutes=ttl_minutes)
    stale = await db.execute(
        select(TerminalLock).where(TerminalLock.locked_at < cutoff)
    )
    for lock in stale.scalars().all():
        print(f"TTL: Auto-liberando terminal {lock.terminal_id} (lock expirado con TTL {ttl_minutes}m)")
        await db.delete(lock)
    await db.flush()


async def get_all_locks(db: AsyncSession, ttl_minutes: int = 15) -> dict:
    """Devuelve todos los candados activos como diccionario {terminal_id: info}."""
    await _purge_stale_locks(db, ttl_minutes)
    result = await db.execute(select(TerminalLock))
    locks = {}
    for lock in result.scalars().all():
        locks[lock.terminal_id] = {
            "occupier_id": lock.occupier_id,
            "occupier_name": lock.occupier_name,
            "locked_at": lock.locked_at,
        }
    return locks


async def lock_terminal(db: AsyncSession, terminal_id: str, occupier_id: int, occupier_name: str, ttl_minutes: int = 15) -> bool:
    """Intenta bloquear una terminal. Retorna True si tuvo éxito."""
    await _purge_stale_locks(db, ttl_minutes)

    # Un usuario solo puede ocupar 1 terminal a la vez: limpiar locks anteriores
    stale_user = await db.execute(
        select(TerminalLock).where(
            TerminalLock.occupier_id == occupier_id,
            TerminalLock.terminal_id != terminal_id
        )
    )
    for old_lock in stale_user.scalars().all():
        await db.delete(old_lock)
    await db.flush()

    # Verificar si la terminal ya está ocupada
    existing = await db.execute(
        select(TerminalLock).where(TerminalLock.terminal_id == terminal_id)
    )
    lock = existing.scalars().first()

    if lock:
        if lock.occupier_id == occupier_id:
            # Renueva TTL si es el mismo usuario
            lock.locked_at = datetime.utcnow()
            await db.flush()
            return True
        return False  # Ocupada por otra persona

    # Crear nuevo candado
    new_lock = TerminalLock(
        terminal_id=terminal_id,
        occupier_id=occupier_id,
        occupier_name=occupier_name,
        locked_at=datetime.utcnow()
    )
    db.add(new_lock)
    await db.flush()
    return True


async def unlock_terminal(db: AsyncSession, terminal_id: str, occupier_id: int) -> bool:
    """Libera una terminal. Solo el dueño puede liberarla."""
    result = await db.execute(
        select(TerminalLock).where(TerminalLock.terminal_id == terminal_id)
    )
    lock = result.scalars().first()

    if lock:
        if lock.occupier_id == occupier_id:
            await db.delete(lock)
            await db.flush()
            return True
        return False  # No eres el dueño
    return True  # Ya estaba libre


async def force_unlock(db: AsyncSession, terminal_id: str):
    """Fuerza la liberación de una terminal (admin)."""
    result = await db.execute(
        select(TerminalLock).where(TerminalLock.terminal_id == terminal_id)
    )
    lock = result.scalars().first()
    if lock:
        await db.delete(lock)
        await db.flush()


async def heartbeat(db: AsyncSession, terminal_id: str, occupier_id: int) -> bool:
    """Renueva el timestamp del candado para evitar que expire por TTL."""
    result = await db.execute(
        select(TerminalLock).where(
            TerminalLock.terminal_id == terminal_id,
            TerminalLock.occupier_id == occupier_id
        )
    )
    lock = result.scalars().first()
    if lock:
        lock.locked_at = datetime.utcnow()
        await db.flush()
        return True
    return False
