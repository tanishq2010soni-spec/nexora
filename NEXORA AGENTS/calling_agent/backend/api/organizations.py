from __future__ import annotations

from datetime import datetime, timezone
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Organization
from ..domain.enums import AgentRole
from ..infrastructure.database import (AppointmentModel, CallModel, CampaignModel,
                                       ContactModel, LeadModel, OrganizationModel,
                                       UserModel, get_session)

router = APIRouter(prefix="/api/v1/organizations", tags=["organizations"])


class CreateOrganizationRequest(BaseModel):
    name: str
    slug: str
    timezone: str = "UTC"
    brand_color: str = "#6366f1"
    business_hours_start: str = "09:00"
    business_hours_end: str = "18:00"
    working_days: list[int] = [0, 1, 2, 3, 4, 5, 6]
    default_country_code: str = "1"
    max_concurrent_calls: int = 50
    max_agents: int = 10


class UpdateOrganizationRequest(BaseModel):
    name: Optional[str] = None
    slug: Optional[str] = None
    status: Optional[str] = None
    timezone: Optional[str] = None
    brand_color: Optional[str] = None
    brand_logo_url: Optional[str] = None
    business_hours_start: Optional[str] = None
    business_hours_end: Optional[str] = None
    working_days: Optional[list[int]] = None
    default_country_code: Optional[str] = None
    max_concurrent_calls: Optional[int] = None
    max_agents: Optional[int] = None
    recording_enabled: Optional[bool] = None
    transcription_enabled: Optional[bool] = None


class OrganizationStatsResponse(BaseModel):
    total_users: int
    total_calls: int
    total_campaigns: int
    total_leads: int
    total_contacts: int
    total_appointments: int
    active_calls: int
    total_cost: float


@router.get("", response_model=list[Organization])
async def list_organizations(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_permissions")),
):
    if AgentRole.admin.value not in current_user.permissions and current_user.role != AgentRole.admin.value:
        result = await session.execute(
            select(OrganizationModel).where(OrganizationModel.id == str(current_user.organization_id))
        )
        models = result.scalars().all()
    else:
        result = await session.execute(select(OrganizationModel).order_by(OrganizationModel.name))
        models = result.scalars().all()

    return [Organization.model_validate(m) for m in models]


@router.post("", response_model=Organization)
async def create_organization(
    req: CreateOrganizationRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_permissions")),
):
    existing = await session.execute(select(OrganizationModel).where(OrganizationModel.slug == req.slug))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Organization slug already exists")

    model = OrganizationModel(
        name=req.name,
        slug=req.slug,
        timezone=req.timezone,
        brand_color=req.brand_color,
        business_hours_start=req.business_hours_start,
        business_hours_end=req.business_hours_end,
        working_days=req.working_days,
        default_country_code=req.default_country_code,
        max_concurrent_calls=req.max_concurrent_calls,
        max_agents=req.max_agents,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Organization.model_validate(model)


@router.get("/{org_id}", response_model=Organization)
async def get_organization(
    org_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_permissions")),
):
    result = await session.execute(
        select(OrganizationModel).where(OrganizationModel.id == str(org_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Organization not found")
    return Organization.model_validate(model)


@router.put("/{org_id}", response_model=Organization)
async def update_organization(
    org_id: UUID,
    req: UpdateOrganizationRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_permissions")),
):
    result = await session.execute(
        select(OrganizationModel).where(OrganizationModel.id == str(org_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Organization not found")

    update_data = req.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(model, field, value)

    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Organization.model_validate(model)


@router.delete("/{org_id}")
async def delete_organization(
    org_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_permissions")),
):
    result = await session.execute(
        select(OrganizationModel).where(OrganizationModel.id == str(org_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Organization not found")

    model.status = "deleted"
    session.add(model)
    await session.flush()
    return {"deleted": True}


@router.get("/{org_id}/stats", response_model=OrganizationStatsResponse)
async def get_organization_stats(
    org_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_permissions")),
):
    org_id_str = str(org_id)

    total_users = (await session.execute(select(func.count()).select_from(UserModel).where(UserModel.organization_id == org_id_str))).scalar() or 0
    total_calls = (await session.execute(select(func.count()).select_from(CallModel).where(CallModel.organization_id == org_id_str))).scalar() or 0
    total_campaigns = (await session.execute(select(func.count()).select_from(CampaignModel).where(CampaignModel.organization_id == org_id_str))).scalar() or 0
    total_leads = (await session.execute(select(func.count()).select_from(LeadModel).where(LeadModel.organization_id == org_id_str))).scalar() or 0
    total_contacts = (await session.execute(select(func.count()).select_from(ContactModel).where(ContactModel.organization_id == org_id_str))).scalar() or 0
    total_appointments = (await session.execute(select(func.count()).select_from(AppointmentModel).where(AppointmentModel.organization_id == org_id_str))).scalar() or 0
    active_calls = (await session.execute(select(func.count()).select_from(CallModel).where(CallModel.organization_id == org_id_str, CallModel.status.in_(["ringing", "in_progress", "hold"])))).scalar() or 0
    total_cost = (await session.execute(select(func.sum(CallModel.cost)).where(CallModel.organization_id == org_id_str))).scalar() or 0.0

    return OrganizationStatsResponse(
        total_users=total_users,
        total_calls=total_calls,
        total_campaigns=total_campaigns,
        total_leads=total_leads,
        total_contacts=total_contacts,
        total_appointments=total_appointments,
        active_calls=active_calls,
        total_cost=float(total_cost),
    )
