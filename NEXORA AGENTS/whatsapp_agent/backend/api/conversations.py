from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select, update as sa_update
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Conversation, Message, User
from ..domain.enums import ConversationStatus, HandoffStatus, MessageDirection, MessageStatus
from ..infrastructure.database import (ConversationModel, MessageModel,
                                       get_session)

router = APIRouter(prefix="/api/v1/conversations", tags=["conversations"])


@router.get("/")
async def list_conversations(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    status: Optional[str] = Query(None),
    department_id: Optional[UUID] = Query(None),
    assigned_to: Optional[UUID] = Query(None),
    search: Optional[str] = Query(None),
    is_archived: Optional[bool] = Query(None),
):
    org_id = str(current_user.organization_id)
    query = select(ConversationModel).where(ConversationModel.organization_id == org_id)
    if status:
        query = query.where(ConversationModel.status == status)
    if department_id:
        query = query.where(ConversationModel.department_id == str(department_id))
    if assigned_to:
        query = query.where(ConversationModel.assigned_to == str(assigned_to))
    if search:
        query = query.where(
            ConversationModel.customer_name.ilike(f"%{search}%") |
            ConversationModel.customer_phone.ilike(f"%{search}%")
        )
    if is_archived is not None:
        query = query.where(ConversationModel.is_archived == is_archived)
    query = query.order_by(ConversationModel.last_message_at.desc().nullslast(), ConversationModel.created_at.desc())
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [Conversation.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.get("/{conversation_id}")
async def get_conversation(
    conversation_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Conversation not found")
    messages_result = await session.execute(
        select(MessageModel).where(MessageModel.conversation_id == str(conversation_id))
        .order_by(MessageModel.created_at.asc())
    )
    messages = messages_result.scalars().all()
    return {
        **Conversation.model_validate(model).model_dump(),
        "messages": [Message.model_validate(m) for m in messages],
    }


@router.patch("/{conversation_id}/status")
async def update_conversation_status(
    conversation_id: UUID,
    status: str,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_inbox")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Conversation not found")
    model.status = status
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return Conversation.model_validate(model)


@router.patch("/{conversation_id}/assign")
async def assign_conversation(
    conversation_id: UUID,
    user_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_inbox")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Conversation not found")
    model.assigned_to = str(user_id)
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return Conversation.model_validate(model)


@router.patch("/{conversation_id}/department")
async def assign_conversation_department(
    conversation_id: UUID,
    department_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_inbox")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Conversation not found")
    model.department_id = str(department_id)
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return Conversation.model_validate(model)


@router.patch("/{conversation_id}/pin")
async def toggle_conversation_pin(
    conversation_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Conversation not found")
    model.is_pinned = not model.is_pinned
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"is_pinned": model.is_pinned}


@router.patch("/{conversation_id}/archive")
async def toggle_conversation_archive(
    conversation_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Conversation not found")
    model.is_archived = not model.is_archived
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"is_archived": model.is_archived}


@router.post("/{conversation_id}/tags")
async def update_conversation_tags(
    conversation_id: UUID,
    tags: list[str],
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_inbox")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Conversation not found")
    model.tags = tags
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"tags": model.tags}


@router.post("/{conversation_id}/handoff/request")
async def request_handoff(
    conversation_id: UUID,
    note: Optional[str] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Conversation not found")
    model.handoff_status = HandoffStatus.requested.value
    model.handoff_requested_by = str(current_user.id)
    model.handoff_note = note
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"handoff_status": model.handoff_status, "handoff_requested_by": model.handoff_requested_by}


@router.post("/{conversation_id}/handoff/accept")
async def accept_handoff(
    conversation_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_inbox")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Conversation not found")
    if model.handoff_status != HandoffStatus.requested.value:
        raise HTTPException(status_code=400, detail="No pending handoff request")
    model.handoff_status = HandoffStatus.active.value
    model.handoff_assigned_to = current_user.id
    model.assigned_to = str(current_user.id)
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"handoff_status": model.handoff_status, "handoff_assigned_to": str(current_user.id)}


@router.post("/{conversation_id}/handoff/complete")
async def complete_handoff(
    conversation_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_inbox")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Conversation not found")
    if model.handoff_status != HandoffStatus.active.value:
        raise HTTPException(status_code=400, detail="No active handoff")
    model.handoff_status = HandoffStatus.completed.value
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"handoff_status": model.handoff_status}


@router.post("/{conversation_id}/ai/toggle")
async def toggle_conversation_ai(
    conversation_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_inbox")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Conversation not found")
    model.ai_active = not model.ai_active
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"ai_active": model.ai_active}


@router.get("/{conversation_id}/messages")
async def get_conversation_messages(
    conversation_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=200),
):
    org_id = str(current_user.organization_id)
    conv_result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    if not conv_result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Conversation not found")
    query = select(MessageModel).where(MessageModel.conversation_id == str(conversation_id))
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit).order_by(MessageModel.created_at.desc()))
    models = result.scalars().all()
    return {
        "items": [Message.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.post("/{conversation_id}/messages", status_code=201)
async def send_message(
    conversation_id: UUID,
    content: str,
    content_type: str = "text",
    from_phone: Optional[str] = None,
    to_phone: Optional[str] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    conv_result = await session.execute(
        select(ConversationModel).where(
            ConversationModel.id == str(conversation_id),
            ConversationModel.organization_id == org_id,
        )
    )
    conv = conv_result.scalar_one_or_none()
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")
    sender = from_phone or "agent"
    receiver = to_phone or conv.customer_phone
    msg = MessageModel(
        id=str(uuid4()),
        organization_id=org_id,
        conversation_id=str(conversation_id),
        direction=MessageDirection.outbound.value,
        from_phone=sender,
        to_phone=receiver,
        content=content,
        content_type=content_type,
        status=MessageStatus.sent.value,
        is_ai_generated=False,
    )
    session.add(msg)
    conv.message_count = (conv.message_count or 0) + 1
    conv.last_message_at = datetime.utcnow()
    conv.last_message_preview = content[:255]
    conv.updated_at = datetime.utcnow()
    session.add(conv)
    await session.flush()
    await session.refresh(msg)
    return Message.model_validate(msg)
