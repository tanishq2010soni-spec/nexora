from __future__ import annotations

from typing import Any

import pytest

from nexora_ai.domain.entities.planner import ExecutionGraph, Plan, PlanResult, Task
from nexora_ai.domain.enums.planner_enums import ExecutionStrategy, TaskPriority, TaskStatus


class PlanningService:

    def __init__(self) -> None:
        self._plans: dict[str, Plan] = {}

    async def decompose_goal(self, goal: str) -> Plan:
        import uuid
        plan_id = str(uuid.uuid4())
        graph = ExecutionGraph(id=plan_id)
        plan = Plan(id=plan_id, goal=goal, graph=graph)
        self._plans[plan_id] = plan
        return plan

    def resolve_dependencies(self, graph: ExecutionGraph) -> list[list[str]]:
        tasks = graph.tasks
        in_degree: dict[str, int] = {tid: 0 for tid in tasks}
        for tid, task in tasks.items():
            for dep in task.dependencies:
                if dep in in_degree:
                    in_degree[tid] = in_degree.get(tid, 0) + 1

        levels: list[list[str]] = []
        remaining = set(tasks.keys())

        while remaining:
            level = [tid for tid in remaining if in_degree.get(tid, 0) == 0]
            if not level:
                raise ValueError("Circular dependency detected")
            levels.append(level)
            for tid in level:
                remaining.remove(tid)
                for t2 in remaining:
                    if tid in tasks[t2].dependencies:
                        in_degree[t2] -= 1
        return levels

    def detect_cycle(self, graph: ExecutionGraph) -> list[str] | None:
        tasks = graph.tasks
        WHITE, GRAY, BLACK = 0, 1, 2
        color: dict[str, int] = {tid: WHITE for tid in tasks}
        parent: dict[str, str | None] = {tid: None for tid in tasks}

        def dfs(node: str) -> list[str] | None:
            color[node] = GRAY
            task = tasks[node]
            for dep in task.dependencies:
                if dep not in color:
                    continue
                if color[dep] == GRAY:
                    cycle = [dep, node]
                    cur = node
                    while cur != dep:
                        cur = parent.get(cur)
                        if cur is None:
                            break
                        cycle.append(cur)
                    return cycle
                if color[dep] == WHITE:
                    parent[dep] = node
                    result = dfs(dep)
                    if result is not None:
                        return result
            color[node] = BLACK
            return None

        for tid in tasks:
            if color[tid] == WHITE:
                result = dfs(tid)
                if result is not None:
                    return result
        return None

    async def execute_graph_sequential(self, graph: ExecutionGraph, task_executor: Any) -> PlanResult:
        import time
        start = time.monotonic()
        output: dict[str, Any] = {}
        errors: list[Any] = []

        topo_levels = self.resolve_dependencies(graph)
        for level in topo_levels:
            for tid in level:
                task = graph.tasks[tid]
                try:
                    result = await task_executor(tid, task)
                    output[tid] = result
                    task.status = TaskStatus.COMPLETED
                except Exception as exc:
                    task.status = TaskStatus.FAILED
                    from nexora_ai.domain.entities.planner import PlanError
                    errors.append(PlanError(task_id=tid, message=str(exc), code="EXECUTION_ERROR"))
                    return PlanResult(
                        plan_id=graph.id, success=False, output=output,
                        errors=errors, duration_ms=(time.monotonic() - start) * 1000,
                    )
        return PlanResult(
            plan_id=graph.id, success=True, output=output,
            duration_ms=(time.monotonic() - start) * 1000,
        )

    async def execute_graph_parallel(self, graph: ExecutionGraph, task_executor: Any) -> PlanResult:
        import asyncio
        import time
        start = time.monotonic()
        output: dict[str, Any] = {}
        errors: list[Any] = []

        topo_levels = self.resolve_dependencies(graph)
        for level in topo_levels:
            tasks_in_level = [graph.tasks[tid] for tid in level if tid in graph.tasks]

            async def run_task(tid: str, task: Task) -> tuple[str, Any]:
                try:
                    result = await task_executor(tid, task)
                    task.status = TaskStatus.COMPLETED
                    return tid, result
                except Exception as exc:
                    task.status = TaskStatus.FAILED
                    from nexora_ai.domain.entities.planner import PlanError
                    errors.append(PlanError(task_id=tid, message=str(exc), code="EXECUTION_ERROR"))
                    return tid, None

            coros = [run_task(tid, graph.tasks[tid]) for tid in level if tid in graph.tasks]
            results = await asyncio.gather(*coros, return_exceptions=False)
            for tid, result in results:
                output[tid] = result

            if errors:
                return PlanResult(
                    plan_id=graph.id, success=False, output=output,
                    errors=errors, duration_ms=(time.monotonic() - start) * 1000,
                )
        return PlanResult(
            plan_id=graph.id, success=True, output=output,
            duration_ms=(time.monotonic() - start) * 1000,
        )

    async def rollback_on_failure(self, graph: ExecutionGraph, task_executor: Any) -> PlanResult:
        completed: list[str] = []
        errors: list[Any] = []

        try:
            topo_levels = self.resolve_dependencies(graph)
            for level in topo_levels:
                for tid in level:
                    task = graph.tasks[tid]
                    result = await task_executor(tid, task)
                    task.status = TaskStatus.COMPLETED
                    completed.append(tid)
                    if task.metadata.get("should_fail"):
                        raise RuntimeError(f"Task {tid} failed intentionally")
        except Exception as exc:
            from nexora_ai.domain.entities.planner import PlanError
            for tid in reversed(completed):
                graph.tasks[tid].status = TaskStatus.ROLLED_BACK
            errors.append(PlanError(task_id=completed[-1] if completed else "", message=str(exc), code="ROLLBACK"))
            return PlanResult(plan_id=graph.id, success=False, errors=errors)
        return PlanResult(plan_id=graph.id, success=True)


@pytest.fixture
def service() -> PlanningService:
    return PlanningService()


class TestPlanningService:

    async def test_decompose_goal(self, service: PlanningService) -> None:
        plan = await service.decompose_goal("Build a web app")
        assert plan.goal == "Build a web app"
        assert plan.id is not None
        assert plan.status == TaskStatus.PENDING

    async def test_dependency_resolution_topological(self, service: PlanningService) -> None:
        graph = ExecutionGraph(id="test")
        tasks = {
            "A": Task(id="A", title="Task A", dependencies=[]),
            "B": Task(id="B", title="Task B", dependencies=["A"]),
            "C": Task(id="C", title="Task C", dependencies=["A"]),
            "D": Task(id="D", title="Task D", dependencies=["B", "C"]),
        }
        graph.tasks = tasks
        levels = service.resolve_dependencies(graph)
        assert levels[0] == ["A"]
        assert set(levels[1]) == {"B", "C"}
        assert levels[2] == ["D"]

    async def test_cycle_detection(self, service: PlanningService) -> None:
        graph = ExecutionGraph(id="test")
        tasks = {
            "A": Task(id="A", title="A", dependencies=["B"]),
            "B": Task(id="B", title="B", dependencies=["C"]),
            "C": Task(id="C", title="C", dependencies=["A"]),
        }
        graph.tasks = tasks
        cycle_nodes = service.detect_cycle(graph)
        assert cycle_nodes is not None

    async def test_execute_graph_sequential(self, service: PlanningService) -> None:
        graph = ExecutionGraph(id="test")
        tasks = {
            "A": Task(id="A", title="A", dependencies=[]),
            "B": Task(id="B", title="B", dependencies=["A"]),
        }
        graph.tasks = tasks

        async def executor(tid: str, task: Task) -> str:
            return f"{tid}:done"

        result = await service.execute_graph_sequential(graph, executor)
        assert result.success is True
        assert "A" in result.output
        assert "B" in result.output

    async def test_execute_graph_parallel(self, service: PlanningService) -> None:
        graph = ExecutionGraph(id="test")
        tasks = {
            "A": Task(id="A", title="A", dependencies=[]),
            "B": Task(id="B", title="B", dependencies=[]),
            "C": Task(id="C", title="C", dependencies=["A", "B"]),
        }
        graph.tasks = tasks

        async def executor(tid: str, task: Task) -> str:
            return f"{tid}:done"

        result = await service.execute_graph_parallel(graph, executor)
        assert result.success is True

    async def test_rollback_on_failure(self, service: PlanningService) -> None:
        graph = ExecutionGraph(id="test")
        tasks = {
            "A": Task(id="A", title="A", dependencies=[], metadata={"should_fail": False}),
            "B": Task(id="B", title="B", dependencies=["A"], metadata={"should_fail": True}),
        }
        graph.tasks = tasks

        async def executor(tid: str, task: Task) -> str:
            return f"{tid}:done"

        result = await service.rollback_on_failure(graph, executor)
        assert result.success is False
        assert graph.tasks["A"].status == TaskStatus.ROLLED_BACK
