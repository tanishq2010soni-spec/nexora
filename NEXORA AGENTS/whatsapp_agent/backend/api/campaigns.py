from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Campaign, User
from ..domain.enums import CampaignStatus, CampaignType
from ..infrastructure.database import CampaignModel, get_session

router = APIRouter(prefix="/api/v1/campaigns", tags=["campaigns"])


@router.get("/")
async def list_campaigns(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    status: Optional[str] = Query(None),
    campaign_type: Optional[str] = Query(None, alias="type"),
):
    org_id = str(current_user.organization_id)
    query = select(CampaignModel).where(CampaignModel.organization_id == org_id)
    if status:
        query = query.where(CampaignModel.status == status)
    if campaign_type:
        query = query.where(CampaignModel.type == campaign_type)
    query = query.order_by(CampaignModel.updated_at.desc())
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [Campaign.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.post("/", status_code=201)
async def create_campaign(
    name: str,
    message_template: str,
    campaign_type: str = CampaignType.broadcast.value,
    target_filter: Optional[dict] = None,
    scheduled_at: Optional[datetime] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_campaigns")),
):
    org_id = str(current_user.organization_id)
    model = CampaignModel(
        id=str(uuid4()),
        organization_id=org_id,
        name=name,
        type=campaign_type,
        message_template=message_template,
        target_filter=target_filter or {},
        status=CampaignStatus.draft.value,
        scheduled_at=scheduled_at,
        created_by=str(current_user.id),
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Campaign.model_validate(model)


@router.get("/{campaign_id}")
async def get_campaign(
    campaign_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(CampaignModel).where(
            CampaignModel.id == str(campaign_id),
            CampaignModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Campaign not found")
    return Campaign.model_validate(model)


@router.put("/{campaign_id}")
async def update_campaign(
    campaign_id: UUID,
    name: Optional[str] = None,
    message_template: Optional[str] = None,
    target_filter: Optional[dict] = None,
    scheduled_at: Optional[datetime] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_campaigns")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(CampaignModel).where(
            CampaignModel.id == str(campaign_id),
            CampaignModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Campaign not found")
    if name is not None:
        model.name = name
    if message_template is not None:
        model.message_template = message_template
    if target_filter is not None:
        model.target_filter = target_filter
    if scheduled_at is not None:
        model.scheduled_at = scheduled_at
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Campaign.model_validate(model)


@router.delete("/{campaign_id}")
async def delete_campaign(
    campaign_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_campaigns")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(CampaignModel).where(
            CampaignModel.id == str(campaign_id),
            CampaignModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Campaign not found")
    await session.delete(model)
    await session.flush()
    return {"detail": "Campaign deleted"}


@router.post("/{campaign_id}/send")
async def start_campaign(
    campaign_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_campaigns")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(CampaignModel).where(
            CampaignModel.id == str(campaign_id),
            CampaignModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Campaign not found")
    if model.status not in (CampaignStatus.draft.value, CampaignStatus.scheduled.value):
        raise HTTPException(status_code=400, detail=f"Cannot send campaign with status {model.status}")
    model.status = CampaignStatus.sending.value
    model.sent_count = model.total_recipients or 0
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"status": model.status, "sent_count": model.sent_count}


@router.post("/{campaign_id}/pause")
async def pause_campaign(
    campaign_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_campaigns")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(CampaignModel).where(
            CampaignModel.id == str(campaign_id),
            CampaignModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Campaign not found")
    if model.status != CampaignStatus.sending.value:
        raise HTTPException(status_code=400, detail="Campaign is not currently sending")
    model.status = CampaignStatus.draft.value
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"status": model.status}


@router.get("/{campaign_id}/recipients")
async def get_campaign_recipients(
    campaign_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(CampaignModel).where(
            CampaignModel.id == str(campaign_id),
            CampaignModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Campaign not found")
    from ..infrastructure.database import CustomerModel
    query = select(CustomerModel).where(CustomerModel.organization_id == org_id)
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    customers_result = await session.execute(query.offset(offset).limit(limit))
    customers = customers_result.scalars().all()
    from ..domain.entities import Customer
    return {
        "items": [Customer.model_validate(c) for c in customers],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.post("/{campaign_id}/test")
async def test_campaign(
    campaign_id: UUID,
    test_phone: str,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_campaigns")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(CampaignModel).where(
            CampaignModel.id == str(campaign_id),
            CampaignModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Campaign not found")
    return {
        "test_message": model.message_template,
        "sent_to": test_phone,
        "status": "test_sent",
        "detail": "Test message would be sent via WhatsApp adapter",
    }
