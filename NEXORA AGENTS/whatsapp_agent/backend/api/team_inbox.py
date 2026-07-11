from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Department, User
from ..infrastructure.database import (ConversationModel, DepartmentModel,
                                       get_session)

router = APIRouter(prefix="/api/v1/inbox", tags=["team_inbox"])


@router.get("/overview")
async def inbox_overview(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    unread = await session.execute(
        select(func.count()).select_from(ConversationModel).where(
            ConversationModel.organization_id == org_id,
            ConversationModel.is_unread == True,
            ConversationModel.is_archived == False,
        )
    )
    assigned_to_me = await session.execute(
        select(func.count()).select_from(ConversationModel).where(
            ConversationModel.organization_id == org_id,
            ConversationModel.assigned_to == str(current_user.id),
            ConversationModel.is_archived == False,
        )
    )
    unassigned = await session.execute(
        select(func.count()).select_from(ConversationModel).where(
            ConversationModel.organization_id == org_id,
            ConversationModel.assigned_to.is_(None),
            ConversationModel.is_archived == False,
        )
    )
    archived = await session.execute(
        select(func.count()).select_from(ConversationModel).where(
            ConversationModel.organization_id == org_id,
            ConversationModel.is_archived == True,
        )
    )
    handoff_pending = await session.execute(
        select(func.count()).select_from(ConversationModel).where(
            ConversationModel.organization_id == org_id,
            ConversationModel.handoff_status == "requested",
        )
    )
    active = await session.execute(
        select(func.count()).select_from(ConversationModel).where(
            ConversationModel.organization_id == org_id,
            ConversationModel.status == "active",
            ConversationModel.is_archived == False,
        )
    )
    return {
        "unread_count": unread.scalar() or 0,
        "assigned_to_me": assigned_to_me.scalar() or 0,
        "unassigned": unassigned.scalar() or 0,
        "archived": archived.scalar() or 0,
        "handoff_pending": handoff_pending.scalar() or 0,
        "active_conversations": active.scalar() or 0,
    }


@router.get("/departments")
async def list_departments(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(DepartmentModel).where(
            DepartmentModel.organization_id == org_id,
            DepartmentModel.is_active == True,
        )
    )
    models = result.scalars().all()
    return {"items": [Department.model_validate(m) for m in models]}


@router.post("/departments", status_code=201)
async def create_department(
    name: str,
    description: Optional[str] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_team")),
):
    org_id = str(current_user.organization_id)
    model = DepartmentModel(
        id=str(uuid4()),
        organization_id=org_id,
        name=name,
        description=description,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Department.model_validate(model)


@router.put("/departments/{dept_id}")
async def update_department(
    dept_id: UUID,
    name: Optional[str] = None,
    description: Optional[str] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_team")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(DepartmentModel).where(
            DepartmentModel.id == str(dept_id),
            DepartmentModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Department not found")
    if name is not None:
        model.name = name
    if description is not None:
        model.description = description
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Department.model_validate(model)


@router.delete("/departments/{dept_id}")
async def delete_department(
    dept_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_team")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(DepartmentModel).where(
            DepartmentModel.id == str(dept_id),
            DepartmentModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Department not found")
    model.is_active = False
    session.add(model)
    await session.flush()
    return {"detail": "Department deactivated"}


@router.get("/assignments")
async def get_my_assignments(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
):
    org_id = str(current_user.organization_id)
    query = select(ConversationModel).where(
        ConversationModel.organization_id == org_id,
        ConversationModel.assigned_to == str(current_user.id),
        ConversationModel.is_archived == False,
    ).order_by(ConversationModel.last_message_at.desc().nullslast())
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    from ..domain.entities import Conversation
    return {
        "items": [Conversation.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.post("/bulk/assign")
async def bulk_assign_conversations(
    conversation_ids: list[UUID],
    assign_to: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_inbox")),
):
    org_id = str(current_user.organization_id)
    str_ids = [str(cid) for cid in conversation_ids]
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id.in_(str_ids),
            ConversationModel.organization_id == org_id,
        )
    )
    models = result.scalars().all()
    updated_count = 0
    for model in models:
        model.assigned_to = str(assign_to)
        model.updated_at = datetime.utcnow()
        session.add(model)
        updated_count += 1
    await session.flush()
    return {"updated": updated_count, "total_requested": len(conversation_ids)}


@router.post("/bulk/archive")
async def bulk_archive_conversations(
    conversation_ids: list[UUID],
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_inbox")),
):
    org_id = str(current_user.organization_id)
    str_ids = [str(cid) for cid in conversation_ids]
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id.in_(str_ids),
            ConversationModel.organization_id == org_id,
        )
    )
    models = result.scalars().all()
    updated_count = 0
    for model in models:
        model.is_archived = True
        model.updated_at = datetime.utcnow()
        session.add(model)
        updated_count += 1
    await session.flush()
    return {"archived": updated_count, "total_requested": len(conversation_ids)}


@router.post("/bulk/tags")
async def bulk_tag_conversations(
    conversation_ids: list[UUID],
    tags: list[str],
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_inbox")),
):
    org_id = str(current_user.organization_id)
    str_ids = [str(cid) for cid in conversation_ids]
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id.in_(str_ids),
            ConversationModel.organization_id == org_id,
        )
    )
    models = result.scalars().all()
    updated_count = 0
    for model in models:
        current_tags = set(model.tags or [])
        current_tags.update(tags)
        model.tags = list(current_tags)
        model.updated_at = datetime.utcnow()
        session.add(model)
        updated_count += 1
    await session.flush()
    return {"updated": updated_count, "total_requested": len(conversation_ids)}
