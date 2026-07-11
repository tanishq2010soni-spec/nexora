# Architecture

## Overview

Personal AI Assistant uses a two-tier architecture: a Flutter frontend providing the UI and a Python backend handling AI logic, memory, tool execution, and system integration. Communication between tiers uses REST for request-response and WebSocket for real-time streaming.

```
+---------------------------+          +---------------------------+
|    Flutter Frontend       |  REST +  |    Python Backend         |
|                           |  WebSocket|                           |
|  - UI (Material 3)       |<--------->|  - FastAPI Server         |
|  - State (Provider)      |           |  - LLM Integration        |
|  - Local Cache           |           |  - Memory Store           |
|  - Animated Character    |           |  - Tool Executor          |
+---------------------------+           |  - Plugin Runtime        |
                                         |  - File Manager          |
                                         +---------------------------+
```

## Frontend Architecture

### Layer Structure

```
lib/
  core/           # Shared utilities
    theme/        # AppColors, AppTheme
    widgets/      # Common reusable widgets
    router/       # Navigation routes

  models/         # Data classes (plain Dart objects)

  providers/      # State management (ChangeNotifier + Provider)

  services/       # API communication layer

  features/       # Feature modules (screens + widgets)
    dashboard/
    chat/
    memory/
    tasks/
    settings/
    permissions/
    plugins/
    character/
```

### State Management

Provider (with ChangeNotifier) is used for state management. Each major domain has its own provider:

- **ConversationProvider** - Chat conversation list, active conversation
- **ChatProvider** - Messages, streaming state, typing indicator
- **HealthProvider** - Connection status, system metrics
- **MemoryProvider** - Memory entries, search, type counts, tags
- **TaskProvider** - Task CRUD, step tracking, status management
- **SettingsProvider** - All configurable settings, persistence
- **PermissionProvider** - Permission requests queue, history
- **PluginProvider** - Plugin registry, enable/disable
- **CharacterProvider** - Expression state, message queue, animation

### Routing

Navigation uses `Navigator.push` with `MaterialPageRoute` for a desktop-style stack navigation. No auto-router is used to keep dependencies minimal.

## Backend Architecture

### Component Overview

```
backend/
  services/
    llm_service.py        # LLM interaction (OpenAI, Claude, local)
    memory_service.py     # Memory storage and retrieval
    task_service.py       # Task management and scheduling
    tool_service.py       # Tool execution and permission gating
    plugin_service.py     # Plugin loading and lifecycle
    voice_service.py      # Text-to-speech and speech-to-text

  tools/
    mouse_tool.py
    keyboard_tool.py
    file_tool.py
    browser_tool.py
    terminal_tool.py

  adapters/
    rest_api.py           # FastAPI routes
    websocket_manager.py  # WebSocket connections
    file_adapter.py       # File system abstraction
```

## Communication

### REST Endpoints

All REST endpoints are prefixed with `/api/v1`. Used for CRUD operations and configuration.

### WebSocket

The WebSocket endpoint at `/ws/v1/chat` handles:
- Streaming LLM responses (token-by-token)
- Typing indicators
- Tool call notifications
- Permission requests
- Real-time health updates

## Data Flow

### Chat Flow

```
User Input -> ChatProvider -> ApiService.sendMessage() -> REST POST /chat
                                                              |
Backend processes -> LLM streaming -> WebSocket tokens ------>|
                                                              |
ChatProvider receives tokens -> MessageBubble renders         |
Tool calls sent via WebSocket -> Permission check -> execute  |
Result streamed back -> appended to message                   |
```

### Memory Flow

```
Conversation completed -> Backend summarizes -> stores to vector DB
Memory query -> MemoryProvider.search() -> REST GET /memory/search
Results rendered with highlight matches
```

### Task Flow

```
User creates task -> TaskProvider -> REST POST /tasks
Backend schedules -> executes steps sequentially
Progress updates via WebSocket -> TaskProvider updates UI
```

## Desktop Integration

- **Window Management**: Desktop window with frameless option, resize, minimize/maximize
- **File System**: Native file picker for attachments and plugin installation
- **System Tray**: Background operation with system tray icon
- **Global Shortcuts**: Keyboard shortcuts for quick access

## Plugin System

Plugins extend AI capabilities. They are Python packages (.whl or .zip) loaded at runtime:

- Each plugin declares capabilities, permissions, and hooks
- The plugin service sandboxes execution
- Permissions are gated through the permission system
- UI plugins can register custom settings panels

## Security

- All tool execution requires explicit user permission
- Permission decisions can be "allow once", "allow always", or "deny"
- Plugin sandboxing prevents system access without approval
- Sensitive operations require re-authentication
