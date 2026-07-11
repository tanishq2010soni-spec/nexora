from enum import Enum


class PermissionEffect(str, Enum):
    ALLOW = "allow"
    DENY = "deny"
    AUDIT = "audit"


class ResourceType(str, Enum):
    TOOL = "tool"
    MEMORY = "memory"
    PROVIDER = "provider"
    FILE = "file"
    NETWORK = "network"
    CONFIG = "config"
    SECRET = "secret"
    RUNTIME = "runtime"
    PLUGIN = "plugin"


class AuditAction(str, Enum):
    CREATE = "create"
    READ = "read"
    UPDATE = "update"
    DELETE = "delete"
    EXECUTE = "execute"
    LOGIN = "login"
    LOGOUT = "logout"
    PERMISSION_CHANGE = "permission_change"
    SECRET_ACCESS = "secret_access"
    CONFIG_CHANGE = "config_change"


class SandboxLevel(str, Enum):
    NONE = "none"
    RESTRICTED = "restricted"
    ISOLATED = "isolated"
    JAIL = "jail"
