from enum import Enum


class PluginStatus(str, Enum):
    INSTALLED = "installed"
    ACTIVE = "active"
    INACTIVE = "inactive"
    ERROR = "error"
    DISABLED = "disabled"
    UNINSTALLED = "uninstalled"


class PluginPermissionScope(str, Enum):
    RUNTIME = "runtime"
    PROVIDER = "provider"
    MEMORY = "memory"
    TOOL = "tool"
    CONVERSATION = "conversation"
    FILESYSTEM = "filesystem"
    NETWORK = "network"
    UI = "ui"
    SECURITY = "security"
    CUSTOM = "custom"


class HotReloadStrategy(str, Enum):
    RESTART = "restart"
    DYNAMIC = "dynamic"
    DEFERRED = "deferred"
    MANUAL = "manual"
