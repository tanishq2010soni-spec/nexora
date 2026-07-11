from enum import Enum


class EventPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    NORMAL = "normal"
    HIGH = "high"
    CRITICAL = "critical"


class EventStatus(str, Enum):
    PUBLISHED = "published"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"
    DEAD_LETTER = "dead_letter"


class EventType(str, Enum):
    SYSTEM = "system"
    RUNTIME = "runtime"
    PROVIDER = "provider"
    CONVERSATION = "conversation"
    MEMORY = "memory"
    TASK = "task"
    TOOL = "tool"
    PLUGIN = "plugin"
    WORKFLOW = "workflow"
    SECURITY = "security"
    CUSTOM = "custom"
