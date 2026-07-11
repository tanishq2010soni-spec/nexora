import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import Task, Note
from src.presentation.api.dependencies import get_current_org_id, require_role

router = APIRouter()


class TaskResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    title: str
    description: Optional[str] = None
    priority: str
    status: str
    assigned_to: Optional[str] = None
    due_date: Optional[str] = None
    reminder_at: Optional[str] = None
    entity_type: Optional[str] = None
    entity_id: Optional[uuid.UUID] = None
    created_at: str
    updated_at: str


class CreateTaskRequest(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    priority: str = Field(default="medium", pattern="^(low|medium|high|urgent)$")
    assigned_to: Optional[str] = None
    due_date: Optional[str] = None
    reminder_at: Optional[str] = None
    entity_type: Optional[str] = None
    entity_id: Optional[uuid.UUID] = None


class UpdateTaskRequest(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    priority: Optional[str] = Field(None, pattern="^(low|medium|high|urgent)$")
    status: Optional[str] = Field(None, pattern="^(pending|in_progress|completed|cancelled)$")
    assigned_to: Optional[str] = None
    due_date: Optional[str] = None


class NoteResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    entity_type: str
    entity_id: uuid.UUID
    content: str
    created_by: Optional[str] = None
    created_at: str


class CreateNoteRequest(BaseModel):
    entity_type: str = Field(..., pattern="^(lead|customer|conversation)$")
    entity_id: uuid.UUID
    content: str = Field(..., min_length=1, max_length=10000)
    created_by: Optional[str] = None


def _task_to_response(t) -> TaskResponse:
    return TaskResponse(
        id=t.id, org_id=t.org_id, title=t.title, description=t.description,
        priority=t.priority, status=t.status, assigned_to=t.assigned_to,
        due_date=t.due_date.isoformat() if t.due_date else None,
        reminder_at=t.reminder_at.isoformat() if t.reminder_at else None,
        entity_type=t.entity_type, entity_id=t.entity_id,
        created_at=t.created_at.isoformat(), updated_at=t.updated_at.isoformat(),
    )


def _note_to_response(n) -> NoteResponse:
    return NoteResponse(
        id=n.id, org_id=n.org_id, entity_type=n.entity_type, entity_id=n.entity_id,
        content=n.content, created_by=n.created_by, created_at=n.created_at.isoformat(),
    )


@router.get("/", response_model=List[TaskResponse])
async def list_tasks(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    status_filter: Optional[str] = Query(default=None, alias="status"),
    priority: Optional[str] = Query(default=None),
    assigned_to: Optional[str] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[TaskResponse]:
    stmt = select(Task).where(Task.org_id == org_id)
    if status_filter:
        stmt = stmt.where(Task.status == status_filter)
    if priority:
        stmt = stmt.where(Task.priority == priority)
    if assigned_to:
        stmt = stmt.where(Task.assigned_to == assigned_to)
    stmt = stmt.order_by(Task.created_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_task_to_response(t) for t in result.scalars().all()]


@router.post("/", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
async def create_task(
    data: CreateTaskRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> TaskResponse:
    now = datetime.datetime.now(datetime.timezone.utc)
    task = Task(
        id=uuid.uuid4(), org_id=org_id, title=data.title, description=data.description,
        priority=data.priority, status="pending", assigned_to=data.assigned_to,
        due_date=datetime.datetime.fromisoformat(data.due_date) if data.due_date else None,
        reminder_at=datetime.datetime.fromisoformat(data.reminder_at) if data.reminder_at else None,
        entity_type=data.entity_type, entity_id=data.entity_id,
        created_at=now, updated_at=now,
    )
    db.add(task)
    await db.commit()
    await db.refresh(task)
    return _task_to_response(task)


@router.patch("/{task_id}", response_model=TaskResponse)
async def update_task(
    task_id: uuid.UUID,
    data: UpdateTaskRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> TaskResponse:
    stmt = select(Task).where(Task.id == task_id, Task.org_id == org_id)
    result = await db.execute(stmt)
    task = result.scalar_one_or_none()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found.")
    if data.title is not None:
        task.title = data.title
    if data.description is not None:
        task.description = data.description
    if data.priority is not None:
        task.priority = data.priority
    if data.status is not None:
        task.status = data.status
    if data.assigned_to is not None:
        task.assigned_to = data.assigned_to
    if data.due_date is not None:
        task.due_date = datetime.datetime.fromisoformat(data.due_date)
    task.updated_at = datetime.datetime.now(datetime.timezone.utc)
    await db.commit()
    await db.refresh(task)
    return _task_to_response(task)


@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_task(
    task_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> None:
    stmt = select(Task).where(Task.id == task_id, Task.org_id == org_id)
    result = await db.execute(stmt)
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Task not found.")
    await db.execute(sa_delete(Task).where(Task.id == task_id))
    await db.commit()


@router.get("/notes", response_model=List[NoteResponse])
async def list_notes(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    entity_type: Optional[str] = Query(default=None),
    entity_id: Optional[uuid.UUID] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[NoteResponse]:
    stmt = select(Note).where(Note.org_id == org_id)
    if entity_type:
        stmt = stmt.where(Note.entity_type == entity_type)
    if entity_id:
        stmt = stmt.where(Note.entity_id == entity_id)
    stmt = stmt.order_by(Note.created_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_note_to_response(n) for n in result.scalars().all()]


@router.post("/notes", response_model=NoteResponse, status_code=status.HTTP_201_CREATED)
async def create_note(
    data: CreateNoteRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> NoteResponse:
    note = Note(
        id=uuid.uuid4(), org_id=org_id, entity_type=data.entity_type,
        entity_id=data.entity_id, content=data.content, created_by=data.created_by,
        created_at=datetime.datetime.now(datetime.timezone.utc),
    )
    db.add(note)
    await db.commit()
    await db.refresh(note)
    return _note_to_response(note)
