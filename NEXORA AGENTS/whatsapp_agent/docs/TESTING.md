# Testing Guide

## Test Structure

Tests are organized into five categories following a testing pyramid approach:

```
        ┌─────────┐
        │  E2E    │  Few, slow, full-system tests
       ┌┴─────────┴┐
       │ Workflow  │  Medium, multi-step integration
      ┌┴───────────┴┐
      │ Integration │  Medium, API + DB tests
     ┌┴─────────────┴┐
     │   Contract   │  Shape and interface verification
    ┌┴───────────────┴┐
    │      Unit       │  Many, fast, isolated tests
    └─────────────────┘
```

### Directory Layout

```
backend/tests/
├── __init__.py
├── unit/
│   ├── __init__.py
│   ├── test_domain.py       # Domain entity tests
│   └── test_services.py     # Service layer tests
├── integration/
│   ├── __init__.py
│   └── test_api.py          # API endpoint tests
├── contract/
│   ├── __init__.py
│   └── test_entities.py     # Entity contract tests
├── workflow/
│   ├── __init__.py
│   └── test_lead_workflow.py  # Lead qualification workflow
└── e2e/
    ├── __init__.py
    └── test_full_flow.py    # End-to-end flow test
```

## Running Tests

### Run All Tests

```bash
cd backend
pytest
```

### Run Specific Test Categories

```bash
# Unit tests only
pytest tests/unit/

# Integration tests only
pytest tests/integration/

# Contract tests only
pytest tests/contract/

# Workflow tests only
pytest tests/workflow/

# E2E tests only
pytest tests/e2e/
```

### Run with Coverage

```bash
pip install pytest-cov
pytest --cov=backend --cov-report=term-missing
```

### Run with Verbose Output

```bash
pytest -v
```

### Run Specific Test Function

```bash
pytest tests/unit/test_domain.py::TestOrganization::test_create_organization -v
```

## Writing Tests

### Unit Tests

Unit tests test individual components in isolation. Mock all external dependencies (database, network, filesystem).

```python
import pytest
from backend.services.lead_scorer import LeadScorer

@pytest.mark.asyncio
async def test_calculate_score():
    scorer = LeadScorer()
    score = await scorer.calculate_score({
        "message_count": 10,
        "response_rate": 0.5,
        "sentiment": "positive",
        "intent": "purchase",
        "avg_response_minutes": 30,
    })
    assert 20.0 <= score <= 100.0
```

### Integration Tests

Integration tests verify API endpoints with a real database. Use SQLite in-memory for test isolation.

```python
import pytest
from httpx import AsyncClient, ASGITransport

@pytest.mark.asyncio
async def test_health_endpoint(test_app, auth_headers):
    transport = ASGITransport(app=test_app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/health", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
```

### Contract Tests

Contract tests ensure all domain entities and enums meet expected structural requirements.

```python
def test_entity_has_from_attributes_config():
    assert Organization.Config.from_attributes is True

def test_enum_is_str_enum():
    import enum
    assert issubclass(LeadStatus, str, enum.Enum)
```

### Workflow Tests

Workflow tests cover multi-step business processes with database state.

```python
@pytest.mark.asyncio
async def test_lead_qualification(db_session):
    lead = LeadModel(
        id=str(uuid4()),
        organization_id="org-id",
        customer_phone="+1234567890",
        status="new",
    )
    db_session.add(lead)
    await db_session.commit()

    lead.status = "qualified"
    db_session.add(lead)
    await db_session.commit()

    assert lead.status == "qualified"
```

### E2E Tests

End-to-end tests validate the full system flow from API through database.

```python
@pytest.mark.asyncio
async def test_full_flow(client, headers):
    # Create lead via API
    resp = await client.post(
        "/api/v1/crm/leads?customer_phone=%2B1234567890",
        headers=headers,
    )
    assert resp.status_code == 201

    # Convert lead to customer
    lead_id = resp.json()["id"]
    resp = await client.post(
        f"/api/v1/crm/leads/{lead_id}/convert",
        headers=headers,
    )
    assert resp.status_code == 201
    assert resp.json()["phone"] == "+1234567890"
```

## Mock Strategies

### Database

For integration, workflow, and E2E tests, override the database engine with SQLite in-memory:

```python
@pytest_asyncio.fixture
async def db_engine():
    from backend.infrastructure.database.models import Base
    engine = create_async_engine("sqlite+aiosqlite://")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    await engine.dispose()

@pytest_asyncio.fixture
async def test_app(db_engine):
    import backend.infrastructure.database as db_module
    original = db_module.async_session_factory
    db_module.engine = db_engine
    db_module.async_session_factory = async_sessionmaker(db_engine, ...)
    yield app
    db_module.async_session_factory = original
```

### Authentication

For API tests, seed a user and obtain a real JWT token:

```python
@pytest_asyncio.fixture
async def seed_user(db_session):
    org = OrganizationModel(id=str(uuid4()), name="Test", slug="test")
    user = UserModel(
        id=str(uuid4()),
        organization_id=org.id,
        email="test@test.com",
        password_hash=pwd_context.hash("password"),
        name="Test",
        role="admin",
        permissions=[p.value for p in Permission],
    )
    db_session.add_all([org, user])
    await db_session.commit()
    return user

@pytest_asyncio.fixture
async def auth_token(client, seed_user):
    resp = await client.post("/api/v1/auth/login", json={
        "email": "test@test.com",
        "password": "password",
    })
    return resp.json()["access_token"]
```

### External Services

For services that call external APIs (e.g., `IntentDetector._nexora_fallback`), the code already handles `ImportError` gracefully, so no mocking is needed in most cases. If you need to mock:

```python
from unittest.mock import patch

@pytest.mark.asyncio
async def test_with_mock():
    detector = IntentDetector()
    with patch.object(detector, '_nexora_fallback', return_value=IntentCategory.support):
        result = await detector.detect("help")
        assert result == IntentCategory.support
```

### No Mocking Needed For:

- **SentimentAnalyzer** — Pure TextBlob, no network calls
- **LanguageDetector** — Pure langdetect, no network calls
- **LeadScorer** — Pure math, no dependencies
- **ConversationSummarizer** — Pure text processing

## Test Configuration

Add a `pytest.ini` or `pyproject.toml` configuration:

```ini
[pytest]
asyncio_mode = auto
testpaths = tests
python_files = test_*.py
```

Or in `pyproject.toml`:

```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
python_files = ["test_*.py"]
```
