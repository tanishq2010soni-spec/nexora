from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Protocol
from uuid import uuid4

from nexora_ai.domain.enums.tool_enums import (
    ToolCategory,
    ToolExecutionMode,
    ToolPermission,
    ToolStatus,
)


class ToolDefinition:
    def __init__(
        self,
        name: str,
        description: str,
        category: ToolCategory,
        parameters: dict[str, Any],
        required_permissions: list[ToolPermission] | None = None,
        execution_mode: ToolExecutionMode = ToolExecutionMode.SYNC,
        status: ToolStatus = ToolStatus.INSTALLED,
    ) -> None:
        self.name = name
        self.description = description
        self.category = category
        self.parameters = parameters
        self.required_permissions = required_permissions or []
        self.execution_mode = execution_mode
        self.status = status


class ToolResult:
    def __init__(
        self,
        success: bool,
        output: Any = None,
        error: str | None = None,
        execution_time_ms: float = 0.0,
    ) -> None:
        self.success = success
        self.output = output
        self.error = error
        self.execution_time_ms = execution_time_ms


class ToolHealth:
    def __init__(
        self,
        status: ToolStatus,
        last_checked: datetime,
        latency_ms: float = 0.0,
        error_rate: float = 0.0,
    ) -> None:
        self.status = status
        self.last_checked = last_checked
        self.latency_ms = latency_ms
        self.error_rate = error_rate


class AuditEntry:
    def __init__(
        self,
        action: str,
        resource: str,
        user_id: str | None = None,
        details: dict[str, Any] | None = None,
        timestamp: datetime | None = None,
    ) -> None:
        self.action = action
        self.resource = resource
        self.user_id = user_id
        self.details = details or {}
        self.timestamp = timestamp or datetime.now(timezone.utc)


class PermissionChecker(Protocol):
    async def check_tool_permission(self, tool_name: str, user_id: str | None, permission: ToolPermission) -> bool: ...


class ToolExecutor(Protocol):
    async def execute(self, tool_name: str, arguments: dict[str, Any], context: dict[str, Any]) -> ToolResult: ...


class ToolRegistry(Protocol):
    def get_definition(self, tool_name: str) -> ToolDefinition | None: ...
    def list_by_category(self, category: ToolCategory | None) -> list[ToolDefinition]: ...
    def register(self, definition: ToolDefinition) -> bool: ...
    def get_health(self, tool_name: str) -> ToolHealth: ...


class AuditLogger(Protocol):
    async def log(self, entry: AuditEntry) -> None: ...


class ToolUseCases:
    def __init__(
        self,
        tool_registry: ToolRegistry,
        tool_executor: ToolExecutor,
        permission_checker: PermissionChecker,
        audit_logger: AuditLogger,
    ) -> None:
        self._tool_registry = tool_registry
        self._tool_executor = tool_executor
        self._permission_checker = permission_checker
        self._audit_logger = audit_logger

    async def execute_tool(
        self,
        tool_name: str,
        arguments: dict[str, Any],
        context: dict[str, Any],
    ) -> ToolResult:
        definition = self._tool_registry.get_definition(tool_name)
        if definition is None:
            raise ValueError(f"Tool {tool_name} not found")
        user_id = context.get("user_id")
        for permission in definition.required_permissions:
            allowed = await self._permission_checker.check_tool_permission(
                tool_name, user_id, permission
            )
            if not allowed:
                await self._audit_logger.log(
                    AuditEntry(
                        action="tool_execution_denied",
                        resource=f"tool:{tool_name}",
                        user_id=user_id,
                        details={"permission": permission.value, "arguments": arguments},
                    )
                )
                return ToolResult(success=False, error=f"Missing permission: {permission.value}")
        result = await self._tool_executor.execute(tool_name, arguments, context)
        await self._audit_logger.log(
            AuditEntry(
                action="tool_executed",
                resource=f"tool:{tool_name}",
                user_id=user_id,
                details={
                    "arguments": arguments,
                    "success": result.success,
                    "execution_time_ms": result.execution_time_ms,
                },
            )
        )
        return result

    async def list_available_tools(self, category: ToolCategory | None = None) -> list[ToolDefinition]:
        return self._tool_registry.list_by_category(category)

    async def get_tool_health(self, tool_name: str) -> ToolHealth:
        return self._tool_registry.get_health(tool_name)

    async def register_custom_tool(self, definition: ToolDefinition) -> bool:
        return self._tool_registry.register(definition)
