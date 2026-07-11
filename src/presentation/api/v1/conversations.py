import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import select, func, case, literal_column
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import ChatSession, Agent, Message
from src.presentation.api.dependencies import get_current_org_id

router = APIRouter()


class ConversationResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    external_user_id: str
    agent_id: uuid.UUID
    agent_name: str
    platform: str
    status: str
    message_count: int = 0
    last_message_preview: Optional[str] = None
    last_message_at: Optional[str] = None
    created_at: str
    updated_at: str


class MessageResponse(BaseModel):
    id: uuid.UUID
    session_id: uuid.UUID
    role: str
    content: str
    token_count: int = 0
    created_at: Optional[str] = None


@router.get("/", response_model=List[ConversationResponse])
async def list_conversations(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    platform: Optional[str] = Query(default=None),
    status_filter: Optional[str] = Query(default=None, alias="status"),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[ConversationResponse]:
    """List all conversations (chat sessions) for the organization."""
    stmt = (
        select(ChatSession, Agent)
        .join(Agent, ChatSession.agent_id == Agent.id)
        .where(Agent.org_id == org_id)
        .order_by(ChatSession.created_at.desc())
        .limit(limit)
        .offset(offset)
    )

    if status_filter:
        stmt = stmt.where(ChatSession.status == status_filter)

    if platform:
        stmt = stmt.where(Agent.platform_type == platform)

    msg_count_subq = (
        select(
            Message.session_id,
            func.count().label("message_count"),
        )
        .group_by(Message.session_id)
        .subquery()
    )

    last_msg_subq = (
        select(
            Message.session_id,
            Message.content.label("last_content"),
            Message.created_at.label("last_created_at"),
        )
        .where(
            Message.id.in_(
                select(func.max(Message.id)).group_by(Message.session_id)
            )
        )
        .subquery()
    )

    full_stmt = (
        select(
            ChatSession,
            Agent,
            func.coalesce(msg_count_subq.c.message_count, 0).label("message_count"),
            last_msg_subq.c.last_content,
            last_msg_subq.c.last_created_at,
        )
        .join(Agent, ChatSession.agent_id == Agent.id)
        .outerjoin(msg_count_subq, ChatSession.id == msg_count_subq.c.session_id)
        .outerjoin(last_msg_subq, ChatSession.id == last_msg_subq.c.session_id)
        .where(Agent.org_id == org_id)
        .order_by(ChatSession.created_at.desc())
        .limit(limit)
        .offset(offset)
    )

    if status_filter:
        full_stmt = full_stmt.where(ChatSession.status == status_filter)

    if platform:
        full_stmt = full_stmt.where(Agent.platform_type == platform)

    result = await db.execute(full_stmt)
    rows = result.all()

    responses = []
    for session, agent, message_count, last_content, last_created_at in rows:
        responses.append(ConversationResponse(
            id=session.id,
            org_id=agent.org_id,
            external_user_id=session.external_user_id,
            agent_id=session.agent_id,
            agent_name=agent.name,
            platform=agent.platform_type,
            status=session.status,
            message_count=message_count,
            last_message_preview=last_content[:100] if last_content else None,
            last_message_at=last_created_at.isoformat() if last_created_at else None,
            created_at=session.created_at.isoformat(),
            updated_at=session.updated_at.isoformat(),
        ))

    return responses


@router.get("/{session_id}", response_model=ConversationResponse)
async def get_conversation(
    session_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> ConversationResponse:
    """Get a conversation by ID."""
    stmt = select(ChatSession).join(Agent).where(
        ChatSession.id == session_id,
        Agent.org_id == org_id,
    )
    result = await db.execute(stmt)
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Conversation not found.")

    agent_stmt = select(Agent).where(Agent.id == session.agent_id)
    agent_result = await db.execute(agent_stmt)
    agent = agent_result.scalar_one_or_none()

    msg_count_stmt = select(func.count()).select_from(Message).where(Message.session_id == session.id)
    msg_count_result = await db.execute(msg_count_stmt)
    message_count = msg_count_result.scalar_one() or 0

    last_msg_stmt = (
        select(Message)
        .where(Message.session_id == session.id)
        .order_by(Message.created_at.desc())
        .limit(1)
    )
    last_msg_result = await db.execute(last_msg_stmt)
    last_msg = last_msg_result.scalar_one_or_none()

    return ConversationResponse(
        id=session.id,
        org_id=agent.org_id if agent else org_id,
        external_user_id=session.external_user_id,
        agent_id=session.agent_id,
        agent_name=agent.name if agent else "Unknown",
        platform=agent.platform_type if agent else "unknown",
        status=session.status,
        message_count=message_count,
        last_message_preview=last_msg.content[:100] if last_msg else None,
        last_message_at=last_msg.created_at.isoformat() if last_msg and last_msg.created_at else None,
        created_at=session.created_at.isoformat(),
        updated_at=session.updated_at.isoformat(),
    )


@router.get("/{session_id}/messages", response_model=List[MessageResponse])
async def get_messages(
    session_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[MessageResponse]:
    """Get messages for a conversation."""
    # Verify session ownership
    session_stmt = (
        select(ChatSession)
        .join(Agent, ChatSession.agent_id == Agent.id)
        .where(ChatSession.id == session_id, Agent.org_id == org_id)
    )
    session_result = await db.execute(session_stmt)
    session = session_result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Conversation not found.")

    msg_stmt = (
        select(Message)
        .where(Message.session_id == session_id)
        .order_by(Message.created_at.asc())
        .limit(limit)
        .offset(offset)
    )
    msg_result = await db.execute(msg_stmt)
    messages = msg_result.scalars().all()

    return [
        MessageResponse(
            id=m.id,
            session_id=m.session_id,
            role=m.role,
            content=m.content,
            token_count=m.token_count,
            created_at=m.created_at.isoformat() if m.created_at else None,
        )
        for m in messages
    ]
