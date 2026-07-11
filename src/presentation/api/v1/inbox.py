import uuid
import datetime
import csv
import io
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status, BackgroundTasks
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete, or_, update
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import InboxConversation, InboxMessage, Customer
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService
from src.infrastructure.realtime.connection_manager import manager

router = APIRouter()


class InboxConversationResponse(BaseModel):
    id: uuid.UUID
    customer_id: Optional[uuid.UUID] = None
    channel: str
    platform_user_id: str
    customer_name: Optional[str] = None
    customer_phone: Optional[str] = None
    customer_email: Optional[str] = None
    last_message: Optional[str] = None
    unread_count: int = 0
    status: str = "open"
    assigned_to: Optional[str] = None
    assigned_to_name: Optional[str] = None
    takeover_mode: str = "ai"
    message_count: int = 0
    created_at: str
    updated_at: str


class InboxMessageResponse(BaseModel):
    id: uuid.UUID
    conversation_id: uuid.UUID
    sender_type: str
    content: str
    channel: str
    attachment_url: Optional[str] = None
    attachment_type: Optional[str] = None
    is_read: bool = False
    platform_message_id: Optional[str] = None
    created_at: str


class SendMessageRequest(BaseModel):
    conversation_id: uuid.UUID
    content: str = Field(..., min_length=1, max_length=4096)
    sender_type: str = Field(default="agent", pattern="^(user|bot|agent|system)$")
    attachment_url: Optional[str] = None
    attachment_type: Optional[str] = None


class UpdateConversationRequest(BaseModel):
    status: Optional[str] = Field(None, pattern="^(open|closed|pending)$")
    assigned_to: Optional[str] = None
    assigned_to_name: Optional[str] = None
    takeover_mode: Optional[str] = Field(None, pattern="^(ai|human)$")


class MarkReadRequest(BaseModel):
    conversation_id: uuid.UUID


class TypingIndicatorRequest(BaseModel):
    conversation_id: uuid.UUID
    is_typing: bool


class WebhookMessageRequest(BaseModel):
    channel: str = Field(..., pattern="^(whatsapp|instagram|facebook|website)$")
    org_id: uuid.UUID = Field(..., description="Organization ID for tenant routing")
    platform_user_id: str = Field(..., max_length=255)
    customer_name: Optional[str] = Field(None, max_length=255)
    customer_phone: Optional[str] = Field(None, max_length=50)
    customer_email: Optional[str] = Field(None, max_length=255)
    content: str = Field(..., max_length=10000)
    platform_message_id: Optional[str] = Field(None, max_length=255)
    attachment_url: Optional[str] = Field(None, max_length=2048)
    attachment_type: Optional[str] = Field(None, max_length=50)
    signature: Optional[str] = Field(None, description="Webhook signature for verification")

    def model_post_init(self, __context: Any) -> None:
        """Sanitize string inputs to prevent stored XSS."""
        import re
        if self.customer_name:
            self.customer_name = re.sub(r'<[^>]+>', '', self.customer_name).strip()[:255]
        if self.content:
            self.content = re.sub(r'<script[^>]*>.*?</script>', '', self.content, flags=re.IGNORECASE | re.DOTALL)


class CustomerSidePanelResponse(BaseModel):
    customer_id: Optional[uuid.UUID] = None
    name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    segment: Optional[str] = None
    preferences: Optional[str] = None
    notes: Optional[str] = None
    total_conversations: int = 0
    total_spent: float = 0.0
    last_order_date: Optional[str] = None
    tags: List[str] = []


class ConversationDetailResponse(InboxConversationResponse):
    messages: List[InboxMessageResponse] = []
    customer_panel: Optional[CustomerSidePanelResponse] = None


def _conv_to_response(c) -> InboxConversationResponse:
    return InboxConversationResponse(
        id=c.id,
        customer_id=c.customer_id,
        channel=c.channel,
        platform_user_id=c.platform_user_id,
        customer_name=c.customer_name,
        customer_phone=c.customer_phone,
        customer_email=c.customer_email,
        last_message=c.last_message,
        unread_count=c.unread_count,
        status=c.status or "open",
        assigned_to=c.assigned_to,
        assigned_to_name=c.assigned_to_name,
        takeover_mode=c.takeover_mode or "ai",
        message_count=len(c.messages) if hasattr(c, 'messages') and c.messages else 0,
        created_at=c.created_at.isoformat(),
        updated_at=c.updated_at.isoformat(),
    )


def _msg_to_response(m) -> InboxMessageResponse:
    return InboxMessageResponse(
        id=m.id,
        conversation_id=m.conversation_id,
        sender_type=m.sender_type,
        content=m.content,
        channel=m.channel,
        attachment_url=m.attachment_url,
        attachment_type=m.attachment_type,
        is_read=m.is_read,
        platform_message_id=m.platform_message_id,
        created_at=m.created_at.isoformat(),
    )


@router.get("/conversations", response_model=List[InboxConversationResponse])
async def list_conversations(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    channel: Optional[str] = Query(default=None),
    status_filter: Optional[str] = Query(default=None, alias="status"),
    assigned_to: Optional[str] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[InboxConversationResponse]:
    stmt = select(InboxConversation).where(InboxConversation.org_id == org_id)
    if channel:
        stmt = stmt.where(InboxConversation.channel == channel)
    if status_filter:
        stmt = stmt.where(InboxConversation.status == status_filter)
    if assigned_to:
        stmt = stmt.where(InboxConversation.assigned_to == assigned_to)
    stmt = stmt.order_by(InboxConversation.updated_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    convs = result.scalars().all()
    return [_conv_to_response(c) for c in convs]


@router.get("/conversations/{conv_id}", response_model=InboxConversationResponse)
async def get_conversation(
    conv_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> InboxConversationResponse:
    stmt = select(InboxConversation).where(
        InboxConversation.id == conv_id, InboxConversation.org_id == org_id
    )
    result = await db.execute(stmt)
    conv = result.scalar_one_or_none()
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found.")
    return _conv_to_response(conv)


@router.get("/conversations/{conv_id}/messages", response_model=List[InboxMessageResponse])
async def get_messages(
    conv_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=100, ge=1, le=500),
    offset: int = Query(default=0, ge=0),
) -> List[InboxMessageResponse]:
    conv_stmt = select(InboxConversation).where(
        InboxConversation.id == conv_id, InboxConversation.org_id == org_id
    )
    conv_result = await db.execute(conv_stmt)
    if not conv_result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Conversation not found.")

    stmt = (
        select(InboxMessage)
        .where(InboxMessage.conversation_id == conv_id)
        .order_by(InboxMessage.created_at.asc())
        .limit(limit)
        .offset(offset)
    )
    result = await db.execute(stmt)
    return [_msg_to_response(m) for m in result.scalars().all()]


@router.post("/messages", response_model=InboxMessageResponse, status_code=status.HTTP_201_CREATED)
async def send_message(
    data: SendMessageRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> InboxMessageResponse:
    conv_stmt = select(InboxConversation).where(
        InboxConversation.id == data.conversation_id, InboxConversation.org_id == org_id
    )
    conv_result = await db.execute(conv_stmt)
    conv = conv_result.scalar_one_or_none()
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found.")

    now = datetime.datetime.now(datetime.timezone.utc)
    msg = InboxMessage(
        id=uuid.uuid4(),
        conversation_id=data.conversation_id,
        sender_type=data.sender_type,
        content=data.content,
        channel=conv.channel,
        attachment_url=data.attachment_url,
        attachment_type=data.attachment_type,
        is_read=False,
        created_at=now,
    )
    db.add(msg)

    conv.last_message = data.content[:200]
    conv.updated_at = now
    conv.unread_count = 0

    await db.flush()
    await AuditService.log(
        db=db, action="send_message", resource="inbox",
        org_id=org_id, resource_id=str(data.conversation_id),
        detail=f"Message sent via {conv.channel}",
    )
    await db.commit()
    await db.refresh(msg)

    import asyncio
    asyncio.create_task(manager.broadcast_new_message(
        data.conversation_id,
        {
            "id": str(msg.id),
            "conversation_id": str(data.conversation_id),
            "sender_type": data.sender_type,
            "content": data.content,
            "channel": conv.channel,
            "created_at": msg.created_at.isoformat(),
        },
    ))

    return _msg_to_response(msg)


@router.patch("/conversations/{conv_id}", response_model=InboxConversationResponse)
async def update_conversation(
    conv_id: uuid.UUID,
    data: UpdateConversationRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> InboxConversationResponse:
    stmt = select(InboxConversation).where(
        InboxConversation.id == conv_id, InboxConversation.org_id == org_id
    )
    result = await db.execute(stmt)
    conv = result.scalar_one_or_none()
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found.")

    if data.status is not None:
        conv.status = data.status
    if data.assigned_to is not None:
        conv.assigned_to = data.assigned_to
    if data.assigned_to_name is not None:
        conv.assigned_to_name = data.assigned_to_name
    if data.takeover_mode is not None:
        conv.takeover_mode = data.takeover_mode
    conv.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(conv)
    return _conv_to_response(conv)


@router.patch("/conversations/{conv_id}/takeover", response_model=InboxConversationResponse)
async def toggle_takeover(
    conv_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> InboxConversationResponse:
    stmt = select(InboxConversation).where(
        InboxConversation.id == conv_id, InboxConversation.org_id == org_id
    )
    result = await db.execute(stmt)
    conv = result.scalar_one_or_none()
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found.")

    conv.takeover_mode = "human" if conv.takeover_mode == "ai" else "ai"
    conv.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await AuditService.log(
        db=db, action="takeover", resource="inbox",
        org_id=org_id, resource_id=str(conv_id),
        detail=f"Takeover mode changed to {conv.takeover_mode}",
    )
    await db.commit()
    await db.refresh(conv)
    return _conv_to_response(conv)


@router.get("/search", response_model=List[InboxConversationResponse])
async def search_conversations(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    q: str = Query(..., min_length=1, max_length=255),
    limit: int = Query(default=20, ge=1, le=100),
) -> List[InboxConversationResponse]:
    pattern = f"%{q}%"
    stmt = (
        select(InboxConversation)
        .where(
            InboxConversation.org_id == org_id,
            or_(
                InboxConversation.customer_name.ilike(pattern),
                InboxConversation.customer_phone.ilike(pattern),
                InboxConversation.customer_email.ilike(pattern),
                InboxConversation.platform_user_id.ilike(pattern),
                InboxConversation.last_message.ilike(pattern),
            ),
        )
        .limit(limit)
    )
    result = await db.execute(stmt)
    return [_conv_to_response(c) for c in result.scalars().all()]


@router.get("/analytics")
async def inbox_analytics(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    now = datetime.datetime.now(datetime.timezone.utc)
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)

    conv_stmt = select(InboxConversation).where(InboxConversation.org_id == org_id)
    conv_result = await db.execute(conv_stmt)
    conversations = conv_result.scalars().all()

    total_convs = len(conversations)
    open_convs = sum(1 for c in conversations if c.status == "open")
    closed_convs = sum(1 for c in conversations if c.status == "closed")
    ai_mode = sum(1 for c in conversations if c.takeover_mode == "ai")
    human_mode = sum(1 for c in conversations if c.takeover_mode == "human")

    channel_breakdown = {}
    for c in conversations:
        ch = c.channel or "unknown"
        channel_breakdown[ch] = channel_breakdown.get(ch, 0) + 1

    msgs_stmt = (
        select(func.count())
        .select_from(InboxMessage)
        .join(InboxConversation, InboxMessage.conversation_id == InboxConversation.id)
        .where(
            InboxConversation.org_id == org_id,
            InboxMessage.created_at >= today_start,
        )
    )
    msgs_result = await db.execute(msgs_stmt)
    messages_today = msgs_result.scalar() or 0

    return {
        "total_conversations": total_convs,
        "open_conversations": open_convs,
        "closed_conversations": closed_convs,
        "ai_mode": ai_mode,
        "human_mode": human_mode,
        "messages_today": messages_today,
        "channel_breakdown": channel_breakdown,
        "ai_resolution_rate": round(ai_mode / total_convs * 100, 1) if total_convs else 0.0,
        "human_resolution_rate": round(human_mode / total_convs * 100, 1) if total_convs else 0.0,
    }


@router.get("/export/csv")
async def export_inbox_csv(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> StreamingResponse:
    stmt = (
        select(InboxConversation)
        .where(InboxConversation.org_id == org_id)
        .order_by(InboxConversation.updated_at.desc())
    )
    result = await db.execute(stmt)
    convs = result.scalars().all()

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow([
        "id", "channel", "customer_name", "customer_phone", "customer_email",
        "status", "assigned_to", "takeover_mode", "unread_count",
        "last_message", "created_at", "updated_at",
    ])
    for c in convs:
        writer.writerow([
            str(c.id), c.channel, c.customer_name or "", c.customer_phone or "",
            c.customer_email or "", c.status or "open", c.assigned_to or "",
            c.takeover_mode or "ai", c.unread_count,
            (c.last_message or "")[:100], c.created_at.isoformat(),
            c.updated_at.isoformat(),
        ])
    output.seek(0)
    return StreamingResponse(
        iter([output.getvalue()]),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=inbox_conversations.csv"},
    )


@router.get("/conversations/{conv_id}/detail", response_model=ConversationDetailResponse)
async def get_conversation_detail(
    conv_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> ConversationDetailResponse:
    stmt = select(InboxConversation).where(
        InboxConversation.id == conv_id, InboxConversation.org_id == org_id
    )
    result = await db.execute(stmt)
    conv = result.scalar_one_or_none()
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found.")

    msg_stmt = (
        select(InboxMessage)
        .where(InboxMessage.conversation_id == conv_id)
        .order_by(InboxMessage.created_at.asc())
        .limit(200)
    )
    msg_result = await db.execute(msg_stmt)
    messages = [_msg_to_response(m) for m in msg_result.scalars().all()]

    customer_panel = None
    if conv.customer_id:
        cust_stmt = select(Customer).where(Customer.id == conv.customer_id)
        cust_result = await db.execute(cust_stmt)
        customer = cust_result.scalar_one_or_none()
        if customer:
            conv_count_stmt = select(func.count()).select_from(InboxConversation).where(
                InboxConversation.customer_id == customer.id
            )
            conv_count_result = await db.execute(conv_count_stmt)
            total_convs = conv_count_result.scalar() or 0

            customer_panel = CustomerSidePanelResponse(
                customer_id=customer.id,
                name=customer.name,
                phone=customer.phone,
                email=None,
                segment=customer.segment,
                preferences=customer.preferences,
                notes=customer.notes,
                total_conversations=total_convs,
                total_spent=0.0,
                last_order_date=None,
                tags=[customer.segment] if customer.segment else [],
            )
    elif conv.customer_name or conv.customer_phone:
        customer_panel = CustomerSidePanelResponse(
            name=conv.customer_name,
            phone=conv.customer_phone,
            email=conv.customer_email,
        )

    resp = ConversationDetailResponse(
        id=conv.id,
        customer_id=conv.customer_id,
        channel=conv.channel,
        platform_user_id=conv.platform_user_id,
        customer_name=conv.customer_name,
        customer_phone=conv.customer_phone,
        customer_email=conv.customer_email,
        last_message=conv.last_message,
        unread_count=conv.unread_count,
        status=conv.status or "open",
        assigned_to=conv.assigned_to,
        assigned_to_name=conv.assigned_to_name,
        takeover_mode=conv.takeover_mode or "ai",
        message_count=len(messages),
        created_at=conv.created_at.isoformat(),
        updated_at=conv.updated_at.isoformat(),
        messages=messages,
        customer_panel=customer_panel,
    )
    return resp


@router.post("/mark-read", status_code=status.HTTP_200_OK)
async def mark_conversation_read(
    data: MarkReadRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> dict:
    conv_stmt = select(InboxConversation).where(
        InboxConversation.id == data.conversation_id, InboxConversation.org_id == org_id
    )
    conv_result = await db.execute(conv_stmt)
    conv = conv_result.scalar_one_or_none()
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found.")

    stmt = (
        update(InboxMessage)
        .where(
            InboxMessage.conversation_id == data.conversation_id,
            InboxMessage.is_read == False,
            InboxMessage.sender_type != "agent",
        )
        .values(is_read=True)
    )
    await db.execute(stmt)
    conv.unread_count = 0
    await db.commit()
    return {"status": "ok"}


@router.post("/typing", status_code=status.HTTP_200_OK)
async def send_typing_indicator(
    data: TypingIndicatorRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    _=Depends(require_role("admin", "member")),
) -> dict:
    await manager.broadcast_typing_indicator(
        data.conversation_id, str(org_id), "agent", data.is_typing
    )
    return {"status": "ok"}


@router.post("/webhook", status_code=status.HTTP_201_CREATED)
async def receive_webhook_message(
    data: WebhookMessageRequest,
    request: Request,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    """Receive incoming webhook messages. Uses org_id from payload for tenant routing."""
    from src.infrastructure.integrations.meta_service import MetaOmnichannelService, MetaWebhookVerifier
    from src.config import settings

    if data.signature and settings.META_APP_SECRET:
        verifier = MetaWebhookVerifier(settings.META_APP_SECRET)
        body = await request.body()
        if not verifier.verify_signature(payload=body.decode("utf-8"), signature=data.signature):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid webhook signature")

    service = MetaOmnichannelService(db)
    result = await service.process_webhook_message(
        channel=data.channel,
        platform_user_id=data.platform_user_id,
        message_content=data.content,
        org_id=data.org_id,
        platform_message_id=data.platform_message_id,
        customer_name=data.customer_name,
        customer_phone=data.customer_phone,
        customer_email=data.customer_email,
        attachment_url=data.attachment_url,
        attachment_type=data.attachment_type,
    )
    await db.commit()
    return result


@router.delete("/conversations/{conv_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_conversation(
    conv_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    stmt = select(InboxConversation).where(
        InboxConversation.id == conv_id, InboxConversation.org_id == org_id
    )
    result = await db.execute(stmt)
    conv = result.scalar_one_or_none()
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found.")

    msg_del = sa_delete(InboxMessage).where(InboxMessage.conversation_id == conv_id)
    await db.execute(msg_del)
    conv_del = sa_delete(InboxConversation).where(InboxConversation.id == conv_id)
    await db.execute(conv_del)

    await AuditService.log(
        db=db, action="delete", resource="inbox",
        org_id=org_id, resource_id=str(conv_id),
        detail=f"Deleted conversation: {conv.customer_name or conv.platform_user_id}",
    )
    await db.commit()
