# Testing Guide

## Overview

The test suite is organized into six categories, each serving a specific purpose in validating the system.

## Test Categories

### Unit Tests (`backend/tests/unit/`)

Tests for individual components in isolation, mocking external dependencies.

**test_domain.py**: Validates domain entity creation, `from_attributes` conversion, and all enum values.

```bash
pytest backend/tests/unit/test_domain.py -v
```

**test_services.py**: Tests business logic services with mocked database sessions.

```bash
pytest backend/tests/unit/test_services.py -v
```

### Integration Tests (`backend/tests/integration/`)

Tests that verify API endpoints work correctly with a real (in-memory) database.

**test_api.py**: Tests all REST API endpoints using `httpx.AsyncClient` and SQLite in-memory database.

```bash
pytest backend/tests/integration/test_api.py -v
```

Key patterns:
- Uses `ASGITransport` for async HTTP testing
- Overrides database session dependency with in-memory SQLite
- Tests authentication flow (login, refresh, me)
- Tests CRUD operations for calls, campaigns, leads
- Tests permission-based access control

### Contract Tests (`backend/tests/contract/`)

Tests that verify entity contracts and data shape consistency.

**test_entities.py**: Ensures all entities have required fields, correct types, and proper configuration.

```bash
pytest backend/tests/contract/test_entities.py -v
```

Validates:
- Entity field presence
- Field types (UUID, datetime, Decimal, etc.)
- `Config.from_attributes` setting
- Enum value integrity
- Model validation from dictionaries

### Voice Pipeline Tests (`backend/tests/voice/`)

Tests for the voice processing pipeline components.

**test_pipeline.py**: Tests VAD detection, STT/TTS factories, and VoicePipeline processing flow.

```bash
pytest backend/tests/voice/test_pipeline.py -v
```

Tests:
- WebRTC VAD speech/silence detection
- Silero VAD silence detection
- VAD factory provider creation
- STT factory (Whisper, Deepgram, unknown)
- TTS factory (pyttsx3, ElevenLabs, unknown)
- VoicePipeline process_input (speech, silence, noise)
- VoicePipeline generate_output streaming
- VoicePipeline process_stream (utterance detection)
- VoicePipeline detect_interruption logic
- Noise suppression functionality

### Campaign Engine Tests (`backend/tests/campaign/`)

Tests for the campaign scheduling and execution engine.

**test_campaign_engine.py**: Tests campaign lifecycle, lead processing, queue management, and retry logic.

```bash
pytest backend/tests/campaign/test_campaign_engine.py -v
```

Tests:
- Campaign start/pause/resume/stop
- Lead processing and queue addition
- FIFO queue ordering
- Retry logic with various dispositions
- Do-not-call handling
- Business hours validation
- Working day validation
- Max attempt limits

### End-to-End Tests (`backend/tests/e2e/`)

Tests that verify complete workflows from start to finish.

**test_full_flow.py**: Tests full campaign flow including organization creation, campaign management, lead processing, call simulation, disposition handling, and analytics verification.

```bash
pytest backend/tests/e2e/test_full_flow.py -v
```

Covers:
- Complete campaign lifecycle
- Multiple lead processing
- Disposition-based lead status updates
- Campaign metric tracking
- Analytics accumulation
- Sale/conversion tracking
- No-answer handling

## Running Tests

### Run All Tests

```bash
pytest
```

### Run with Coverage

```bash
pytest --cov=backend --cov-report=term-missing --cov-report=html
```

### Run Specific Categories

```bash
# Unit tests only
pytest backend/tests/unit/

# Integration tests only
pytest backend/tests/integration/

# Voice tests only
pytest backend/tests/voice/

# Campaign tests only
pytest backend/tests/campaign/

# E2E tests only
pytest backend/tests/e2e/

# Contract tests only
pytest backend/tests/contract/
```

### Run with Verbose Output

```bash
pytest -v
```

### Run with Live Logging

```bash
pytest -v --log-cli-level=DEBUG
```

### Run Specific Test

```bash
pytest backend/tests/unit/test_domain.py::TestOrganization::test_create -v
```

## Writing Tests

### Test Structure

```python
from __future__ import annotations

import pytest
from unittest.mock import AsyncMock, MagicMock


class TestFeature:
    def setup_method(self):
        # Setup before each test
        self.mock_dependency = MagicMock()

    def test_basic_functionality(self):
        # Arrange
        expected = "result"

        # Act
        actual = function_under_test()

        # Assert
        assert actual == expected

    @pytest.mark.asyncio
    async def test_async_functionality(self):
        # Arrange
        mock = AsyncMock()
        mock.async_method.return_value = "async_result"

        # Act
        result = await mock.async_method()

        # Assert
        assert result == "async_result"
```

### Fixtures

```python
@pytest.fixture
def sample_organization():
    from backend.domain.entities import Organization
    return Organization(name="Test Org", slug="test-org")

@pytest_asyncio.fixture
async def db_session():
    # Create in-memory database session
    engine = create_async_engine("sqlite+aiosqlite://")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with async_sessionmaker(engine)() as session:
        yield session
    await engine.dispose()
```

### Mocking

```python
# Mocking a service
mock_scorer = MagicMock()
mock_scorer.calculate_score.return_value = 85.0

# Mocking an async method
mock_stt.transcribe = AsyncMock(return_value="hello world")

# Mocking with side effects
mock_vad.is_speech.side_effect = [True, False, True]
```

### Assertions

```python
# Basic assertions
assert result == expected
assert result is not None
assert len(items) > 0

# Type assertions
assert isinstance(entity.id, UUID)
assert isinstance(entity.created_at, datetime)

# Exception assertions
with pytest.raises(ValueError, match="Unknown provider"):
    factory.create("unknown", {})

# List/dict assertions
assert "item" in items
assert entity.field == Decimal("10.00")
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -r requirements.txt
      - run: pip install pytest pytest-asyncio pytest-cov httpx
      - run: pytest --cov=backend --cov-report=term-missing
```
