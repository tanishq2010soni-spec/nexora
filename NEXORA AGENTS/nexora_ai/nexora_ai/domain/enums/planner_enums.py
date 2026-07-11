from enum import Enum


class TaskStatus(str, Enum):
    PENDING = "pending"
    READY = "ready"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"
    BLOCKED = "blocked"
    ROLLING_BACK = "rolling_back"
    ROLLED_BACK = "rolled_back"


class TaskPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class DependencyType(str, Enum):
    SEQUENTIAL = "sequential"
    PARALLEL = "parallel"
    CONDITIONAL = "conditional"


class ExecutionStrategy(str, Enum):
    BREADTH_FIRST = "breadth_first"
    DEPTH_FIRST = "depth_first"
    PRIORITY_FIRST = "priority_first"


class RollbackStrategy(str, Enum):
    NONE = "none"
    REVERSE_ORDER = "reverse_order"
    PARALLEL = "parallel"
    FAIL_FAST = "fail_fast"
