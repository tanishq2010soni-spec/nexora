from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.automation_enums import ActionType, ConditionOperator, ScheduleType, WorkflowStatus


@dataclass
class ScheduleConfig:
    type: ScheduleType = ScheduleType.IMMEDIATE
    cron_expr: str | None = None
    delay_ms: int | None = None
    interval_ms: int | None = None
    event_type: str | None = None

    def to_json(self) -> dict[str, Any]:
        return {
            "type": self.type.value,
            "cron_expr": self.cron_expr,
            "delay_ms": self.delay_ms,
            "interval_ms": self.interval_ms,
            "event_type": self.event_type,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> ScheduleConfig:
        return cls(
            type=ScheduleType(data.get("type", ScheduleType.IMMEDIATE.value)),
            cron_expr=data.get("cron_expr"),
            delay_ms=data.get("delay_ms"),
            interval_ms=data.get("interval_ms"),
            event_type=data.get("event_type"),
        )


@dataclass
class StepCondition:
    operator: ConditionOperator
    field: str
    value: Any = None

    def to_json(self) -> dict[str, Any]:
        return {
            "operator": self.operator.value,
            "field": self.field,
            "value": self.value,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> StepCondition:
        return cls(
            operator=ConditionOperator(data["operator"]),
            field=data["field"],
            value=data.get("value"),
        )


@dataclass
class RetryPolicy:
    max_retries: int = 3
    delay_ms: int = 1000
    backoff_multiplier: float = 2.0
    max_delay_ms: int = 60000

    def to_json(self) -> dict[str, Any]:
        return {
            "max_retries": self.max_retries,
            "delay_ms": self.delay_ms,
            "backoff_multiplier": self.backoff_multiplier,
            "max_delay_ms": self.max_delay_ms,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> RetryPolicy:
        return cls(
            max_retries=data.get("max_retries", 3),
            delay_ms=data.get("delay_ms", 1000),
            backoff_multiplier=data.get("backoff_multiplier", 2.0),
            max_delay_ms=data.get("max_delay_ms", 60000),
        )


@dataclass
class WorkflowStep:
    id: str
    name: str
    type: ActionType
    config: dict[str, Any] = field(default_factory=dict)
    conditions: list[StepCondition] = field(default_factory=list)
    retry_policy: RetryPolicy | None = None
    timeout: int = 300
    depends_on: list[str] = field(default_factory=list)
    loop_config: dict[str, Any] | None = None

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "name": self.name,
            "type": self.type.value,
            "config": self.config,
            "conditions": [c.to_json() for c in self.conditions],
            "retry_policy": self.retry_policy.to_json() if self.retry_policy else None,
            "timeout": self.timeout,
            "depends_on": self.depends_on,
            "loop_config": self.loop_config,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> WorkflowStep:
        return cls(
            id=data["id"],
            name=data["name"],
            type=ActionType(data["type"]),
            config=data.get("config", {}),
            conditions=[StepCondition.from_json(c) for c in data.get("conditions", [])],
            retry_policy=RetryPolicy.from_json(data["retry_policy"]) if data.get("retry_policy") else None,
            timeout=data.get("timeout", 300),
            depends_on=data.get("depends_on", []),
            loop_config=data.get("loop_config"),
        )


@dataclass
class WorkflowDefinition:
    id: str
    name: str
    description: str = ""
    steps: list[WorkflowStep] = field(default_factory=list)
    variables: dict[str, Any] = field(default_factory=dict)
    status: WorkflowStatus = WorkflowStatus.DRAFT
    schedule: ScheduleConfig | None = None
    metadata: dict[str, Any] = field(default_factory=dict)
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "steps": [s.to_json() for s in self.steps],
            "variables": self.variables,
            "status": self.status.value,
            "schedule": self.schedule.to_json() if self.schedule else None,
            "metadata": self.metadata,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> WorkflowDefinition:
        return cls(
            id=data["id"],
            name=data["name"],
            description=data.get("description", ""),
            steps=[WorkflowStep.from_json(s) for s in data.get("steps", [])],
            variables=data.get("variables", {}),
            status=WorkflowStatus(data.get("status", WorkflowStatus.DRAFT.value)),
            schedule=ScheduleConfig.from_json(data["schedule"]) if data.get("schedule") else None,
            metadata=data.get("metadata", {}),
            created_at=datetime.fromisoformat(data["created_at"]) if "created_at" in data else datetime.now(timezone.utc),
            updated_at=datetime.fromisoformat(data["updated_at"]) if "updated_at" in data else datetime.now(timezone.utc),
        )


@dataclass
class WorkflowExecution:
    id: str
    workflow_id: str
    status: WorkflowStatus = WorkflowStatus.ACTIVE
    current_step: str | None = None
    step_results: dict[str, Any] = field(default_factory=dict)
    variables: dict[str, Any] = field(default_factory=dict)
    error: str | None = None
    started_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    completed_at: datetime | None = None

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "workflow_id": self.workflow_id,
            "status": self.status.value,
            "current_step": self.current_step,
            "step_results": self.step_results,
            "variables": self.variables,
            "error": self.error,
            "started_at": self.started_at.isoformat(),
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> WorkflowExecution:
        return cls(
            id=data["id"],
            workflow_id=data["workflow_id"],
            status=WorkflowStatus(data.get("status", WorkflowStatus.ACTIVE.value)),
            current_step=data.get("current_step"),
            step_results=data.get("step_results", {}),
            variables=data.get("variables", {}),
            error=data.get("error"),
            started_at=datetime.fromisoformat(data["started_at"]) if "started_at" in data else datetime.now(timezone.utc),
            completed_at=datetime.fromisoformat(data["completed_at"]) if data.get("completed_at") else None,
        )
