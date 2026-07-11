from enum import Enum


class WorkflowStatus(str, Enum):
    DRAFT = "draft"
    ACTIVE = "active"
    PAUSED = "paused"
    COMPLETED = "completed"
    ERROR = "error"
    CANCELLED = "cancelled"


class ActionType(str, Enum):
    SHELL_COMMAND = "shell_command"
    API_CALL = "api_call"
    TOOL_EXECUTION = "tool_execution"
    CONDITION = "condition"
    LOOP = "loop"
    WAIT = "wait"
    SUB_WORKFLOW = "sub_workflow"
    VARIABLE_ASSIGN = "variable_assign"
    NOTIFICATION = "notification"
    CUSTOM = "custom"


class ScheduleType(str, Enum):
    IMMEDIATE = "immediate"
    DELAYED = "delayed"
    CRON = "cron"
    INTERVAL = "interval"
    EVENT_DRIVEN = "event_driven"


class ConditionOperator(str, Enum):
    EQUALS = "equals"
    NOT_EQUALS = "not_equals"
    GREATER_THAN = "greater_than"
    LESS_THAN = "less_than"
    CONTAINS = "contains"
    MATCHES = "matches"
    EXISTS = "exists"
    BOOLEAN = "boolean"
