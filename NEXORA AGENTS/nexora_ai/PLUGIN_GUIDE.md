# Plugin Development Guide

## Overview

Nexora AI's plugin system allows you to extend the framework with custom functionality. Plugins are loaded via manifests and can hook into various lifecycle events.

## Manifest Format

A plugin is defined by a `PluginManifest`:

```python
from nexora_ai.domain.enums.plugin_enums import PluginPermissionScope
from nexora_ai.infrastructure.plugin_sdk import PluginManifest

manifest = PluginManifest(
    name="my-plugin",
    version="1.0.0",
    description="My custom plugin",
    author="Your Name",
    dependencies=["base-plugin"],
    permissions=[PluginPermissionScope.READ],
    entry_point="my_plugin.handler:setup",
)
```

### Manifest Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | `str` | Yes | Unique plugin identifier |
| `version` | `str` | Yes | Semantic version |
| `description` | `str` | No | Human-readable description |
| `author` | `str` | No | Plugin author |
| `dependencies` | `list[str]` | No | Plugin dependencies by name |
| `permissions` | `list[PluginPermissionScope]` | No | Required permissions |
| `entry_point` | `str` | No | Module path to entry point |

## Hook System

Plugins can register hooks to extend framework behavior:

### Available Hooks

| Hook Name | Trigger | Arguments |
|-----------|---------|-----------|
| `provider.before_chat` | Before LLM chat call | `messages`, `config` |
| `provider.after_chat` | After LLM chat response | `messages`, `response` |
| `memory.before_store` | Before memory write | `entry` |
| `memory.after_retrieve` | After memory read | `entry` |
| `tool.before_execute` | Before tool execution | `context` |
| `tool.after_execute` | After tool result | `context`, `result` |
| `runtime.on_start` | Runtime start | `config` |
| `runtime.on_shutdown` | Runtime shutdown | `None` |
| `event.custom` | Custom events | Any |

### Registering Hooks

```python
from nexora_ai.infrastructure.plugin_sdk import PluginLoader

loader = PluginLoader()
loader.register_hook("my-plugin", "provider.before_chat", my_handler)
```

## Lifecycle

```
1. LOAD_MANIFEST  →  PluginLoader.load_manifest()
       │
2. INSTALLED      →  Status set to INSTALLED
       │
3. ENABLE         →  Status set to ENABLED (default on load)
       │
4. ACTIVE         →  Hooks registered, plugin operational
       │
5. DISABLE        →  Status set to DISABLED (hooks paused)
       │
6. UNLOAD         →  Plugin removed from registry
```

```python
# Load
loader.load_manifest(manifest)

# Enable/Disable
loader.enable("my-plugin")
loader.disable("my-plugin")

# Unload
loader.unload("my-plugin")
```

## Permissions

Plugins must declare required permissions. The permission system enforces access control:

| Scope | Access |
|-------|--------|
| `NONE` | No special permissions |
| `READ` | Read access to framework state |
| `WRITE` | Write access to memory, conversations |
| `ADMIN` | Full access (tool execution, configuration changes) |

## Distribution

1. Package your plugin as a Python package:
   ```
   my-plugin/
   ├── pyproject.toml
   ├── src/
   │   └── my_plugin/
   │       ├── __init__.py
   │       └── handler.py
   └── manifest.yaml
   ```

2. Install via pip: `pip install my-plugin`

3. Load in application:
   ```python
   from nexora_ai.infrastructure.plugin_sdk import PluginLoader, PluginManifest
   loader = PluginLoader()
   manifest = PluginManifest(name="my-plugin", version="1.0.0", entry_point="my_plugin:setup")
   loader.load_manifest(manifest)
   ```

## Example Plugin

```python
# my_plugin/handler.py
from typing import Any

async def setup(loader: Any) -> None:
    loader.register_hook("my-plugin", "provider.before_chat", log_messages)

async def log_messages(event: dict) -> None:
    messages = event.get("data", {}).get("messages", [])
    print(f"Chat request with {len(messages)} messages")
```
