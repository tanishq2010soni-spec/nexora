# Personal AI Assistant

A desktop AI assistant powered by Flutter + Python, featuring a rich chat interface, memory system, task management, plugin architecture, and an animated character.

## Features

- **Chat Interface**: Full-featured chat with markdown rendering, streaming responses, and tool call indicators
- **Memory System**: Persistent memory with search, filters, tags, and auto-summarization
- **Task Management**: Multi-step task creation, execution tracking, and retry/cancel
- **Plugin Architecture**: Extensible plugin system with capability and permission management
- **Animated Character**: 2D animated assistant with expression system, speech bubbles, and mouse tracking
- **Permission System**: Granular control over AI tool access with approve/deny workflow
- **System Health**: Real-time monitoring of model status, memory usage, tasks, and uptime
- **Settings**: Comprehensive settings for model, memory, tools, appearance, voice, plugins, and automation

## Screenshots

(Screenshots to be added)

## Quick Start

### Prerequisites

- Flutter SDK 3.16+
- Python 3.11+

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env      # Configure API keys
uvicorn main:app --reload --port 8755
```

### Frontend

```bash
flutter pub get
flutter run -d windows
```

## Architecture

```
+---------------------------+          +---------------------------+
|    Flutter Frontend       |  REST +  |    Python Backend         |
|                           |  WebSocket|                           |
|  - UI (Material 3)       |<--------->|  - FastAPI Server         |
|  - State (Provider)      |           |  - LLM Integration        |
|  - Local Cache           |           |  - Memory Store           |
|  - Animated Character    |           |  - Tool Executor          |
+---------------------------+           |  - Plugin Runtime        |
                                         +---------------------------+
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - System architecture and data flow
- [API Reference](docs/API.md) - Backend API documentation
- [Settings Guide](docs/SETTINGS.md) - Configuration reference
- [Plugin Development](docs/PLUGINS.md) - Creating and installing plugins
- [User Guide](docs/USER_GUIDE.md) - End-user feature documentation
- [Developer Guide](docs/DEVELOPER.md) - Setup and development workflow
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Python (FastAPI)
- **State Management**: Provider
- **Real-time**: WebSocket
- **Storage**: ChromaDB (vector), JSON files (settings)
- **LLM**: OpenAI, Anthropic, local models

## License

Proprietary. All rights reserved.

---

Built with Flutter and Python.
