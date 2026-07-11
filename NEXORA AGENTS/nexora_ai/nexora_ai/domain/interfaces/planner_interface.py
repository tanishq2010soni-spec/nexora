from __future__ import annotations

from abc import ABC, abstractmethod
from collections.abc import AsyncIterator

from nexora_ai.domain.entities.planner import Plan, PlanResult, Task


class PlannerInterface(ABC):
    @abstractmethod
    async def create_plan(self, goal: str, context: dict) -> Plan: ...

    @abstractmethod
    async def execute_plan(self, plan: Plan) -> AsyncIterator[PlanResult]: ...

    @abstractmethod
    async def cancel_plan(self, plan_id: str) -> None: ...

    @abstractmethod
    async def get_plan(self, plan_id: str) -> Plan | None: ...

    @abstractmethod
    async def get_task(self, task_id: str) -> Task | None: ...

    @abstractmethod
    async def update_plan(self, plan_id: str, updates: dict) -> Plan: ...

    @abstractmethod
    async def rollback_plan(self, plan_id: str) -> PlanResult: ...
