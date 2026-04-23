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

from .occupancy import get_all_locks, lock_terminal, unlock_terminal, force_unlock, heartbeat
from .models import TerminalLock
from modules.settings.service import get_setting_by_key

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
async def reserve_ticket(req: schemas.ReserveTicketRequest, db: AsyncSession = Depends(get_db)):
    return await pos_service.reserve_ticket(db, req.terminal_id, req.captured_by_id)

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
    return await pos_service.get_tickets(db=db, terminal_id=terminal_id, status=status, search=search, limit=limit)

@router.get("/tickets/open", response_model=List[schemas.TicketResponse])
async def get_open_tickets(db: AsyncSession = Depends(get_db)):
    return await pos_service.get_open_tickets(db)

@router.get("/terminals/status")
async def get_terminals_status(db: AsyncSession = Depends(get_db)):
    """
    Fuente de verdad UNIFICADA (v4.3):
    1. Lee candados persistentes de la tabla terminal_locks (DB)
    2. Complementa con sesiones de caja abiertas (CashSession)
    3. Previene que un usuario aparezca en 2+ terminales simultáneamente
    4. Aplica TTL máximo de 24h a CashSessions huérfanas
    No depende de RAM volátil.
    """
    try:
        ttl_setting = await get_setting_by_key(db, "pos_terminal_lock_ttl_m")
        ttl = int(ttl_setting.value)
    except Exception:
        ttl = 15
    
    # Fuente 1: Candados persistentes (reemplaza _locks en RAM)
    locks = await get_all_locks(db, ttl_minutes=ttl)
    
    # Construir set de user IDs que ya tienen un lock activo (con heartbeat reciente)
    locked_user_ids = {info["occupier_id"] for info in locks.values()}
    
    # Fuente 2: Sesiones de caja activas (persisten incluso sin lock)
    from modules.cash.models import CashSession
    from sqlalchemy.future import select
    from datetime import datetime, timedelta
    
    CASH_SESSION_MAX_TTL_HOURS = 24  # TTL máximo para sesiones de caja huérfanas
    
    result = await db.execute(select(CashSession).where(CashSession.status == "OPEN"))
    active_cash = result.scalars().all()
    
    # Combinar: locks de DB + caja abierta
    res = dict(locks)
    cutoff = datetime.utcnow() - timedelta(hours=CASH_SESSION_MAX_TTL_HOURS)
    
    for c in active_cash:
        tid = c.terminal_id.strip() if c.terminal_id else ""
        
        # v4.3 Bug Fix: Si el usuario de esta CashSession ya tiene un lock activo
        # en OTRA terminal, no crear un candado fantasma en esta terminal.
        # Solo marcar como caja abierta sin operador presente.
        user_locked_elsewhere = (c.employee_id in locked_user_ids) and (tid not in res or res[tid].get("occupier_id") != c.employee_id)
        
        if tid not in res:
            if user_locked_elsewhere:
                # El cajero se fue a otra terminal — marcar caja como abierta pero sin operador activo
                res[tid] = {
                    "occupier_id": c.employee_id,
                    "occupier_name": f"{c.employee_name} (CAJA ABIERTA)",
                    "locked_at": c.opened_at,
                    "is_cash_register": True,
                    "operator_absent": True
                }
            elif c.opened_at and c.opened_at < cutoff:
                # v4.3: CashSession huérfana (>24h sin cerrar) — marcar como zombie
                res[tid] = {
                    "occupier_id": c.employee_id,
                    "occupier_name": f"{c.employee_name} (SESIÓN EXPIRADA)",
                    "locked_at": c.opened_at,
                    "is_cash_register": True,
                    "stale_session": True
                }
            else:
                res[tid] = {
                    "occupier_id": c.employee_id,
                    "occupier_name": c.employee_name,
                    "locked_at": c.opened_at,
                    "is_cash_register": True
                }
        else:
            res[tid]["is_cash_register"] = True
    return res

@router.post("/terminals/{terminal_id}/lock")
async def take_terminal_lock(terminal_id: str, req: LockRequest, db: AsyncSession = Depends(get_db)):
    tid = terminal_id.strip()
    try:
        ttl_setting = await get_setting_by_key(db, "pos_terminal_lock_ttl_m")
        ttl = int(ttl_setting.value)
    except Exception:
        ttl = 15
    success = await lock_terminal(db, tid, req.occupier_id, req.occupier_name, ttl_minutes=ttl)
    if not success:
        raise HTTPException(status_code=400, detail="Terminal ocupada por otra persona.")
    return {"status": "locked", "terminal_id": tid}

@router.post("/terminals/{terminal_id}/unlock")
async def release_terminal_lock(terminal_id: str, req: LockRequest, db: AsyncSession = Depends(get_db)):
    tid = terminal_id.strip()
    success = await unlock_terminal(db, tid, req.occupier_id)
    if not success:
        raise HTTPException(status_code=403, detail="No tienes permiso para liberar esta terminal.")
    return {"status": "unlocked", "terminal_id": tid}

@router.post("/terminals/{terminal_id}/force_unlock")
async def force_terminal_unlock(terminal_id: str, req: LockRequest, db: AsyncSession = Depends(get_db)):
    """
    Fuerza la liberación de una terminal bloqueada (hardened v4.4).
    
    Seguridad:
      1. Valida permisos del usuario en el backend (no solo en frontend).
      2. Si la terminal tiene CashSession activa, requiere permiso pos_force_cash_unlock.
      3. Transfiere titularidad de CashSession al desbloqueador (Traspuesta de Titularidad).
      4. Registra auditoría de quién desbloqueó qué, a quién le quitó, y cuándo.
    """
    import logging
    from datetime import datetime
    from modules.cash.models import CashSession
    from modules.security.models import Employee, SecurityProfile
    from sqlalchemy.future import select
    from sqlalchemy.orm import selectinload

    logger = logging.getLogger("pos.force_unlock")
    tid = terminal_id.strip()

    # ── 1. VALIDAR PERMISOS EN BACKEND ──────────────────────────────────
    employee = await db.execute(
        select(Employee)
        .options(selectinload(Employee.profile))
        .where(Employee.id == req.occupier_id)
    )
    emp = employee.scalars().first()
    if not emp:
        raise HTTPException(status_code=404, detail="Empleado no encontrado.")
    
    permissions = {}
    if emp.profile and emp.profile.permissions:
        permissions = emp.profile.permissions
    
    is_admin = (emp.role or "").strip().upper() == "ADMIN"
    has_unlock_perm = permissions.get("pos_force_unlock") in ("full", True)
    
    if not is_admin and not has_unlock_perm:
        logger.warning(f"🚫 FORCE UNLOCK DENEGADO: {emp.name} (id={emp.id}) intentó desbloquear {tid} sin permisos")
        raise HTTPException(status_code=403, detail="No tienes permiso para forzar el desbloqueo de terminales.")
    
    # Verificar permiso de caja si la terminal tiene CashSession activa
    result_cash = await db.execute(select(CashSession).where(
        CashSession.terminal_id == tid,
        CashSession.status == "OPEN"
    ))
    cash_session = result_cash.scalars().first()
    
    if cash_session:
        has_cash_perm = permissions.get("pos_force_cash_unlock") in ("full", True)
        if not is_admin and not has_cash_perm:
            logger.warning(f"🚫 FORCE UNLOCK CAJA DENEGADO: {emp.name} (id={emp.id}) intentó desbloquear CAJA en {tid} sin permiso pos_force_cash_unlock")
            raise HTTPException(status_code=403, detail="No tienes permiso para forzar el desbloqueo de terminales con CAJA activa.")

    # ── 2. OBTENER DATOS DEL OCUPANTE ANTERIOR (para auditoría) ─────────
    prev_lock = await db.execute(
        select(TerminalLock).where(TerminalLock.terminal_id == tid)
    )
    previous_occupier = prev_lock.scalars().first()
    prev_name = previous_occupier.occupier_name if previous_occupier else "NADIE"
    prev_id = previous_occupier.occupier_id if previous_occupier else None

    # ── 3. TRANSACCIÓN ATÓMICA: unlock + traspuesta + auditoría ─────────
    # Todo dentro del mismo commit para evitar estados inconsistentes
    await force_unlock(db, tid)
    
    cash_transferred = False
    if cash_session:
        cash_session.employee_id = req.occupier_id
        cash_session.employee_name = req.occupier_name
        cash_transferred = True

    # ── 4. LOG DE AUDITORÍA ─────────────────────────────────────────────
    logger.warning(
        f"🔓 FORCE UNLOCK: Terminal={tid} | "
        f"Ejecutado por: {emp.name} (id={emp.id}) | "
        f"Quitado a: {prev_name} (id={prev_id}) | "
        f"CashSession transferida: {cash_transferred} | "
        f"Timestamp: {datetime.utcnow().isoformat()}"
    )

    await db.commit()

    return {
        "status": "unlocked", 
        "terminal_id": tid,
        "previous_occupier": prev_name,
        "cash_session_transferred": cash_transferred,
        "unlocked_by": emp.name
    }

@router.post("/terminals/{terminal_id}/heartbeat")
async def heartbeat_terminal_lock(terminal_id: str, req: LockRequest, db: AsyncSession = Depends(get_db)):
    tid = terminal_id.strip()
    try:
        ttl_setting = await get_setting_by_key(db, "pos_terminal_lock_ttl_m")
        ttl = int(ttl_setting.value)
    except Exception:
        ttl = 15
    success = await heartbeat(db, tid, req.occupier_id, ttl_minutes=ttl)
    if not success:
        raise HTTPException(status_code=404, detail="No active lock found for this terminal/user.")
    return {"status": "alive", "terminal_id": terminal_id}

@router.post("/tickets/emergency-save")
async def emergency_save_ticket(payload: dict, db: AsyncSession = Depends(get_db)):
    """
    v4.0 ZERO-LOSS: Endpoint de emergencia para sendBeacon (cierre de navegador).
    Acepta un payload simplificado y hace lo posible por guardar el ticket.
    No lanza excepciones — siempre retorna 200 para no bloquear el cierre del navegador.
    """
    import logging
    logger = logging.getLogger("pos.emergency")
    
    try:
        account_num = payload.get("account_num")
        items = payload.get("items", [])
        
        if not account_num or not items:
            logger.warning("Emergency save: payload incompleto, ignorando")
            return {"status": "ignored", "reason": "incomplete payload"}
        
        logger.warning(f"🆘 EMERGENCY SAVE: {account_num} con {len(items)} items")
        
        # Buscar sesión activa para cualquier terminal
        from sqlalchemy.future import select
        from .models import TerminalSession
        result = await db.execute(
            select(TerminalSession).where(TerminalSession.is_active == True).limit(1)
        )
        session = result.scalars().first()
        
        if not session:
            logger.error("Emergency save: No hay sesión activa")
            return {"status": "failed", "reason": "no active session"}
        
        # Construir TicketCreate y guardar
        ticket_data = schemas.TicketCreate(
            account_num=account_num,
            session_id=session.id,
            items=[schemas.TicketItemCreate(**item) for item in items],
            status="OPEN"
        )
        
        await pos_service.create_ticket(db, ticket_data)
        logger.warning(f"✅ EMERGENCY SAVE exitoso: {account_num}")
        return {"status": "saved", "account_num": account_num}
        
    except Exception as e:
        logger.error(f"❌ EMERGENCY SAVE falló: {e}")
        return {"status": "failed", "error": str(e)}

@router.post("/vision/training/upload")
async def upload_vision_training(payload: schemas.VisionTrainingUpload):
    return await pos_service.upload_training_images(payload)

@router.post("/vision/predict", response_model=schemas.VisionPredictionResponse)
async def predict_vision(payload: schemas.VisionPredictionRequest):
    return await pos_service.predict_vision(payload)
