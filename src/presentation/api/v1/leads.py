import csv
import io
import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field
from sqlalchemy import select, func, case, delete as sa_delete, or_
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.repositories import SQLAlchemyLeadRepository
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService

router = APIRouter()


class LeadResponse(BaseModel):
    id: uuid.UUID
    session_id: uuid.UUID
    name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    intent: Optional[str] = None
    product_interest: Optional[str] = None
    budget: Optional[float] = None
    score: float = 0.0
    status: str = "new"
    assigned_to: Optional[str] = None
    created_at: str
    updated_at: Optional[str] = None


class LeadCreate(BaseModel):
    name: Optional[str] = Field(None, max_length=255)
    phone: Optional[str] = Field(None, max_length=50)
    email: Optional[str] = Field(None, max_length=255)
    intent: Optional[str] = None
    product_interest: Optional[str] = Field(None, max_length=255)
    budget: Optional[float] = None
    session_id: Optional[uuid.UUID] = None


class LeadUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=255)
    phone: Optional[str] = Field(None, max_length=50)
    email: Optional[str] = Field(None, max_length=255)
    intent: Optional[str] = None
    product_interest: Optional[str] = Field(None, max_length=255)
    budget: Optional[float] = None


class LeadStatusUpdate(BaseModel):
    status: str = Field(..., pattern="^(new|contacted|qualified|converted|lost)$")


class LeadAssignUpdate(BaseModel):
    assigned_to: Optional[str] = None


class LeadNoteCreate(BaseModel):
    description: str


def _score_lead(lead) -> float:
    score = 0.0
    if lead.name:
        score += 0.2
    if lead.email:
        score += 0.2
    if lead.phone:
        score += 0.15
    if lead.intent:
        score += 0.15
    if lead.product_interest:
        score += 0.15
    if lead.budget is not None and lead.budget > 0:
        score += 0.15
    return min(score, 1.0)


def _lead_to_response(lead) -> LeadResponse:
    return LeadResponse(
        id=lead.id,
        session_id=lead.session_id,
        name=lead.name,
        phone=lead.phone,
        email=lead.email,
        intent=lead.intent,
        product_interest=lead.product_interest,
        budget=lead.budget,
        score=_score_lead(lead),
        status=getattr(lead, "status", "new") or "new",
        assigned_to=getattr(lead, "assigned_to", None),
        created_at=lead.created_at.isoformat(),
        updated_at=lead.updated_at.isoformat() if getattr(lead, "updated_at", None) else None,
    )


# ==================== STATIC ROUTES (before /{lead_id}) ====================

@router.get("/", response_model=List[LeadResponse])
async def list_leads(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    sort: str = Query(default="score", pattern="^(score|date|name)$"),
) -> List[LeadResponse]:
    from src.infrastructure.database.models import Lead as ORMLead

    repo = SQLAlchemyLeadRepository(db)
    if sort == "score":
        leads = await repo.get_scored_leads(org_id, limit=limit, offset=offset)
        return [_lead_to_response(l) for l in leads]
    elif sort == "name":
        stmt = select(ORMLead).where(ORMLead.org_id == org_id).order_by(ORMLead.name.asc()).limit(limit).offset(offset)
    else:
        stmt = select(ORMLead).where(ORMLead.org_id == org_id).order_by(ORMLead.created_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_lead_to_response(l) for l in result.scalars().all()]


@router.get("/count", status_code=status.HTTP_200_OK)
async def count_leads(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    from src.infrastructure.database.models import Lead as ORMLead
    stmt = select(func.count()).select_from(ORMLead).where(ORMLead.org_id == org_id)
    result = await db.execute(stmt)
    return {"count": result.scalar_one() or 0}


@router.get("/analytics")
async def lead_analytics(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    from src.infrastructure.database.models import Lead as ORMLead

    total_stmt = select(func.count()).select_from(ORMLead).where(ORMLead.org_id == org_id)
    total = (await db.execute(total_stmt)).scalar() or 0

    status_stmt = (
        select(func.coalesce(ORMLead.status, "new").label("s"), func.count().label("cnt"))
        .where(ORMLead.org_id == org_id)
        .group_by(func.coalesce(ORMLead.status, "new"))
    )
    status_rows = (await db.execute(status_stmt)).all()
    status_counts = {row.s: row.cnt for row in status_rows}

    score_expr = (
        case((ORMLead.name.isnot(None), 0.2), else_=0.0)
        + case((ORMLead.email.isnot(None), 0.2), else_=0.0)
        + case((ORMLead.phone.isnot(None), 0.15), else_=0.0)
        + case((ORMLead.intent.isnot(None), 0.15), else_=0.0)
        + case((ORMLead.product_interest.isnot(None), 0.15), else_=0.0)
        + case((ORMLead.budget > 0, 0.15), else_=0.0)
    )

    avg_stmt = select(func.coalesce(func.avg(score_expr), 0.0)).where(ORMLead.org_id == org_id)
    avg_score = (await db.execute(avg_stmt)).scalar() or 0

    budget_stmt = select(func.coalesce(func.sum(ORMLead.budget), 0.0)).where(ORMLead.org_id == org_id)
    total_budget = (await db.execute(budget_stmt)).scalar() or 0

    high_stmt = select(func.count()).select_from(ORMLead).where(ORMLead.org_id == org_id, score_expr >= 0.7)
    high = (await db.execute(high_stmt)).scalar() or 0

    med_stmt = select(func.count()).select_from(ORMLead).where(ORMLead.org_id == org_id, score_expr >= 0.4, score_expr < 0.7)
    medium = (await db.execute(med_stmt)).scalar() or 0

    low = total - high - medium

    return {
        "total_leads": total,
        "status_breakdown": status_counts,
        "average_score": round(avg_score, 2),
        "total_budget": total_budget,
        "score_distribution": {
            "high (0.7-1.0)": high,
            "medium (0.4-0.7)": medium,
            "low (0.0-0.4)": low,
        },
    }


@router.get("/search", response_model=List[LeadResponse])
async def search_leads(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    q: str = Query(..., min_length=1, max_length=255),
    limit: int = Query(default=20, ge=1, le=100),
) -> List[LeadResponse]:
    from src.infrastructure.database.models import Lead as ORMLead
    pattern = f"%{q}%"
    stmt = select(ORMLead).where(
        ORMLead.org_id == org_id,
        or_(
            ORMLead.name.ilike(pattern),
            ORMLead.email.ilike(pattern),
            ORMLead.phone.ilike(pattern),
            ORMLead.intent.ilike(pattern),
            ORMLead.product_interest.ilike(pattern),
        ),
    ).limit(limit)
    result = await db.execute(stmt)
    return [_lead_to_response(l) for l in result.scalars().all()]


@router.get("/export/csv")
async def export_leads_csv(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> StreamingResponse:
    from src.infrastructure.database.models import Lead as ORMLead
    stmt = select(ORMLead).where(ORMLead.org_id == org_id).order_by(ORMLead.created_at.desc())
    result = await db.execute(stmt)
    leads = result.scalars().all()

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["id", "name", "email", "phone", "intent", "product_interest", "budget", "score", "status", "assigned_to", "created_at"])
    for l in leads:
        writer.writerow([
            str(l.id), l.name or "", l.email or "", l.phone or "",
            l.intent or "", l.product_interest or "",
            l.budget or 0, round(_score_lead(l), 2),
            getattr(l, "status", "new") or "new",
            getattr(l, "assigned_to", "") or "",
            l.created_at.isoformat(),
        ])
    output.seek(0)
    return StreamingResponse(iter([output.getvalue()]), media_type="text/csv", headers={"Content-Disposition": "attachment; filename=leads.csv"})


@router.post("/", response_model=LeadResponse, status_code=status.HTTP_201_CREATED)
async def create_lead(
    data: LeadCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> LeadResponse:
    from src.infrastructure.database.models import Lead as ORMLead, ChatSession as ORMChatSession, Agent as ORMAgent

    session_id = data.session_id
    if not session_id:
        agent_stmt = select(ORMAgent).where(ORMAgent.org_id == org_id).limit(1)
        agent_result = await db.execute(agent_stmt)
        agent = agent_result.scalar_one_or_none()
        if not agent:
            raise HTTPException(status_code=400, detail="No agents found. Create an agent first.")
        session = ORMChatSession(id=uuid.uuid4(), agent_id=agent.id, external_user_id=data.phone or "unknown", status="active")
        db.add(session)
        await db.flush()
        session_id = session.id

    now = datetime.datetime.now(datetime.timezone.utc)
    lead = ORMLead(
        id=uuid.uuid4(), org_id=org_id, session_id=session_id,
        name=data.name, phone=data.phone, email=data.email,
        intent=data.intent, product_interest=data.product_interest,
        budget=data.budget, status="new",
        created_at=now, updated_at=now,
    )
    db.add(lead)
    await db.flush()

    await AuditService.log(db=db, action="create", resource="lead", org_id=org_id, resource_id=str(lead.id), detail=f"Created lead: {lead.name or lead.phone or lead.email}")
    await db.commit()
    await db.refresh(lead)
    return _lead_to_response(lead)


# ==================== PARAMETERIZED ROUTES (/{lead_id}) ====================

@router.get("/{lead_id}", response_model=LeadResponse)
async def get_lead(
    lead_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> LeadResponse:
    from src.infrastructure.database.models import Lead as ORMLead
    stmt = select(ORMLead).where(ORMLead.id == lead_id, ORMLead.org_id == org_id)
    result = await db.execute(stmt)
    lead = result.scalar_one_or_none()
    if not lead:
        raise HTTPException(status_code=404, detail="Lead not found.")
    return _lead_to_response(lead)


@router.put("/{lead_id}", response_model=LeadResponse)
async def update_lead(
    lead_id: uuid.UUID,
    data: LeadUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> LeadResponse:
    from src.infrastructure.database.models import Lead as ORMLead
    stmt = select(ORMLead).where(ORMLead.id == lead_id, ORMLead.org_id == org_id)
    result = await db.execute(stmt)
    lead = result.scalar_one_or_none()
    if not lead:
        raise HTTPException(status_code=404, detail="Lead not found.")

    if data.name is not None:
        lead.name = data.name
    if data.phone is not None:
        lead.phone = data.phone
    if data.email is not None:
        lead.email = data.email
    if data.intent is not None:
        lead.intent = data.intent
    if data.product_interest is not None:
        lead.product_interest = data.product_interest
    if data.budget is not None:
        lead.budget = data.budget
    lead.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await AuditService.log(db=db, action="update", resource="lead", org_id=org_id, resource_id=str(lead.id), detail=f"Updated lead: {lead.name}")
    await db.commit()
    await db.refresh(lead)
    return _lead_to_response(lead)


@router.patch("/{lead_id}/status", response_model=LeadResponse)
async def update_lead_status(
    lead_id: uuid.UUID,
    data: LeadStatusUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> LeadResponse:
    from src.infrastructure.database.models import Lead as ORMLead
    stmt = select(ORMLead).where(ORMLead.id == lead_id, ORMLead.org_id == org_id)
    result = await db.execute(stmt)
    lead = result.scalar_one_or_none()
    if not lead:
        raise HTTPException(status_code=404, detail="Lead not found.")

    old_status = getattr(lead, "status", "new") or "new"
    lead.status = data.status
    lead.updated_at = datetime.datetime.now(datetime.timezone.utc)

    from src.infrastructure.database.models import ActivityLog
    log = ActivityLog(org_id=org_id, entity_type="lead", entity_id=lead_id, activity_type="status_change", description=f"Status changed from {old_status} to {data.status}", performed_by="system")
    db.add(log)
    await AuditService.log(db=db, action="status_change", resource="lead", org_id=org_id, resource_id=str(lead.id), detail=f"Status: {old_status} → {data.status}")
    await db.commit()
    await db.refresh(lead)
    return _lead_to_response(lead)


@router.patch("/{lead_id}/assign", response_model=LeadResponse)
async def assign_lead(
    lead_id: uuid.UUID,
    data: LeadAssignUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> LeadResponse:
    from src.infrastructure.database.models import Lead as ORMLead
    stmt = select(ORMLead).where(ORMLead.id == lead_id, ORMLead.org_id == org_id)
    result = await db.execute(stmt)
    lead = result.scalar_one_or_none()
    if not lead:
        raise HTTPException(status_code=404, detail="Lead not found.")

    lead.assigned_to = data.assigned_to
    lead.updated_at = datetime.datetime.now(datetime.timezone.utc)

    from src.infrastructure.database.models import ActivityLog
    log = ActivityLog(org_id=org_id, entity_type="lead", entity_id=lead_id, activity_type="assignment", description=f"Assigned to {data.assigned_to or 'unassigned'}", performed_by="system")
    db.add(log)
    await AuditService.log(db=db, action="assign", resource="lead", org_id=org_id, resource_id=str(lead.id), detail=f"Assigned to: {data.assigned_to}")
    await db.commit()
    await db.refresh(lead)
    return _lead_to_response(lead)


@router.get("/{lead_id}/activities")
async def get_lead_activities(
    lead_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200),
) -> List[dict]:
    from src.infrastructure.database.models import ActivityLog, Lead as ORMLead
    lead_stmt = select(ORMLead).where(ORMLead.id == lead_id, ORMLead.org_id == org_id)
    lead_result = await db.execute(lead_stmt)
    if not lead_result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Lead not found.")

    stmt = select(ActivityLog).where(
        ActivityLog.org_id == org_id, ActivityLog.entity_type == "lead", ActivityLog.entity_id == lead_id
    ).order_by(ActivityLog.created_at.desc()).limit(limit)
    result = await db.execute(stmt)
    return [
        {
            "id": str(log.id),
            "activity_type": log.activity_type,
            "description": log.description,
            "performed_by": log.performed_by,
            "created_at": log.created_at.isoformat(),
        }
        for log in result.scalars().all()
    ]


@router.post("/{lead_id}/notes")
async def add_lead_note(
    lead_id: uuid.UUID,
    data: LeadNoteCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    from src.infrastructure.database.models import ActivityLog, Lead as ORMLead
    lead_stmt = select(ORMLead).where(ORMLead.id == lead_id, ORMLead.org_id == org_id)
    lead_result = await db.execute(lead_stmt)
    if not lead_result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Lead not found.")

    log = ActivityLog(org_id=org_id, entity_type="lead", entity_id=lead_id, activity_type="note", description=data.description, performed_by="system")
    db.add(log)
    await db.commit()
    await db.refresh(log)
    return {"id": str(log.id), "activity_type": "note", "description": data.description, "created_at": log.created_at.isoformat()}


@router.delete("/{lead_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_lead(
    lead_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    from src.infrastructure.database.models import Lead as ORMLead
    stmt = select(ORMLead).where(ORMLead.id == lead_id, ORMLead.org_id == org_id)
    result = await db.execute(stmt)
    lead = result.scalar_one_or_none()
    if not lead:
        raise HTTPException(status_code=404, detail="Lead not found.")
    d_stmt = sa_delete(ORMLead).where(ORMLead.id == lead_id)
    await db.execute(d_stmt)
    await AuditService.log(db=db, action="delete", resource="lead", org_id=org_id, resource_id=str(lead_id), detail=f"Deleted lead: {lead.name or lead.phone}")
    await db.commit()


@router.delete("/", status_code=status.HTTP_200_OK)
async def bulk_delete_leads(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    ids: Optional[List[uuid.UUID]] = Query(default=None),
    _=Depends(require_role("admin")),
) -> dict:
    from src.infrastructure.database.models import Lead as ORMLead
    if ids:
        stmt = sa_delete(ORMLead).where(ORMLead.id.in_(ids), ORMLead.org_id == org_id)
    else:
        stmt = sa_delete(ORMLead).where(ORMLead.org_id == org_id)
    result = await db.execute(stmt)
    count = result.rowcount or 0
    await AuditService.log(db=db, action="bulk_delete", resource="lead", org_id=org_id, detail=f"Bulk deleted {count} leads")
    await db.commit()
    return {"deleted": count}
