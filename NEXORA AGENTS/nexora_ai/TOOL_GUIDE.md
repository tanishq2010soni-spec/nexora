# Tool Development Guide

## Overview

Tools are executable functions that agents can call. They represent capabilities like file I/O, web requests, code execution, and more.

## Tool API

Each tool is defined by a `ToolDefinition` and implemented by a handler function.

### Definition Structure

```python
from nexora_ai.domain.entities.tool import (
    ToolDefinition, ToolParameter, ToolContext, ToolResult,
)
from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolPermission

definition = ToolDefinition(
    name="read_file",
    description="Read contents of a file",
    category=ToolCategory.DATA,
    version="1.0.0",
    author="Nexora",
    permissions=[ToolPermission.FILE_READ],
    parameters=[
        ToolParameter(name="path", type="string", description="File path", required=True),
        ToolParameter(name="encoding", type="string", description="File encoding", default="utf-8"),
    ],
    return_type="string",
    timeout_seconds=30,
)
```

### Handler Signature

```python
async def my_tool_handler(context: ToolContext) -> str | ToolResult:
    # Access arguments via context.arguments
    path = context.arguments.get("path")

    # Access metadata
    user_id = context.user_id
    conversation_id = context.conversation_id

    # Return a string (auto-wrapped in ToolResult)
    return "file contents"

    # Or return a ToolResult directly
    return ToolResult(success=True, output="file contents")
```

## Creating Custom Tools

### Step 1: Define the tool

```python
from nexora_ai.domain.entities.tool import ToolDefinition, ToolParameter, ToolContext, ToolResult
from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolPermission

weather_tool = ToolDefinition(
    name="get_weather",
    description="Get current weather for a city",
    category=ToolCategory.UTILITY,
    permissions=[ToolPermission.NETWORK],
    parameters=[
        ToolParameter(name="city", type="string", description="City name", required=True),
    ],
)
```

### Step 2: Implement the handler

```python
import httpx

async def get_weather_handler(ctx: ToolContext) -> str:
    city = ctx.arguments["city"]
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"https://wttr.in/{city}?format=%C+%t")
        return resp.text
```

### Step 3: Register with the registry

```python
from nexora_ai.infrastructure.tools import ToolRegistry

registry = ToolRegistry()
registry.register(weather_tool, get_weather_handler)
```

### Step 4: Execute the tool

```python
context = ToolContext(
    tool_name="get_weather",
    arguments={"city": "London"},
    user_id="user-1",
    timeout=10,
)
result = await registry.execute(context)
print(result.output)
```

## Permission System

Tools must declare required permissions. The `PermissionManager` enforces access:

| Permission | Description |
|------------|-------------|
| `FILE_READ` | Read files from disk |
| `FILE_WRITE` | Write files to disk |
| `NETWORK` | Make network requests |
| `EXECUTE` | Execute system commands |
| `SHELL` | Run shell scripts |
| `BROWSER` | Control web browser |
| `SCREENSHOT` | Capture screen |
| `CLIPBOARD` | Access clipboard |
| `EMAIL` | Send emails |
| `AI` | Call AI providers |

```python
from nexora_ai.infrastructure.security import PermissionManager, PermissionRule
from nexora_ai.domain.enums.security_enums import PermissionEffect, ResourceType, AuditAction

pm = PermissionManager()
pm.add_rule(PermissionRule(
    ResourceType.TOOL, "get_weather", PermissionEffect.ALLOW,
    actions=[AuditAction.EXECUTE],
))
```

## Security Considerations

1. **Validate all inputs**: Check argument types, lengths, and allowed values
2. **Set appropriate timeouts**: Prevent runaway tool execution
3. **Least privilege**: Request only the permissions you need
4. **Sandbox untrusted tools**: Use `SandboxLevel.ISOLATED` for user-submitted tools
5. **Audit sensitive operations**: Use `PermissionEffect.AUDIT_ONLY` for visibility
6. **Limit resource access**: Constrain file paths, network endpoints, and system commands

## Built-in Tools Reference

The framework includes these built-in tool categories:

| Category | Example Tools |
|----------|--------------|
| `UTILITY` | `calculate`, `format_json`, `uuid_gen` |
| `DATA` | `read_file`, `write_file`, `list_directory` |
| `NETWORK` | `http_get`, `http_post`, `web_search` |
| `AI` | `generate_text`, `embed_text`, `classify` |
| `SYSTEM` | `run_command`, `get_system_info` |
| `BROWSER` | `navigate`, `click`, `type_text`, `screenshot` |
| `COMMUNICATION` | `send_email`, `send_slack` |
