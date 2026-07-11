import csv
import io
import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete, or_
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.repositories import SQLAlchemyCustomerRepository
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService

router = APIRouter()


class CustomerResponse(BaseModel):
    id: uuid.UUID
    phone: str
    name: Optional[str] = None
    preferences: Optional[str] = None
    notes: Optional[str] = None
    segment: Optional[str] = None
    assigned_to: Optional[str] = None
    created_at: str
    updated_at: str


class CustomerCreate(BaseModel):
    phone: str = Field(..., min_length=1, max_length=50)
    name: Optional[str] = Field(None, max_length=255)
    preferences: Optional[str] = None
    notes: Optional[str] = None
    segment: Optional[str] = None


class CustomerUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    preferences: Optional[str] = None
    notes: Optional[str] = None


class CustomerSegmentUpdate(BaseModel):
    segment: Optional[str] = None


class CustomerAssignUpdate(BaseModel):
    assigned_to: Optional[str] = None


class CustomerNoteCreate(BaseModel):
    description: str


def _customer_to_response(c) -> CustomerResponse:
    return CustomerResponse(
        id=c.id,
        phone=c.phone,
        name=c.name,
        preferences=c.preferences,
        notes=c.notes,
        segment=getattr(c, "segment", None),
        assigned_to=getattr(c, "assigned_to", None),
        created_at=c.created_at.isoformat(),
        updated_at=c.updated_at.isoformat(),
    )


# ==================== STATIC ROUTES (before /{customer_id}) ====================

@router.get("/", response_model=List[CustomerResponse])
async def list_customers(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[CustomerResponse]:
    from src.infrastructure.database.models import Customer as ORMCustomer
    stmt = select(ORMCustomer).where(ORMCustomer.org_id == org_id).order_by(ORMCustomer.updated_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_customer_to_response(c) for c in result.scalars().all()]


@router.get("/analytics")
async def customer_analytics(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    from src.infrastructure.database.models import Customer as ORMCustomer
    stmt = select(ORMCustomer).where(ORMCustomer.org_id == org_id)
    result = await db.execute(stmt)
    customers = result.scalars().all()
    total = len(customers)
    segment_counts = {}
    for c in customers:
        seg = getattr(c, "segment", None) or "unsegmented"
        segment_counts[seg] = segment_counts.get(seg, 0) + 1
    assigned = sum(1 for c in customers if getattr(c, "assigned_to", None))
    return {
        "total_customers": total,
        "segment_breakdown": segment_counts,
        "assigned_count": assigned,
        "unassigned_count": total - assigned,
    }


@router.get("/search", response_model=List[CustomerResponse])
async def search_customers(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    q: str = Query(..., min_length=1, max_length=255),
    limit: int = Query(default=20, ge=1, le=100),
) -> List[CustomerResponse]:
    from src.infrastructure.database.models import Customer as ORMCustomer
    pattern = f"%{q}%"
    stmt = select(ORMCustomer).where(
        ORMCustomer.org_id == org_id,
        or_(
            ORMCustomer.name.ilike(pattern),
            ORMCustomer.phone.ilike(pattern),
            ORMCustomer.preferences.ilike(pattern),
        ),
    ).limit(limit)
    result = await db.execute(stmt)
    return [_customer_to_response(c) for c in result.scalars().all()]


@router.get("/export/csv")
async def export_customers_csv(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> StreamingResponse:
    from src.infrastructure.database.models import Customer as ORMCustomer
    stmt = select(ORMCustomer).where(ORMCustomer.org_id == org_id).order_by(ORMCustomer.created_at.desc())
    result = await db.execute(stmt)
    customers = result.scalars().all()

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["id", "phone", "name", "preferences", "notes", "segment", "assigned_to", "created_at", "updated_at"])
    for c in customers:
        writer.writerow([
            str(c.id), c.phone, c.name or "", c.preferences or "", c.notes or "",
            getattr(c, "segment", "") or "",
            getattr(c, "assigned_to", "") or "",
            c.created_at.isoformat(), c.updated_at.isoformat(),
        ])
    output.seek(0)
    return StreamingResponse(iter([output.getvalue()]), media_type="text/csv", headers={"Content-Disposition": "attachment; filename=customers.csv"})


@router.post("/", response_model=CustomerResponse, status_code=status.HTTP_201_CREATED)
async def create_customer(
    data: CustomerCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> CustomerResponse:
    from src.infrastructure.database.models import Customer as ORMCustomer
    existing = await db.execute(select(ORMCustomer).where(ORMCustomer.org_id == org_id, ORMCustomer.phone == data.phone))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Customer with this phone already exists.")

    now = datetime.datetime.now(datetime.timezone.utc)
    c = ORMCustomer(
        id=uuid.uuid4(), org_id=org_id, phone=data.phone,
        name=data.name, preferences=data.preferences, notes=data.notes,
        created_at=now, updated_at=now,
    )
    if hasattr(ORMCustomer, "segment") and data.segment:
        c.segment = data.segment
    db.add(c)
    await db.flush()

    await AuditService.log(db=db, action="create", resource="customer", org_id=org_id, resource_id=str(c.id), detail=f"Created customer: {c.name or c.phone}")
    await db.commit()
    await db.refresh(c)
    return _customer_to_response(c)


# ==================== PARAMETERIZED ROUTES (/{customer_id}) ====================

@router.get("/{customer_id}", response_model=CustomerResponse)
async def get_customer(
    customer_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> CustomerResponse:
    from src.infrastructure.database.models import Customer as ORMCustomer
    stmt = select(ORMCustomer).where(ORMCustomer.id == customer_id, ORMCustomer.org_id == org_id)
    result = await db.execute(stmt)
    c = result.scalar_one_or_none()
    if not c:
        raise HTTPException(status_code=404, detail="Customer not found.")
    return _customer_to_response(c)


@router.patch("/{customer_id}", response_model=CustomerResponse)
async def update_customer(
    customer_id: uuid.UUID,
    data: CustomerUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> CustomerResponse:
    from src.infrastructure.database.models import Customer as ORMCustomer
    stmt = select(ORMCustomer).where(ORMCustomer.id == customer_id, ORMCustomer.org_id == org_id)
    result = await db.execute(stmt)
    c = result.scalar_one_or_none()
    if not c:
        raise HTTPException(status_code=404, detail="Customer not found.")

    if data.name is not None:
        c.name = data.name
    if data.preferences is not None:
        c.preferences = data.preferences
    if data.notes is not None:
        c.notes = data.notes
    c.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(c)
    return _customer_to_response(c)


@router.patch("/{customer_id}/segment", response_model=CustomerResponse)
async def update_customer_segment(
    customer_id: uuid.UUID,
    data: CustomerSegmentUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> CustomerResponse:
    from src.infrastructure.database.models import Customer as ORMCustomer
    stmt = select(ORMCustomer).where(ORMCustomer.id == customer_id, ORMCustomer.org_id == org_id)
    result = await db.execute(stmt)
    c = result.scalar_one_or_none()
    if not c:
        raise HTTPException(status_code=404, detail="Customer not found.")

    old_segment = getattr(c, "segment", None)
    if hasattr(c, "segment"):
        c.segment = data.segment
    c.updated_at = datetime.datetime.now(datetime.timezone.utc)

    from src.infrastructure.database.models import ActivityLog
    log = ActivityLog(org_id=org_id, entity_type="customer", entity_id=customer_id, activity_type="segment_change", description=f"Segment changed from {old_segment} to {data.segment}", performed_by="system")
    db.add(log)
    await AuditService.log(db=db, action="segment_change", resource="customer", org_id=org_id, resource_id=str(customer_id), detail=f"Segment: {old_segment} → {data.segment}")
    await db.commit()
    await db.refresh(c)
    return _customer_to_response(c)


@router.patch("/{customer_id}/assign", response_model=CustomerResponse)
async def assign_customer(
    customer_id: uuid.UUID,
    data: CustomerAssignUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> CustomerResponse:
    from src.infrastructure.database.models import Customer as ORMCustomer
    stmt = select(ORMCustomer).where(ORMCustomer.id == customer_id, ORMCustomer.org_id == org_id)
    result = await db.execute(stmt)
    c = result.scalar_one_or_none()
    if not c:
        raise HTTPException(status_code=404, detail="Customer not found.")

    if hasattr(c, "assigned_to"):
        c.assigned_to = data.assigned_to
    c.updated_at = datetime.datetime.now(datetime.timezone.utc)

    from src.infrastructure.database.models import ActivityLog
    log = ActivityLog(org_id=org_id, entity_type="customer", entity_id=customer_id, activity_type="assignment", description=f"Assigned to {data.assigned_to or 'unassigned'}", performed_by="system")
    db.add(log)
    await AuditService.log(db=db, action="assign", resource="customer", org_id=org_id, resource_id=str(customer_id), detail=f"Assigned to: {data.assigned_to}")
    await db.commit()
    await db.refresh(c)
    return _customer_to_response(c)


@router.get("/{customer_id}/activities")
async def get_customer_activities(
    customer_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200),
) -> List[dict]:
    from src.infrastructure.database.models import ActivityLog, Customer as ORMCustomer
    cust_stmt = select(ORMCustomer).where(ORMCustomer.id == customer_id, ORMCustomer.org_id == org_id)
    cust_result = await db.execute(cust_stmt)
    if not cust_result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Customer not found.")

    stmt = select(ActivityLog).where(
        ActivityLog.org_id == org_id, ActivityLog.entity_type == "customer", ActivityLog.entity_id == customer_id
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


@router.post("/{customer_id}/notes")
async def add_customer_note(
    customer_id: uuid.UUID,
    data: CustomerNoteCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    from src.infrastructure.database.models import ActivityLog, Customer as ORMCustomer
    cust_stmt = select(ORMCustomer).where(ORMCustomer.id == customer_id, ORMCustomer.org_id == org_id)
    cust_result = await db.execute(cust_stmt)
    if not cust_result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Customer not found.")

    log = ActivityLog(org_id=org_id, entity_type="customer", entity_id=customer_id, activity_type="note", description=data.description, performed_by="system")
    db.add(log)
    await db.commit()
    await db.refresh(log)
    return {"id": str(log.id), "activity_type": "note", "description": data.description, "created_at": log.created_at.isoformat()}


@router.delete("/{customer_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_customer(
    customer_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    from src.infrastructure.database.models import Customer as ORMCustomer
    stmt = select(ORMCustomer).where(ORMCustomer.id == customer_id, ORMCustomer.org_id == org_id)
    result = await db.execute(stmt)
    c = result.scalar_one_or_none()
    if not c:
        raise HTTPException(status_code=404, detail="Customer not found.")
    d_stmt = sa_delete(ORMCustomer).where(ORMCustomer.id == customer_id)
    await db.execute(d_stmt)
    await AuditService.log(db=db, action="delete", resource="customer", org_id=org_id, resource_id=str(customer_id), detail=f"Deleted customer: {c.name or c.phone}")
    await db.commit()


@router.delete("/", status_code=status.HTTP_200_OK)
async def bulk_delete_customers(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    ids: Optional[List[uuid.UUID]] = Query(default=None),
    _=Depends(require_role("admin")),
) -> dict:
    from src.infrastructure.database.models import Customer as ORMCustomer
    if ids:
        stmt = sa_delete(ORMCustomer).where(ORMCustomer.id.in_(ids), ORMCustomer.org_id == org_id)
    else:
        stmt = sa_delete(ORMCustomer).where(ORMCustomer.org_id == org_id)
    result = await db.execute(stmt)
    count = result.rowcount or 0
    await AuditService.log(db=db, action="bulk_delete", resource="customer", org_id=org_id, detail=f"Bulk deleted {count} customers")
    await db.commit()
    return {"deleted": count}
