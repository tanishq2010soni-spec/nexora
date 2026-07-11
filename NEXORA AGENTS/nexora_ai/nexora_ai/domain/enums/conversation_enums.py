from enum import Enum


class MessageRole(str, Enum):
    SYSTEM = "system"
    USER = "user"
    ASSISTANT = "assistant"
    TOOL = "tool"
    FUNCTION = "function"
    REASONING = "reasoning"


class MessageType(str, Enum):
    TEXT = "text"
    TOOL_CALL = "tool_call"
    TOOL_RESULT = "tool_result"
    IMAGE = "image"
    CODE = "code"
    REASONING = "reasoning"
    SYSTEM = "system"


class ConversationStatus(str, Enum):
    ACTIVE = "active"
    PAUSED = "paused"
    COMPLETED = "completed"
    ARCHIVED = "archived"
    ERROR = "error"


class ContextStrategy(str, Enum):
    SLIDING_WINDOW = "sliding_window"
    SUMMARY_COMPRESSION = "summary_compression"
    SEMANTIC_FILTER = "semantic_filter"
    HYBRID = "hybrid"


class StreamingState(str, Enum):
    IDLE = "idle"
    STREAMING = "streaming"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    ERROR = "error"
