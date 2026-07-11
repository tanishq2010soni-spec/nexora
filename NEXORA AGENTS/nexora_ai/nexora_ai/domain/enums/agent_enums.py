from enum import Enum


class AgentStatus(str, Enum):
    STARTING = "starting"
    ONLINE = "online"
    DEGRADED = "degraded"
    OFFLINE = "offline"
    ERROR = "error"
    MAINTENANCE = "maintenance"


class AgentType(str, Enum):
    PERSONAL_AI = "personal_ai"
    WHATSAPP = "whatsapp"
    CALLING = "calling"
    CUSTOM = "custom"


class HeartbeatState(str, Enum):
    HEALTHY = "healthy"
    WARNING = "warning"
    STALE = "stale"
    DEAD = "dead"
