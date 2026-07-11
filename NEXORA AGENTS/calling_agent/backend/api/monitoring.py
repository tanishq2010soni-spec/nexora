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
from ..infrastructure.database import CallEventModel, CallModel, get_session

router = APIRouter(prefix="/api/v1/monitoring", tags=["monitoring"])


class LiveCallResponse(BaseModel):
    call: Call
    duration_seconds: int
    events: list[dict[str, Any]]


class WhisperRequest(BaseModel):
    message: str
    target_agent: Optional[str] = None


class BargeRequest(BaseModel):
    message: Optional[str] = None


class CoachingSuggestionRequest(BaseModel):
    suggestion: str
    category: str = "general"


class QueueEntry(BaseModel):
    position: int
    call: Call
    wait_time_seconds: int


@router.get("/live", response_model=list[LiveCallResponse])
async def get_live_calls(
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

    live_calls = []
    for m in models:
        events_result = await session.execute(
            select(CallEventModel)
            .where(CallEventModel.call_id == m.id)
            .order_by(CallEventModel.timestamp)
        )
        events = events_result.scalars().all()

        duration = 0
        if m.started_at:
            duration = int((datetime.now(timezone.utc) - m.started_at).total_seconds())

        live_calls.append(
            LiveCallResponse(
                call=Call.model_validate(m),
                duration_seconds=duration,
                events=[{"id": e.id, "event_type": e.event_type, "data": e.data, "timestamp": e.timestamp.isoformat() if e.timestamp else None} for e in events],
            )
        )

    return live_calls


@router.get("/live/{call_id}", response_model=LiveCallResponse)
async def get_live_call(
    call_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_live_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    events_result = await session.execute(
        select(CallEventModel)
        .where(CallEventModel.call_id == str(call_id))
        .order_by(CallEventModel.timestamp)
    )
    events = events_result.scalars().all()

    duration = 0
    if model.started_at:
        duration = int((datetime.now(timezone.utc) - model.started_at).total_seconds())

    return LiveCallResponse(
        call=Call.model_validate(model),
        duration_seconds=duration,
        events=[{"id": e.id, "event_type": e.event_type, "data": e.data, "timestamp": e.timestamp.isoformat() if e.timestamp else None} for e in events],
    )


@router.get("/live/{call_id}/transcript")
async def get_live_transcript(
    call_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_live_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    events_result = await session.execute(
        select(CallEventModel)
        .where(CallEventModel.call_id == str(call_id))
        .where(CallEventModel.event_type.in_(["transcript", "transcription", "utterance"]))
        .order_by(CallEventModel.timestamp)
    )
    events = events_result.scalars().all()

    return {
        "call_id": call_id,
        "transcript": model.transcript or "",
        "live_events": [
            {"id": e.id, "event_type": e.event_type, "data": e.data, "timestamp": e.timestamp.isoformat() if e.timestamp else None}
            for e in events
        ],
    }


@router.post("/live/{call_id}/whisper")
async def send_whisper(
    call_id: UUID,
    req: WhisperRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("whisper_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    event = CallEventModel(
        call_id=str(call_id),
        organization_id=str(current_user.organization_id),
        event_type="whisper",
        data={
            "message": req.message,
            "target_agent": req.target_agent,
            "sent_by": str(current_user.id),
            "sent_at": datetime.now(timezone.utc).isoformat(),
        },
    )
    session.add(event)
    await session.flush()

    return {"sent": True, "message": req.message}


@router.post("/live/{call_id}/barge")
async def barge_into_call(
    call_id: UUID,
    req: BargeRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("barge_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    event = CallEventModel(
        call_id=str(call_id),
        organization_id=str(current_user.organization_id),
        event_type="barge",
        data={
            "message": req.message,
            "barged_by": str(current_user.id),
            "barged_at": datetime.now(timezone.utc).isoformat(),
        },
    )
    session.add(event)

    model.extra_data = {
        **(model.extra_data or {}),
        "barge_in": True,
        "barge_by": str(current_user.id),
    }
    session.add(model)
    await session.flush()

    return {"barged": True, "message": req.message}


@router.post("/live/{call_id}/coaching-suggestion")
async def send_coaching_suggestion(
    call_id: UUID,
    req: CoachingSuggestionRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("monitor_calls")),
):
    result = await session.execute(
        select(CallModel).where(CallModel.id == str(call_id))
        .where(CallModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Call not found")

    event = CallEventModel(
        call_id=str(call_id),
        organization_id=str(current_user.organization_id),
        event_type="coaching_suggestion",
        data={
            "suggestion": req.suggestion,
            "category": req.category,
            "sent_by": str(current_user.id),
            "sent_at": datetime.now(timezone.utc).isoformat(),
        },
    )
    session.add(event)
    await session.flush()

    return {"sent": True, "suggestion": req.suggestion, "category": req.category}


@router.get("/queue", response_model=list[QueueEntry])
async def get_call_queue(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_call_queue")),
):
    result = await session.execute(
        select(CallModel)
        .where(CallModel.organization_id == str(current_user.organization_id))
        .where(CallModel.status == "queued")
        .order_by(CallModel.created_at)
    )
    models = result.scalars().all()

    now = datetime.now(timezone.utc)
    queue = []
    for i, m in enumerate(models):
        wait_time = int((now - m.created_at).total_seconds()) if m.created_at else 0
        queue.append(
            QueueEntry(
                position=i + 1,
                call=Call.model_validate(m),
                wait_time_seconds=wait_time,
            )
        )

    return queue
