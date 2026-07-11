# Plugin Development Guide

## Overview

Plugins extend the Personal AI Assistant's capabilities. They are Python packages that integrate with the backend runtime, adding new tools, hooks, and behaviors.

## Plugin Structure

A plugin is a Python package with a standard structure:

```
my_plugin/
  __init__.py
  plugin.py          # Main plugin class
  manifest.json      # Plugin metadata
  requirements.txt   # Dependencies
  assets/            # Optional: UI assets
```

### manifest.json

```json
{
  "name": "My Plugin",
  "version": "1.0.0",
  "description": "Description of what the plugin does",
  "author": "Your Name",
  "icon": "extension",
  "capabilities": ["custom_tool", "data_analysis"],
  "permissions": ["files:read"],
  "hooks": ["on_message", "on_tool_result"],
  "min_app_version": "1.0.0"
}
```

### Plugin Class

Create a `plugin.py` file with a class that extends `BasePlugin`:

```python
from nexora.plugins import BasePlugin
from nexora.tools import Tool
from nexora.events import EventHook

class MyPlugin(BasePlugin):
    def __init__(self):
        super().__init__()
        self.name = "My Plugin"
        self.tools = [MyCustomTool()]
        self.hooks = {
            "on_message": self.handle_message,
        }

    async def on_load(self):
        """Called when plugin is loaded."""
        pass

    async def on_unload(self):
        """Called when plugin is uninstalled."""
        pass

    async def handle_message(self, context, message):
        """Handle a message event."""
        return message

class MyCustomTool(Tool):
    def __init__(self):
        super().__init__(
            name="my_custom_tool",
            description="Does something useful",
            parameters={
                "input": {"type": "string", "description": "Input data"}
            }
        )

    async def execute(self, args, context):
        input_data = args["input"]
        # Do something
        return {"result": "processed"}
```

## Capabilities

Capabilities declare what your plugin can do. They are used for permission gating and discovery:

- `code_analysis` - Analyze source code
- `code_generation` - Generate code
- `web_search` - Search the web
- `data_analysis` - Analyze data
- `file_management` - Manage files
- `image_generation` - Generate images
- `custom_tool` - Custom tool execution

## Permissions

Plugins must declare required permissions. The system will prompt the user for approval:

- `files:read` - Read files from the filesystem
- `files:write` - Write files to the filesystem
- `network:http` - Make HTTP requests
- `system:exec` - Execute system commands
- `clipboard:read` - Read clipboard contents
- `clipboard:write` - Write to clipboard

## Hooks

Hooks allow plugins to intercept and modify events:

| Hook | Description |
|------|-------------|
| `on_message` | Called when a message is received |
| `on_response` | Called when a response is generated |
| `on_tool_call` | Called before a tool is executed |
| `on_tool_result` | Called after a tool returns |
| `on_command` | Called for custom slash commands |
| `on_startup` | Called when the app starts |
| `on_shutdown` | Called when the app shuts down |

## Distribution

Plugins are distributed as `.whl` (Wheel) or `.zip` files:

```bash
# Build wheel
python -m build my_plugin/

# Install via UI
# Open Plugins screen -> Install -> Select .whl file
```

## Best Practices

1. **Declare minimal permissions** - Only request what you actually need
2. **Handle errors gracefully** - Never crash the host application
3. **Use async/await** - All plugin operations should be non-blocking
4. **Log appropriately** - Use the provided logging system
5. **Test thoroughly** - Test with different models and configurations
6. **Document your plugin** - Include clear description and usage instructions

## Example: Web Search Plugin

```python
from nexora.plugins import BasePlugin
from nexora.tools import Tool
import aiohttp

class WebSearchPlugin(BasePlugin):
    def __init__(self):
        super().__init__()
        self.name = "Web Search"
        self.tools = [WebSearchTool()]
        self.session = None

    async def on_load(self):
        self.session = aiohttp.ClientSession()

    async def on_unload(self):
        if self.session:
            await self.session.close()

class WebSearchTool(Tool):
    def __init__(self):
        super().__init__(
            name="search_web",
            description="Search the web for information",
            parameters={
                "query": {
                    "type": "string",
                    "description": "Search query"
                },
                "num_results": {
                    "type": "integer",
                    "description": "Number of results (1-10)",
                    "default": 5
                }
            }
        )

    async def execute(self, args, context):
        query = args["query"]
        num = min(args.get("num_results", 5), 10)
        # Implement search logic
        return {"results": []}
```
