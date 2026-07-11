from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..config import settings
from ..infrastructure.database import OrganizationModel, get_session

router = APIRouter(prefix="/api/v1", tags=["health"])

_start_time = datetime.now(timezone.utc)


class HealthResponse(BaseModel):
    status: str
    uptime_seconds: float
    database: str
    version: str
    app_name: str


@router.get("/health", response_model=HealthResponse)
async def health(session: AsyncSession = Depends(get_session)):
    db_status = "ok"
    try:
        result = await session.execute(select(OrganizationModel).limit(1))
        result.scalar_one_or_none()
    except Exception:
        db_status = "error"

    uptime = (datetime.now(timezone.utc) - _start_time).total_seconds()
    return HealthResponse(
        status="ok" if db_status == "ok" else "degraded",
        uptime_seconds=uptime,
        database=db_status,
        version=settings.app_version,
        app_name=settings.app_name,
    )
