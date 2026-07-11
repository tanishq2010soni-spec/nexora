# Developer Guide

## Setup Development Environment

### Prerequisites

- Python 3.12+
- Git
- Virtual environment tool (venv)

### Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd whatsapp_agent

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Install dependencies
cd backend
pip install -r requirements.txt

# Install dev dependencies
pip install pytest pytest-asyncio pytest-cov httpx
```

### IDE Configuration

Recommended VS Code extensions:

- **Python** — Microsoft Python extension
- **Pylance** — Fast, feature-rich language support
- **Ruff** — Fast Python linter

Add to `.vscode/settings.json`:

```json
{
  "python.defaultInterpreterPath": "./venv/Scripts/python.exe",
  "python.testing.pytestEnabled": true,
  "python.testing.pytestArgs": ["tests"],
  "[python]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  }
}
```

### Running the Server

```bash
cd backend
python main.py
```

Server starts at `http://localhost:8100` with auto-reload enabled.

## Code Conventions

### Naming

| Element        | Convention               | Example                     |
|----------------|--------------------------|-----------------------------|
| Packages       | lowercase, no underscores| `backend.services`          |
| Modules        | lowercase, underscores   | `sentiment_analyzer.py`     |
| Classes        | PascalCase               | `LeadScorer`                |
| Functions      | snake_case               | `calculate_score`           |
| Variables      | snake_case               | `message_count`             |
| Constants      | UPPER_CASE               | `MAX_SCORE`                 |
| Private methods| leading underscore       | `_score_sentiment`          |

### Imports

Order imports in three groups separated by a blank line:

1. Standard library (`from datetime import datetime`)
2. Third-party (`from fastapi import APIRouter`)
3. Application (`from backend.domain.entities import Lead`)

Use relative imports within the same top-level package.

### Type Hints

All functions must have type annotations:

```python
from typing import Optional
from uuid import UUID

async def calculate_score(self, lead_data: dict[str, float]) -> float:
    ...
```

### Async/Await

All database operations and service methods must be async. Use `async def` and `await` consistently.

### Error Handling

- Use HTTPException for API errors with appropriate status codes
- Log errors with the `logger` module
- Never expose internal details in error messages

## Adding New Features

### 1. Domain Entity

Add the entity to `backend/domain/entities.py`:

```python
class MyNewEntity(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    name: str
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True
```

### 2. Database Model

Add the SQLAlchemy model to `backend/infrastructure/database/models.py`:

```python
class MyNewEntityModel(Base):
    __tablename__ = "my_new_entities"

    id: Mapped[str] = mapped_column(GUID, primary_key=True)
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"))
    name: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
```

### 3. API Router

Create or extend a router in `backend/api/`:

```python
router = APIRouter(prefix="/api/v1/my-entity", tags=["my_entity"])

@router.get("/")
async def list_items(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    ...
```

Register the router in `backend/main.py`:

```python
from backend.api import my_entity
app.include_router(my_entity.router)
```

### 4. Tests

Add tests in the appropriate test directory:

- **Unit tests** — `tests/unit/test_my_service.py`
- **Integration tests** — `tests/integration/test_api.py`
- **Contract tests** — `tests/contract/test_entities.py`

### 5. Documentation

Update the relevant documentation in `docs/`.

## Architecture Decisions

### Why Pydantic v2 Entities?

- Automatic validation and serialization
- `from_attributes = True` allows direct conversion from SQLAlchemy models
- JSON Schema generation for API documentation
- Type safety with IDE autocompletion

### Why Separate Domain Entities from DB Models?

- Domain entities are pure Pydantic models without ORM coupling
- SQLAlchemy models handle database-specific concerns
- Enables testing domain logic without a database
- Clean separation of concerns

### Why SQLite for Development?

- Zero configuration, no external dependencies
- Same async interface with aiosqlite
- Easy test setup with in-memory databases
- Migration to PostgreSQL requires only URL change

### Why Service Layer Pattern?

- Business logic is testable in isolation
- Services are reusable across different API endpoints
- Clear separation from API concerns (auth, routing)
- Easy to swap implementations

### Why Async Throughout?

- Handles concurrent WhatsApp connections efficiently
- Non-blocking database operations
- Scalable to many simultaneous conversations
- Compatible with WebSocket-based features

## Commit Conventions

Use conventional commit messages:

```
feat: add lead scoring by sentiment analysis
fix: correct conversation status update query
docs: add plugin development guide
test: add domain entity contract tests
refactor: extract handoff logic to service
```

## Code Review Checklist

- [ ] Type hints on all function signatures
- [ ] Async/await used correctly
- [ ] Error handling with appropriate HTTP status codes
- [ ] Database operations within try/except for rollback
- [ ] Permissions checked on protected endpoints
- [ ] Tests pass with `pytest`
- [ ] No hardcoded secrets or tokens
- [ ] Logging added for important operations
- [ ] Documentation updated if API changed
