# Plugin Development Guide

## Overview

The plugin system allows extending the calling agent with custom functionality. Plugins can hook into various events and add new features without modifying core code.

## Plugin Structure

Each plugin is a Python module or package with a standard entry point.

### Basic Plugin

```python
# my_plugin.py
from backend.plugins.base import PluginBase

class MyPlugin(PluginBase):
    name = "my-plugin"
    version = "1.0.0"
    description = "My custom plugin"

    async def on_call_start(self, call):
        print(f"Call started: {call.id}")

    async def on_call_complete(self, call):
        print(f"Call completed: {call.id}")

    async def on_transcript(self, call, text):
        print(f"Transcript: {text}")
```

## Plugin Lifecycle

1. **Registration**: Plugin is registered with the plugin manager
2. **Initialization**: Plugin's `initialize()` method is called
3. **Activation**: Plugin is enabled and starts receiving events
4. **Execution**: Plugin handles events during call processing
5. **Deactivation**: Plugin is disabled
6. **Cleanup**: Plugin's `cleanup()` method is called

## Event Hooks

### Call Events

| Hook | Arguments | Description |
|------|-----------|-------------|
| `on_call_start` | `call` | Called when a call starts |
| `on_call_complete` | `call` | Called when a call ends |
| `on_call_status_change` | `call`, `old_status`, `new_status` | Call status transition |
| `on_call_disposition` | `call`, `disposition` | Disposition set |
| `on_call_transfer` | `call`, `target` | Call transferred |
| `on_call_handoff` | `call`, `user` | Call handed off to human |

### Voice Events

| Hook | Arguments | Description |
|------|-----------|-------------|
| `on_transcript` | `call`, `text` | Speech transcribed |
| `on_response` | `call`, `text` | AI response generated |
| `on_audio_chunk` | `call`, `chunk` | Audio chunk processed |

### Campaign Events

| Hook | Arguments | Description |
|------|-----------|-------------|
| `on_campaign_start` | `campaign` | Campaign started |
| `on_campaign_pause` | `campaign` | Campaign paused |
| `on_campaign_complete` | `campaign` | Campaign completed |

### Lead Events

| Hook | Arguments | Description |
|------|-----------|-------------|
| `on_lead_added` | `lead` | Lead added to campaign |
| `on_lead_contacted` | `lead`, `call` | Lead contacted |

## Plugin Configuration

Plugins can define a configuration schema using JSON Schema:

```python
from backend.plugins.base import PluginBase

class ConfigurablePlugin(PluginBase):
    name = "configurable-plugin"
    description = "Plugin with configuration"

    config_schema = {
        "type": "object",
        "properties": {
            "api_key": {
                "type": "string",
                "description": "API key for external service"
            },
            "endpoint": {
                "type": "string",
                "format": "uri",
                "description": "API endpoint URL"
            },
            "enabled_features": {
                "type": "array",
                "items": {"type": "string"},
                "default": ["feature1", "feature2"]
            },
            "threshold": {
                "type": "number",
                "minimum": 0,
                "maximum": 1,
                "default": 0.5
            }
        },
        "required": ["api_key"]
    }

    async def initialize(self, config: dict):
        self.api_key = config["api_key"]
        self.endpoint = config.get("endpoint", "https://default.example.com")
        self.threshold = config.get("threshold", 0.5)
```

## Async Support

All plugin hooks support async/await:

```python
class AsyncPlugin(PluginBase):
    async def on_call_start(self, call):
        # Perform async operation
        result = await some_async_function(call.id)
        await self.save_result(result)

    async def on_transcript(self, call, text):
        # Process transcript asynchronously
        analysis = await self.analyze_sentiment(text)
        await self.store_analysis(call.id, analysis)
```

## Error Handling

Plugins should handle errors gracefully:

```python
class RobustPlugin(PluginBase):
    async def on_call_start(self, call):
        try:
            await self.external_service.notify(call.id)
        except Exception as e:
            # Log error but don't crash the call
            self.logger.error(f"Failed to notify: {e}")

    async def on_transcript(self, call, text):
        if not text or not text.strip():
            return  # Skip empty transcripts
```

## Plugin Registration

Plugins can be registered in two ways:

### 1. Configuration File

```json
{
  "plugins": {
    "enabled": ["my-plugin", "configurable-plugin"],
    "configs": {
      "configurable-plugin": {
        "api_key": "xxx",
        "endpoint": "https://api.example.com"
      }
    }
  }
}
```

### 2. Programmatic Registration

```python
from backend.plugins.manager import PluginManager

manager = PluginManager()
manager.register(MyPlugin())
manager.register(ConfigurablePlugin(), config={
    "api_key": "xxx",
    "endpoint": "https://api.example.com"
})

# Enable plugins
await manager.enable("my-plugin")
await manager.enable("configurable-plugin")
```

## Example Plugins

### Sentiment Analysis Plugin

```python
from backend.plugins.base import PluginBase

class SentimentPlugin(PluginBase):
    name = "sentiment-analysis"
    description = "Analyzes call sentiment in real-time"

    async def on_transcript(self, call, text):
        # Simple keyword-based sentiment analysis
        positive_words = ["great", "excellent", "happy", "thanks", "perfect"]
        negative_words = ["bad", "terrible", "angry", "upset", "worst"]

        positive_count = sum(1 for w in positive_words if w in text.lower())
        negative_count = sum(1 for w in negative_words if w in text.lower())

        if positive_count > negative_count:
            sentiment = "positive"
        elif negative_count > positive_count:
            sentiment = "negative"
        else:
            sentiment = "neutral"

        # Update call sentiment
        call.sentiment = sentiment
```

### CRM Sync Plugin

```python
from backend.plugins.base import PluginBase

class CRMSyncPlugin(PluginBase):
    name = "crm-sync"
    description = "Syncs call data to external CRM"

    config_schema = {
        "type": "object",
        "properties": {
            "api_url": {"type": "string"},
            "api_key": {"type": "string"}
        },
        "required": ["api_url", "api_key"]
    }

    async def on_call_complete(self, call):
        data = {
            "call_id": str(call.id),
            "phone": call.to_number,
            "duration": call.duration_seconds,
            "disposition": call.disposition,
            "transcript": call.transcript,
            "summary": call.summary,
        }

        async with httpx.AsyncClient() as client:
            await client.post(
                f"{self.config['api_url']}/calls",
                json=data,
                headers={"Authorization": f"Bearer {self.config['api_key']}"}
            )
```

### Analytics Plugin

```python
from backend.plugins.base import PluginBase

class AnalyticsPlugin(PluginBase):
    name = "custom-analytics"
    description = "Custom analytics tracking"

    async def on_call_complete(self, call):
        # Track call duration distribution
        if call.duration_seconds:
            bucket = (call.duration_seconds // 30) * 30
            await self.increment_metric(f"duration_bucket_{bucket}s")

        # Track disposition rates
        if call.disposition:
            await self.increment_metric(f"disposition_{call.disposition}")

        # Track hourly distribution
        if call.started_at:
            hour = call.started_at.hour
            await self.increment_metric(f"hour_{hour}")

    async def increment_metric(self, metric: str):
        # Store metric in database or external service
        print(f"Metric: {metric}")
```

## Testing Plugins

```python
import pytest
from unittest.mock import AsyncMock, MagicMock

from my_plugin import MyPlugin

@pytest.mark.asyncio
async def test_plugin_on_call_start():
    plugin = MyPlugin()
    mock_call = MagicMock()
    mock_call.id = "test-call-id"

    await plugin.on_call_start(mock_call)
    # Assert plugin behavior

@pytest.mark.asyncio
async def test_plugin_with_config():
    plugin = ConfigurablePlugin()
    await plugin.initialize({"api_key": "test"})
    assert plugin.api_key == "test"
```

## Publishing Plugins

To make your plugin available to other users:

1. Package your plugin as a Python package
2. Include a `plugin.json` manifest:
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Description of my plugin",
  "entry_point": "my_plugin:MyPlugin",
  "min_app_version": "1.0.0"
}
```

3. Install via pip or place in the plugins directory
4. Enable through configuration or plugin manager
