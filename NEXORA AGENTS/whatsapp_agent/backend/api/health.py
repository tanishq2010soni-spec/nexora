from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user
from ..domain.entities import User
from ..infrastructure.database import get_session

router = APIRouter(prefix="/api/v1", tags=["health"])

_start_time = datetime.now(timezone.utc)


@router.get("/health")
async def health_check(
    session: AsyncSession = Depends(get_session),
    _: User = Depends(get_current_user),
):
    db_ok = False
    try:
        await session.execute(text("SELECT 1"))
        db_ok = True
    except Exception:
        db_ok = False
    uptime = (datetime.now(timezone.utc) - _start_time).total_seconds()
    return {
        "status": "healthy" if db_ok else "degraded",
        "uptime_seconds": round(uptime, 2),
        "database": "connected" if db_ok else "disconnected",
        "version": "1.0.0",
    }
