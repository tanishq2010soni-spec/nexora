"""Nexora AI domain exceptions hierarchy."""


class NexoraError(Exception):
    """Base exception for all nexora_ai errors."""


class ConfigurationError(NexoraError):
    """Raised when configuration is invalid or missing."""


class ProviderError(NexoraError):
    """Raised when a provider operation fails."""


class ProviderTimeoutError(ProviderError):
    """Raised when a provider request times out."""


class ProviderAuthError(ProviderError):
    """Raised when provider authentication fails."""


class MemoryError(NexoraError):
    """Raised when a memory operation fails."""


class PluginError(NexoraError):
    """Raised when a plugin operation fails."""


class PluginLoadError(PluginError):
    """Raised when a plugin fails to load."""


class PluginDependencyError(PluginError):
    """Raised when a plugin dependency is missing."""


class ToolError(NexoraError):
    """Raised when a tool operation fails."""


class ToolNotFoundError(ToolError):
    """Raised when a requested tool is not found."""


class ToolExecutionError(ToolError):
    """Raised when a tool fails during execution."""


class SecurityError(NexoraError):
    """Raised when a security check fails."""


class PermissionDeniedError(SecurityError):
    """Raised when a permission check denies access."""


class SandboxError(NexoraError):
    """Raised when a sandbox operation fails."""


class WorkflowError(NexoraError):
    """Raised when a workflow operation fails."""


class WorkflowExecutionError(WorkflowError):
    """Raised when a workflow fails during execution."""


class ConversationError(NexoraError):
    """Raised when a conversation operation fails."""


class EventbusError(NexoraError):
    """Raised when an event bus operation fails."""


class RuntimeError(NexoraError):
    """Raised when a runtime operation fails."""


class SerializationError(NexoraError):
    """Raised when serialization/deserialization fails."""


class ValidationError(NexoraError):
    """Raised when validation fails."""
