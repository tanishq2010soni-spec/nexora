import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, update as sa_update
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import Notification
from src.presentation.api.dependencies import get_current_org_id, require_role

router = APIRouter()


class NotificationResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    user_id: Optional[str] = None
    title: str
    message: str
    notification_type: str
    category: str
    is_read: bool
    action_url: Optional[str] = None
    metadata_json: Optional[str] = None
    created_at: str


class CreateNotificationRequest(BaseModel):
    user_id: Optional[str] = None
    title: str = Field(..., min_length=1, max_length=255)
    message: str = Field(..., min_length=1, max_length=2000)
    notification_type: str = Field(..., pattern="^(in_app|email|whatsapp|push)$")
    category: str = Field(default="general", pattern="^(general|lead|conversation|task|system)$")
    action_url: Optional[str] = None
    metadata_json: Optional[str] = None


def _notif_to_response(n) -> NotificationResponse:
    return NotificationResponse(
        id=n.id, org_id=n.org_id, user_id=n.user_id, title=n.title,
        message=n.message, notification_type=n.notification_type, category=n.category,
        is_read=n.is_read, action_url=n.action_url, metadata_json=n.metadata_json,
        created_at=n.created_at.isoformat(),
    )


@router.get("/", response_model=List[NotificationResponse])
async def list_notifications(
    org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session),
    user_id: Optional[str] = Query(default=None),
    category: Optional[str] = Query(default=None),
    is_read: Optional[bool] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[NotificationResponse]:
    stmt = select(Notification).where(Notification.org_id == org_id)
    if user_id:
        stmt = stmt.where(Notification.user_id == user_id)
    if category:
        stmt = stmt.where(Notification.category == category)
    if is_read is not None:
        stmt = stmt.where(Notification.is_read == is_read)
    stmt = stmt.order_by(Notification.created_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_notif_to_response(n) for n in result.scalars().all()]


@router.get("/unread-count")
async def unread_count(
    org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session),
) -> dict:
    stmt = select(func.count()).select_from(Notification).where(
        Notification.org_id == org_id, Notification.is_read == False
    )
    result = await db.execute(stmt)
    count = result.scalar() or 0
    return {"unread_count": count}


@router.post("/", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED)
async def create_notification(
    data: CreateNotificationRequest, org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session), _=Depends(require_role("admin")),
) -> NotificationResponse:
    now = datetime.datetime.now(datetime.timezone.utc)
    notif = Notification(
        id=uuid.uuid4(), org_id=org_id, user_id=data.user_id, title=data.title,
        message=data.message, notification_type=data.notification_type, category=data.category,
        is_read=False, action_url=data.action_url, metadata_json=data.metadata_json,
        created_at=now,
    )
    db.add(notif)
    await db.commit()
    await db.refresh(notif)
    return _notif_to_response(notif)


@router.patch("/{notification_id}/read")
async def mark_read(
    notification_id: uuid.UUID, org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    stmt = select(Notification).where(Notification.id == notification_id, Notification.org_id == org_id)
    result = await db.execute(stmt)
    notif = result.scalar_one_or_none()
    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found.")
    notif.is_read = True
    await db.commit()
    return {"status": "ok"}


@router.patch("/read-all")
async def mark_all_read(
    org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session),
) -> dict:
    stmt = sa_update(Notification).where(Notification.org_id == org_id, Notification.is_read == False).values(is_read=True)
    await db.execute(stmt)
    await db.commit()
    return {"status": "ok"}
