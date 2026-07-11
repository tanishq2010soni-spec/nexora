from __future__ import annotations

import asyncio
import copy
import json
import re
import string
import time
from collections.abc import Awaitable, Callable
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.automation_enums import (
    ActionType,
    ConditionOperator,
    ScheduleType,
    WorkflowStatus,
)
from nexora_ai.domain.interfaces.automation_interface import AutomationInterface


class WorkflowStep:
    def __init__(
        self,
        id: str,
        action_type: ActionType,
        config: dict[str, Any],
        condition: dict[str, Any] | None = None,
        retry_config: dict[str, Any] | None = None,
        loop_config: dict[str, Any] | None = None,
        depends_on: list[str] | None = None,
    ) -> None:
        self.id = id
        self.action_type = action_type
        self.config = config
        self.condition = condition
        self.retry_config = retry_config or {"max_retries": 0, "base_delay": 1.0}
        self.loop_config = loop_config
        self.depends_on = depends_on or []
        self.result: Any = None
        self.error: str | None = None
        self.executed_at: float | None = None


class Workflow:
    def __init__(
        self,
        id: str,
        name: str,
        steps: list[WorkflowStep],
        variables: dict[str, Any] | None = None,
        timeout: float = 3600.0,
    ) -> None:
        self.id = id
        self.name = name
        self.steps = steps
        self.variables = variables or {}
        self.timeout = timeout
        self.status: WorkflowStatus = WorkflowStatus.DRAFT
        self.snapshot: dict[str, Any] = {}
        self.step_map: dict[str, WorkflowStep] = {s.id: s for s in steps}
        self.current_step_index: int = 0


class ScheduledWorkflow:
    def __init__(
        self,
        schedule_id: str,
        workflow_id: str,
        schedule_type: ScheduleType,
        config: dict[str, Any],
        context: dict[str, Any] | None = None,
    ) -> None:
        self.schedule_id = schedule_id
        self.workflow_id = workflow_id
        self.schedule_type = schedule_type
        self.config = config
        self.context = context or {}
        self.next_run: float = 0.0
        self.task: asyncio.Task[Any] | None = None


class AutomationEngine(AutomationInterface):
    def __init__(self) -> None:
        self._workflows: dict[str, Workflow] = {}
        self._schedules: dict[str, ScheduledWorkflow] = {}
        self._action_handlers: dict[ActionType, Callable[..., Awaitable[Any]]] = {}
        self._undo_handlers: dict[ActionType, Callable[..., Awaitable[Any]]] = {}
        self._lock: asyncio.Lock = asyncio.Lock()
        self._scheduler_task: asyncio.Task[Any] | None = None

    def register_action_handler(
        self,
        action_type: ActionType,
        handler: Callable[..., Awaitable[Any]],
    ) -> None:
        self._action_handlers[action_type] = handler

    def register_undo_handler(
        self,
        action_type: ActionType,
        handler: Callable[..., Awaitable[Any]],
    ) -> None:
        self._undo_handlers[action_type] = handler

    async def start_scheduler(self) -> None:
        if self._scheduler_task is None:
            self._scheduler_task = asyncio.create_task(self._scheduler_loop())

    async def stop_scheduler(self) -> None:
        if self._scheduler_task is not None:
            self._scheduler_task.cancel()
            try:
                await self._scheduler_task
            except asyncio.CancelledError:
                pass
            self._scheduler_task = None

    async def create_workflow(self, definition: WorkflowDefinition | Workflow | None = None) -> str:
        if isinstance(definition, Workflow):
            self._workflows[definition.id] = definition
            return definition.id
        elif definition is not None and hasattr(definition, "id"):
            workflow = Workflow(
                id=definition.id,
                name=definition.name,
                steps=[],
                variables=getattr(definition, "variables", {}),
            )
            self._workflows[workflow.id] = workflow
            return workflow.id
        msg = "Workflow definition is required"
        raise ValueError(msg)

    async def execute_workflow(
        self,
        workflow_id: str,
        variables: dict[str, Any] | None = None,
    ) -> dict[str, Any] | WorkflowExecution:
        from nexora_ai.domain.entities.automation import WorkflowExecution

        result = await self._execute_workflow_impl(workflow_id, variables)
        if isinstance(result, dict):
            return WorkflowExecution(
                id=f"exec_{int(time.time())}_{workflow_id}",
                workflow_id=workflow_id,
                status=WorkflowStatus.COMPLETED if result.get("status") == WorkflowStatus.COMPLETED.value else WorkflowStatus.ERROR,
                step_results=result.get("steps", {}),
                variables=result.get("variables", {}),
                error=result.get("error"),
            )
        return result

    async def _execute_workflow_impl(
        self,
        workflow_id: str,
        context: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        async with self._lock:
            workflow = self._workflows.get(workflow_id)
            if workflow is None:
                msg = f"Workflow '{workflow_id}' not found"
                raise ValueError(msg)
            workflow = copy.deepcopy(workflow)
            workflow.status = WorkflowStatus.ACTIVE
            if context:
                workflow.variables.update(context)

        try:
            step_results: list[dict[str, Any]] = []
            for step in workflow.steps:
                workflow.current_step_index = workflow.steps.index(step)

                if step.condition:
                    if not await self._evaluate_condition(step.condition, workflow.variables):
                        step_results.append({
                            "step_id": step.id,
                            "skipped": True,
                            "reason": "Condition not met",
                        })
                        continue

                if step.loop_config:
                    loop_result = await self._execute_loop(step, workflow.variables)
                    step.result = loop_result
                else:
                    step_result = await self._execute_step(step, workflow.variables)
                    step.result = step_result

                workflow.variables.update({f"{step.id}_result": step.result})
                step.executed_at = time.monotonic()
                step_results.append({
                    "step_id": step.id,
                    "result": step.result,
                    "error": step.error,
                })

                await self._take_snapshot(workflow)

            workflow.status = WorkflowStatus.COMPLETED
            return {
                "workflow_id": workflow_id,
                "status": WorkflowStatus.COMPLETED.value,
                "steps": step_results,
                "variables": workflow.variables,
            }
        except Exception as exc:
            workflow.status = WorkflowStatus.ERROR
            return {
                "workflow_id": workflow_id,
                "status": WorkflowStatus.ERROR.value,
                "error": str(exc),
            }

    async def schedule_workflow(
        self,
        workflow_id: str,
        schedule: dict[str, Any],
    ) -> str:
        schedule_id = f"sched_{int(time.time())}_{workflow_id}"
        schedule_type = ScheduleType(schedule.get("type", "immediate"))
        scheduled = ScheduledWorkflow(
            schedule_id=schedule_id,
            workflow_id=workflow_id,
            schedule_type=schedule_type,
            config=schedule,
            context=schedule.get("context"),
        )
        async with self._lock:
            self._schedules[schedule_id] = scheduled
        if schedule_type == ScheduleType.IMMEDIATE:
            asyncio.create_task(self.execute_workflow(workflow_id, scheduled.context))
        return schedule_id

    async def cancel_workflow(self, workflow_id: str) -> None:
        async with self._lock:
            workflow = self._workflows.get(workflow_id)
            if workflow:
                workflow.status = WorkflowStatus.CANCELLED

    async def get_workflow_status(self, workflow_id: str) -> dict[str, Any]:
        async with self._lock:
            workflow = self._workflows.get(workflow_id)
            if workflow is None:
                msg = f"Workflow '{workflow_id}' not found"
                raise ValueError(msg)
            return {
                "id": workflow.id,
                "name": workflow.name,
                "status": workflow.status.value,
                "step_count": len(workflow.steps),
                "current_step": workflow.current_step_index,
            }

    def register_workflow(self, workflow: Workflow) -> None:
        self._workflows[workflow.id] = workflow

    async def _execute_step(
        self,
        step: WorkflowStep,
        variables: dict[str, Any],
    ) -> Any:
        handler = self._action_handlers.get(step.action_type)
        if handler is None:
            msg = f"No handler registered for action type: {step.action_type}"
            raise ValueError(msg)

        resolved_config = self._resolve_template(step.config, variables)
        max_retries = step.retry_config.get("max_retries", 0)
        base_delay = step.retry_config.get("base_delay", 1.0)

        last_exception: Exception | None = None
        for attempt in range(max_retries + 1):
            try:
                result = await handler(resolved_config, variables)
                return result
            except Exception as exc:
                last_exception = exc
                if attempt < max_retries:
                    await asyncio.sleep(base_delay * (2 ** attempt))
        step.error = str(last_exception)
        raise RuntimeError(f"Step {step.id} failed") from last_exception

    async def _execute_loop(
        self,
        step: WorkflowStep,
        variables: dict[str, Any],
    ) -> list[Any]:
        loop_config = step.loop_config or {}
        results: list[Any] = []
        collection = variables.get(loop_config.get("collection", ""), [])
        max_iterations = loop_config.get("max_iterations", 100)

        for idx, item in enumerate(collection[:max_iterations]):
            loop_vars = dict(variables)
            loop_vars["item"] = item
            loop_vars["index"] = idx
            result = await self._execute_step(step, loop_vars)
            results.append(result)

        if loop_config.get("until"):
            while True:
                result = await self._execute_step(step, variables)
                results.append(result)
                if self._check_until_condition(loop_config["until"], result, variables):
                    break
                if len(results) >= max_iterations:
                    break

        return results

    async def undo_step(self, workflow_id: str, step_id: str) -> None:
        async with self._lock:
            workflow = self._workflows.get(workflow_id)
            if workflow is None:
                return
            step = workflow.step_map.get(step_id)
            if step is None:
                return
            undo_handler = self._undo_handlers.get(step.action_type)
            if undo_handler is not None:
                await undo_handler(step.config, workflow.variables)

    async def _evaluate_condition(
        self,
        condition: dict[str, Any],
        variables: dict[str, Any],
    ) -> bool:
        operator = ConditionOperator(condition.get("operator", "equals"))
        field = condition.get("field", "")
        value = condition.get("value")
        actual = variables.get(field, condition.get("default"))

        if operator == ConditionOperator.EQUALS:
            return actual == value
        elif operator == ConditionOperator.NOT_EQUALS:
            return actual != value
        elif operator == ConditionOperator.GREATER_THAN:
            return actual is not None and value is not None and actual > value
        elif operator == ConditionOperator.LESS_THAN:
            return actual is not None and value is not None and actual < value
        elif operator == ConditionOperator.CONTAINS:
            return actual is not None and value is not None and value in actual
        elif operator == ConditionOperator.MATCHES:
            return actual is not None and value is not None and bool(re.match(str(value), str(actual)))
        elif operator == ConditionOperator.EXISTS:
            return field in variables
        elif operator == ConditionOperator.BOOLEAN:
            return bool(actual)
        return False

    def _check_until_condition(
        self,
        until: dict[str, Any],
        result: Any,
        variables: dict[str, Any],
    ) -> bool:
        check_vars = dict(variables)
        check_vars["result"] = result
        return self._evaluate_condition(until, check_vars)

    def _resolve_template(
        self,
        config: Any,
        variables: dict[str, Any],
    ) -> Any:
        if isinstance(config, str):
            return string.Template(config).safe_substitute(variables)
        if isinstance(config, dict):
            return {k: self._resolve_template(v, variables) for k, v in config.items()}
        if isinstance(config, list):
            return [self._resolve_template(item, variables) for item in config]
        return config

    async def _take_snapshot(self, workflow: Workflow) -> None:
        workflow.snapshot = {
            "variables": copy.deepcopy(workflow.variables),
            "status": workflow.status.value,
            "current_step": workflow.current_step_index,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    async def restore_from_snapshot(self, workflow_id: str) -> None:
        async with self._lock:
            workflow = self._workflows.get(workflow_id)
            if workflow is None or not workflow.snapshot:
                return
            snapshot = workflow.snapshot
            workflow.variables = copy.deepcopy(snapshot.get("variables", {}))
            workflow.status = WorkflowStatus(snapshot.get("status", "draft"))
            workflow.current_step_index = snapshot.get("current_step", 0)

    async def get_workflow(self, workflow_id: str) -> Workflow | None:
        return self._workflows.get(workflow_id)

    async def get_execution(self, execution_id: str) -> dict | None:
        return {"id": execution_id, "status": "unknown"}

    async def pause_workflow(self, execution_id: str) -> bool:
        return True

    async def resume_workflow(self, execution_id: str) -> bool:
        return True

    async def undo_last_action(self, execution_id: str) -> bool:
        return True

    async def get_workflow_schedule(self, workflow_id: str) -> ScheduledWorkflow | None:
        return self._schedules.get(workflow_id)

    async def _scheduler_loop(self) -> None:
        while True:
            await asyncio.sleep(10.0)
            now = time.time()
            async with self._lock:
                for sched in list(self._schedules.values()):
                    if sched.schedule_type == ScheduleType.INTERVAL:
                        interval = sched.config.get("interval_seconds", 300)
                        if sched.next_run <= now:
                            asyncio.create_task(
                                self.execute_workflow(sched.workflow_id, sched.context)
                            )
                            sched.next_run = now + interval
                    elif sched.schedule_type == ScheduleType.CRON:
                        if sched.next_run <= now:
                            asyncio.create_task(
                                self.execute_workflow(sched.workflow_id, sched.context)
                            )
                            try:
                                import croniter
                                sched.next_run = croniter.croniter(
                                    sched.config.get("cron_expression", "* * * * *"),
                                    datetime.now(timezone.utc),
                                ).get_next(float)
                            except ImportError:
                                sched.next_run = now + 3600
