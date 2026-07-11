from datetime import datetime
from typing import Optional
from urllib.parse import urlparse
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import User, WhatsAppAccount
from ..domain.enums import WhatsAppAccountStatus
from ..infrastructure.database import WhatsAppAccountModel, get_session

router = APIRouter(prefix="/api/v1/whatsapp", tags=["whatsapp"])

_ALLOWED_WEBHOOK_HOSTS = frozenset({"localhost", "127.0.0.1", "::1"})
_PHONE_PATTERN = __import__("re").compile(r"^\+?[1-9]\d{6,14}$")


def _validate_phone_number(phone: str) -> None:
    if not _PHONE_PATTERN.match(phone):
        raise HTTPException(status_code=400, detail="Invalid phone number format. Use E.164 format (e.g. +1234567890)")


def _validate_webhook_url(url: str) -> None:
    parsed = urlparse(url)
    if parsed.scheme not in ("https", "http"):
        raise HTTPException(status_code=400, detail="Webhook URL must use http or https")
    if parsed.scheme == "http" and parsed.hostname not in _ALLOWED_WEBHOOK_HOSTS:
        raise HTTPException(
            status_code=400,
            detail="HTTP webhook URLs are only allowed for localhost. Use HTTPS for remote URLs.",
        )


@router.get("/accounts")
async def list_whatsapp_accounts(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    status: Optional[str] = Query(None),
):
    org_id = str(current_user.organization_id)
    query = select(WhatsAppAccountModel).where(WhatsAppAccountModel.organization_id == org_id)
    if status:
        query = query.where(WhatsAppAccountModel.status == status)
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [WhatsAppAccount.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.post("/accounts", status_code=201)
async def create_whatsapp_account(
    phone_number: str,
    business_name: str = "",
    webhook_url: Optional[str] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_whatsapp")),
):
    org_id = str(current_user.organization_id)
    count_result = await session.execute(
        select(func.count()).select_from(WhatsAppAccountModel).where(
            WhatsAppAccountModel.organization_id == org_id,
            WhatsAppAccountModel.is_active == True,
        )
    )
    if count_result.scalar() >= 5:
        raise HTTPException(status_code=400, detail="Maximum WhatsApp accounts reached")
    _validate_phone_number(phone_number)
    if webhook_url:
        _validate_webhook_url(webhook_url)
    model = WhatsAppAccountModel(
        id=str(uuid4()),
        organization_id=org_id,
        phone_number=phone_number,
        business_name=business_name,
        webhook_url=webhook_url,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return WhatsAppAccount.model_validate(model)


@router.get("/accounts/{account_id}")
async def get_whatsapp_account(
    account_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    result = await session.execute(
        select(WhatsAppAccountModel).where(
            WhatsAppAccountModel.id == str(account_id),
            WhatsAppAccountModel.organization_id == str(current_user.organization_id),
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="WhatsApp account not found")
    return WhatsAppAccount.model_validate(model)


@router.put("/accounts/{account_id}")
async def update_whatsapp_account(
    account_id: UUID,
    phone_number: Optional[str] = None,
    business_name: Optional[str] = None,
    webhook_url: Optional[str] = None,
    rate_limit_per_minute: Optional[int] = None,
    daily_message_limit: Optional[int] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_whatsapp")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WhatsAppAccountModel).where(
            WhatsAppAccountModel.id == str(account_id),
            WhatsAppAccountModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="WhatsApp account not found")
    if phone_number is not None:
        model.phone_number = phone_number
    if business_name is not None:
        model.business_name = business_name
    if webhook_url is not None:
        _validate_webhook_url(webhook_url)
        model.webhook_url = webhook_url
    if rate_limit_per_minute is not None:
        model.rate_limit_per_minute = rate_limit_per_minute
    if daily_message_limit is not None:
        model.daily_message_limit = daily_message_limit
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return WhatsAppAccount.model_validate(model)


@router.delete("/accounts/{account_id}")
async def delete_whatsapp_account(
    account_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_whatsapp")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WhatsAppAccountModel).where(
            WhatsAppAccountModel.id == str(account_id),
            WhatsAppAccountModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="WhatsApp account not found")
    model.is_active = False
    model.status = WhatsAppAccountStatus.disconnected.value
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"detail": "WhatsApp account removed"}


@router.post("/accounts/{account_id}/connect")
async def connect_whatsapp_account(
    account_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_whatsapp")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WhatsAppAccountModel).where(
            WhatsAppAccountModel.id == str(account_id),
            WhatsAppAccountModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="WhatsApp account not found")
    import uuid
    model.status = WhatsAppAccountStatus.connecting.value
    model.qr_code = f"whatsapp-qr-{uuid.uuid4().hex[:16]}"
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return {"qr_code": model.qr_code, "status": model.status}


@router.post("/accounts/{account_id}/disconnect")
async def disconnect_whatsapp_account(
    account_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_whatsapp")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WhatsAppAccountModel).where(
            WhatsAppAccountModel.id == str(account_id),
            WhatsAppAccountModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="WhatsApp account not found")
    model.status = WhatsAppAccountStatus.disconnected.value
    model.qr_code = None
    model.qr_expires_at = None
    model.session_data = None
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"detail": "WhatsApp account disconnected", "status": model.status}


@router.get("/accounts/{account_id}/qr")
async def get_whatsapp_qr(
    account_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WhatsAppAccountModel).where(
            WhatsAppAccountModel.id == str(account_id),
            WhatsAppAccountModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="WhatsApp account not found")
    if not model.qr_code:
        raise HTTPException(status_code=400, detail="No QR code available. Initiate connection first.")
    return {"qr_code": model.qr_code, "expires_at": model.qr_expires_at}


@router.get("/accounts/{account_id}/health")
async def whatsapp_account_health(
    account_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WhatsAppAccountModel).where(
            WhatsAppAccountModel.id == str(account_id),
            WhatsAppAccountModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="WhatsApp account not found")
    return {
        "id": account_id,
        "status": model.status,
        "health_status": model.health_status,
        "last_health_check": model.last_health_check,
        "error_message": model.error_message,
        "is_active": model.is_active,
    }


@router.post("/accounts/{account_id}/webhook")
async def set_whatsapp_webhook(
    account_id: UUID,
    webhook_url: str,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_whatsapp")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WhatsAppAccountModel).where(
            WhatsAppAccountModel.id == str(account_id),
            WhatsAppAccountModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="WhatsApp account not found")
    _validate_webhook_url(webhook_url)
    model.webhook_url = webhook_url
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"detail": "Webhook URL updated", "webhook_url": model.webhook_url}
