import uuid
import datetime
import json
from typing import Any, Dict, List, Optional
from fastapi import APIRouter, Body, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import Workflow, WorkflowExecution
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService

router = APIRouter()


class WorkflowResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    name: str
    description: Optional[str] = None
    trigger_type: str
    is_active: bool
    nodes_json: str
    edges_json: str
    execution_count: int
    last_executed_at: Optional[str] = None
    created_at: str
    updated_at: str


class CreateWorkflowRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    trigger_type: str = Field(..., pattern="^(new_lead|customer_replied|call_missed|appointment_booked|manual)$")
    nodes_json: str = Field(default="[]")
    edges_json: str = Field(default="[]")


class UpdateWorkflowRequest(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    is_active: Optional[bool] = None
    nodes_json: Optional[str] = None
    edges_json: Optional[str] = None


class WorkflowExecutionResponse(BaseModel):
    id: uuid.UUID
    workflow_id: uuid.UUID
    trigger_event: str
    status: str
    input_json: Optional[str] = None
    output_json: Optional[str] = None
    error_message: Optional[str] = None
    started_at: str
    completed_at: Optional[str] = None


def _workflow_to_response(w) -> WorkflowResponse:
    return WorkflowResponse(
        id=w.id,
        org_id=w.org_id,
        name=w.name,
        description=w.description,
        trigger_type=w.trigger_type,
        is_active=w.is_active,
        nodes_json=w.nodes_json,
        edges_json=w.edges_json,
        execution_count=w.execution_count,
        last_executed_at=w.last_executed_at.isoformat() if w.last_executed_at else None,
        created_at=w.created_at.isoformat(),
        updated_at=w.updated_at.isoformat(),
    )


def _exec_to_response(e) -> WorkflowExecutionResponse:
    return WorkflowExecutionResponse(
        id=e.id,
        workflow_id=e.workflow_id,
        trigger_event=e.trigger_event,
        status=e.status,
        input_json=e.input_json,
        output_json=e.output_json,
        error_message=e.error_message,
        started_at=e.started_at.isoformat(),
        completed_at=e.completed_at.isoformat() if e.completed_at else None,
    )


@router.get("/", response_model=List[WorkflowResponse])
async def list_workflows(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    trigger_type: Optional[str] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[WorkflowResponse]:
    stmt = select(Workflow).where(Workflow.org_id == org_id)
    if trigger_type:
        stmt = stmt.where(Workflow.trigger_type == trigger_type)
    stmt = stmt.order_by(Workflow.created_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_workflow_to_response(w) for w in result.scalars().all()]


@router.get("/{workflow_id}", response_model=WorkflowResponse)
async def get_workflow(
    workflow_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> WorkflowResponse:
    stmt = select(Workflow).where(Workflow.id == workflow_id, Workflow.org_id == org_id)
    result = await db.execute(stmt)
    wf = result.scalar_one_or_none()
    if not wf:
        raise HTTPException(status_code=404, detail="Workflow not found.")
    return _workflow_to_response(wf)


@router.post("/", response_model=WorkflowResponse, status_code=status.HTTP_201_CREATED)
async def create_workflow(
    data: CreateWorkflowRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> WorkflowResponse:
    now = datetime.datetime.now(datetime.timezone.utc)
    wf = Workflow(
        id=uuid.uuid4(),
        org_id=org_id,
        name=data.name,
        description=data.description,
        trigger_type=data.trigger_type,
        is_active=True,
        nodes_json=data.nodes_json,
        edges_json=data.edges_json,
        execution_count=0,
        created_at=now,
        updated_at=now,
    )
    db.add(wf)
    await AuditService.log(
        db=db, action="create", resource="workflow",
        org_id=org_id, resource_id=str(wf.id),
        detail=f"Workflow '{data.name}' created",
    )
    await db.commit()
    await db.refresh(wf)
    return _workflow_to_response(wf)


@router.patch("/{workflow_id}", response_model=WorkflowResponse)
async def update_workflow(
    workflow_id: uuid.UUID,
    data: UpdateWorkflowRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> WorkflowResponse:
    stmt = select(Workflow).where(Workflow.id == workflow_id, Workflow.org_id == org_id)
    result = await db.execute(stmt)
    wf = result.scalar_one_or_none()
    if not wf:
        raise HTTPException(status_code=404, detail="Workflow not found.")

    if data.name is not None:
        wf.name = data.name
    if data.description is not None:
        wf.description = data.description
    if data.is_active is not None:
        wf.is_active = data.is_active
    if data.nodes_json is not None:
        wf.nodes_json = data.nodes_json
    if data.edges_json is not None:
        wf.edges_json = data.edges_json
    wf.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(wf)
    return _workflow_to_response(wf)


@router.delete("/{workflow_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_workflow(
    workflow_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    stmt = select(Workflow).where(Workflow.id == workflow_id, Workflow.org_id == org_id)
    result = await db.execute(stmt)
    wf = result.scalar_one_or_none()
    if not wf:
        raise HTTPException(status_code=404, detail="Workflow not found.")
    await db.execute(sa_delete(WorkflowExecution).where(WorkflowExecution.workflow_id == workflow_id))
    await db.execute(sa_delete(Workflow).where(Workflow.id == workflow_id))
    await AuditService.log(
        db=db, action="delete", resource="workflow",
        org_id=org_id, resource_id=str(workflow_id),
        detail=f"Workflow deleted",
    )
    await db.commit()


@router.get("/{workflow_id}/executions", response_model=List[WorkflowExecutionResponse])
async def list_executions(
    workflow_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
) -> List[WorkflowExecutionResponse]:
    wf_stmt = select(Workflow).where(Workflow.id == workflow_id, Workflow.org_id == org_id)
    wf_result = await db.execute(wf_stmt)
    if not wf_result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Workflow not found.")

    stmt = (
        select(WorkflowExecution)
        .where(WorkflowExecution.workflow_id == workflow_id)
        .order_by(WorkflowExecution.started_at.desc())
        .limit(limit)
        .offset(offset)
    )
    result = await db.execute(stmt)
    return [_exec_to_response(e) for e in result.scalars().all()]


class ExecuteWorkflowRequest(BaseModel):
    input_data: Optional[Dict[str, Any]] = Field(default=None)


@router.post("/{workflow_id}/execute", response_model=WorkflowExecutionResponse, status_code=status.HTTP_201_CREATED)
async def execute_workflow(
    workflow_id: uuid.UUID,
    data: ExecuteWorkflowRequest = Body(default=ExecuteWorkflowRequest()),
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> WorkflowExecutionResponse:
    wf_stmt = select(Workflow).where(Workflow.id == workflow_id, Workflow.org_id == org_id)
    wf_result = await db.execute(wf_stmt)
    wf = wf_result.scalar_one_or_none()
    if not wf:
        raise HTTPException(status_code=404, detail="Workflow not found.")
    if not wf.is_active:
        raise HTTPException(status_code=400, detail="Workflow is not active.")

    from src.application.services.workflow_engine import WorkflowEngine
    engine = WorkflowEngine(db=db, org_id=org_id)
    execution = await engine.execute_workflow(
        workflow=wf,
        trigger_event="manual",
        input_data=data.input_data,
    )
    return _exec_to_response(execution)
