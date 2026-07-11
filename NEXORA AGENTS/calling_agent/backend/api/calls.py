from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Call, CallEvent
from ..domain.enums import CallDisposition, CallStatus
from ..infrastructure.database import CallEventModel, CallModel, get_session

router = APIRouter(prefix="/api/v1/calls", tags=["calls"])


class CallListResponse(BaseModel):
    items: list[Call]
    total: int
    page: int
    limit: int
    pages: int


class StatusUpdateRequest(BaseModel):
    status: str


class DispositionRequest(BaseModel):
    disposition: str


class AssignRequest(BaseModel):
    user_id: UUID


class NotesRequest(BaseModel):
    note: str
    author: Optional[str] = None


class TagsRequest(BaseModel):
    tags: list[str]


class QualityRequest(BaseModel):
    score: float


class TransferRequest(BaseModel):
    target_number: str
    target_type: Optional[str] = None


class ConferenceRequest(BaseModel):
    numbers: list[str]


class HandoffRequest(BaseModel):
    user_id: UUID
    reason: Optional[str] = None


@router.get("", response_model=CallListResponse)
async def list_calls(
    status: Optional[str] = Query(None),
    direction: Optional[str] = Query(None),
    campaign_id: Optional[UUID] = Query(None),
    lead_id: Optional[UUID] = Query(None),
    user_id: Optional[UUID] = Query(None),
    date_from: Optional[datetime] = Query(None),
    date_to: Optional[datetime] = Query(None),
    search: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=200),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_dashboard")),
):
    query = select(CallModel).where(CallModel.organization_id == str(current_user.organization_id))

    if status:
        query = query.where(CallModel.status == status)
    if direction:
        query = query.where(CallModel.direction == direction)
    if campaign_id:
        query = query.where(CallModel.campaign_id == str(campaign_id))
    if lead_id:
        query = query.where(CallModel.lead_id == str(lead_id))
    if user_id:
        query = query.where(CallModel.user_id == str(user_id))
    if date_from:
        query = query.where(CallModel.created_at >= date_from)
    if date_to:
        query = query.where(CallModel.created_at <= date_to)
    if search:
        search_filter = f"%{search}%"
        query = query.where(
            CallModel.from_number.ilike(search_filter)
            | CallModel.to_number.ilike(search_filter)
            | CallModel.notes.cast(str).ilike(search_filter)
        )

    count_query = select(func.count()).select_from(query.subquery())
    total_result = await session.execute(count_query)
    total = total_result.scalar() or 0

    pages = max(1, (total + limit - 1) // limit)
    offset = (page - 1) * limit
    query = query.order_by(desc(CallModel.created_at)).offset(offset).limit(limit)
    result = await session.execute(query)
    models = result.scalars().all()
    calls = [Call.model_validate(m) for m in models]

    return CallListResponse(items=calls, total=total, page=page, limit=limit, pages=pages)


@router.get("/active", response_model=list[Call])
async def get_active_calls(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_live_calls")),
):
    active_statuses = ["ringing", "in_progress", "hold", "transferring", "conferencing"]
    result = await session.execute(
        select(CallModel)
        .where(CallModel.organization_id == str(current_user.organization_id))
        .where(CallModel.status.in_(active_statuses))
        .order_by(desc(CallModel.created_at))
    )
    models = result.scalars().all()
    return [Call.model_validate(m) for m in models]


@router.get("/{call_id}", response_model=Call)
async def get_call(
    call_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")
    return Call.model_validate(model)


@router.patch("/{call_id}/status", response_model=Call)
async def update_call_status(
    call_id: UUID,
    req: StatusUpdateRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    valid_statuses = [s.value for s in CallStatus]
    if req.status not in valid_statuses:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=f"Invalid status. Valid: {valid_statuses}")

    model.status = req.status
    if req.status == CallStatus.in_progress.value and not model.started_at:
        model.started_at = datetime.now(timezone.utc)
    if req.status in (CallStatus.completed.value, CallStatus.failed.value, CallStatus.missed.value, CallStatus.cancelled.value):
        model.ended_at = datetime.now(timezone.utc)
        if model.started_at and not model.duration_seconds:
            model.duration_seconds = int((model.ended_at - model.started_at).total_seconds())

    session.add(model)
    await session.flush()
    await session.refresh(model)

    event = CallEventModel(
        call_id=str(call_id),
        organization_id=str(current_user.organization_id),
        event_type="status_change",
        data={"old_status": model.status, "new_status": req.status, "changed_by": str(current_user.id)},
    )
    session.add(event)

    return Call.model_validate(model)


@router.patch("/{call_id}/disposition", response_model=Call)
async def set_call_disposition(
    call_id: UUID,
    req: DispositionRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    valid_dispositions = [d.value for d in CallDisposition]
    if req.disposition not in valid_dispositions:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=f"Invalid disposition. Valid: {valid_dispositions}")

    model.disposition = req.disposition
    session.add(model)
    await session.flush()
    await session.refresh(model)

    event = CallEventModel(
        call_id=str(call_id),
        organization_id=str(current_user.organization_id),
        event_type="disposition_set",
        data={"disposition": req.disposition, "set_by": str(current_user.id)},
    )
    session.add(event)

    return Call.model_validate(model)


@router.patch("/{call_id}/assign", response_model=Call)
async def assign_call(
    call_id: UUID,
    req: AssignRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    model.user_id = str(req.user_id)
    session.add(model)
    await session.flush()
    await session.refresh(model)

    event = CallEventModel(
        call_id=str(call_id),
        organization_id=str(current_user.organization_id),
        event_type="assigned",
        data={"assigned_to": str(req.user_id), "assigned_by": str(current_user.id)},
    )
    session.add(event)

    return Call.model_validate(model)


@router.patch("/{call_id}/notes", response_model=Call)
async def add_call_note(
    call_id: UUID,
    req: NotesRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

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
    return Call.model_validate(model)


@router.patch("/{call_id}/tags", response_model=Call)
async def update_call_tags(
    call_id: UUID,
    req: TagsRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    model.tags = req.tags
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Call.model_validate(model)


@router.patch("/{call_id}/quality", response_model=Call)
async def set_call_quality(
    call_id: UUID,
    req: QualityRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_calls")),
):
    if req.score < 0 or req.score > 100:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Score must be between 0 and 100")

    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    model.quality_score = req.score
    session.add(model)
    await session.flush()
    await session.refresh(model)

    event = CallEventModel(
        call_id=str(call_id),
        organization_id=str(current_user.organization_id),
        event_type="quality_set",
        data={"score": req.score, "set_by": str(current_user.id)},
    )
    session.add(event)

    return Call.model_validate(model)


@router.post("/{call_id}/hold", response_model=Call)
async def hold_call(
    call_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")
    if model.status != CallStatus.in_progress.value:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Call must be in_progress to hold")

    model.status = CallStatus.hold.value
    session.add(model)
    await session.flush()
    await session.refresh(model)

    event = CallEventModel(
        call_id=str(call_id),
        organization_id=str(current_user.organization_id),
        event_type="hold",
        data={"action_by": str(current_user.id)},
    )
    session.add(event)

    return Call.model_validate(model)


@router.post("/{call_id}/resume", response_model=Call)
async def resume_call(
    call_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")
    if model.status != CallStatus.hold.value:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Call must be on hold to resume")

    model.status = CallStatus.in_progress.value
    session.add(model)
    await session.flush()
    await session.refresh(model)

    event = CallEventModel(
        call_id=str(call_id),
        organization_id=str(current_user.organization_id),
        event_type="resume",
        data={"action_by": str(current_user.id)},
    )
    session.add(event)

    return Call.model_validate(model)


@router.post("/{call_id}/transfer", response_model=Call)
async def transfer_call(
    call_id: UUID,
    req: TransferRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    model.status = CallStatus.transferring.value
    model.extra_data = {
        **(model.extra_data or {}),
        "transfer_target": req.target_number,
        "transfer_type": req.target_type or "number",
    }
    session.add(model)
    await session.flush()
    await session.refresh(model)

    event = CallEventModel(
        call_id=str(call_id),
        organization_id=str(current_user.organization_id),
        event_type="transfer",
        data={"target_number": req.target_number, "target_type": req.target_type, "action_by": str(current_user.id)},
    )
    session.add(event)

    return Call.model_validate(model)


@router.post("/{call_id}/conference", response_model=Call)
async def conference_call(
    call_id: UUID,
    req: ConferenceRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    model.status = CallStatus.conferencing.value
    model.extra_data = {
        **(model.extra_data or {}),
        "conference_participants": [str(n) for n in req.numbers],
    }
    session.add(model)
    await session.flush()
    await session.refresh(model)

    event = CallEventModel(
        call_id=str(call_id),
        organization_id=str(current_user.organization_id),
        event_type="conference",
        data={"participants": [str(n) for n in req.numbers], "action_by": str(current_user.id)},
    )
    session.add(event)

    return Call.model_validate(model)


@router.post("/{call_id}/handoff", response_model=Call)
async def handoff_call(
    call_id: UUID,
    req: HandoffRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    model.ai_handled = False
    model.handoff_to = str(req.user_id)
    model.handoff_reason = req.reason
    session.add(model)
    await session.flush()
    await session.refresh(model)

    event = CallEventModel(
        call_id=str(call_id),
        organization_id=str(current_user.organization_id),
        event_type="handoff",
        data={"handoff_to": str(req.user_id), "reason": req.reason, "action_by": str(current_user.id)},
    )
    session.add(event)

    return Call.model_validate(model)


@router.get("/{call_id}/events", response_model=list[CallEvent])
async def get_call_events(
    call_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(CallEventModel)
        .where(CallEventModel.call_id == str(call_id))
        .where(CallEventModel.organization_id == str(current_user.organization_id))
        .order_by(CallEventModel.timestamp)
    )
    models = result.scalars().all()
    return [CallEvent.model_validate(m) for m in models]
