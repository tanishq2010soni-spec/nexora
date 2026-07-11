from enum import Enum, auto


class ProviderType(str, Enum):
    GLM = "glm"
    OPENAI = "openai"
    ANTHROPIC = "anthropic"
    GEMINI = "gemini"
    DEEPSEEK = "deepseek"
    OPENROUTER = "openrouter"
    GROQ = "groq"
    OLLAMA = "ollama"
    LM_STUDIO = "lm_studio"
    MISTRAL = "mistral"
    MOCK = "mock"


class ModelCapability(str, Enum):
    CHAT = "chat"
    COMPLETION = "completion"
    EMBEDDING = "embedding"
    TOOL_CALL = "tool_call"
    STREAMING = "streaming"
    VISION = "vision"
    AUDIO = "audio"
    REASONING = "reasoning"
    CODE_GENERATION = "code_generation"


class RoutingStrategy(str, Enum):
    PRIORITY = "priority"
    FALLBACK = "fallback"
    LOAD_BALANCE = "load_balance"
    COST_AWARE = "cost_aware"
    CAPABILITY = "capability"
    LATENCY = "latency"


class ProviderStatus(str, Enum):
    ACTIVE = "active"
    DEGRADED = "degraded"
    DOWN = "down"
    MAINTENANCE = "maintenance"
    INACTIVE = "inactive"
    ERROR = "error"
