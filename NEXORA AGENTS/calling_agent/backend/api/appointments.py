from __future__ import annotations

from datetime import datetime, timezone
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Appointment
from ..domain.enums import AppointmentStatus
from ..infrastructure.database import AppointmentModel, get_session

router = APIRouter(prefix="/api/v1/appointments", tags=["appointments"])


class AppointmentListResponse(BaseModel):
    items: list[Appointment]
    total: int
    page: int
    limit: int
    pages: int


class CreateAppointmentRequest(BaseModel):
    lead_id: Optional[UUID] = None
    contact_id: Optional[UUID] = None
    call_id: Optional[UUID] = None
    title: str
    description: Optional[str] = None
    scheduled_at: datetime
    duration_minutes: int = 30
    assigned_to: Optional[UUID] = None
    notes: Optional[str] = None


class UpdateAppointmentRequest(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    scheduled_at: Optional[datetime] = None
    duration_minutes: Optional[int] = None
    assigned_to: Optional[UUID] = None
    notes: Optional[str] = None


class RescheduleRequest(BaseModel):
    scheduled_at: datetime
    reason: Optional[str] = None


@router.get("", response_model=AppointmentListResponse)
async def list_appointments(
    status: Optional[str] = Query(None),
    date_from: Optional[datetime] = Query(None),
    date_to: Optional[datetime] = Query(None),
    assigned_to: Optional[UUID] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=200),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_crm")),
):
    query = select(AppointmentModel).where(AppointmentModel.organization_id == str(current_user.organization_id))

    if status:
        query = query.where(AppointmentModel.status == status)
    if date_from:
        query = query.where(AppointmentModel.scheduled_at >= date_from)
    if date_to:
        query = query.where(AppointmentModel.scheduled_at <= date_to)
    if assigned_to:
        query = query.where(AppointmentModel.assigned_to == str(assigned_to))

    count_query = select(func.count()).select_from(query.subquery())
    total = (await session.execute(count_query)).scalar() or 0
    pages = max(1, (total + limit - 1) // limit)
    offset = (page - 1) * limit

    query = query.order_by(desc(AppointmentModel.scheduled_at)).offset(offset).limit(limit)
    result = await session.execute(query)
    models = result.scalars().all()

    return AppointmentListResponse(
        items=[Appointment.model_validate(m) for m in models],
        total=total, page=page, limit=limit, pages=pages,
    )


@router.post("", response_model=Appointment)
async def create_appointment(
    req: CreateAppointmentRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_crm")),
):
    model = AppointmentModel(
        organization_id=str(current_user.organization_id),
        lead_id=str(req.lead_id) if req.lead_id else None,
        contact_id=str(req.contact_id) if req.contact_id else None,
        call_id=str(req.call_id) if req.call_id else None,
        title=req.title,
        description=req.description,
        scheduled_at=req.scheduled_at,
        duration_minutes=req.duration_minutes,
        assigned_to=str(req.assigned_to) if req.assigned_to else None,
        notes=req.notes,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Appointment.model_validate(model)


@router.get("/{appointment_id}", response_model=Appointment)
async def get_appointment(
    appointment_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(AppointmentModel).where(AppointmentModel.id == str(appointment_id))
        .where(AppointmentModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Appointment not found")
    return Appointment.model_validate(model)


@router.put("/{appointment_id}", response_model=Appointment)
async def update_appointment(
    appointment_id: UUID,
    req: UpdateAppointmentRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_crm")),
):
    result = await session.execute(
        select(AppointmentModel).where(AppointmentModel.id == str(appointment_id))
        .where(AppointmentModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Appointment not found")

    update_data = req.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if field == "assigned_to" and value is not None:
            setattr(model, field, str(value))
        elif value is not None:
            setattr(model, field, value)

    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Appointment.model_validate(model)


@router.delete("/{appointment_id}")
async def delete_appointment(
    appointment_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_crm")),
):
    result = await session.execute(
        select(AppointmentModel).where(AppointmentModel.id == str(appointment_id))
        .where(AppointmentModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Appointment not found")

    await session.delete(model)
    return {"deleted": True}


@router.post("/{appointment_id}/confirm", response_model=Appointment)
async def confirm_appointment(
    appointment_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_crm")),
):
    result = await session.execute(
        select(AppointmentModel).where(AppointmentModel.id == str(appointment_id))
        .where(AppointmentModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Appointment not found")
    if model.status != AppointmentStatus.scheduled.value:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only scheduled appointments can be confirmed")

    model.status = AppointmentStatus.confirmed.value
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Appointment.model_validate(model)


@router.post("/{appointment_id}/cancel", response_model=Appointment)
async def cancel_appointment(
    appointment_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_crm")),
):
    result = await session.execute(
        select(AppointmentModel).where(AppointmentModel.id == str(appointment_id))
        .where(AppointmentModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Appointment not found")
    if model.status == AppointmentStatus.completed.value:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot cancel completed appointment")

    model.status = AppointmentStatus.cancelled.value
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Appointment.model_validate(model)


@router.post("/{appointment_id}/reschedule", response_model=Appointment)
async def reschedule_appointment(
    appointment_id: UUID,
    req: RescheduleRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_crm")),
):
    result = await session.execute(
        select(AppointmentModel).where(AppointmentModel.id == str(appointment_id))
        .where(AppointmentModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Appointment not found")
    if model.status == AppointmentStatus.completed.value:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot reschedule completed appointment")

    model.status = AppointmentStatus.rescheduled.value
    model.scheduled_at = req.scheduled_at
    if req.reason:
        model.notes = (model.notes or "") + f"\nRescheduled: {req.reason}"

    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Appointment.model_validate(model)
