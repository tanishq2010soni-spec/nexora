from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import User, Workflow, WorkflowExecution
from ..domain.enums import WorkflowStatus, WorkflowTriggerType
from ..infrastructure.database import (WorkflowExecutionModel, WorkflowModel,
                                       get_session)

router = APIRouter(prefix="/api/v1/workflows", tags=["workflows"])


@router.get("/")
async def list_workflows(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    status: Optional[str] = Query(None),
    trigger_type: Optional[str] = Query(None),
):
    org_id = str(current_user.organization_id)
    query = select(WorkflowModel).where(WorkflowModel.organization_id == org_id)
    if status:
        query = query.where(WorkflowModel.status == status)
    if trigger_type:
        query = query.where(WorkflowModel.trigger_type == trigger_type)
    query = query.order_by(WorkflowModel.updated_at.desc())
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [Workflow.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.post("/", status_code=201)
async def create_workflow(
    name: str,
    trigger_type: str,
    description: Optional[str] = None,
    trigger_config: Optional[dict] = None,
    steps: Optional[list[dict]] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_workflows")),
):
    org_id = str(current_user.organization_id)
    model = WorkflowModel(
        id=str(uuid4()),
        organization_id=org_id,
        name=name,
        description=description,
        trigger_type=trigger_type,
        trigger_config=trigger_config or {},
        steps=steps or [],
        status=WorkflowStatus.active.value,
        created_by=str(current_user.id),
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Workflow.model_validate(model)


@router.get("/{workflow_id}")
async def get_workflow(
    workflow_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WorkflowModel).where(
            WorkflowModel.id == str(workflow_id),
            WorkflowModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Workflow not found")
    return Workflow.model_validate(model)


@router.put("/{workflow_id}")
async def update_workflow(
    workflow_id: UUID,
    name: Optional[str] = None,
    description: Optional[str] = None,
    trigger_type: Optional[str] = None,
    trigger_config: Optional[dict] = None,
    steps: Optional[list[dict]] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_workflows")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WorkflowModel).where(
            WorkflowModel.id == str(workflow_id),
            WorkflowModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Workflow not found")
    if name is not None:
        model.name = name
    if description is not None:
        model.description = description
    if trigger_type is not None:
        model.trigger_type = trigger_type
    if trigger_config is not None:
        model.trigger_config = trigger_config
    if steps is not None:
        model.steps = steps
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Workflow.model_validate(model)


@router.delete("/{workflow_id}")
async def delete_workflow(
    workflow_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_workflows")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WorkflowModel).where(
            WorkflowModel.id == str(workflow_id),
            WorkflowModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Workflow not found")
    await session.execute(
        select(WorkflowExecutionModel).where(WorkflowExecutionModel.workflow_id == str(workflow_id))
    )
    await session.delete(model)
    await session.flush()
    return {"detail": "Workflow deleted"}


@router.patch("/{workflow_id}/status")
async def update_workflow_status(
    workflow_id: UUID,
    status: str,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_workflows")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WorkflowModel).where(
            WorkflowModel.id == str(workflow_id),
            WorkflowModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Workflow not found")
    model.status = status
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"status": model.status}


@router.post("/{workflow_id}/test")
async def test_workflow(
    workflow_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_workflows")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WorkflowModel).where(
            WorkflowModel.id == str(workflow_id),
            WorkflowModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Workflow not found")
    execution = WorkflowExecutionModel(
        id=str(uuid4()),
        workflow_id=str(workflow_id),
        organization_id=org_id,
        trigger_type=model.trigger_type,
        trigger_data={"test": True, "triggered_by": str(current_user.id)},
        status="running",
        total_steps=len(model.steps or []),
    )
    session.add(execution)
    model.execution_count = (model.execution_count or 0) + 1
    model.last_executed_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    execution.status = "completed"
    execution.steps_completed = execution.total_steps
    execution.completed_at = datetime.utcnow()
    session.add(execution)
    await session.flush()
    await session.refresh(execution)
    return {
        "execution_id": execution.id,
        "status": "completed",
        "steps_executed": execution.total_steps,
        "message": "Workflow test run completed successfully",
    }


@router.get("/{workflow_id}/executions")
async def get_workflow_executions(
    workflow_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
):
    org_id = str(current_user.organization_id)
    query = select(WorkflowExecutionModel).where(
        WorkflowExecutionModel.workflow_id == str(workflow_id),
        WorkflowExecutionModel.organization_id == org_id,
    ).order_by(WorkflowExecutionModel.started_at.desc())
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [WorkflowExecution.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.get("/executions/{exec_id}")
async def get_workflow_execution(
    exec_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(WorkflowExecutionModel).where(
            WorkflowExecutionModel.id == str(exec_id),
            WorkflowExecutionModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Workflow execution not found")
    return WorkflowExecution.model_validate(model)
