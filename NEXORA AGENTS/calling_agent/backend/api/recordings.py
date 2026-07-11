from __future__ import annotations

from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Recording
from ..infrastructure.database import RecordingModel, get_session

router = APIRouter(prefix="/api/v1/recordings", tags=["recordings"])


class RecordingListResponse(BaseModel):
    items: list[Recording]
    total: int
    page: int
    limit: int
    pages: int


@router.get("", response_model=RecordingListResponse)
async def list_recordings(
    status: Optional[str] = Query(None),
    call_id: Optional[UUID] = Query(None),
    is_archived: Optional[bool] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=200),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_recordings")),
):
    query = select(RecordingModel).where(RecordingModel.organization_id == str(current_user.organization_id))

    if status:
        query = query.where(RecordingModel.status == status)
    if call_id:
        query = query.where(RecordingModel.call_id == str(call_id))
    if is_archived is not None:
        query = query.where(RecordingModel.is_archived == is_archived)

    count_query = select(func.count()).select_from(query.subquery())
    total = (await session.execute(count_query)).scalar() or 0
    pages = max(1, (total + limit - 1) // limit)
    offset = (page - 1) * limit

    query = query.order_by(desc(RecordingModel.created_at)).offset(offset).limit(limit)
    result = await session.execute(query)
    models = result.scalars().all()

    return RecordingListResponse(
        items=[Recording.model_validate(m) for m in models],
        total=total, page=page, limit=limit, pages=pages,
    )


@router.get("/{recording_id}", response_model=Recording)
async def get_recording(
    recording_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(RecordingModel).where(RecordingModel.id == str(recording_id))
        .where(RecordingModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Recording not found")
    return Recording.model_validate(model)


@router.delete("/{recording_id}")
async def delete_recording(
    recording_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_recordings")),
):
    result = await session.execute(
        select(RecordingModel).where(RecordingModel.id == str(recording_id))
        .where(RecordingModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Recording not found")

    await session.delete(model)
    return {"deleted": True}


@router.post("/{recording_id}/transcribe", response_model=Recording)
async def transcribe_recording(
    recording_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_recordings")),
):
    result = await session.execute(
        select(RecordingModel).where(RecordingModel.id == str(recording_id))
        .where(RecordingModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Recording not found")

    model.transcription_status = "processing"
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Recording.model_validate(model)


@router.get("/{recording_id}/transcript")
async def get_transcript(
    recording_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(RecordingModel).where(RecordingModel.id == str(recording_id))
        .where(RecordingModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Recording not found")

    return {
        "recording_id": recording_id,
        "transcription_status": model.transcription_status,
        "transcription_text": model.transcription_text,
    }


@router.post("/{recording_id}/archive", response_model=Recording)
async def archive_recording(
    recording_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_recordings")),
):
    result = await session.execute(
        select(RecordingModel).where(RecordingModel.id == str(recording_id))
        .where(RecordingModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Recording not found")

    model.is_archived = True
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Recording.model_validate(model)
