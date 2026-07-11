from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Protocol
from uuid import uuid4

from nexora_ai.domain.enums.automation_enums import (
    ActionType,
    ConditionOperator,
    ScheduleType,
    WorkflowStatus,
)


class WorkflowDefinition:
    def __init__(
        self,
        id: str,
        name: str,
        actions: list[dict[str, Any]],
        variables: dict[str, Any] | None = None,
        status: WorkflowStatus = WorkflowStatus.DRAFT,
    ) -> None:
        self.id = id
        self.name = name
        self.actions = actions
        self.variables = variables or {}
        self.status = status


class WorkflowExecution:
    def __init__(
        self,
        execution_id: str,
        workflow_id: str,
        status: WorkflowStatus = WorkflowStatus.ACTIVE,
        variables: dict[str, Any] | None = None,
        started_at: datetime | None = None,
        completed_at: datetime | None = None,
    ) -> None:
        self.execution_id = execution_id
        self.workflow_id = workflow_id
        self.status = status
        self.variables = variables or {}
        self.started_at = started_at or datetime.now(timezone.utc)
        self.completed_at = completed_at


class ScheduleConfig:
    def __init__(
        self,
        type: ScheduleType = ScheduleType.IMMEDIATE,
        cron_expression: str | None = None,
        interval_seconds: int | None = None,
        delay_seconds: int = 0,
    ) -> None:
        self.type = type
        self.cron_expression = cron_expression
        self.interval_seconds = interval_seconds
        self.delay_seconds = delay_seconds


class WorkflowRepository(Protocol):
    async def save(self, workflow: WorkflowDefinition) -> None: ...
    async def get(self, workflow_id: str) -> WorkflowDefinition | None: ...
    async def save_execution(self, execution: WorkflowExecution) -> None: ...
    async def get_execution(self, execution_id: str) -> WorkflowExecution | None: ...


class WorkflowEngine(Protocol):
    async def execute(self, definition: WorkflowDefinition, variables: dict[str, Any]) -> str: ...
    async def cancel(self, execution_id: str) -> None: ...
    async def pause(self, execution_id: str) -> None: ...
    async def resume(self, execution_id: str) -> None: ...
    async def schedule(self, workflow_id: str, schedule: ScheduleConfig) -> bool: ...


class AutomationUseCases:
    def __init__(
        self,
        workflow_engine: WorkflowEngine,
        repository: WorkflowRepository,
    ) -> None:
        self._workflow_engine = workflow_engine
        self._repository = repository

    async def create_and_execute_workflow(
        self,
        definition: WorkflowDefinition,
        variables: dict[str, Any],
    ) -> str:
        await self._repository.save(definition)
        execution_id = await self._workflow_engine.execute(definition, variables)
        return execution_id

    async def cancel_workflow(self, execution_id: str) -> None:
        await self._workflow_engine.cancel(execution_id)

    async def get_workflow_status(self, execution_id: str) -> WorkflowExecution:
        execution = await self._repository.get_execution(execution_id)
        if execution is None:
            raise ValueError(f"Execution {execution_id} not found")
        return execution

    async def schedule_workflow(
        self,
        workflow_id: str,
        schedule: ScheduleConfig,
    ) -> bool:
        return await self._workflow_engine.schedule(workflow_id, schedule)

    async def pause_workflow(self, execution_id: str) -> None:
        await self._workflow_engine.pause(execution_id)

    async def resume_workflow(self, execution_id: str) -> None:
        await self._workflow_engine.resume(execution_id)
