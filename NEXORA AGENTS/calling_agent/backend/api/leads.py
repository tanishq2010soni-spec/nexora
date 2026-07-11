from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, status
from pydantic import BaseModel
from sqlalchemy import select, func, desc, or_
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Lead
from ..domain.enums import LeadSource, LeadStatus
from ..infrastructure.database import LeadModel, get_session

router = APIRouter(prefix="/api/v1/leads", tags=["leads"])


class LeadListResponse(BaseModel):
    items: list[Lead]
    total: int
    page: int
    limit: int
    pages: int


class CreateLeadRequest(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: str
    email: Optional[str] = None
    company: Optional[str] = None
    position: Optional[str] = None
    source: str = "manual"
    status: str = "new"
    campaign_id: Optional[UUID] = None
    tags: list[str] = []
    custom_fields: dict[str, Any] = {}
    timezone: Optional[str] = None
    best_time_to_call: Optional[str] = None


class UpdateLeadRequest(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    company: Optional[str] = None
    position: Optional[str] = None
    status: Optional[str] = None
    source: Optional[str] = None
    score: Optional[float] = None
    tags: Optional[list[str]] = None
    custom_fields: Optional[dict[str, Any]] = None
    timezone: Optional[str] = None
    best_time_to_call: Optional[str] = None
    do_not_call: Optional[bool] = None


class LeadNoteRequest(BaseModel):
    note: str
    author: Optional[str] = None


class LeadTagsRequest(BaseModel):
    tags: list[str]


class BulkAssignRequest(BaseModel):
    lead_ids: list[UUID]
    campaign_id: UUID


class BulkDeleteRequest(BaseModel):
    lead_ids: list[UUID]


@router.get("", response_model=LeadListResponse)
async def list_leads(
    status: Optional[str] = Query(None),
    source: Optional[str] = Query(None),
    campaign_id: Optional[UUID] = Query(None),
    search: Optional[str] = Query(None),
    do_not_call: Optional[bool] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=200),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_leads")),
):
    query = select(LeadModel).where(LeadModel.organization_id == str(current_user.organization_id))

    if status:
        query = query.where(LeadModel.status == status)
    if source:
        query = query.where(LeadModel.source == source)
    if campaign_id:
        query = query.where(LeadModel.campaign_id == str(campaign_id))
    if do_not_call is not None:
        query = query.where(LeadModel.do_not_call == do_not_call)
    if search:
        search_filter = f"%{search}%"
        query = query.where(
            or_(
                LeadModel.first_name.ilike(search_filter),
                LeadModel.last_name.ilike(search_filter),
                LeadModel.phone.ilike(search_filter),
                LeadModel.email.ilike(search_filter),
                LeadModel.company.ilike(search_filter),
            )
        )

    count_query = select(func.count()).select_from(query.subquery())
    total = (await session.execute(count_query)).scalar() or 0
    pages = max(1, (total + limit - 1) // limit)
    offset = (page - 1) * limit

    query = query.order_by(desc(LeadModel.created_at)).offset(offset).limit(limit)
    result = await session.execute(query)
    models = result.scalars().all()

    return LeadListResponse(
        items=[Lead.model_validate(m) for m in models],
        total=total, page=page, limit=limit, pages=pages,
    )


@router.post("", response_model=Lead)
async def create_lead(
    req: CreateLeadRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_leads")),
):
    model = LeadModel(
        organization_id=str(current_user.organization_id),
        first_name=req.first_name,
        last_name=req.last_name,
        phone=req.phone,
        email=req.email,
        company=req.company,
        position=req.position,
        source=req.source,
        status=req.status,
        campaign_id=str(req.campaign_id) if req.campaign_id else None,
        tags=req.tags,
        custom_fields=req.custom_fields,
        timezone=req.timezone,
        best_time_to_call=req.best_time_to_call,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Lead.model_validate(model)


@router.post("/import", response_model=list[Lead])
async def bulk_import_leads(
    file: UploadFile = File(...),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_leads")),
):
    import csv
    import io

    content = await file.read()
    text = content.decode("utf-8-sig")
    reader = csv.DictReader(io.StringIO(text))

    created = []
    for row in reader:
        model = LeadModel(
            organization_id=str(current_user.organization_id),
            first_name=row.get("first_name"),
            last_name=row.get("last_name"),
            phone=row.get("phone", ""),
            email=row.get("email"),
            company=row.get("company"),
            position=row.get("position"),
            source=row.get("source", "manual"),
            status=row.get("status", "new"),
            tags=[t.strip() for t in row.get("tags", "").split(",") if t.strip()] if row.get("tags") else [],
            custom_fields={k: v for k, v in row.items() if k not in ("first_name", "last_name", "phone", "email", "company", "position", "source", "status", "tags")},
        )
        session.add(model)
        created.append(model)

    await session.flush()
    for m in created:
        await session.refresh(m)
    return [Lead.model_validate(m) for m in created]


@router.get("/export")
async def export_leads(
    status: Optional[str] = Query(None),
    source: Optional[str] = Query(None),
    campaign_id: Optional[UUID] = Query(None),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_leads")),
):
    import csv
    import io

    query = select(LeadModel).where(LeadModel.organization_id == str(current_user.organization_id))
    if status:
        query = query.where(LeadModel.status == status)
    if source:
        query = query.where(LeadModel.source == source)
    if campaign_id:
        query = query.where(LeadModel.campaign_id == str(campaign_id))

    result = await session.execute(query)
    models = result.scalars().all()

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["id", "first_name", "last_name", "phone", "email", "company", "position", "status", "source", "score", "tags", "created_at"])
    for m in models:
        writer.writerow([m.id, m.first_name, m.last_name, m.phone, m.email, m.company, m.position, m.status, m.source, m.score, ",".join(m.tags or []), m.created_at.isoformat()])

    from fastapi.responses import StreamingResponse
    output.seek(0)
    return StreamingResponse(
        iter([output.getvalue()]),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=leads_export.csv"},
    )


@router.get("/{lead_id}", response_model=Lead)
async def get_lead(
    lead_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(LeadModel).where(LeadModel.id == str(lead_id))
        .where(LeadModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Lead not found")
    return Lead.model_validate(model)


@router.put("/{lead_id}", response_model=Lead)
async def update_lead(
    lead_id: UUID,
    req: UpdateLeadRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_leads")),
):
    result = await session.execute(
        select(LeadModel).where(LeadModel.id == str(lead_id))
        .where(LeadModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Lead not found")

    update_data = req.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(model, field, value)

    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Lead.model_validate(model)


@router.delete("/{lead_id}")
async def delete_lead(
    lead_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_leads")),
):
    result = await session.execute(
        select(LeadModel).where(LeadModel.id == str(lead_id))
        .where(LeadModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Lead not found")

    await session.delete(model)
    return {"deleted": True}


@router.post("/{lead_id}/notes", response_model=Lead)
async def add_lead_note(
    lead_id: UUID,
    req: LeadNoteRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_leads")),
):
    result = await session.execute(
        select(LeadModel).where(LeadModel.id == str(lead_id))
        .where(LeadModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Lead not found")

    note_entry = {
        "note": req.note,
        "author": req.author or current_user.name,
        "user_id": str(current_user.id),
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    notes = list(model.notes or [])
    notes.append(note_entry)
    model.notes = notes
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Lead.model_validate(model)


@router.post("/{lead_id}/tags", response_model=Lead)
async def update_lead_tags(
    lead_id: UUID,
    req: LeadTagsRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_leads")),
):
    result = await session.execute(
        select(LeadModel).where(LeadModel.id == str(lead_id))
        .where(LeadModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Lead not found")

    model.tags = req.tags
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Lead.model_validate(model)


@router.post("/bulk/delete")
async def bulk_delete_leads(
    req: BulkDeleteRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_leads")),
):
    for lead_id in req.lead_ids:
        result = await session.execute(
            select(LeadModel).where(LeadModel.id == str(lead_id))
            .where(LeadModel.organization_id == str(current_user.organization_id))
        )
        model = result.scalar_one_or_none()
        if model:
            await session.delete(model)
    return {"deleted": len(req.lead_ids)}


@router.post("/bulk/assign")
async def bulk_assign_leads(
    req: BulkAssignRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_leads")),
):
    campaign_result = await session.execute(
        select(LeadModel).where(LeadModel.organization_id == str(current_user.organization_id)).limit(1)
    )

    updated = 0
    for lead_id in req.lead_ids:
        result = await session.execute(
            select(LeadModel).where(LeadModel.id == str(lead_id))
            .where(LeadModel.organization_id == str(current_user.organization_id))
        )
        model = result.scalar_one_or_none()
        if model:
            model.campaign_id = str(req.campaign_id)
            session.add(model)
            updated += 1

    await session.flush()
    return {"assigned": updated}
