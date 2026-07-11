from __future__ import annotations

import asyncio
from datetime import datetime, timezone
from typing import Any

import pytest

from nexora_ai.domain.entities.tool import (
    ToolContext,
    ToolDefinition,
    ToolParameter,
    ToolResult,
)
from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolExecutionMode, ToolPermission, ToolStatus


class ToolRegistry:

    def __init__(self) -> None:
        self._tools: dict[str, ToolDefinition] = {}
        self._handlers: dict[str, Any] = {}

    def register(self, definition: ToolDefinition, handler: Any) -> None:
        self._tools[definition.name] = definition
        self._handlers[definition.name] = handler

    def get(self, name: str) -> ToolDefinition:
        if name not in self._tools:
            raise KeyError(f"Tool '{name}' not found")
        return self._tools[name]

    async def execute(self, context: ToolContext) -> ToolResult:
        import time
        tool_name = context.tool_name
        if tool_name not in self._handlers:
            return ToolResult(success=False, error=f"Tool '{tool_name}' not found", tool_name=tool_name)

        tool_def = self._tools[tool_name]

        validation_error = self._validate(context, tool_def)
        if validation_error:
            return ToolResult(success=False, error=validation_error, tool_name=tool_name)

        handler = self._handlers[tool_name]
        start = time.monotonic()

        try:
            timeout = context.timeout or tool_def.timeout_seconds
            result = await asyncio.wait_for(
                handler(context),
                timeout=timeout,
            )
            elapsed = (time.monotonic() - start) * 1000
            if isinstance(result, ToolResult):
                result.execution_time_ms = elapsed
                result.tool_name = tool_name
                return result
            return ToolResult(success=True, output=result, execution_time_ms=elapsed, tool_name=tool_name)
        except asyncio.TimeoutError:
            elapsed = (time.monotonic() - start) * 1000
            return ToolResult(
                success=False, error=f"Tool '{tool_name}' timed out after {timeout}s",
                execution_time_ms=elapsed, tool_name=tool_name,
            )
        except Exception as exc:
            elapsed = (time.monotonic() - start) * 1000
            return ToolResult(
                success=False, error=str(exc), execution_time_ms=elapsed, tool_name=tool_name,
            )

    def _validate(self, context: ToolContext, definition: ToolDefinition) -> str | None:
        for param in definition.parameters:
            if param.required and param.name not in context.arguments:
                return f"Missing required parameter: {param.name}"
        return None

    def list_by_category(self, category: ToolCategory) -> list[ToolDefinition]:
        return [t for t in self._tools.values() if t.category == category]

    def list_all(self) -> list[ToolDefinition]:
        return list(self._tools.values())


@pytest.fixture
def registry() -> ToolRegistry:
    return ToolRegistry()


class TestToolRegistry:

    async def test_register_tool(self, registry: ToolRegistry) -> None:
        definition = ToolDefinition(
            name="test_tool",
            description="A test tool",
            category=ToolCategory.UTILITY,
            parameters=[
                ToolParameter(name="input", type="string", required=True),
            ],
        )

        async def handler(ctx: ToolContext) -> str:
            return f"Processed: {ctx.arguments.get('input')}"

        registry.register(definition, handler)
        retrieved = registry.get("test_tool")
        assert retrieved.name == "test_tool"
        assert retrieved.category == ToolCategory.UTILITY

    async def test_execute_tool(self, registry: ToolRegistry) -> None:
        definition = ToolDefinition(
            name="echo", description="Echo tool", category=ToolCategory.UTILITY,
            parameters=[ToolParameter(name="msg", type="string", required=True)],
        )

        async def handler(ctx: ToolContext) -> str:
            return ctx.arguments.get("msg", "")

        registry.register(definition, handler)
        context = ToolContext(tool_name="echo", arguments={"msg": "hello"})
        result = await registry.execute(context)
        assert result.success is True
        assert result.output == "hello"

    async def test_tool_not_found(self, registry: ToolRegistry) -> None:
        context = ToolContext(tool_name="nonexistent")
        result = await registry.execute(context)
        assert result.success is False
        assert "not found" in (result.error or "")

    async def test_validation_failure(self, registry: ToolRegistry) -> None:
        definition = ToolDefinition(
            name="validated_tool", description="Validated tool", category=ToolCategory.UTILITY,
            parameters=[ToolParameter(name="required_param", type="string", required=True)],
        )

        async def handler(ctx: ToolContext) -> str:
            return "ok"

        registry.register(definition, handler)
        context = ToolContext(tool_name="validated_tool", arguments={})
        result = await registry.execute(context)
        assert result.success is False
        assert "Missing required" in (result.error or "")

    async def test_timeout(self, registry: ToolRegistry) -> None:
        definition = ToolDefinition(
            name="slow_tool", description="Slow tool", category=ToolCategory.UTILITY,
            timeout_seconds=1,
        )

        async def handler(ctx: ToolContext) -> str:
            await asyncio.sleep(10)
            return "done"

        registry.register(definition, handler)
        context = ToolContext(tool_name="slow_tool", timeout=1)
        result = await registry.execute(context)
        assert result.success is False
        assert "timed out" in (result.error or "")

    async def test_list_by_category(self, registry: ToolRegistry) -> None:
        util_def = ToolDefinition(name="util1", description="Util tool", category=ToolCategory.UTILITY)
        custom_def = ToolDefinition(name="custom1", description="Custom tool", category=ToolCategory.CUSTOM)

        async def handler(ctx: ToolContext) -> str:
            return "ok"

        registry.register(util_def, handler)
        registry.register(custom_def, handler)

        util_tools = registry.list_by_category(ToolCategory.UTILITY)
        assert len(util_tools) == 1
        assert util_tools[0].name == "util1"

        custom_tools = registry.list_by_category(ToolCategory.CUSTOM)
        assert len(custom_tools) == 1
