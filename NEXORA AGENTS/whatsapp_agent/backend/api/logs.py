from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import AuditLog, User
from ..domain.enums import LogLevel
from ..infrastructure.database import AuditLogModel, get_session

router = APIRouter(prefix="/api/v1/logs", tags=["logs"])


@router.get("/")
async def list_logs(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("view_logs")),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    level: Optional[str] = Query(None),
    action: Optional[str] = Query(None),
    user_id: Optional[UUID] = Query(None),
    resource_type: Optional[str] = Query(None),
    date_from: Optional[datetime] = Query(None),
    date_to: Optional[datetime] = Query(None),
):
    org_id = str(current_user.organization_id)
    query = select(AuditLogModel).where(AuditLogModel.organization_id == org_id)
    if level:
        query = query.where(AuditLogModel.details["level"].as_string() == level)
    if action:
        query = query.where(AuditLogModel.action.ilike(f"%{action}%"))
    if user_id:
        query = query.where(AuditLogModel.user_id == str(user_id))
    if resource_type:
        query = query.where(AuditLogModel.resource_type == resource_type)
    if date_from:
        query = query.where(AuditLogModel.created_at >= date_from)
    if date_to:
        query = query.where(AuditLogModel.created_at <= date_to)
    query = query.order_by(AuditLogModel.created_at.desc())
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [AuditLog.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.get("/{log_id}")
async def get_log(
    log_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("view_logs")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(AuditLogModel).where(
            AuditLogModel.id == str(log_id),
            AuditLogModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Log entry not found")
    return AuditLog.model_validate(model)


@router.post("/", status_code=201)
async def create_log_entry(
    action: str,
    resource_type: str,
    resource_id: Optional[str] = None,
    details: Optional[dict] = None,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    model = AuditLogModel(
        id=str(uuid4()),
        organization_id=org_id,
        user_id=str(current_user.id),
        action=action,
        resource_type=resource_type,
        resource_id=resource_id,
        details=details or {},
        ip_address=ip_address,
        user_agent=user_agent,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return AuditLog.model_validate(model)
