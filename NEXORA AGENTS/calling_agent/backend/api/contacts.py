from __future__ import annotations

from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import select, func, desc, or_
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Appointment, Call, Contact
from ..infrastructure.database import AppointmentModel, CallModel, ContactModel, get_session

router = APIRouter(prefix="/api/v1/contacts", tags=["contacts"])


class ContactListResponse(BaseModel):
    items: list[Contact]
    total: int
    page: int
    limit: int
    pages: int


class CreateContactRequest(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: str
    email: Optional[str] = None
    company: Optional[str] = None
    position: Optional[str] = None
    tags: list[str] = []
    custom_fields: dict[str, Any] = {}


class UpdateContactRequest(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    company: Optional[str] = None
    position: Optional[str] = None
    tags: Optional[list[str]] = None
    custom_fields: Optional[dict[str, Any]] = None


@router.get("", response_model=ContactListResponse)
async def list_contacts(
    search: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=200),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_crm")),
):
    query = select(ContactModel).where(ContactModel.organization_id == str(current_user.organization_id))

    if search:
        search_filter = f"%{search}%"
        query = query.where(
            or_(
                ContactModel.first_name.ilike(search_filter),
                ContactModel.last_name.ilike(search_filter),
                ContactModel.phone.ilike(search_filter),
                ContactModel.email.ilike(search_filter),
                ContactModel.company.ilike(search_filter),
            )
        )

    count_query = select(func.count()).select_from(query.subquery())
    total = (await session.execute(count_query)).scalar() or 0
    pages = max(1, (total + limit - 1) // limit)
    offset = (page - 1) * limit

    query = query.order_by(desc(ContactModel.created_at)).offset(offset).limit(limit)
    result = await session.execute(query)
    models = result.scalars().all()

    return ContactListResponse(
        items=[Contact.model_validate(m) for m in models],
        total=total, page=page, limit=limit, pages=pages,
    )


@router.post("", response_model=Contact)
async def create_contact(
    req: CreateContactRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_crm")),
):
    model = ContactModel(
        organization_id=str(current_user.organization_id),
        first_name=req.first_name,
        last_name=req.last_name,
        phone=req.phone,
        email=req.email,
        company=req.company,
        position=req.position,
        tags=req.tags,
        custom_fields=req.custom_fields,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Contact.model_validate(model)


@router.get("/{contact_id}", response_model=Contact)
async def get_contact(
    contact_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(ContactModel).where(ContactModel.id == str(contact_id))
        .where(ContactModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Contact not found")
    return Contact.model_validate(model)


@router.put("/{contact_id}", response_model=Contact)
async def update_contact(
    contact_id: UUID,
    req: UpdateContactRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_crm")),
):
    result = await session.execute(
        select(ContactModel).where(ContactModel.id == str(contact_id))
        .where(ContactModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Contact not found")

    update_data = req.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(model, field, value)

    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Contact.model_validate(model)


@router.delete("/{contact_id}")
async def delete_contact(
    contact_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_crm")),
):
    result = await session.execute(
        select(ContactModel).where(ContactModel.id == str(contact_id))
        .where(ContactModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Contact not found")

    await session.delete(model)
    return {"deleted": True}


@router.get("/{contact_id}/calls", response_model=list[Call])
async def get_contact_calls(
    contact_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(CallModel).where(CallModel.contact_id == str(contact_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
        .order_by(desc(CallModel.created_at))
    )
    models = result.scalars().all()
    return [Call.model_validate(m) for m in models]


@router.get("/{contact_id}/appointments", response_model=list[Appointment])
async def get_contact_appointments(
    contact_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(AppointmentModel).where(AppointmentModel.contact_id == str(contact_id))
        .where(AppointmentModel.organization_id == str(current_user.organization_id))
        .order_by(desc(AppointmentModel.scheduled_at))
    )
    models = result.scalars().all()
    return [Appointment.model_validate(m) for m in models]
