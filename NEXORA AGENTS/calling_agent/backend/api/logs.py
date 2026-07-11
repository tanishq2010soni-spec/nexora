from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import AuditLog
from ..domain.enums import LogLevel
from ..infrastructure.database import AuditLogModel, get_session

router = APIRouter(prefix="/api/v1/logs", tags=["logs"])


class LogListResponse(BaseModel):
    items: list[AuditLog]
    total: int
    page: int
    limit: int
    pages: int


class CreateLogRequest(BaseModel):
    action: str
    resource_type: str
    resource_id: Optional[str] = None
    details: dict[str, Any] = {}
    level: str = "info"


@router.get("", response_model=LogListResponse)
async def list_logs(
    level: Optional[str] = Query(None),
    action: Optional[str] = Query(None),
    user_id: Optional[UUID] = Query(None),
    resource_type: Optional[str] = Query(None),
    date_from: Optional[datetime] = Query(None),
    date_to: Optional[datetime] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=200),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_logs")),
):
    query = select(AuditLogModel).where(AuditLogModel.organization_id == str(current_user.organization_id))

    if level:
        query = query.where(AuditLogModel.action == level)
    if action:
        query = query.where(AuditLogModel.action == action)
    if user_id:
        query = query.where(AuditLogModel.user_id == str(user_id))
    if resource_type:
        query = query.where(AuditLogModel.resource_type == resource_type)
    if date_from:
        query = query.where(AuditLogModel.created_at >= date_from)
    if date_to:
        query = query.where(AuditLogModel.created_at <= date_to)

    count_query = select(func.count()).select_from(query.subquery())
    total = (await session.execute(count_query)).scalar() or 0
    pages = max(1, (total + limit - 1) // limit)
    offset = (page - 1) * limit

    query = query.order_by(desc(AuditLogModel.created_at)).offset(offset).limit(limit)
    result = await session.execute(query)
    models = result.scalars().all()

    return LogListResponse(
        items=[AuditLog.model_validate(m) for m in models],
        total=total, page=page, limit=limit, pages=pages,
    )


@router.get("/{log_id}", response_model=AuditLog)
async def get_log(
    log_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_logs")),
):
    result = await session.execute(
        select(AuditLogModel).where(AuditLogModel.id == str(log_id))
        .where(AuditLogModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Log entry not found")
    return AuditLog.model_validate(model)


@router.post("", response_model=AuditLog)
async def create_log(
    req: CreateLogRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_logs")),
):
    model = AuditLogModel(
        organization_id=str(current_user.organization_id),
        user_id=str(current_user.id),
        action=req.action,
        resource_type=req.resource_type,
        resource_id=req.resource_id,
        details=req.details,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return AuditLog.model_validate(model)
