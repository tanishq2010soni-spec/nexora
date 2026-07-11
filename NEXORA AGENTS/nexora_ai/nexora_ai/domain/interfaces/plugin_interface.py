from __future__ import annotations

from abc import ABC, abstractmethod

from nexora_ai.domain.entities.plugin import PluginInstance, PluginManifest


class PluginInterface(ABC):
    @abstractmethod
    async def load(self, manifest_path: str) -> PluginInstance: ...

    @abstractmethod
    async def unload(self, plugin_id: str) -> bool: ...

    @abstractmethod
    async def get_instance(self, plugin_id: str) -> PluginInstance | None: ...

    @abstractmethod
    async def list_installed(self) -> list[PluginInstance]: ...

    @abstractmethod
    async def enable(self, plugin_id: str) -> bool: ...

    @abstractmethod
    async def disable(self, plugin_id: str) -> bool: ...

    @abstractmethod
    async def hot_reload(self, plugin_id: str) -> bool: ...

    @abstractmethod
    async def discover(self, plugin_dir: str) -> list[PluginManifest]: ...

    @abstractmethod
    async def get_dependency_graph(self) -> dict: ...
