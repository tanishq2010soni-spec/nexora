# NEXORA

AI-powered business platform. FastAPI backend with Flutter frontend.

## Prerequisites

- Python 3.11+
- Flutter 3.x
- Redis (optional, for caching)
- Qdrant (optional, for vector storage)
- Ollama (optional, for local LLM)

## Quick Start

```bash
# Backend
poetry install
cp .env.example .env
uvicorn src.main:app --reload

# Frontend
cd control_center
flutter pub get
flutter run -d windows
```

## Documentation

See `release/` directory for installation guide, changelog, and deployment instructions.
