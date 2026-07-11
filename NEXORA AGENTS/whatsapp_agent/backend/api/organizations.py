from datetime import datetime, time
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Organization, User
from ..domain.enums import OrganizationStatus
from ..infrastructure.database import (ConversationModel, LeadModel,
                                       OrganizationModel, UserModel, get_session)

router = APIRouter(prefix="/api/v1/organizations", tags=["organizations"])


def _model_to_entity(m: OrganizationModel) -> Organization:
    return Organization(
        id=UUID(str(m.id)),
        name=m.name,
        slug=m.slug,
        status=m.status,
        timezone=m.timezone,
        brand_color=m.brand_color,
        brand_logo_url=m.brand_logo_url,
        working_hours_start=time.fromisoformat(m.working_hours_start) if m.working_hours_start else time(9, 0),
        working_hours_end=time.fromisoformat(m.working_hours_end) if m.working_hours_end else time(18, 0),
        working_days=m.working_days or [0, 1, 2, 3, 4, 5, 6],
        default_language=m.default_language,
        max_whatsapp_accounts=m.max_whatsapp_accounts,
        max_users=m.max_users,
        max_leads=m.max_leads,
        extra_data=m.extra_data or {},
        created_at=m.created_at,
        updated_at=m.updated_at,
    )


@router.get("/")
async def list_organizations(
    session: AsyncSession = Depends(get_session),
    _: User = Depends(require_permission("manage_settings")),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    status: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
):
    query = select(OrganizationModel)
    if status:
        query = query.where(OrganizationModel.status == status)
    if search:
        query = query.where(OrganizationModel.name.ilike(f"%{search}%"))
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [_model_to_entity(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.post("/", status_code=201)
async def create_organization(
    name: str,
    slug: str,
    session: AsyncSession = Depends(get_session),
    _: User = Depends(require_permission("manage_settings")),
):
    existing = await session.execute(select(OrganizationModel).where(OrganizationModel.slug == slug))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Organization with this slug already exists")
    model = OrganizationModel(id=str(uuid4()), name=name, slug=slug)
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return _model_to_entity(model)


@router.get("/{org_id}")
async def get_organization(
    org_id: UUID,
    session: AsyncSession = Depends(get_session),
    _: User = Depends(require_permission("manage_settings")),
):
    result = await session.execute(select(OrganizationModel).where(OrganizationModel.id == str(org_id)))
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Organization not found")
    return _model_to_entity(model)


@router.put("/{org_id}")
async def update_organization(
    org_id: UUID,
    name: Optional[str] = None,
    status: Optional[str] = None,
    timezone: Optional[str] = None,
    brand_color: Optional[str] = None,
    brand_logo_url: Optional[str] = None,
    working_hours_start: Optional[str] = None,
    working_hours_end: Optional[str] = None,
    working_days: Optional[list[int]] = None,
    default_language: Optional[str] = None,
    max_whatsapp_accounts: Optional[int] = None,
    max_users: Optional[int] = None,
    max_leads: Optional[int] = None,
    session: AsyncSession = Depends(get_session),
    _: User = Depends(require_permission("manage_settings")),
):
    result = await session.execute(select(OrganizationModel).where(OrganizationModel.id == str(org_id)))
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Organization not found")
    if name is not None:
        model.name = name
    if status is not None:
        model.status = status
    if timezone is not None:
        model.timezone = timezone
    if brand_color is not None:
        model.brand_color = brand_color
    if brand_logo_url is not None:
        model.brand_logo_url = brand_logo_url
    if working_hours_start is not None:
        model.working_hours_start = working_hours_start
    if working_hours_end is not None:
        model.working_hours_end = working_hours_end
    if working_days is not None:
        model.working_days = working_days
    if default_language is not None:
        model.default_language = default_language
    if max_whatsapp_accounts is not None:
        model.max_whatsapp_accounts = max_whatsapp_accounts
    if max_users is not None:
        model.max_users = max_users
    if max_leads is not None:
        model.max_leads = max_leads
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return _model_to_entity(model)


@router.delete("/{org_id}")
async def delete_organization(
    org_id: UUID,
    session: AsyncSession = Depends(get_session),
    _: User = Depends(require_permission("manage_settings")),
):
    result = await session.execute(select(OrganizationModel).where(OrganizationModel.id == str(org_id)))
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Organization not found")
    model.status = OrganizationStatus.suspended.value
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"detail": "Organization suspended"}


@router.get("/{org_id}/stats")
async def get_organization_stats(
    org_id: UUID,
    session: AsyncSession = Depends(get_session),
    _: User = Depends(require_permission("view_dashboard")),
):
    org_result = await session.execute(select(OrganizationModel).where(OrganizationModel.id == str(org_id)))
    if not org_result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Organization not found")
    conv_count = await session.execute(
        select(func.count()).select_from(ConversationModel).where(ConversationModel.organization_id == str(org_id))
    )
    lead_count = await session.execute(
        select(func.count()).select_from(LeadModel).where(LeadModel.organization_id == str(org_id))
    )
    user_count = await session.execute(
        select(func.count()).select_from(UserModel).where(UserModel.organization_id == str(org_id))
    )
    return {
        "organization_id": org_id,
        "total_conversations": conv_count.scalar(),
        "total_leads": lead_count.scalar(),
        "total_users": user_count.scalar(),
    }
