# Plugin Development Guide

## Plugin Architecture

The WhatsApp Agent plugin system allows third-party developers to extend the platform's functionality. Plugins are Python modules that register hooks into the application lifecycle.

### How It Works

1. Plugins are stored as Python modules in the `plugins/` directory
2. Each plugin has a database record with its entry point, config schema, and state
3. The application loads plugins at startup via the entry point reference
4. Plugins can hook into message processing, workflow execution, and API events

### Plugin Lifecycle

```
Install → Configure → Enable → Load → Execute Hooks → Unload → Disable → Uninstall
```

## Creating a Plugin

### 1. Plugin Structure

```
plugins/
└── my_plugin/
    ├── __init__.py
    ├── plugin.py       # Main plugin class
    └── config.json     # Optional default config
```

### 2. Plugin Class

Each plugin must expose a class that inherits from a base or follows a duck-typed protocol:

```python
# plugins/my_plugin/plugin.py
from typing import Any


class MyPlugin:
    name = "my-plugin"
    version = "1.0.0"
    description = "Description of my plugin"

    async def on_message(self, message: dict, context: dict) -> dict | None:
        """Called when a new message is received.
        
        Args:
            message: The incoming message data
            context: Execution context (organization_id, conversation_id, etc.)
            
        Returns:
            Modified message dict or None to skip processing
        """
        return message

    async def on_lead_created(self, lead: dict, context: dict) -> dict | None:
        """Called when a new lead is created."""
        return lead

    async def on_workflow_execute(self, workflow: dict, context: dict) -> Any:
        """Called when a workflow step is executed."""
        return None

    async def on_startup(self, app: Any) -> None:
        """Called when the application starts."""
        pass

    async def on_shutdown(self) -> None:
        """Called when the application shuts down."""
        pass
```

### 3. Plugin Entry Point

The entry point is a dotted Python path to the plugin class:

```
plugins.my_plugin.plugin.MyPlugin
```

### 4. Plugin Configuration Schema

Define a JSON schema for plugin configuration:

```python
config_schema = {
    "type": "object",
    "properties": {
        "api_key": {"type": "string", "description": "API key for external service"},
        "endpoint": {"type": "string", "format": "uri", "description": "API endpoint URL"},
        "enabled_features": {
            "type": "array",
            "items": {"type": "string"},
            "description": "List of enabled features",
        },
    },
    "required": ["api_key"],
}
```

## Registering Plugins

### Via API

```bash
POST /api/v1/plugins/
Content-Type: application/x-www-form-urlencoded
Authorization: Bearer <token>

name=My Plugin&entry_point=plugins.my_plugin.plugin.MyPlugin&version=1.0.0&description=My awesome plugin
```

### Via Configuration File

Create a `plugins.json` in the plugin directory:

```json
{
  "plugins": [
    {
      "name": "My Plugin",
      "entry_point": "plugins.my_plugin.plugin.MyPlugin",
      "version": "1.0.0",
      "enabled": true,
      "config": {
        "api_key": "sk-...",
        "endpoint": "https://api.example.com"
      }
    }
  ]
}
```

## Configuration

### Plugin Configuration

Configure a plugin via the API:

```bash
PUT /api/v1/plugins/{plugin_id}
Content-Type: application/json
Authorization: Bearer <token>

{
  "config": {
    "api_key": "new-api-key",
    "endpoint": "https://api.example.com/v2"
  }
}
```

### Enable/Disable

```bash
POST /api/v1/plugins/{plugin_id}/toggle
Authorization: Bearer <token>
```

## Available Hooks

| Hook                | Trigger                        | Expected Return                |
|---------------------|--------------------------------|--------------------------------|
| `on_message`        | New message received           | Modified dict or None          |
| `on_lead_created`   | New lead created               | Modified dict or None          |
| `on_workflow_execute`| Workflow step execution       | Any or None                    |
| `on_startup`        | Application startup            | None                           |
| `on_shutdown`       | Application shutdown           | None                           |

## Best Practices

1. **Isolate dependencies** — Use a virtual environment for plugin development
2. **Handle errors gracefully** — Never let plugin exceptions crash the main application
3. **Keep plugins stateless** — Store state in the database, not in memory
4. **Version your plugins** — Use semantic versioning for compatibility
5. **Test your plugins** — Write unit tests that mock the application context
6. **Document configuration** — Provide clear JSON schema for config options
7. **Respect rate limits** — Don't make excessive API calls in hooks

## Example: Sentiment Logger Plugin

```python
# plugins/sentiment_logger/plugin.py
import logging

logger = logging.getLogger(__name__)


class SentimentLoggerPlugin:
    name = "sentiment-logger"
    version = "1.0.0"
    description = "Logs sentiment scores for all messages"

    async def on_message(self, message: dict, context: dict) -> dict | None:
        if "sentiment" in message:
            logger.info(
                "Message %s in conversation %s has sentiment: %s",
                message.get("id"),
                context.get("conversation_id"),
                message["sentiment"],
            )
        return message
```
