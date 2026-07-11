from __future__ import annotations

from abc import ABC, abstractmethod

from nexora_ai.domain.entities.tool import ToolContext, ToolDefinition, ToolHealth, ToolResult
from nexora_ai.domain.enums.tool_enums import ToolCategory


class ToolInterface(ABC):
    @abstractmethod
    async def execute(self, tool_name: str, context: ToolContext) -> ToolResult: ...

    @abstractmethod
    async def get_definition(self, tool_name: str) -> ToolDefinition | None: ...

    @abstractmethod
    async def list_tools(self, category: ToolCategory | None = None) -> list[ToolDefinition]: ...

    @abstractmethod
    async def validate(self, tool_name: str, arguments: dict) -> bool: ...

    @abstractmethod
    async def get_health(self, tool_name: str) -> ToolHealth | None: ...

    @abstractmethod
    async def register(self, tool: ToolDefinition) -> bool: ...

    @abstractmethod
    async def unregister(self, tool_name: str) -> bool: ...
