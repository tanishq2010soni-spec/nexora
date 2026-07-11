from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Campaign, Lead
from ..domain.enums import CampaignStatus, CampaignType
from ..infrastructure.database import CampaignModel, LeadModel, get_session

router = APIRouter(prefix="/api/v1/campaigns", tags=["campaigns"])


class CampaignListResponse(BaseModel):
    items: list[Campaign]
    total: int
    page: int
    limit: int
    pages: int


class CreateCampaignRequest(BaseModel):
    name: str
    type: str
    script_id: Optional[UUID] = None
    phone_provider_id: Optional[UUID] = None
    caller_id: Optional[str] = None
    target_filter: dict[str, Any] = {}
    schedule: dict[str, Any] = {}
    max_calls_per_day: int = 100
    max_attempts: int = 3
    retry_delay_minutes: int = 60
    call_window_start: str = "09:00"
    call_window_end: str = "18:00"
    working_days: list[int] = [0, 1, 2, 3, 4, 5, 6]
    timezone: str = "UTC"


class UpdateCampaignRequest(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    script_id: Optional[UUID] = None
    phone_provider_id: Optional[UUID] = None
    caller_id: Optional[str] = None
    target_filter: Optional[dict[str, Any]] = None
    schedule: Optional[dict[str, Any]] = None
    max_calls_per_day: Optional[int] = None
    max_attempts: Optional[int] = None
    retry_delay_minutes: Optional[int] = None
    call_window_start: Optional[str] = None
    call_window_end: Optional[str] = None
    working_days: Optional[list[int]] = None
    timezone: Optional[str] = None


class AddLeadsRequest(BaseModel):
    lead_ids: list[UUID]


class CampaignStatsResponse(BaseModel):
    total_calls: int
    total_answered: int
    total_converted: int
    total_cost: float
    answer_rate: float
    conversion_rate: float
    leads_count: int
    active_leads: int


@router.get("", response_model=CampaignListResponse)
async def list_campaigns(
    status: Optional[str] = Query(None),
    type: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=200),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_campaigns")),
):
    query = select(CampaignModel).where(CampaignModel.organization_id == str(current_user.organization_id))

    if status:
        query = query.where(CampaignModel.status == status)
    if type:
        query = query.where(CampaignModel.type == type)
    if search:
        query = query.where(CampaignModel.name.ilike(f"%{search}%"))

    count_query = select(func.count()).select_from(query.subquery())
    total = (await session.execute(count_query)).scalar() or 0
    pages = max(1, (total + limit - 1) // limit)
    offset = (page - 1) * limit

    query = query.order_by(desc(CampaignModel.created_at)).offset(offset).limit(limit)
    result = await session.execute(query)
    models = result.scalars().all()

    return CampaignListResponse(
        items=[Campaign.model_validate(m) for m in models],
        total=total, page=page, limit=limit, pages=pages,
    )


@router.post("", response_model=Campaign)
async def create_campaign(
    req: CreateCampaignRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_campaigns")),
):
    valid_types = [t.value for t in CampaignType]
    if req.type not in valid_types:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=f"Invalid type. Valid: {valid_types}")

    model = CampaignModel(
        organization_id=str(current_user.organization_id),
        name=req.name,
        type=req.type,
        script_id=str(req.script_id) if req.script_id else None,
        phone_provider_id=str(req.phone_provider_id) if req.phone_provider_id else None,
        caller_id=req.caller_id,
        target_filter=req.target_filter,
        schedule=req.schedule,
        max_calls_per_day=req.max_calls_per_day,
        max_attempts=req.max_attempts,
        retry_delay_minutes=req.retry_delay_minutes,
        call_window_start=req.call_window_start,
        call_window_end=req.call_window_end,
        working_days=req.working_days,
        timezone=req.timezone,
        created_by=str(current_user.id),
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Campaign.model_validate(model)


@router.get("/{campaign_id}", response_model=Campaign)
async def get_campaign(
    campaign_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(CampaignModel).where(CampaignModel.id == str(campaign_id))
        .where(CampaignModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Campaign not found")
    return Campaign.model_validate(model)


@router.put("/{campaign_id}", response_model=Campaign)
async def update_campaign(
    campaign_id: UUID,
    req: UpdateCampaignRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_campaigns")),
):
    result = await session.execute(
        select(CampaignModel).where(CampaignModel.id == str(campaign_id))
        .where(CampaignModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Campaign not found")

    update_data = req.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if field == "script_id" and value is not None:
            setattr(model, field, str(value))
        elif field == "phone_provider_id" and value is not None:
            setattr(model, field, str(value))
        elif value is not None:
            setattr(model, field, value)

    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Campaign.model_validate(model)


@router.delete("/{campaign_id}")
async def delete_campaign(
    campaign_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_campaigns")),
):
    result = await session.execute(
        select(CampaignModel).where(CampaignModel.id == str(campaign_id))
        .where(CampaignModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Campaign not found")

    await session.delete(model)
    return {"deleted": True}


@router.post("/{campaign_id}/activate", response_model=Campaign)
async def activate_campaign(
    campaign_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_campaigns")),
):
    result = await session.execute(
        select(CampaignModel).where(CampaignModel.id == str(campaign_id))
        .where(CampaignModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Campaign not found")
    if model.status != CampaignStatus.draft.value and model.status != CampaignStatus.paused.value:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only draft or paused campaigns can be activated")

    model.status = CampaignStatus.active.value
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Campaign.model_validate(model)


@router.post("/{campaign_id}/pause", response_model=Campaign)
async def pause_campaign(
    campaign_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_campaigns")),
):
    result = await session.execute(
        select(CampaignModel).where(CampaignModel.id == str(campaign_id))
        .where(CampaignModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Campaign not found")
    if model.status != CampaignStatus.active.value:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only active campaigns can be paused")

    model.status = CampaignStatus.paused.value
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Campaign.model_validate(model)


@router.post("/{campaign_id}/start", response_model=Campaign)
async def start_campaign(
    campaign_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_campaigns")),
):
    result = await session.execute(
        select(CampaignModel).where(CampaignModel.id == str(campaign_id))
        .where(CampaignModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Campaign not found")

    model.status = CampaignStatus.active.value
    model.extra_data = {**(model.extra_data or {}), "started_at": datetime.now(timezone.utc).isoformat()}
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Campaign.model_validate(model)


@router.get("/{campaign_id}/leads", response_model=list[Lead])
async def get_campaign_leads(
    campaign_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_campaigns")),
):
    result = await session.execute(
        select(LeadModel).where(LeadModel.campaign_id == str(campaign_id))
        .where(LeadModel.organization_id == str(current_user.organization_id))
    )
    models = result.scalars().all()
    return [Lead.model_validate(m) for m in models]


@router.post("/{campaign_id}/leads", response_model=list[Lead])
async def add_leads_to_campaign(
    campaign_id: UUID,
    req: AddLeadsRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_campaigns")),
):
    campaign_result = await session.execute(
        select(CampaignModel).where(CampaignModel.id == str(campaign_id))
        .where(CampaignModel.organization_id == str(current_user.organization_id))
    )
    if campaign_result.scalar_one_or_none() is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Campaign not found")

    updated = []
    for lead_id in req.lead_ids:
        lead_result = await session.execute(
            select(LeadModel).where(LeadModel.id == str(lead_id))
            .where(LeadModel.organization_id == str(current_user.organization_id))
        )
        lead_model = lead_result.scalar_one_or_none()
        if lead_model:
            lead_model.campaign_id = str(campaign_id)
            session.add(lead_model)
            updated.append(Lead.model_validate(lead_model))

    await session.flush()
    return updated


@router.get("/{campaign_id}/stats", response_model=CampaignStatsResponse)
async def get_campaign_stats(
    campaign_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(CampaignModel).where(CampaignModel.id == str(campaign_id))
        .where(CampaignModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Campaign not found")

    leads_result = await session.execute(
        select(func.count()).select_from(LeadModel)
        .where(LeadModel.campaign_id == str(campaign_id))
        .where(LeadModel.organization_id == str(current_user.organization_id))
    )
    total_leads = leads_result.scalar() or 0

    active_leads_result = await session.execute(
        select(func.count()).select_from(LeadModel)
        .where(LeadModel.campaign_id == str(campaign_id))
        .where(LeadModel.organization_id == str(current_user.organization_id))
        .where(LeadModel.status.in_(["new", "contacted", "qualified"]))
    )
    active_leads = active_leads_result.scalar() or 0

    answer_rate = (model.total_answered / model.total_calls * 100) if model.total_calls > 0 else 0.0
    conversion_rate = (model.total_converted / model.total_answered * 100) if model.total_answered > 0 else 0.0

    return CampaignStatsResponse(
        total_calls=model.total_calls,
        total_answered=model.total_answered,
        total_converted=model.total_converted,
        total_cost=model.total_cost,
        answer_rate=round(answer_rate, 2),
        conversion_rate=round(conversion_rate, 2),
        leads_count=total_leads,
        active_leads=active_leads,
    )
