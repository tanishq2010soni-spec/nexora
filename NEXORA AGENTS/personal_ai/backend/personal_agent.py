from __future__ import annotations

from collections.abc import AsyncIterator
from typing import Any

from nexora_ai.application.di.container import DIContainer
from nexora_ai.application.services.conversation_service import ConversationService
from nexora_ai.application.services.context_service import ContextService
from nexora_ai.application.services.memory_service import MemoryService
from nexora_ai.application.services.planning_service import PlanningService
from nexora_ai.application.services.retry_service import RetryService
from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.entities.memory import MemoryEntry
from nexora_ai.domain.enums.event_enums import EventType
from nexora_ai.domain.enums.memory_enums import MemoryImportance, MemoryType
from nexora_ai.domain.enums.provider_enums import ProviderType
from nexora_ai.domain.interfaces.event_bus_interface import EventBusInterface
from nexora_ai.domain.interfaces.logging_interface import LoggingInterface
from nexora_ai.infrastructure.event_bus.event_bus import AsyncEventBus
from nexora_ai.infrastructure.logging.json_logger import JsonLogger
from nexora_ai.infrastructure.memory.memory_manager import MemoryManager
from nexora_ai.infrastructure.provider_router import ProviderRouter
from nexora_ai.infrastructure.tools.tool_registry import ToolRegistry

from backend.services.conversation_manager import ConversationManager
from backend.services.desktop_controller import DesktopController
from backend.services.screen_capture import ScreenCapture
from backend.services.file_intelligence import FileIntelligence
from backend.services.browser_controller import BrowserController
from backend.services.permissions_manager import PermissionsManager
from backend.services.settings_manager import SettingsManager, AppSettings
from backend.tools.register_tools import register_all_tools


class PersonalAgent:
    def __init__(self, container: DIContainer) -> None:
        self._container = container

        self._event_bus: AsyncEventBus = container.resolve(EventBusInterface)
        self._logger: JsonLogger = container.resolve(LoggingInterface)
        self._tool_registry: ToolRegistry = container.resolve(ToolRegistry)
        self._provider_router: ProviderRouter = container.resolve(ProviderRouter)
        self._memory_manager: MemoryManager = container.resolve(MemoryManager)
        self._conversation_service: ConversationService = container.resolve(ConversationService)

        self._context_service: ContextService = container.resolve(ContextService)
        self._retry_service: RetryService = container.resolve(RetryService)
        self._planning_service: PlanningService = container.resolve(PlanningService)
        self._memory_service: MemoryService = container.resolve(MemoryService)

        self._permissions_manager = PermissionsManager()
        self._settings_manager = SettingsManager(
            event_bus=self._event_bus,
            logger=self._logger,
        )

        self._conversation_manager = ConversationManager(
            conversation_service=self._conversation_service,
            provider_router=self._provider_router,
            memory_manager=self._memory_manager,
            context_service=self._context_service,
            retry_service=self._retry_service,
            logger=self._logger,
        )

        self._desktop_controller = DesktopController(
            tool_registry=self._tool_registry,
            permissions_manager=self._permissions_manager,
            logger=self._logger,
        )

        self._screen_capture = ScreenCapture(
            tool_registry=self._tool_registry,
            logger=self._logger,
        )

        self._file_intelligence = FileIntelligence(
            tool_registry=self._tool_registry,
            permissions_manager=self._permissions_manager,
            logger=self._logger,
        )

        self._browser_controller = BrowserController(
            tool_registry=self._tool_registry,
            permissions_manager=self._permissions_manager,
            logger=self._logger,
        )

        self._settings: AppSettings | None = None
        self._started: bool = False

    @property
    def conversation_manager(self) -> ConversationManager:
        return self._conversation_manager

    @property
    def permissions_manager(self) -> PermissionsManager:
        return self._permissions_manager

    @property
    def settings_manager(self) -> SettingsManager:
        return self._settings_manager

    @property
    def tool_registry(self) -> ToolRegistry:
        return self._tool_registry

    async def start(self) -> None:
        if self._started:
            return
        await self._logger.info("PersonalAgent starting...", category="agent")

        self._settings = await self._settings_manager.load()

        await self._desktop_controller.register_tools()
        await self._screen_capture.register_tools()
        await self._file_intelligence.register_tools()
        await self._browser_controller.register_tools()

        await self._event_bus.start()
        self._started = True
        await self._logger.info("PersonalAgent started", category="agent")

    async def shutdown(self) -> None:
        if not self._started:
            return
        await self._logger.info("PersonalAgent shutting down...", category="agent")
        await self._event_bus.publish(EventType.RUNTIME, {"action": "shutdown"})
        await self._event_bus.stop()
        self._started = False
        await self._logger.info("PersonalAgent shut down", category="agent")

    async def chat(
        self,
        message: str,
        conversation_id: str | None = None,
        stream: bool = True,
    ) -> AsyncIterator[StreamingChunk]:
        async for chunk in self._conversation_manager.chat(
            message=message,
            conversation_id=conversation_id,
            stream=stream,
        ):
            yield chunk

    async def execute_plan(self, goal: str) -> dict[str, Any]:
        await self._logger.info(f"Executing plan for goal: {goal}", category="plan")
        context = {"settings": self._settings.to_dict() if self._settings else {}}
        graph = self._planning_service.decompose_goal(goal, context)
        tasks_result: list[dict[str, Any]] = []
        async for task in self._planning_service.execute_graph(graph):
            tasks_result.append({
                "id": task.id,
                "description": task.description,
                "status": task.status.value,
                "result": task.result,
                "error": task.error,
            })
        return {"goal": goal, "tasks": tasks_result}

    async def search_memory(self, query: str) -> list[dict[str, Any]]:
        return await self._conversation_manager.search_memory(query)

    async def get_system_health(self) -> dict[str, Any]:
        memory_stats: dict[str, Any] = {}
        try:
            stats = await self._memory_manager._primary.get_stats()
            memory_stats = stats
        except Exception:
            memory_stats = {"error": "unavailable"}

        return {
            "status": "healthy" if self._started else "stopped",
            "started": self._started,
            "tools": await self._tool_registry.get_health_stats(),
            "memory": memory_stats,
            "event_bus": {"dead_letter_count": await self._event_bus.get_dead_letter_count()},
            "settings": self._settings.to_dict() if self._settings else {},
        }
