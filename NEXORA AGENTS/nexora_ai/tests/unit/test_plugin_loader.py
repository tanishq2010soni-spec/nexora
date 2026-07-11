from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import Any

import pytest


class PluginStatus(Enum):
    INSTALLED = "installed"
    ENABLED = "enabled"
    DISABLED = "disabled"
    UNINSTALLED = "uninstalled"


class PluginPermissionScope(Enum):
    NONE = "none"
    READ = "read"
    WRITE = "write"
    ADMIN = "admin"


class PluginManifest:

    def __init__(
        self,
        name: str,
        version: str,
        description: str = "",
        author: str = "",
        dependencies: list[str] | None = None,
        permissions: list[PluginPermissionScope] | None = None,
        entry_point: str = "",
    ) -> None:
        self.name = name
        self.version = version
        self.description = description
        self.author = author
        self.dependencies = dependencies or []
        self.permissions = permissions or [PluginPermissionScope.NONE]
        self.entry_point = entry_point
        self.status = PluginStatus.INSTALLED
        self.installed_at = datetime.now(timezone.utc)


class PluginLoader:

    def __init__(self) -> None:
        self._plugins: dict[str, PluginManifest] = {}
        self._hooks: dict[str, list[tuple[str, Any]]] = {}

    def load_manifest(self, manifest: PluginManifest) -> str:
        if manifest.name in self._plugins:
            raise ValueError(f"Plugin '{manifest.name}' is already loaded")
        for dep in manifest.dependencies:
            if dep not in self._plugins:
                raise ValueError(f"Unresolved dependency: '{dep}' required by '{manifest.name}'")
        self._plugins[manifest.name] = manifest
        manifest.status = PluginStatus.ENABLED
        return manifest.name

    def unload(self, plugin_name: str) -> bool:
        if plugin_name in self._plugins:
            dependents = [name for name, m in self._plugins.items() if plugin_name in m.dependencies]
            if dependents:
                for dep_name in dependents:
                    self._plugins[dep_name].status = PluginStatus.DISABLED
            self._plugins[plugin_name].status = PluginStatus.UNINSTALLED
            del self._plugins[plugin_name]
            self._hooks = {k: [(p, h) for p, h in v if p != plugin_name] for k, v in self._hooks.items()}
            return True
        return False

    def list_installed(self) -> list[PluginManifest]:
        return [m for m in self._plugins.values() if m.status != PluginStatus.UNINSTALLED]

    def enable(self, plugin_name: str) -> bool:
        if plugin_name in self._plugins:
            for dep in self._plugins[plugin_name].dependencies:
                if dep not in self._plugins or self._plugins[dep].status == PluginStatus.DISABLED:
                    return False
            self._plugins[plugin_name].status = PluginStatus.ENABLED
            return True
        return False

    def disable(self, plugin_name: str) -> bool:
        if plugin_name in self._plugins:
            dependents = [name for name, m in self._plugins.items() if plugin_name in m.dependencies]
            if dependents and any(self._plugins[d].status == PluginStatus.ENABLED for d in dependents):
                return False
            self._plugins[plugin_name].status = PluginStatus.DISABLED
            return True
        return False

    def get_manifest(self, plugin_name: str) -> PluginManifest | None:
        return self._plugins.get(plugin_name)

    def register_hook(self, plugin_name: str, hook_name: str, handler: Any) -> None:
        if hook_name not in self._hooks:
            self._hooks[hook_name] = []
        self._hooks[hook_name].append((plugin_name, handler))

    def get_hooks(self, hook_name: str) -> list[tuple[str, Any]]:
        return self._hooks.get(hook_name, [])

    def resolve_dependency_chain(self, plugin_name: str) -> list[str]:
        resolved: list[str] = []
        visited: set[str] = set()

        def dfs(name: str) -> None:
            if name in visited:
                return
            visited.add(name)
            manifest = self._plugins.get(name)
            if manifest:
                for dep in manifest.dependencies:
                    dfs(dep)
                resolved.append(name)

        dfs(plugin_name)
        return resolved


@pytest.fixture
def loader() -> PluginLoader:
    return PluginLoader()


class TestPluginLoader:

    async def test_load_manifest(self, loader: PluginLoader) -> None:
        manifest = PluginManifest(
            name="test-plugin", version="1.0.0",
            description="A test plugin", author="Test Author",
        )
        plugin_id = loader.load_manifest(manifest)
        assert plugin_id == "test-plugin"
        assert manifest.status == PluginStatus.ENABLED

    async def test_unload_plugin(self, loader: PluginLoader) -> None:
        manifest = PluginManifest(name="temp-plugin", version="0.1.0")
        loader.load_manifest(manifest)
        assert len(loader.list_installed()) == 1

        result = loader.unload("temp-plugin")
        assert result is True
        assert len(loader.list_installed()) == 0

        result = loader.unload("nonexistent")
        assert result is False

    async def test_list_installed(self, loader: PluginLoader) -> None:
        manifests = [
            PluginManifest(name="p1", version="1.0.0"),
            PluginManifest(name="p2", version="2.0.0"),
        ]
        for m in manifests:
            loader.load_manifest(m)
        installed = loader.list_installed()
        assert len(installed) == 2
        names = [p.name for p in installed]
        assert "p1" in names
        assert "p2" in names

    async def test_enable_disable(self, loader: PluginLoader) -> None:
        manifest = PluginManifest(name="toggle", version="1.0.0")
        loader.load_manifest(manifest)

        assert manifest.status == PluginStatus.ENABLED
        result = loader.disable("toggle")
        assert result is True
        assert manifest.status == PluginStatus.DISABLED

        result = loader.enable("toggle")
        assert result is True
        assert manifest.status == PluginStatus.ENABLED

    async def test_dependency_resolution(self, loader: PluginLoader) -> None:
        base = PluginManifest(name="base", version="1.0.0")
        ext = PluginManifest(name="extension", version="1.0.0", dependencies=["base"])
        loader.load_manifest(base)
        loader.load_manifest(ext)

        chain = loader.resolve_dependency_chain("extension")
        assert chain == ["base", "extension"]

        with pytest.raises(ValueError, match="Unresolved dependency"):
            orphan = PluginManifest(name="orphan", version="1.0.0", dependencies=["missing"])
            loader.load_manifest(orphan)
