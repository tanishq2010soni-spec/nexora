from enum import Enum


class MemoryType(str, Enum):
    SHORT_TERM = "short_term"
    LONG_TERM = "long_term"
    SEMANTIC = "semantic"
    EPISODIC = "episodic"
    WORKING = "working"
    CONVERSATION = "conversation"
    TASK = "task"
    USER = "user"
    FACT = "fact"
    KNOWLEDGE = "knowledge"
    WORKFLOW = "workflow"


class MemoryBackendType(str, Enum):
    IN_MEMORY = "in_memory"
    SQLITE = "sqlite"
    JSON = "json"
    VECTOR = "vector"


class MemoryImportance(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class MemoryOperation(str, Enum):
    STORE = "store"
    RETRIEVE = "retrieve"
    UPDATE = "update"
    DELETE = "delete"
    SEARCH = "search"
