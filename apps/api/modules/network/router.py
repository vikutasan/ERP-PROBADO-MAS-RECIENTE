from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_
from core.database import get_db
from . import schemas, models
from typing import List, Optional
from datetime import datetime, timedelta

router = APIRouter()

@router.post("/incidents", response_model=schemas.NetworkIncidentResponse)
async def create_incident(req: schemas.NetworkIncidentCreate, db: AsyncSession = Depends(get_db)):
    incident = models.NetworkIncident(
        terminal_id=req.terminal_id,
        incident_type=req.incident_type,
        user_logged=req.user_logged,
        details=req.details
    )
    db.add(incident)
    await db.commit()
    await db.refresh(incident)
    return incident

@router.get("/incidents", response_model=List[schemas.NetworkIncidentResponse])
async def list_incidents(
    date: Optional[str] = Query(None, description="Fecha YYYY-MM-DD, default hoy"),
    terminal: Optional[str] = Query(None),
    limit: int = Query(200, le=500),
    db: AsyncSession = Depends(get_db)
):
    if date:
        try:
            target = datetime.strptime(date, "%Y-%m-%d")
        except ValueError:
            target = datetime.utcnow()
    else:
        target = datetime.utcnow()

    start = target.replace(hour=0, minute=0, second=0, microsecond=0)
    end = start + timedelta(days=1)

    query = select(models.NetworkIncident).where(
        and_(
            models.NetworkIncident.created_at >= start,
            models.NetworkIncident.created_at < end
        )
    )

    if terminal:
        query = query.where(models.NetworkIncident.terminal_id == terminal)

    query = query.order_by(models.NetworkIncident.created_at.desc()).limit(limit)
    result = await db.execute(query)
    return result.scalars().all()

@router.get("/incidents/summary")
async def incidents_summary(
    date: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db)
):
    if date:
        try:
            target = datetime.strptime(date, "%Y-%m-%d")
        except ValueError:
            target = datetime.utcnow()
    else:
        target = datetime.utcnow()

    start = target.replace(hour=0, minute=0, second=0, microsecond=0)
    end = start + timedelta(days=1)

    # Total por terminal
    query = select(
        models.NetworkIncident.terminal_id,
        models.NetworkIncident.incident_type,
        func.count().label("count")
    ).where(
        and_(
            models.NetworkIncident.created_at >= start,
            models.NetworkIncident.created_at < end
        )
    ).group_by(
        models.NetworkIncident.terminal_id,
        models.NetworkIncident.incident_type
    )

    result = await db.execute(query)
    rows = result.all()

    summary = {}
    for terminal_id, incident_type, count in rows:
        if terminal_id not in summary:
            summary[terminal_id] = {"disconnects": 0, "slow": 0, "reconnects": 0}
        if incident_type == "disconnect":
            summary[terminal_id]["disconnects"] = count
        elif incident_type == "slow":
            summary[terminal_id]["slow"] = count
        elif incident_type == "reconnect":
            summary[terminal_id]["reconnects"] = count

    return {"date": start.strftime("%Y-%m-%d"), "terminals": summary}
