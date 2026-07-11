from __future__ import annotations

import asyncio
import inspect
import importlib
import time
from collections.abc import Awaitable, Callable
from pathlib import Path
from typing import Any

from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolPermission, ToolStatus
from nexora_ai.domain.interfaces.tool_interface import ToolInterface
from nexora_ai.domain.entities.tool import ToolDefinition as DomainToolDefinition, ToolResult as ToolResultEntity, ToolHealth as ToolHealthEntity
from datetime import datetime, timezone


class ToolDefinition:
    def __init__(
        self,
        name: str,
        category: ToolCategory,
        handler: Callable[..., Awaitable[Any]],
        description: str = "",
        parameters: dict[str, Any] | None = None,
        permissions: list[ToolPermission] | None = None,
    ) -> None:
        self.name = name
        self.category = category
        self.handler = handler
        self.description = description
        self.parameters = parameters or {}
        self.permissions = permissions or [ToolPermission.READ]
        self.status: ToolStatus = ToolStatus.INSTALLED
        self.execution_count: int = 0
        self.error_count: int = 0
        self.total_execution_time: float = 0.0
        self.last_execution_time: float | None = None


class ToolRegistry(ToolInterface):
    def __init__(self) -> None:
        self._tools: dict[str, ToolDefinition] = {}
        self._lock: asyncio.Lock = asyncio.Lock()

    async def execute(
        self,
        tool_name: str | Any = None,
        context: Any = None,
        parameters: dict[str, Any] | None = None,
    ) -> dict[str, Any] | ToolResult:
        from nexora_ai.domain.entities.tool import ToolContext as ToolContextEntity, ToolResult as ToolResultEntity

        if isinstance(tool_name, ToolContextEntity):
            ctx = tool_name
            tool_name_str = ctx.tool_name
            params = ctx.arguments
        elif isinstance(context, ToolContextEntity):
            ctx = context
            tool_name_str = str(tool_name)
            params = ctx.arguments
        else:
            tool_name_str = str(tool_name) if tool_name else ""
            params = parameters or context if isinstance(context, dict) else {}

        async with self._lock:
            definition = self._tools.get(tool_name_str)
            if definition is None:
                result = {"success": False, "error": f"Tool '{tool_name_str}' not found"}
                return ToolResultEntity(success=False, error=f"Tool '{tool_name_str}' not found", tool_name=tool_name_str) if isinstance(tool_name, (ToolContextEntity,)) or isinstance(context, ToolContextEntity) else result
            if definition.status == ToolStatus.DISABLED:
                result = {"success": False, "error": f"Tool '{tool_name_str}' is disabled"}
                return ToolResultEntity(success=False, error=f"Tool '{tool_name_str}' is disabled", tool_name=tool_name_str) if isinstance(tool_name, (ToolContextEntity,)) or isinstance(context, ToolContextEntity) else result

        validation_error = self._validate_parameters(definition, params)
        if validation_error:
            return ToolResultEntity(success=False, error=validation_error, tool_name=tool_name_str) if isinstance(tool_name, (ToolContextEntity,)) or isinstance(context, ToolContextEntity) else {"success": False, "error": validation_error}

        start_time = time.monotonic()
        try:
            sig = inspect.signature(definition.handler)
            if "context" in sig.parameters:
                result = await definition.handler(parameters=params, context={})
            else:
                result = await definition.handler(params)
            duration = time.monotonic() - start_time

            async with self._lock:
                definition.execution_count += 1
                definition.total_execution_time += duration
                definition.last_execution_time = duration

            tool_result = ToolResultEntity(
                success=True,
                output=result,
                execution_time_ms=duration * 1000,
                tool_name=tool_name_str,
            )
            return {"success": True, "result": result} if not (isinstance(tool_name, (ToolContextEntity,)) or isinstance(context, ToolContextEntity)) else tool_result
        except asyncio.TimeoutError:
            async with self._lock:
                definition.error_count += 1
            return ToolResultEntity(success=False, error="Tool execution timed out", tool_name=tool_name_str) if isinstance(tool_name, (ToolContextEntity,)) or isinstance(context, ToolContextEntity) else {"success": False, "error": "Tool execution timed out"}
        except Exception as exc:
            async with self._lock:
                definition.error_count += 1
            return ToolResultEntity(success=False, error=str(exc), tool_name=tool_name_str) if isinstance(tool_name, (ToolContextEntity,)) or isinstance(context, ToolContextEntity) else {"success": False, "error": str(exc)}

    async def register(self, tool: ToolDefinition | Any = None, tool_name: str | None = None) -> bool:
        from nexora_ai.domain.entities.tool import ToolDefinition as DomainToolDef

        if isinstance(tool, DomainToolDef):
            async with self._lock:
                handler = None
                if hasattr(tool, "metadata") and "handler" in tool.metadata:
                    handler = tool.metadata["handler"]
                if handler is None:
                    return False
                definition = ToolDefinition(
                    name=tool.name,
                    category=tool.category,
                    handler=handler,
                    description=tool.description,
                )
                self._tools[tool.name] = definition
                return True
        elif tool_name and tool:
            await self.register_tool(tool_name, tool)
            return True
        return False

    async def register_tool(self, tool_name: str, tool_instance: Any) -> None:
        async with self._lock:
            category = ToolCategory.CUSTOM
            if hasattr(tool_instance, "category"):
                category = tool_instance.category
            handler = getattr(tool_instance, "execute", None) or getattr(tool_instance, "__call__", None)
            if handler is None:
                msg = f"Tool '{tool_name}' has no callable execute method"
                raise ValueError(msg)
            definition = ToolDefinition(
                name=tool_name,
                category=category,
                handler=handler,
                description=getattr(tool_instance, "description", ""),
                parameters=getattr(tool_instance, "parameters", {}),
                permissions=getattr(tool_instance, "permissions", [ToolPermission.READ]),
            )
            self._tools[tool_name] = definition

    async def unregister(self, tool_name: str) -> bool:
        async with self._lock:
            if tool_name in self._tools:
                del self._tools[tool_name]
                return True
            return False

    async def unregister_tool(self, tool_name: str) -> None:
        await self.unregister(tool_name)

    async def get_definition(self, tool_name: str) -> ToolDefinition | None:
        from nexora_ai.domain.entities.tool import ToolDefinition as DomainToolDef

        async with self._lock:
            defn = self._tools.get(tool_name)
            if defn is None:
                return None
            return DomainToolDef(
                name=defn.name,
                description=defn.description,
                category=defn.category,
                parameters=[],
            )

    async def validate(self, tool_name: str, arguments: dict) -> bool:
        async with self._lock:
            definition = self._tools.get(tool_name)
            if definition is None:
                return False
            return self._validate_parameters(definition, arguments) is None

    async def get_health(self, tool_name: str) -> ToolHealth | None:
        from nexora_ai.domain.entities.tool import ToolHealth as DomainToolHealth

        async with self._lock:
            defn = self._tools.get(tool_name)
            if defn is None:
                return None
            return DomainToolHealth(
                status="healthy" if defn.status == ToolStatus.ACTIVE else "disabled",
                last_check=datetime.now(timezone.utc),
                error_count=defn.error_count,
            )

    async def list_tools(self, category: str | ToolCategory | None = None) -> list[dict[str, Any]]:
        async with self._lock:
            tools_list: list[dict[str, Any]] = []
            for tool in self._tools.values():
                cat_value = tool.category.value if hasattr(tool.category, "value") else tool.category
                filter_value = category.value if hasattr(category, "value") else category if isinstance(category, str) else None
                if filter_value is None or cat_value == filter_value:
                    tools_list.append({
                        "name": tool.name,
                        "category": cat_value,
                        "description": tool.description,
                        "parameters": tool.parameters,
                        "status": tool.status.value,
                    })
            return tools_list

    async def get_health_stats(self) -> dict[str, Any]:
        async with self._lock:
            stats: dict[str, Any] = {}
            for name, tool in self._tools.items():
                stats[name] = {
                    "execution_count": tool.execution_count,
                    "error_count": tool.error_count,
                    "error_rate": tool.error_count / max(tool.execution_count, 1),
                    "avg_execution_time": tool.total_execution_time / max(tool.execution_count, 1),
                }
            return stats

    def _validate_parameters(
        self,
        definition: ToolDefinition,
        parameters: dict[str, Any],
    ) -> str | None:
        for param_name, param_schema in definition.parameters.items():
            required = param_schema.get("required", False)
            param_type = param_schema.get("type", "string")
            if required and param_name not in parameters:
                return f"Missing required parameter: {param_name}"
            if param_name in parameters:
                value = parameters[param_name]
                if param_type == "string" and not isinstance(value, str):
                    return f"Parameter '{param_name}' must be a string"
                if param_type == "integer" and not isinstance(value, int):
                    return f"Parameter '{param_name}' must be an integer"
                if param_type == "number" and not isinstance(value, (int, float)):
                    return f"Parameter '{param_name}' must be a number"
                if param_type == "boolean" and not isinstance(value, bool):
                    return f"Parameter '{param_name}' must be a boolean"
                if param_type == "array" and not isinstance(value, list):
                    return f"Parameter '{param_name}' must be an array"
                if param_type == "object" and not isinstance(value, dict):
                    return f"Parameter '{param_name}' must be an object"
        return None
