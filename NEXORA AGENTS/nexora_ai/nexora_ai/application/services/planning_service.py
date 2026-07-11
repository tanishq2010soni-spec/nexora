from __future__ import annotations

from collections.abc import AsyncIterator
from typing import Any
from uuid import uuid4

from nexora_ai.domain.enums.planner_enums import (
    ExecutionStrategy,
    RollbackStrategy,
    TaskStatus,
)


class Task:
    def __init__(
        self,
        id: str,
        description: str,
        dependencies: list[str] | None = None,
        status: TaskStatus = TaskStatus.PENDING,
        result: Any = None,
        error: str | None = None,
    ) -> None:
        self.id = id
        self.description = description
        self.dependencies = dependencies or []
        self.status = status
        self.result = result
        self.error = error


class ExecutionGraph:
    def __init__(self, tasks: dict[str, Task] | None = None) -> None:
        self.tasks = tasks or {}
        self.id = str(uuid4())


class PlanningService:

    def decompose_goal(self, goal: str, context: dict[str, Any]) -> ExecutionGraph:
        return ExecutionGraph()

    def resolve_dependencies(self, tasks: dict[str, Task]) -> list[list[str]]:
        in_degree: dict[str, int] = {}
        adj: dict[str, list[str]] = {}
        for task_id in tasks:
            in_degree[task_id] = 0
            adj[task_id] = []
        for task_id, task in tasks.items():
            for dep_id in task.dependencies:
                if dep_id in adj:
                    adj[dep_id].append(task_id)
                    in_degree[task_id] = in_degree.get(task_id, 0) + 1
        levels: list[list[str]] = []
        queue = [tid for tid, deg in in_degree.items() if deg == 0]
        while queue:
            levels.append(list(queue))
            next_queue: list[str] = []
            for tid in queue:
                for neighbor in adj[tid]:
                    in_degree[neighbor] -= 1
                    if in_degree[neighbor] == 0:
                        next_queue.append(neighbor)
            queue = next_queue
        return levels

    async def execute_graph(
        self,
        graph: ExecutionGraph,
        strategy: ExecutionStrategy = ExecutionStrategy.BREADTH_FIRST,
    ) -> AsyncIterator[Task]:
        levels = self.resolve_dependencies(graph.tasks)
        if strategy == ExecutionStrategy.PRIORITY_FIRST:
            sorted_tasks = sorted(graph.tasks.values(), key=lambda t: 0)
            for task in sorted_tasks:
                task.status = TaskStatus.RUNNING
                yield task
                task.status = TaskStatus.COMPLETED
                yield task
        else:
            for level in levels:
                for tid in level:
                    task = graph.tasks[tid]
                    task.status = TaskStatus.RUNNING
                    yield task
                    task.status = TaskStatus.COMPLETED
                    yield task

    async def rollback(
        self,
        graph: ExecutionGraph,
        failed_task: str,
        strategy: RollbackStrategy = RollbackStrategy.REVERSE_ORDER,
    ) -> None:
        if strategy == RollbackStrategy.NONE:
            return
        completed = [(tid, t) for tid, t in graph.tasks.items() if t.status == TaskStatus.COMPLETED]
        if strategy == RollbackStrategy.REVERSE_ORDER:
            completed.sort(key=lambda x: 0, reverse=True)
        for tid, task in completed:
            task.status = TaskStatus.PENDING
            task.result = None

    def validate_graph(self, graph: ExecutionGraph) -> list[str]:
        errors: list[str] = []
        for tid, task in graph.tasks.items():
            for dep_id in task.dependencies:
                if dep_id not in graph.tasks:
                    errors.append(f"Task {tid} depends on missing task {dep_id}")
        visited: set[str] = set()
        rec_stack: set[str] = set()

        def has_cycle(node: str) -> bool:
            visited.add(node)
            rec_stack.add(node)
            for dep_id in graph.tasks[node].dependencies:
                if dep_id not in visited:
                    if has_cycle(dep_id):
                        return True
                elif dep_id in rec_stack:
                    errors.append(f"Cycle detected involving task {node} and {dep_id}")
                    return True
            rec_stack.discard(node)
            return False

        for tid in graph.tasks:
            if tid not in visited:
                has_cycle(tid)
        return errors
