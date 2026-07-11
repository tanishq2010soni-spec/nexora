# Developer Guide

## Prerequisites

- Python 3.11+
- Poetry 1.7+
- Docker & Docker Compose
- Node.js 18+ (for pre-commit hooks)

## Setup

```bash
# Clone the repository
git clone https://github.com/nexora/nexora.git
cd nexora

# Install Python dependencies
poetry install

# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Copy environment config
cp .env.example .env
```

## Development Workflow

### Running the server

```bash
# Start infrastructure services
docker compose up -d postgres redis qdrant

# Run database migrations
alembic upgrade head

# Start development server
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

### Running the full stack

```bash
docker compose up -d
```

### Running tests

```bash
# All tests
pytest tests/ -v

# With coverage
pytest tests/ --cov=src --cov-report=term --cov-report=html

# Specific test file
pytest tests/unit/test_auth.py -v

# E2E tests
pytest tests/e2e/ -v
```

### Code quality

```bash
# Formatting
black src/ tests/

# Imports
isort src/ tests/

# Linting
ruff check src/ tests/
flake8 src/ tests/

# Type checking
pyright src/
mypy src/

# Security scan
bandit -r src/
safety check
```

## Code Standards

1. **Type hints**: All functions must have type annotations
2. **Async**: Use async/await for all I/O operations
3. **Error handling**: Use typed exceptions, never bare except
4. **Logging**: Use structlog with context variables
5. **Testing**: Write tests for all new code (minimum 85% coverage)
6. **Documentation**: Document all public APIs with docstrings
7. **Migrations**: Create Alembic migrations for schema changes
8. **Metrics**: Add Prometheus metrics for new endpoints

## Project Structure

```
src/
├── main.py                          # FastAPI app entry point
├── config.py                        # Pydantic settings
├── application/
│   ├── interfaces/                  # Abstract repositories
│   └── services/                    # Business logic
├── domain/models/                   # Domain models
├── infrastructure/
│   ├── cache/                       # Redis cache
│   ├── database/                    # SQLAlchemy models + repos
│   ├── embeddings/                  # Vector embeddings
│   ├── integrations/               # Third-party APIs
│   ├── jobs/                        # ARQ background worker
│   ├── llm/                         # Ollama client
│   ├── logging/                     # structlog config
│   ├── metrics/                     # Prometheus metrics
│   ├── middleware/                   # Rate limiting
│   ├── realtime/                    # WebSocket manager
│   ├── security/                    # Encryption
│   ├── telemetry/                   # OpenTelemetry
│   └── vector/                      # Qdrant client
└── presentation/
    ├── api/                         # Route handlers
    └── schemas/                     # Pydantic schemas
```
