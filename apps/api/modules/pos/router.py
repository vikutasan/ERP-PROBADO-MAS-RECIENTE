from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from core.database import get_db
from . import schemas
from .service import pos_service

from pydantic import BaseModel
class LockRequest(BaseModel):
    occupier_id: int
    occupier_name: str

from .occupancy import get_all_locks, lock_terminal, unlock_terminal, force_unlock

router = APIRouter()

@router.post("/sessions", response_model=schemas.TerminalSessionResponse)
async def create_session(session: schemas.TerminalSessionCreate, db: AsyncSession = Depends(get_db)):
    return await pos_service.create_session(db, session)

@router.get("/sessions/{terminal_id}/active", response_model=schemas.TerminalSessionResponse)
async def get_active_session(terminal_id: str, db: AsyncSession = Depends(get_db)):
    session = await pos_service.get_active_session(db, terminal_id)
    if not session:
        raise HTTPException(status_code=404, detail="Active session not found")
    return session

@router.post("/tickets/reserve", response_model=schemas.TicketResponse)
async def reserve_ticket(req: schemas.TerminalSessionBase, db: AsyncSession = Depends(get_db)):
    return await pos_service.reserve_ticket(db, req.terminal_id)

@router.post("/tickets", response_model=schemas.TicketResponse)
async def create_ticket(ticket: schemas.TicketCreate, db: AsyncSession = Depends(get_db)):
    return await pos_service.create_ticket(db, ticket)

@router.get("/tickets", response_model=List[schemas.TicketResponse])
async def get_tickets(
    terminal_id: str = None, 
    status: str = None, 
    search: str = None, 
    limit: int = 100, 
    db: AsyncSession = Depends(get_db)
):
    return await pos_service.get_tickets(db, terminal_id, status, search, limit)

@router.get("/tickets/open", response_model=List[schemas.TicketResponse])
async def get_open_tickets(db: AsyncSession = Depends(get_db)):
    return await pos_service.get_open_tickets(db)

@router.get("/terminals/status")
async def get_terminals_status(db: AsyncSession = Depends(get_db)):
    locks = get_all_locks()
    
    from modules.cash.models import CashSession
    from sqlalchemy.future import select
    result = await db.execute(select(CashSession).where(CashSession.status == "OPEN"))
    active_cash = result.scalars().all()
    
    # Combinar locks efímeros en memoria y sesiones de caja reales (que persisten a reinicios)
    res = dict(locks)
    for c in active_cash:
        if c.terminal_id not in res:
            res[c.terminal_id] = {
                "occupier_id": c.employee_id,
                "occupier_name": c.employee_name,
                "locked_at": c.opened_at,
                "is_cash_register": True
            }
        else:
            res[c.terminal_id]["is_cash_register"] = True
    return res

@router.post("/terminals/{terminal_id}/lock")
async def take_terminal_lock(terminal_id: str, req: LockRequest):
    success = lock_terminal(terminal_id, req.occupier_id, req.occupier_name)
    if not success:
        raise HTTPException(status_code=400, detail="Terminal ocupada por otra persona.")
    return {"status": "locked", "terminal_id": terminal_id}

@router.post("/terminals/{terminal_id}/unlock")
async def release_terminal_lock(terminal_id: str, req: LockRequest):
    success = unlock_terminal(terminal_id, req.occupier_id)
    if not success:
        raise HTTPException(status_code=403, detail="No tienes permiso para liberar esta terminal.")
    return {"status": "unlocked", "terminal_id": terminal_id}

@router.post("/terminals/{terminal_id}/force_unlock")
async def force_terminal_unlock(terminal_id: str):
    force_unlock(terminal_id)
    return {"status": "unlocked", "terminal_id": terminal_id}
