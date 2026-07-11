from __future__ import annotations

from collections.abc import AsyncIterator
from typing import Any, Protocol
from uuid import uuid4

from nexora_ai.application.services.planning_service import ExecutionGraph, Task
from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.enums.planner_enums import (
    ExecutionStrategy,
    RollbackStrategy,
    TaskStatus,
)


class PlanResult:
    def __init__(
        self,
        plan_id: str,
        task_id: str | None = None,
        status: TaskStatus = TaskStatus.PENDING,
        content: str = "",
        error: str | None = None,
        completed: bool = False,
    ) -> None:
        self.plan_id = plan_id
        self.task_id = task_id
        self.status = status
        self.content = content
        self.error = error
        self.completed = completed


class Plan:
    def __init__(
        self,
        id: str,
        goal: str,
        graph: ExecutionGraph | None = None,
        status: TaskStatus = TaskStatus.PENDING,
        context: dict[str, Any] | None = None,
        created_at: str = "",
    ) -> None:
        self.id = id
        self.goal = goal
        self.graph = graph
        self.status = status
        self.context = context or {}
        self.created_at = created_at


class PlannerInterface(Protocol):
    async def create_plan(self, goal: str, context: dict[str, Any]) -> ExecutionGraph: ...


class PlanningUseCases:
    def __init__(
        self,
        planner: PlannerInterface,
        planning_service: Any,
    ) -> None:
        self._planner = planner
        self._planning_service = planning_service
        self._plans: dict[str, Plan] = {}

    async def create_and_execute_plan(
        self,
        goal: str,
        context: dict[str, Any],
    ) -> AsyncIterator[PlanResult]:
        plan_id = str(uuid4())
        graph = await self._planner.create_plan(goal, context)
        plan = Plan(
            id=plan_id,
            goal=goal,
            graph=graph,
            status=TaskStatus.RUNNING,
            context=context,
        )
        self._plans[plan_id] = plan
        async for task in self._planning_service.execute_graph(graph, ExecutionStrategy.BREADTH_FIRST):
            if task.status == TaskStatus.RUNNING:
                yield PlanResult(
                    plan_id=plan_id,
                    task_id=task.id,
                    status=TaskStatus.RUNNING,
                )
            else:
                yield PlanResult(
                    plan_id=plan_id,
                    task_id=task.id,
                    status=TaskStatus.COMPLETED,
                    content=str(task.result or ""),
                )
        plan.status = TaskStatus.COMPLETED
        yield PlanResult(
            plan_id=plan_id,
            status=TaskStatus.COMPLETED,
            completed=True,
        )

    async def cancel_plan(self, plan_id: str) -> None:
        plan = self._plans.get(plan_id)
        if plan is None:
            raise ValueError(f"Plan {plan_id} not found")
        plan.status = TaskStatus.CANCELLED
        if plan.graph:
            for task in plan.graph.tasks.values():
                if task.status in (TaskStatus.PENDING, TaskStatus.READY, TaskStatus.RUNNING):
                    task.status = TaskStatus.CANCELLED

    async def get_plan_status(self, plan_id: str) -> Plan:
        plan = self._plans.get(plan_id)
        if plan is None:
            raise ValueError(f"Plan {plan_id} not found")
        return plan

    async def modify_plan(self, plan_id: str, updates: dict[str, Any]) -> Plan:
        plan = self._plans.get(plan_id)
        if plan is None:
            raise ValueError(f"Plan {plan_id} not found")
        if "goal" in updates:
            plan.goal = updates["goal"]
        if "context" in updates:
            plan.context.update(updates["context"])
        return plan
