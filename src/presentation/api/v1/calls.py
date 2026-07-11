import uuid
import datetime
import json
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import Call, CallRecording, CallQueue
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService

router = APIRouter()


class CallResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    agent_id: Optional[uuid.UUID] = None
    direction: str
    caller_number: str
    callee_number: str
    status: str
    started_at: Optional[str] = None
    answered_at: Optional[str] = None
    ended_at: Optional[str] = None
    duration_seconds: int = 0
    recording_url: Optional[str] = None
    transcription: Optional[str] = None
    sentiment: Optional[str] = None
    outcome: Optional[str] = None
    created_at: str
    updated_at: str


class CreateCallRequest(BaseModel):
    agent_id: Optional[uuid.UUID] = None
    direction: str = Field(..., pattern="^(inbound|outbound)$")
    caller_number: str = Field(..., min_length=1, max_length=50)
    callee_number: str = Field(..., min_length=1, max_length=50)


class UpdateCallRequest(BaseModel):
    status: Optional[str] = Field(None, pattern="^(ringing|in_progress|completed|failed|missed)$")
    started_at: Optional[str] = None
    answered_at: Optional[str] = None
    ended_at: Optional[str] = None
    duration_seconds: Optional[int] = None
    recording_url: Optional[str] = None
    transcription: Optional[str] = None
    sentiment: Optional[str] = Field(None, pattern="^(positive|neutral|negative)$")
    outcome: Optional[str] = Field(None, pattern="^(qualified|appointment_booked|callback_requested|no_answer|wrong_number)$")


class CallQueueResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    name: str
    description: Optional[str] = None
    routing_strategy: str
    max_wait_time: int
    is_active: bool
    created_at: str


class CreateCallQueueRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    routing_strategy: str = Field(default="round_robin", pattern="^(round_robin|least_recent|random)$")
    max_wait_time: int = Field(default=300, ge=30, le=3600)


def _call_to_response(c) -> CallResponse:
    return CallResponse(
        id=c.id,
        org_id=c.org_id,
        agent_id=c.agent_id,
        direction=c.direction,
        caller_number=c.caller_number,
        callee_number=c.callee_number,
        status=c.status,
        started_at=c.started_at.isoformat() if c.started_at else None,
        answered_at=c.answered_at.isoformat() if c.answered_at else None,
        ended_at=c.ended_at.isoformat() if c.ended_at else None,
        duration_seconds=c.duration_seconds,
        recording_url=c.recording_url,
        transcription=c.transcription,
        sentiment=c.sentiment,
        outcome=c.outcome,
        created_at=c.created_at.isoformat(),
        updated_at=c.updated_at.isoformat(),
    )


def _queue_to_response(q) -> CallQueueResponse:
    return CallQueueResponse(
        id=q.id,
        org_id=q.org_id,
        name=q.name,
        description=q.description,
        routing_strategy=q.routing_strategy,
        max_wait_time=q.max_wait_time,
        is_active=q.is_active,
        created_at=q.created_at.isoformat(),
    )


@router.get("/calls", response_model=List[CallResponse])
async def list_calls(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    direction: Optional[str] = Query(default=None),
    status_filter: Optional[str] = Query(default=None, alias="status"),
    agent_id: Optional[uuid.UUID] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[CallResponse]:
    stmt = select(Call).where(Call.org_id == org_id)
    if direction:
        stmt = stmt.where(Call.direction == direction)
    if status_filter:
        stmt = stmt.where(Call.status == status_filter)
    if agent_id:
        stmt = stmt.where(Call.agent_id == agent_id)
    stmt = stmt.order_by(Call.created_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_call_to_response(c) for c in result.scalars().all()]


@router.get("/calls/{call_id}", response_model=CallResponse)
async def get_call(
    call_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> CallResponse:
    stmt = select(Call).where(Call.id == call_id, Call.org_id == org_id)
    result = await db.execute(stmt)
    call = result.scalar_one_or_none()
    if not call:
        raise HTTPException(status_code=404, detail="Call not found.")
    return _call_to_response(call)


@router.post("/calls", response_model=CallResponse, status_code=status.HTTP_201_CREATED)
async def create_call(
    data: CreateCallRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> CallResponse:
    from src.infrastructure.integrations.twilio_service import TwilioCallManager
    manager = TwilioCallManager(db)
    call = await manager.create_call(
        org_id=org_id,
        direction=data.direction,
        caller_number=data.caller_number,
        callee_number=data.callee_number,
        agent_id=data.agent_id,
    )
    await AuditService.log(
        db=db, action="create", resource="call",
        org_id=org_id, resource_id=str(call.id),
        detail=f"{data.direction} call created",
    )
    await db.commit()
    await db.refresh(call)
    return _call_to_response(call)


@router.post("/calls/{call_id}/initiate", response_model=CallResponse)
async def initiate_twilio_call(
    call_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> CallResponse:
    stmt = select(Call).where(Call.id == call_id, Call.org_id == org_id)
    result = await db.execute(stmt)
    call = result.scalar_one_or_none()
    if not call:
        raise HTTPException(status_code=404, detail="Call not found.")

    from src.infrastructure.integrations.twilio_service import TwilioVoiceService
    from src.config import settings
    twilio_sid = getattr(settings, "TWILIO_ACCOUNT_SID", "")
    twilio_token = getattr(settings, "TWILIO_AUTH_TOKEN", "")
    twilio_from = getattr(settings, "TWILIO_PHONE_NUMBER", "")

    if not twilio_sid or not twilio_token:
        raise HTTPException(status_code=400, detail="Twilio not configured")

    svc = TwilioVoiceService(twilio_sid, twilio_token)
    base_url = settings.PUBLIC_BASE_URL
    try:
        twilio_result = await svc.initiate_outbound_call(
            to_number=call.callee_number,
            from_number=twilio_from,
            webhook_url=f"{base_url}/api/v1/calls/twiml/{call.id}",
            status_callback_url=f"{base_url}/api/v1/calls/status-callback/{call.id}",
            record=True,
        )
        call.status = "ringing"
        call.started_at = datetime.datetime.now(datetime.timezone.utc)
        call.updated_at = datetime.datetime.now(datetime.timezone.utc)
        await db.commit()
        await db.refresh(call)
    except Exception as e:
        call.status = "failed"
        call.updated_at = datetime.datetime.now(datetime.timezone.utc)
        await db.commit()
        await db.refresh(call)
        raise HTTPException(status_code=502, detail=f"Twilio call failed: {str(e)}")

    return _call_to_response(call)


@router.post("/calls/status-callback/{call_id}")
async def call_status_callback(
    call_id: uuid.UUID,
    CallStatus: str = "",
    CallDuration: str = "",
    RecordingUrl: str = "",
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    from src.infrastructure.integrations.twilio_service import TwilioCallManager
    manager = TwilioCallManager(db)
    try:
        duration = int(CallDuration) if CallDuration else None
    except ValueError:
        duration = None

    await manager.update_call_from_twilio(
        call_id=call_id,
        twilio_status=CallStatus,
        duration=duration,
        recording_url=RecordingUrl if RecordingUrl else None,
    )
    await db.commit()
    return {"status": "ok"}


@router.patch("/calls/{call_id}", response_model=CallResponse)
async def update_call(
    call_id: uuid.UUID,
    data: UpdateCallRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> CallResponse:
    stmt = select(Call).where(Call.id == call_id, Call.org_id == org_id)
    result = await db.execute(stmt)
    call = result.scalar_one_or_none()
    if not call:
        raise HTTPException(status_code=404, detail="Call not found.")

    if data.status is not None:
        call.status = data.status
    if data.started_at is not None:
        call.started_at = datetime.datetime.fromisoformat(data.started_at)
    if data.answered_at is not None:
        call.answered_at = datetime.datetime.fromisoformat(data.answered_at)
    if data.ended_at is not None:
        call.ended_at = datetime.datetime.fromisoformat(data.ended_at)
    if data.duration_seconds is not None:
        call.duration_seconds = data.duration_seconds
    if data.recording_url is not None:
        call.recording_url = data.recording_url
    if data.transcription is not None:
        call.transcription = data.transcription
    if data.sentiment is not None:
        call.sentiment = data.sentiment
    if data.outcome is not None:
        call.outcome = data.outcome
    call.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(call)
    return _call_to_response(call)


@router.get("/calls/analytics")
async def call_analytics(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    stmt = select(Call).where(Call.org_id == org_id)
    result = await db.execute(stmt)
    calls = result.scalars().all()

    total = len(calls)
    inbound = sum(1 for c in calls if c.direction == "inbound")
    outbound = sum(1 for c in calls if c.direction == "outbound")
    completed = sum(1 for c in calls if c.status == "completed")
    missed = sum(1 for c in calls if c.status == "missed")
    total_duration = sum(c.duration_seconds for c in calls)
    avg_duration = round(total_duration / completed, 1) if completed else 0

    sentiment_breakdown = {}
    outcome_breakdown = {}
    for c in calls:
        if c.sentiment:
            sentiment_breakdown[c.sentiment] = sentiment_breakdown.get(c.sentiment, 0) + 1
        if c.outcome:
            outcome_breakdown[c.outcome] = outcome_breakdown.get(c.outcome, 0) + 1

    return {
        "total_calls": total,
        "inbound_calls": inbound,
        "outbound_calls": outbound,
        "completed_calls": completed,
        "missed_calls": missed,
        "total_duration_seconds": total_duration,
        "avg_duration_seconds": avg_duration,
        "answer_rate": round(completed / total * 100, 1) if total else 0.0,
        "sentiment_breakdown": sentiment_breakdown,
        "outcome_breakdown": outcome_breakdown,
    }


@router.get("/queues", response_model=List[CallQueueResponse])
async def list_queues(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> List[CallQueueResponse]:
    stmt = select(CallQueue).where(CallQueue.org_id == org_id).order_by(CallQueue.created_at.desc())
    result = await db.execute(stmt)
    return [_queue_to_response(q) for q in result.scalars().all()]


@router.post("/queues", response_model=CallQueueResponse, status_code=status.HTTP_201_CREATED)
async def create_queue(
    data: CreateCallQueueRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> CallQueueResponse:
    now = datetime.datetime.now(datetime.timezone.utc)
    queue = CallQueue(
        id=uuid.uuid4(),
        org_id=org_id,
        name=data.name,
        description=data.description,
        routing_strategy=data.routing_strategy,
        max_wait_time=data.max_wait_time,
        is_active=True,
        created_at=now,
    )
    db.add(queue)
    await db.commit()
    await db.refresh(queue)
    return _queue_to_response(queue)


@router.delete("/queues/{queue_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_queue(
    queue_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    stmt = select(CallQueue).where(CallQueue.id == queue_id, CallQueue.org_id == org_id)
    result = await db.execute(stmt)
    queue = result.scalar_one_or_none()
    if not queue:
        raise HTTPException(status_code=404, detail="Queue not found.")
    await db.execute(sa_delete(CallQueue).where(CallQueue.id == queue_id))
    await db.commit()
