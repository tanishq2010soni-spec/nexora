from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Customer, Lead, User
from ..domain.enums import LeadSource, LeadStatus, PipelineStage
from ..infrastructure.database import (CustomerModel, LeadModel,
                                       get_session)

router = APIRouter(prefix="/api/v1/crm", tags=["crm"])


@router.get("/leads")
async def list_leads(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    status: Optional[str] = Query(None),
    source: Optional[str] = Query(None),
    pipeline_stage: Optional[str] = Query(None),
    assigned_to: Optional[UUID] = Query(None),
    search: Optional[str] = Query(None),
):
    org_id = str(current_user.organization_id)
    query = select(LeadModel).where(LeadModel.organization_id == org_id)
    if status:
        query = query.where(LeadModel.status == status)
    if source:
        query = query.where(LeadModel.source == source)
    if pipeline_stage:
        query = query.where(LeadModel.pipeline_stage == pipeline_stage)
    if assigned_to:
        query = query.where(LeadModel.assigned_to == str(assigned_to))
    if search:
        query = query.where(
            LeadModel.customer_name.ilike(f"%{search}%") |
            LeadModel.customer_phone.ilike(f"%{search}%") |
            LeadModel.customer_email.ilike(f"%{search}%")
        )
    query = query.order_by(LeadModel.updated_at.desc())
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [Lead.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.post("/leads", status_code=201)
async def create_lead(
    customer_phone: str,
    customer_name: Optional[str] = None,
    customer_email: Optional[str] = None,
    source: str = LeadSource.whatsapp.value,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_crm")),
):
    org_id = str(current_user.organization_id)
    model = LeadModel(
        id=str(uuid4()),
        organization_id=org_id,
        customer_phone=customer_phone,
        customer_name=customer_name,
        customer_email=customer_email,
        source=source,
        status=LeadStatus.new.value,
        pipeline_stage=PipelineStage.new_lead.value,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Lead.model_validate(model)


@router.get("/leads/{lead_id}")
async def get_lead(
    lead_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(LeadModel).where(
            LeadModel.id == str(lead_id),
            LeadModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Lead not found")
    return Lead.model_validate(model)


@router.put("/leads/{lead_id}")
async def update_lead(
    lead_id: UUID,
    customer_name: Optional[str] = None,
    customer_email: Optional[str] = None,
    status: Optional[str] = None,
    source: Optional[str] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_crm")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(LeadModel).where(
            LeadModel.id == str(lead_id),
            LeadModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Lead not found")
    if customer_name is not None:
        model.customer_name = customer_name
    if customer_email is not None:
        model.customer_email = customer_email
    if status is not None:
        model.status = status
    if source is not None:
        model.source = source
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Lead.model_validate(model)


@router.patch("/leads/{lead_id}/stage")
async def update_lead_stage(
    lead_id: UUID,
    pipeline_stage: str,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_crm")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(LeadModel).where(
            LeadModel.id == str(lead_id),
            LeadModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Lead not found")
    model.pipeline_stage = pipeline_stage
    timeline_entry = {
        "action": "stage_changed",
        "from": model.pipeline_stage,
        "to": pipeline_stage,
        "timestamp": datetime.utcnow().isoformat(),
        "user_id": str(current_user.id),
    }
    timeline = list(model.timeline or [])
    timeline.append(timeline_entry)
    model.timeline = timeline
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return Lead.model_validate(model)


@router.patch("/leads/{lead_id}/score")
async def update_lead_score(
    lead_id: UUID,
    score: float,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_crm")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(LeadModel).where(
            LeadModel.id == str(lead_id),
            LeadModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Lead not found")
    model.score = max(0.0, min(100.0, score))
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"score": model.score}


@router.patch("/leads/{lead_id}/assign")
async def assign_lead(
    lead_id: UUID,
    assigned_to: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_crm")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(LeadModel).where(
            LeadModel.id == str(lead_id),
            LeadModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Lead not found")
    model.assigned_to = str(assigned_to)
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return Lead.model_validate(model)


@router.post("/leads/{lead_id}/notes")
async def add_lead_note(
    lead_id: UUID,
    content: str,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_crm")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(LeadModel).where(
            LeadModel.id == str(lead_id),
            LeadModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Lead not found")
    notes = list(model.notes or [])
    note = {
        "id": str(uuid4()),
        "content": content,
        "created_by": str(current_user.id),
        "created_at": datetime.utcnow().isoformat(),
    }
    notes.append(note)
    model.notes = notes
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"notes": model.notes}


@router.post("/leads/{lead_id}/tags")
async def update_lead_tags(
    lead_id: UUID,
    tags: list[str],
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_crm")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(LeadModel).where(
            LeadModel.id == str(lead_id),
            LeadModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Lead not found")
    model.tags = tags
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"tags": model.tags}


@router.post("/leads/{lead_id}/convert", status_code=201)
async def convert_lead_to_customer(
    lead_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_crm")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(LeadModel).where(
            LeadModel.id == str(lead_id),
            LeadModel.organization_id == org_id,
        )
    )
    lead_model = result.scalar_one_or_none()
    if not lead_model:
        raise HTTPException(status_code=404, detail="Lead not found")
    if lead_model.status == LeadStatus.converted.value:
        raise HTTPException(status_code=400, detail="Lead already converted")
    existing_customer = await session.execute(
        select(CustomerModel).where(
            CustomerModel.organization_id == org_id,
            CustomerModel.phone == lead_model.customer_phone,
        )
    )
    if existing_customer.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Customer with this phone already exists")
    customer = CustomerModel(
        id=str(uuid4()),
        organization_id=org_id,
        phone=lead_model.customer_phone,
        name=lead_model.customer_name,
        email=lead_model.customer_email,
        tags=lead_model.tags or [],
    )
    session.add(customer)
    lead_model.status = LeadStatus.converted.value
    lead_model.converted_at = datetime.utcnow()
    lead_model.converted_to_customer_id = customer.id
    lead_model.updated_at = datetime.utcnow()
    session.add(lead_model)
    await session.flush()
    await session.refresh(customer)
    return Customer.model_validate(customer)


@router.get("/customers")
async def list_customers(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    search: Optional[str] = Query(None),
    tier: Optional[str] = Query(None),
):
    org_id = str(current_user.organization_id)
    query = select(CustomerModel).where(CustomerModel.organization_id == org_id)
    if search:
        query = query.where(
            CustomerModel.name.ilike(f"%{search}%") |
            CustomerModel.phone.ilike(f"%{search}%") |
            CustomerModel.email.ilike(f"%{search}%")
        )
    if tier:
        query = query.where(CustomerModel.tier == tier)
    query = query.order_by(CustomerModel.updated_at.desc())
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [Customer.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.get("/customers/{customer_id}")
async def get_customer(
    customer_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(CustomerModel).where(
            CustomerModel.id == str(customer_id),
            CustomerModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Customer not found")
    return Customer.model_validate(model)


@router.put("/customers/{customer_id}")
async def update_customer(
    customer_id: UUID,
    name: Optional[str] = None,
    email: Optional[str] = None,
    tier: Optional[str] = None,
    tags: Optional[list[str]] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_crm")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(CustomerModel).where(
            CustomerModel.id == str(customer_id),
            CustomerModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Customer not found")
    if name is not None:
        model.name = name
    if email is not None:
        model.email = email
    if tier is not None:
        model.tier = tier
    if tags is not None:
        model.tags = tags
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Customer.model_validate(model)
