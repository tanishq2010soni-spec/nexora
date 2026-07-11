from __future__ import annotations

import asyncio
from datetime import datetime, timezone
from enum import Enum
from typing import Any

import pytest


class WorkflowStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class ActionType(Enum):
    TASK = "task"
    CONDITION = "condition"
    WAIT = "wait"
    NOTIFY = "notify"


class ScheduleType(Enum):
    IMMEDIATE = "immediate"
    CRON = "cron"
    DELAYED = "delayed"


class ConditionOperator(Enum):
    EQ = "eq"
    NE = "ne"
    GT = "gt"
    LT = "lt"
    GTE = "gte"
    LTE = "lte"
    CONTAINS = "contains"


class WorkflowStep:

    def __init__(
        self,
        id: str,
        action_type: ActionType,
        config: dict[str, Any] | None = None,
        dependencies: list[str] | None = None,
        conditions: list[dict[str, Any]] | None = None,
        retry_policy: dict[str, Any] | None = None,
    ) -> None:
        self.id = id
        self.action_type = action_type
        self.config = config or {}
        self.dependencies = dependencies or []
        self.conditions = conditions or []
        self.retry_policy = retry_policy or {}
        self.status = WorkflowStatus.PENDING
        self.output: Any = None
        self.error: str | None = None
        self.started_at: datetime | None = None
        self.completed_at: datetime | None = None


class Workflow:

    def __init__(self, id: str, name: str, steps: list[WorkflowStep] | None = None) -> None:
        self.id = id
        self.name = name
        self.steps = steps or []
        self.status = WorkflowStatus.PENDING
        self.created_at = datetime.now(timezone.utc)

    def add_step(self, step: WorkflowStep) -> None:
        self.steps.append(step)


class AutomationEngine:

    def __init__(self) -> None:
        self._workflows: dict[str, Workflow] = {}
        self._schedules: list[dict[str, Any]] = []
        self._running = False
        self._cancel_events: dict[str, asyncio.Event] = {}

    def create_workflow(self, name: str, steps: list[WorkflowStep] | None = None) -> Workflow:
        import uuid
        wf = Workflow(id=str(uuid.uuid4()), name=name, steps=steps or [])
        self._workflows[wf.id] = wf
        return wf

    def get_workflow(self, workflow_id: str) -> Workflow:
        if workflow_id not in self._workflows:
            raise KeyError(f"Workflow '{workflow_id}' not found")
        return self._workflows[workflow_id]

    async def execute_workflow(self, workflow_id: str, context: dict[str, Any] | None = None) -> WorkflowStatus:
        wf = self.get_workflow(workflow_id)
        wf.status = WorkflowStatus.RUNNING
        ctx = context or {}
        cancel_event = asyncio.Event()
        self._cancel_events[workflow_id] = cancel_event

        try:
            for step in wf.steps:
                if wf.status == WorkflowStatus.CANCELLED or cancel_event.is_set():
                    return WorkflowStatus.CANCELLED

                deps_met = all(
                    any(s.id == dep and s.status == WorkflowStatus.COMPLETED for s in wf.steps)
                    for dep in step.dependencies
                )
                if not deps_met:
                    step.status = WorkflowStatus.FAILED
                    step.error = "Dependencies not met"
                    wf.status = WorkflowStatus.FAILED
                    return WorkflowStatus.FAILED

                if step.conditions:
                    conditions_met = self._evaluate_conditions(step.conditions, ctx)
                    if not conditions_met:
                        step.status = WorkflowStatus.COMPLETED
                        step.output = "Skipped (conditions not met)"
                        continue

                max_retries = step.retry_policy.get("max_retries", 0)
                for attempt in range(max_retries + 1):
                    step.started_at = datetime.now(timezone.utc)
                    try:
                        result = await self._execute_step(step, ctx, cancel_event)
                        step.output = result
                        step.status = WorkflowStatus.COMPLETED
                        step.completed_at = datetime.now(timezone.utc)
                        if cancel_event.is_set():
                            wf.status = WorkflowStatus.CANCELLED
                            return WorkflowStatus.CANCELLED
                        break
                    except asyncio.CancelledError:
                        wf.status = WorkflowStatus.CANCELLED
                        return WorkflowStatus.CANCELLED
                    except Exception as exc:
                        step.error = str(exc)
                        if attempt < max_retries:
                            delay = step.retry_policy.get("delay", 0.1)
                            await asyncio.sleep(delay)
                        else:
                            step.status = WorkflowStatus.FAILED
                            wf.status = WorkflowStatus.FAILED
                            return WorkflowStatus.FAILED

            if cancel_event.is_set():
                wf.status = WorkflowStatus.CANCELLED
                return WorkflowStatus.CANCELLED
            wf.status = WorkflowStatus.COMPLETED
            return WorkflowStatus.COMPLETED
        except Exception as exc:
            wf.status = WorkflowStatus.FAILED
            return WorkflowStatus.FAILED
        finally:
            self._cancel_events.pop(workflow_id, None)

    async def _execute_step(self, step: WorkflowStep, context: dict[str, Any], cancel_event: asyncio.Event | None = None) -> Any:
        if step.action_type == ActionType.TASK:
            func = step.config.get("fn")
            if func:
                task = asyncio.create_task(func(context))
                if cancel_event:
                    cancel_task = asyncio.create_task(cancel_event.wait())
                    done, pending = await asyncio.wait(
                        [task, cancel_task],
                        return_when=asyncio.FIRST_COMPLETED,
                    )
                    if cancel_event.is_set():
                        task.cancel()
                        for p in pending:
                            p.cancel()
                        raise asyncio.CancelledError()
                    cancel_task.cancel()
                    return task.result()
                return await task
            return f"Executed task: {step.id}"
        elif step.action_type == ActionType.WAIT:
            duration = step.config.get("duration", 0.1)
            try:
                await asyncio.wait_for(asyncio.sleep(duration), timeout=duration * 10)
            except asyncio.TimeoutError:
                pass
            return f"Waited {duration}s"
        elif step.action_type == ActionType.NOTIFY:
            return f"Notification: {step.config.get('message', '')}"
        return None

    def _evaluate_conditions(self, conditions: list[dict[str, Any]], context: dict[str, Any]) -> bool:
        for condition in conditions:
            field = condition.get("field", "")
            operator = ConditionOperator(condition.get("operator", "eq"))
            value = condition.get("value")
            actual = context.get(field)

            if operator == ConditionOperator.EQ and actual != value:
                return False
            elif operator == ConditionOperator.NE and actual == value:
                return False
            elif operator == ConditionOperator.GT and not (actual is not None and actual > value):
                return False
            elif operator == ConditionOperator.LT and not (actual is not None and actual < value):
                return False
            elif operator == ConditionOperator.GTE and not (actual is not None and actual >= value):
                return False
            elif operator == ConditionOperator.LTE and not (actual is not None and actual <= value):
                return False
            elif operator == ConditionOperator.CONTAINS and (value not in (actual or "")):
                return False
        return True

    def cancel_execution(self, workflow_id: str) -> bool:
        if workflow_id in self._workflows:
            wf = self._workflows[workflow_id]
            if wf.status == WorkflowStatus.RUNNING:
                wf.status = WorkflowStatus.CANCELLED
                cancel_event = self._cancel_events.get(workflow_id)
                if cancel_event is not None:
                    cancel_event.set()
                return True
        return False

    def schedule_cron(self, workflow_id: str, cron_expression: str) -> str:
        import uuid
        schedule_id = str(uuid.uuid4())
        self._schedules.append({
            "schedule_id": schedule_id,
            "workflow_id": workflow_id,
            "cron": cron_expression,
        })
        return schedule_id

    def list_schedules(self) -> list[dict[str, Any]]:
        return list(self._schedules)


@pytest.fixture
def engine() -> AutomationEngine:
    return AutomationEngine()


class TestAutomationEngine:

    async def test_create_workflow(self, engine: AutomationEngine) -> None:
        wf = engine.create_workflow("test-workflow")
        assert wf.name == "test-workflow"
        assert wf.status == WorkflowStatus.PENDING
        assert wf.id is not None

        retrieved = engine.get_workflow(wf.id)
        assert retrieved is wf

    async def test_execute_simple_workflow(self, engine: AutomationEngine) -> None:
        wf = engine.create_workflow("simple")
        wf.add_step(WorkflowStep("step1", ActionType.TASK))
        wf.add_step(WorkflowStep("step2", ActionType.WAIT, config={"duration": 0.01}))
        status = await engine.execute_workflow(wf.id)
        assert status == WorkflowStatus.COMPLETED
        assert wf.steps[0].status == WorkflowStatus.COMPLETED
        assert wf.steps[1].status == WorkflowStatus.COMPLETED

    async def test_step_dependencies(self, engine: AutomationEngine) -> None:
        wf = engine.create_workflow("dep-test")
        wf.add_step(WorkflowStep("step1", ActionType.TASK))
        wf.add_step(WorkflowStep("step2", ActionType.TASK, dependencies=["step1"]))
        status = await engine.execute_workflow(wf.id)
        assert status == WorkflowStatus.COMPLETED

        wf2 = engine.create_workflow("dep-fail")
        wf2.add_step(WorkflowStep("step_a", ActionType.TASK, dependencies=["nonexistent"]))
        status = await engine.execute_workflow(wf2.id)
        assert status == WorkflowStatus.FAILED

    async def test_condition_evaluation(self, engine: AutomationEngine) -> None:
        wf = engine.create_workflow("cond-test")
        wf.add_step(WorkflowStep(
            "check", ActionType.CONDITION,
            conditions=[{"field": "env", "operator": "eq", "value": "production"}],
        ))
        wf.add_step(WorkflowStep("task", ActionType.TASK, dependencies=["check"]))
        status = await engine.execute_workflow(wf.id, {"env": "production"})
        assert status == WorkflowStatus.COMPLETED

        wf2 = engine.create_workflow("cond-skip")
        wf2.add_step(WorkflowStep(
            "check2", ActionType.CONDITION,
            conditions=[{"field": "env", "operator": "eq", "value": "production"}],
        ))
        wf2.add_step(WorkflowStep("task2", ActionType.TASK, dependencies=["check2"]))
        status = await engine.execute_workflow(wf2.id, {"env": "staging"})
        assert status == WorkflowStatus.COMPLETED

    async def test_retry_policy(self, engine: AutomationEngine) -> None:
        attempts = 0

        async def failing_task(ctx: dict[str, Any]) -> str:
            nonlocal attempts
            attempts += 1
            if attempts < 3:
                raise RuntimeError("Temporary failure")
            return "success"

        wf = engine.create_workflow("retry-test")
        wf.add_step(WorkflowStep(
            "retry-step", ActionType.TASK,
            config={"fn": failing_task},
            retry_policy={"max_retries": 3, "delay": 0.01},
        ))
        status = await engine.execute_workflow(wf.id)
        assert status == WorkflowStatus.COMPLETED
        assert attempts == 3

    async def test_cancel_execution(self, engine: AutomationEngine) -> None:
        wf = engine.create_workflow("cancel-test")

        async def long_task(ctx: dict[str, Any]) -> str:
            await asyncio.sleep(10)
            return "done"

        wf.add_step(WorkflowStep("long", ActionType.TASK, config={"fn": long_task}))

        async def run_and_cancel() -> None:
            await asyncio.sleep(0.05)
            engine.cancel_execution(wf.id)

        async with asyncio.TaskGroup() as tg:
            tg.create_task(engine.execute_workflow(wf.id))
            tg.create_task(run_and_cancel())

        assert wf.status == WorkflowStatus.CANCELLED

    async def test_schedule_cron(self, engine: AutomationEngine) -> None:
        wf = engine.create_workflow("scheduled")
        schedule_id = engine.schedule_cron(wf.id, "*/5 * * * *")
        assert schedule_id is not None
        schedules = engine.list_schedules()
        assert len(schedules) == 1
        assert schedules[0]["workflow_id"] == wf.id
        assert schedules[0]["cron"] == "*/5 * * * *"
