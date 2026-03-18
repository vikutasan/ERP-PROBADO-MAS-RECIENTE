from typing import Dict, Optional
from pydantic import BaseModel
from datetime import datetime

# Diccionario en memoria: terminal_id -> info
# Esto es seguro porque uvicorn corre con 1 solo worker.
_locks: Dict[str, dict] = {}

class LockInfo(BaseModel):
    occupier_id: int
    occupier_name: str
    locked_at: datetime

def get_all_locks() -> Dict[str, dict]:
    return _locks

def lock_terminal(terminal_id: str, occupier_id: int, occupier_name: str) -> bool:
    if terminal_id in _locks:
        if _locks[terminal_id]["occupier_id"] == occupier_id:
            return True # Ya la tiene bloqueada él mismo
        return False # Está ocupada por alguien más
    
    _locks[terminal_id] = {
        "occupier_id": occupier_id,
        "occupier_name": occupier_name,
        "locked_at": datetime.utcnow()
    }
    return True

def unlock_terminal(terminal_id: str, occupier_id: int) -> bool:
    if terminal_id in _locks:
        if _locks[terminal_id]["occupier_id"] == occupier_id:
            del _locks[terminal_id]
            return True
        return False # No puede desbloquear la de otro (a menos que sea force)
    return True

def force_unlock(terminal_id: str):
    if terminal_id in _locks:
        del _locks[terminal_id]
