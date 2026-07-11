# Developer Setup Guide

## Prerequisites

- **Flutter SDK** 3.16+ (stable channel)
- **Python** 3.11+
- **Git**
- **Visual Studio Code** or **IntelliJ IDEA** (recommended)
- **Windows** 10/11, macOS 13+, or Linux (Ubuntu 22.04+)

## Frontend Setup

### 1. Install Flutter

```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (Windows PowerShell)
$env:Path += ";C:\path\to\flutter\bin"

# Verify installation
flutter doctor
```

Ensure all checkboxes are green. Install missing dependencies as recommended.

### 2. Clone and Setup

```bash
git clone <repository-url> personal_ai
cd personal_ai

# Install dependencies
flutter pub get

# Run code generation (if applicable)
dart run build_runner build
```

### 3. Run the App

```bash
# Run in debug mode
flutter run

# Run with specific window size (desktop)
flutter run -d windows --window-size 1280,800
```

### 4. Project Structure

```
lib/
  main.dart                  # App entry point
  core/
    theme/
      app_colors.dart        # Color constants
      app_theme.dart         # Theme configuration
    widgets/                 # Shared widgets
    router/                  # Route definitions
  models/                    # Data models
  providers/                 # State management
  services/                  # API services
  features/                  # Feature modules
    dashboard/
    chat/
    memory/
    tasks/
    settings/
    permissions/
    plugins/
    character/
```

## Backend Setup

### 1. Python Environment

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Activate (macOS/Linux)
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Configuration

Create `backend/.env`:

```env
HOST=0.0.0.0
PORT=8755
LOG_LEVEL=INFO

# Model Configuration
OPENAI_API_KEY=sk-your-key-here
ANTHROPIC_API_KEY=sk-ant-your-key-here
DEFAULT_MODEL=gpt-4

# Storage
MEMORY_STORAGE_PATH=./data/memory
SETTINGS_PATH=./data/settings.json
PLUGINS_PATH=./data/plugins
```

### 3. Run Backend

```bash
# Start the server
python main.py

# Or with hot reload (development)
uvicorn main:app --reload --host 0.0.0.0 --port 8755
```

### 4. Backend Structure

```
backend/
  main.py                    # Application entry point
  config.py                  # Configuration loader
  requirements.txt           # Python dependencies
  services/
    llm_service.py           # LLM integration
    memory_service.py        # Memory management
    task_service.py          # Task execution
    tool_service.py          # Tool registry
    plugin_service.py        # Plugin system
    voice_service.py         # Voice I/O
  tools/
    mouse_tool.py
    keyboard_tool.py
    file_tool.py
    browser_tool.py
    terminal_tool.py
  adapters/
    rest_api.py              # FastAPI routes
    websocket_manager.py     # WebSocket handler
```

## Running Full Stack

```bash
# Terminal 1: Backend
cd backend
uvicorn main:app --reload --port 8755

# Terminal 2: Frontend
flutter run -d windows
```

## Development Workflow

### Code Style

- Dart: Follow effective_dart style guide
- Python: Follow PEP 8
- Use `flutter analyze` for static analysis
- Use `ruff` or `black` for Python formatting

### Testing

```bash
# Run Flutter tests
flutter test

# Run with coverage
flutter test --coverage

# Run backend tests
cd backend && pytest

# Run all tests
cd backend && pytest && cd .. && flutter test
```

### Building for Production

```bash
# Build Windows executable
flutter build windows --release

# Output location: build/windows/runner/Release/

# Build macOS app
flutter build macos --release

# Build Linux app
flutter build linux --release
```

### Debugging

**Flutter**:
- Use `debugPrint` for logging
- Flutter DevTools for widget inspection
- Hot reload for quick iteration (`r` in console)

**Python**:
- Use `print()` or `logging` module
- VS Code debugger with launch config
- `--reload` flag for auto-restart on changes

## Dependencies

### Flutter (pubspec.yaml)

Key dependencies:
- `provider` - State management
- `flutter_markdown` - Markdown rendering
- `web_socket_channel` - WebSocket client
- `http` - HTTP client
- `shared_preferences` - Local storage

### Python (requirements.txt)

Key dependencies:
- `fastapi` - REST framework
- `uvicorn` - ASGI server
- `websockets` - WebSocket support
- `openai` - OpenAI API client
- `anthropic` - Anthropic API client
- `chromadb` - Vector database for memory
- `aiofiles` - Async file operations

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `OPENAI_API_KEY` | Yes* | - | OpenAI API key |
| `ANTHROPIC_API_KEY` | No | - | Anthropic API key |
| `HOST` | No | 0.0.0.0 | Backend host |
| `PORT` | No | 8755 | Backend port |
| `LOG_LEVEL` | No | INFO | Logging verbosity |

*At least one model provider API key is required.
