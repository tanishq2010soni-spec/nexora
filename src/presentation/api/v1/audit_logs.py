import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from pydantic import BaseModel
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import AuditLog
from src.presentation.api.dependencies import get_current_org_id

router = APIRouter()


class AuditLogEntry(BaseModel):
    id: str
    org_id: str
    user_email: Optional[str] = None
    action: str
    resource: str
    resource_id: Optional[str] = None
    detail: Optional[str] = None
    ip_address: Optional[str] = None
    created_at: str


@router.get("/audit-logs", response_model=List[AuditLogEntry], status_code=status.HTTP_200_OK)
async def list_audit_logs(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    action: Optional[str] = Query(default=None),
    resource: Optional[str] = Query(default=None),
    limit: int = Query(default=100, ge=1, le=500),
    offset: int = Query(default=0, ge=0),
) -> List[AuditLogEntry]:
    stmt = select(AuditLog).where(AuditLog.org_id == org_id)
    if action:
        stmt = stmt.where(AuditLog.action == action.upper())
    if resource:
        stmt = stmt.where(AuditLog.resource == resource)
    stmt = stmt.order_by(AuditLog.created_at.desc()).limit(limit).offset(offset)

    result = await db.execute(stmt)
    logs = result.scalars().all()

    return [
        AuditLogEntry(
            id=str(log.id),
            org_id=str(log.org_id) if log.org_id else "",
            user_email=log.user_email,
            action=log.action,
            resource=log.resource,
            resource_id=log.resource_id,
            detail=log.detail,
            ip_address=log.ip_address,
            created_at=log.created_at.isoformat() if log.created_at else "",
        )
        for log in logs
    ]


@router.get("/audit-logs/stats")
async def audit_log_stats(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    total_stmt = select(func.count()).select_from(AuditLog).where(AuditLog.org_id == org_id)
    total_result = await db.execute(total_stmt)
    total = total_result.scalar() or 0

    return {
        "total_logs": total,
    }
