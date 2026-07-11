from enum import Enum


class LogLevel(str, Enum):
    DEBUG = "debug"
    INFO = "info"
    WARN = "warn"
    ERROR = "error"
    FATAL = "fatal"


class LogCategory(str, Enum):
    SYSTEM = "system"
    RUNTIME = "runtime"
    PROVIDER = "provider"
    CONVERSATION = "conversation"
    MEMORY = "memory"
    TASK = "task"
    TOOL = "tool"
    PLUGIN = "plugin"
    SECURITY = "security"
    PERFORMANCE = "performance"
    AUDIT = "audit"


class LogFormat(str, Enum):
    JSON = "json"
    TEXT = "text"
    STRUCTURED = "structured"


class OutputDestination(str, Enum):
    CONSOLE = "console"
    FILE = "file"
    SYSLOG = "syslog"
    REMOTE = "remote"
    BUFFER = "buffer"
