# Developer Guide

## Setup

### Prerequisites

- Python 3.12+
- Git
- PostgreSQL (for production) or SQLite (for development)
- Redis (optional, for caching)

### Development Environment

```bash
# Clone the repository
git clone <repo-url>
cd calling_agent

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install dev dependencies
pip install pytest pytest-asyncio pytest-cov httpx

# Copy environment file
cp .env.example .env

# Run the development server
python -m backend.main
```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=backend --cov-report=term-missing

# Run specific test suite
pytest backend/tests/unit/
pytest backend/tests/integration/
pytest backend/tests/voice/
pytest backend/tests/campaign/
pytest backend/tests/e2e/
pytest backend/tests/contract/

# Run with verbose output
pytest -v

# Run specific test file
pytest backend/tests/unit/test_domain.py
```

## Code Conventions

### Style Guide

- Follow PEP 8 for Python code
- Use type hints for all function signatures
- Use `from __future__ import annotations` in all files
- Max line length: 120 characters
- Use descriptive variable names
- Use single quotes for strings

### Project Structure

```
backend/
├── api/           # FastAPI routers (presentation layer)
│   ├── __init__.py
│   ├── auth.py    # Authentication endpoints
│   ├── calls.py   # Call management endpoints
│   ├── health.py  # Health check endpoint
│   └── ...
├── application/   # Application services
│   └── __init__.py
├── domain/        # Domain layer
│   ├── entities.py  # Domain entities
│   └── enums.py     # Enum definitions
├── infrastructure/  # Infrastructure layer
│   ├── database/    # Database models and sessions
│   ├── phone/       # Phone provider implementations
│   ├── voice/       # Voice pipeline implementations
│   └── streaming/   # WebSocket streaming
├── services/      # Business logic
└── tests/         # Test suites
```

### Naming Conventions

- **Files**: snake_case (e.g., `voice_pipeline.py`)
- **Classes**: PascalCase (e.g., `VoicePipeline`)
- **Functions/Methods**: snake_case (e.g., `process_input`)
- **Variables**: snake_case (e.g., `audio_frame`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_ATTEMPTS`)
- **Private members**: Prefix with underscore (e.g., `_vad`)
- **Type variables**: PascalCase (e.g., `T`, `AsyncSession`)

### Import Order

1. `from __future__ import annotations`
2. Standard library imports
3. Third-party imports
4. Application imports

Separate groups with blank lines.

## Adding Phone Providers

1. Create a new directory under `backend/infrastructure/phone/<provider>/`
2. Implement the phone provider interface
3. Add the provider to `backend/infrastructure/phone/__init__.py` factory
4. Add configuration fields to `config.py` if needed
5. Add webhook endpoints to the API
6. Add provider type to `PhoneProvider` enum in `domain/enums.py`
7. Add tests for the new provider

## Adding Voice Providers

### STT Provider

1. Create a new file in `backend/infrastructure/voice/stt/`
2. Implement the `STTProvider` abstract base class
3. Add to `STTFactory.create()` in `backend/infrastructure/voice/stt/factory.py`
4. Add provider type to `STTProvider` enum in `domain/enums.py`
5. Add configuration to `config.py`
6. Add tests

### TTS Provider

1. Create a new file in `backend/infrastructure/voice/tts/`
2. Implement the `TTSProvider` abstract base class
3. Add to `TTSFactory.create()` in `backend/infrastructure/voice/tts/factory.py`
4. Add provider type to `TTSProvider` enum in `domain/enums.py`
5. Add configuration to `config.py`
6. Add tests

### VAD Provider

1. Create a new file in `backend/infrastructure/voice/vad/`
2. Implement the `VADProvider` abstract base class
3. Add to `VADFactory.create()` in `backend/infrastructure/voice/vad/factory.py`
4. Add provider type to `VADProvider` enum in `domain/enums.py`
5. Add tests

## Architecture Decisions

### Why FastAPI?

- Async support for real-time audio streaming
- Automatic OpenAPI documentation
- Pydantic integration for validation
- High performance
- WebSocket support built-in

### Why SQLAlchemy Async?

- Non-blocking database operations during calls
- Support for both SQLite and PostgreSQL
- Type-safe queries with Mapped types
- Alembic migrations support

### Why Domain-Driven Design?

- Clear separation of concerns
- Testable business logic
- Provider-agnostic core
- Easy to extend with new providers

### Why Factory Pattern for Providers?

- Decouples provider creation from usage
- Easy to add new providers without modifying existing code
- Configuration-driven provider selection
- Testable with mock providers

## Debugging

### Enable Debug Mode

```env
CA_DEBUG=true
```

### Database Echo

```env
CA_DATABASE_ECHO=true
```

This will log all SQL queries to the console.

### VAD Debugging

To debug VAD behavior, test with different frame sizes and mode settings:

```python
from backend.infrastructure.voice.vad.factory import VADFactory

vad = VADFactory.create("webrtc", {"mode": 3, "frame_ms": 10})
frame = b"\x00" * vad.get_frame_size()
print(f"Speech: {vad.is_speech(frame)}")
print(f"Silence: {vad.detect_silence(frame)}")
```

### STT Debugging

Test STT with sample audio:

```python
import asyncio
from backend.infrastructure.voice.stt.factory import STTFactory

async def debug_stt():
    stt = STTFactory.create("whisper", {"model": "tiny"})
    with open("test.wav", "rb") as f:
        audio = f.read()
    text = await stt.transcribe(audio)
    print(f"Transcribed: {text}")

asyncio.run(debug_stt())
```
