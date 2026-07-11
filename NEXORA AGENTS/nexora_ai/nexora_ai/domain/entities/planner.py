from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.planner_enums import ExecutionStrategy, TaskPriority, TaskStatus


@dataclass
class PlanError:
    task_id: str
    message: str
    code: str
    recoverable: bool = False

    def to_json(self) -> dict[str, Any]:
        return {
            "task_id": self.task_id,
            "message": self.message,
            "code": self.code,
            "recoverable": self.recoverable,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> PlanError:
        return cls(
            task_id=data["task_id"],
            message=data["message"],
            code=data["code"],
            recoverable=data.get("recoverable", False),
        )


@dataclass
class Task:
    id: str
    title: str
    description: str = ""
    status: TaskStatus = TaskStatus.PENDING
    priority: TaskPriority = TaskPriority.MEDIUM
    dependencies: list[str] = field(default_factory=list)
    parent_id: str | None = None
    subtasks: list[Task] = field(default_factory=list)
    metadata: dict[str, Any] = field(default_factory=dict)
    timeout_seconds: int = 300
    retry_count: int = 0
    max_retries: int = 3
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    started_at: datetime | None = None
    completed_at: datetime | None = None

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "status": self.status.value,
            "priority": self.priority.value,
            "dependencies": self.dependencies,
            "parent_id": self.parent_id,
            "subtasks": [s.to_json() for s in self.subtasks],
            "metadata": self.metadata,
            "timeout_seconds": self.timeout_seconds,
            "retry_count": self.retry_count,
            "max_retries": self.max_retries,
            "created_at": self.created_at.isoformat(),
            "started_at": self.started_at.isoformat() if self.started_at else None,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> Task:
        return cls(
            id=data["id"],
            title=data["title"],
            description=data.get("description", ""),
            status=TaskStatus(data.get("status", TaskStatus.PENDING.value)),
            priority=TaskPriority(data.get("priority", TaskPriority.MEDIUM.value)),
            dependencies=data.get("dependencies", []),
            parent_id=data.get("parent_id"),
            subtasks=[Task.from_json(s) for s in data.get("subtasks", [])],
            metadata=data.get("metadata", {}),
            timeout_seconds=data.get("timeout_seconds", 300),
            retry_count=data.get("retry_count", 0),
            max_retries=data.get("max_retries", 3),
            created_at=datetime.fromisoformat(data["created_at"]) if "created_at" in data else datetime.now(timezone.utc),
            started_at=datetime.fromisoformat(data["started_at"]) if data.get("started_at") else None,
            completed_at=datetime.fromisoformat(data["completed_at"]) if data.get("completed_at") else None,
        )


@dataclass
class ExecutionGraph:
    id: str
    tasks: dict[str, Task] = field(default_factory=dict)
    strategy: ExecutionStrategy = ExecutionStrategy.PRIORITY_FIRST
    metadata: dict[str, Any] = field(default_factory=dict)

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "tasks": {k: v.to_json() for k, v in self.tasks.items()},
            "strategy": self.strategy.value,
            "metadata": self.metadata,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> ExecutionGraph:
        return cls(
            id=data["id"],
            tasks={k: Task.from_json(v) for k, v in data.get("tasks", {}).items()},
            strategy=ExecutionStrategy(data.get("strategy", ExecutionStrategy.PRIORITY_FIRST.value)),
            metadata=data.get("metadata", {}),
        )


@dataclass
class Plan:
    id: str
    goal: str
    graph: ExecutionGraph
    status: TaskStatus = TaskStatus.PENDING
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "goal": self.goal,
            "graph": self.graph.to_json(),
            "status": self.status.value,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> Plan:
        return cls(
            id=data["id"],
            goal=data["goal"],
            graph=ExecutionGraph.from_json(data["graph"]),
            status=TaskStatus(data.get("status", TaskStatus.PENDING.value)),
            created_at=datetime.fromisoformat(data["created_at"]) if "created_at" in data else datetime.now(timezone.utc),
            updated_at=datetime.fromisoformat(data["updated_at"]) if "updated_at" in data else datetime.now(timezone.utc),
        )


@dataclass
class PlanResult:
    plan_id: str
    success: bool
    output: dict[str, Any] = field(default_factory=dict)
    errors: list[PlanError] = field(default_factory=list)
    duration_ms: float = 0.0

    def to_json(self) -> dict[str, Any]:
        return {
            "plan_id": self.plan_id,
            "success": self.success,
            "output": self.output,
            "errors": [e.to_json() for e in self.errors],
            "duration_ms": self.duration_ms,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> PlanResult:
        return cls(
            plan_id=data["plan_id"],
            success=data["success"],
            output=data.get("output", {}),
            errors=[PlanError.from_json(e) for e in data.get("errors", [])],
            duration_ms=data.get("duration_ms", 0.0),
        )
