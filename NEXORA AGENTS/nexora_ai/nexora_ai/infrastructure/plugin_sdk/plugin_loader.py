from __future__ import annotations

import importlib
import inspect
import json
import sys
import time
from collections import deque
from pathlib import Path
from typing import Any

import yaml

from nexora_ai.domain.enums.plugin_enums import PluginStatus
from nexora_ai.domain.interfaces.plugin_interface import PluginInterface

import asyncio


class PluginManifest:
    def __init__(
        self,
        id: str,
        name: str,
        version: str,
        description: str = "",
        author: str = "",
        dependencies: list[str] | None = None,
        entry_point: str = "",
        permissions: list[str] | None = None,
    ) -> None:
        self.id = id
        self.name = name
        self.version = version
        self.description = description
        self.author = author
        self.dependencies = dependencies or []
        self.entry_point = entry_point
        self.permissions = permissions or []
        self.status: PluginStatus = PluginStatus.INSTALLED

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> PluginManifest:
        return cls(
            id=data["id"],
            name=data.get("name", data["id"]),
            version=data.get("version", "0.0.0"),
            description=data.get("description", ""),
            author=data.get("author", ""),
            dependencies=data.get("dependencies", []),
            entry_point=data.get("entry_point", ""),
            permissions=data.get("permissions", []),
        )

    def validate(self) -> list[str]:
        errors: list[str] = []
        if not self.id:
            errors.append("Plugin id is required")
        if not self.version:
            errors.append("Plugin version is required")
        parts = self.version.split(".")
        if len(parts) != 3 or not all(p.isdigit() for p in parts):
            errors.append(f"Invalid version format: {self.version}")
        return errors


class PluginLoader(PluginInterface):
    def __init__(self, plugin_dir: str | Path = "plugins") -> None:
        self._plugin_dir = Path(plugin_dir)
        self._manifests: dict[str, Any] = {}
        self._modules: dict[str, Any] = {}
        self._instances: dict[str, Any] = {}
        self._enabled: dict[str, bool] = {}
        self._lock: asyncio.Lock = asyncio.Lock()

    async def discover(self, plugin_dir: str | None = None) -> list[Any]:
        if plugin_dir:
            self._plugin_dir = Path(plugin_dir)
        if not self._plugin_dir.exists():
            return []
        manifests: list[Any] = []
        for manifest_file in self._plugin_dir.rglob("manifest.*"):
            if manifest_file.suffix in (".json", ".yaml", ".yml"):
                try:
                    content = manifest_file.read_text(encoding="utf-8")
                    if manifest_file.suffix == ".json":
                        data = json.loads(content)
                    else:
                        data = yaml.safe_load(content)
                    manifest = PluginManifest.from_dict(data)
                    errors = manifest.validate()
                    if not errors:
                        async with self._lock:
                            self._manifests[manifest.id] = manifest
                            self._enabled[manifest.id] = True
                        manifests.append(manifest)
                except Exception:
                    pass
        return manifests

    async def discover_plugins(self) -> list[Any]:
        return await self.discover()

    async def load(self, manifest_path: str) -> Any:
        async with self._lock:
            manifest = self._manifests.get(manifest_path)
            if manifest is None:
                for m in self._manifests.values():
                    if hasattr(m, "name") and m.name == manifest_path:
                        manifest = m
                        break
            if manifest is None:
                msg = f"Plugin '{manifest_path}' not found"
                raise ValueError(msg)

            deps_resolved = self._resolve_dependencies(manifest.id)
            for dep_id in deps_resolved:
                if dep_id not in self._modules and dep_id in self._manifests:
                    dep_manifest = self._manifests[dep_id]
                    module = self._import_plugin_module(dep_manifest)
                    self._modules[dep_id] = module
                    instance = self._instantiate_plugin(module, dep_manifest)
                    if instance is not None:
                        self._instances[dep_id] = instance
                        self._call_hook(instance, "on_load")

            if manifest.id not in self._modules:
                module = self._import_plugin_module(manifest)
                self._modules[manifest.id] = module

            instance = self._instantiate_plugin(self._modules[manifest.id], manifest)
            if instance is not None:
                self._instances[manifest.id] = instance
                self._call_hook(instance, "on_load")
                self._call_hook(instance, "on_enable")
                manifest.status = PluginStatus.ACTIVE
            return instance

    async def load_plugin(self, plugin_id: str) -> Any:
        return await self.load(plugin_id)

    async def unload(self, plugin_id: str) -> bool:
        async with self._lock:
            instance = self._instances.pop(plugin_id, None)
            if instance is not None:
                self._call_hook(instance, "on_disable")
                self._call_hook(instance, "on_unload")
            self._modules.pop(plugin_id, None)
            manifest = self._manifests.get(plugin_id)
            if manifest:
                manifest.status = PluginStatus.INACTIVE
                self._enabled[plugin_id] = False
                return True
            return False

    async def unload_plugin(self, plugin_id: str) -> None:
        await self.unload(plugin_id)

    async def get_instance(self, plugin_id: str) -> Any | None:
        return self._instances.get(plugin_id)

    async def list_installed(self) -> list[Any]:
        result = []
        for plugin_id, instance in self._instances.items():
            manifest = self._manifests.get(plugin_id)
            result.append({
                "id": plugin_id,
                "manifest": manifest,
                "instance": instance,
                "enabled": self._enabled.get(plugin_id, False),
            })
        return result

    async def enable(self, plugin_id: str) -> bool:
        async with self._lock:
            if plugin_id in self._manifests:
                self._enabled[plugin_id] = True
                manifest = self._manifests[plugin_id]
                manifest.status = PluginStatus.ACTIVE
                instance = self._instances.get(plugin_id)
                if instance is not None:
                    self._call_hook(instance, "on_enable")
                return True
            return False

    async def disable(self, plugin_id: str) -> bool:
        async with self._lock:
            if plugin_id in self._manifests:
                self._enabled[plugin_id] = False
                manifest = self._manifests[plugin_id]
                manifest.status = PluginStatus.INACTIVE
                instance = self._instances.get(plugin_id)
                if instance is not None:
                    self._call_hook(instance, "on_disable")
                return True
            return False

    async def hot_reload(self, plugin_id: str) -> bool:
        async with self._lock:
            manifest = self._manifests.get(plugin_id)
            if manifest is None:
                return False
            instance = self._instances.pop(plugin_id, None)
            if instance is not None:
                self._call_hook(instance, "on_disable")
                self._call_hook(instance, "on_unload")
            self._modules.pop(plugin_id, None)
            module_path = self._find_plugin_module(manifest)
            if module_path and module_path in sys.modules:
                del sys.modules[module_path]
            module = self._import_plugin_module(manifest)
            self._modules[plugin_id] = module
            new_instance = self._instantiate_plugin(module, manifest)
            if new_instance is not None:
                self._instances[plugin_id] = new_instance
                self._call_hook(new_instance, "on_load")
                self._call_hook(new_instance, "on_enable")
                self._call_hook(new_instance, "on_config_change")
                return True
            return False

    async def get_dependency_graph(self) -> dict:
        graph: dict[str, list[str]] = {}
        for plugin_id, manifest in self._manifests.items():
            graph[plugin_id] = getattr(manifest, "dependencies", [])
        return graph

    def _resolve_dependencies(self, plugin_id: str) -> list[str]:
        manifest = self._manifests.get(plugin_id)
        if manifest is None:
            return []
        visited: set[str] = set()
        result: list[str] = []
        queue = deque(manifest.dependencies)
        while queue:
            dep_id = queue.popleft()
            if dep_id in visited:
                continue
            visited.add(dep_id)
            result.append(dep_id)
            dep_manifest = self._manifests.get(dep_id)
            if dep_manifest:
                queue.extend(dep_manifest.dependencies)
        return result

    def _find_plugin_module(self, manifest: PluginManifest) -> str | None:
        if manifest.entry_point:
            return manifest.entry_point
        plugin_dir = self._plugin_dir / manifest.id
        init_file = plugin_dir / "__init__.py"
        if init_file.exists():
            return f"plugins.{manifest.id}"
        py_files = list(plugin_dir.glob("*.py"))
        if py_files:
            return f"plugins.{manifest.id}.{py_files[0].stem}"
        return None

    def _import_plugin_module(self, manifest: PluginManifest) -> Any:
        module_path = self._find_plugin_module(manifest)
        if module_path is None:
            msg = f"No entry point found for plugin '{manifest.id}'"
            raise ImportError(msg)
        return importlib.import_module(module_path)

    def _instantiate_plugin(self, module: Any, manifest: PluginManifest) -> Any:
        for name, cls in inspect.getmembers(module, inspect.isclass):
            if name.lower() == f"{manifest.id}plugin":
                return cls()
        return None

    def _call_hook(self, instance: Any, hook_name: str) -> None:
        hook = getattr(instance, hook_name, None)
        if hook is not None:
            try:
                hook()
            except Exception:
                pass
