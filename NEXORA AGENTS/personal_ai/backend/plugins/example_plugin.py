from __future__ import annotations

from typing import Any

from nexora_ai.domain.entities.plugin import PluginManifest
from nexora_ai.domain.enums.plugin_enums import PluginPermissionScope, PluginStatus
from nexora_ai.domain.interfaces.plugin_interface import PluginInterface


PLUGIN_MANIFEST = PluginManifest(
    id="personal_ai.example_plugin",
    name="Example Plugin",
    version="1.0.0",
    description="Example plugin demonstrating how to extend Personal AI Assistant",
    author="Personal AI Team",
    permissions=[PluginPermissionScope.TOOLS, PluginPermissionScope.MEMORY],
    hooks=["on_conversation_start", "on_tool_execution", "on_message_received"],
)


async def on_conversation_start(context: dict[str, Any]) -> dict[str, Any]:
    greet = context.get("greeting", True)
    if greet:
        return {"message": "Hello! How can I assist you today?"}
    return {}


async def on_tool_execution(context: dict[str, Any]) -> dict[str, Any]:
    tool_name = context.get("tool_name", "")
    parameters = context.get("parameters", {})
    print(f"[ExamplePlugin] Tool executing: {tool_name} with {parameters}")
    return {"proceed": True}


async def on_message_received(context: dict[str, Any]) -> dict[str, Any]:
    message = context.get("message", "")
    if "hello" in message.lower():
        return {"response": "Hi there! I'm your Personal AI Assistant."}
    return {}


class ExamplePlugin(PluginInterface):
    def __init__(self) -> None:
        self._manifest = PLUGIN_MANIFEST
        self._status = PluginStatus.INSTALLED

    async def initialize(self, config: dict[str, Any] | None = None) -> bool:
        self._status = PluginStatus.ACTIVE
        return True

    async def shutdown(self) -> bool:
        self._status = PluginStatus.DISABLED
        return True

    async def get_manifest(self) -> PluginManifest:
        return self._manifest

    async def execute_hook(self, hook_name: str, context: dict[str, Any]) -> dict[str, Any]:
        hooks = {
            "on_conversation_start": on_conversation_start,
            "on_tool_execution": on_tool_execution,
            "on_message_received": on_message_received,
        }
        handler = hooks.get(hook_name)
        if handler is None:
            return {"error": f"Hook '{hook_name}' not implemented"}
        return await handler(context)

    async def get_status(self) -> PluginStatus:
        return self._status

    async def validate_config(self, config: dict[str, Any]) -> bool:
        return True
