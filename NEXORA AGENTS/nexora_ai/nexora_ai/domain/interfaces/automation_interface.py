from __future__ import annotations

from abc import ABC, abstractmethod

from nexora_ai.domain.entities.automation import ScheduleConfig, WorkflowDefinition, WorkflowExecution


class AutomationInterface(ABC):
    @abstractmethod
    async def create_workflow(self, definition: WorkflowDefinition) -> str: ...

    @abstractmethod
    async def execute_workflow(self, workflow_id: str, variables: dict) -> WorkflowExecution: ...

    @abstractmethod
    async def cancel_workflow(self, execution_id: str) -> bool: ...

    @abstractmethod
    async def get_workflow(self, workflow_id: str) -> WorkflowDefinition | None: ...

    @abstractmethod
    async def get_execution(self, execution_id: str) -> WorkflowExecution | None: ...

    @abstractmethod
    async def pause_workflow(self, execution_id: str) -> bool: ...

    @abstractmethod
    async def resume_workflow(self, execution_id: str) -> bool: ...

    @abstractmethod
    async def undo_last_action(self, execution_id: str) -> bool: ...

    @abstractmethod
    async def get_workflow_schedule(self, workflow_id: str) -> ScheduleConfig | None: ...
