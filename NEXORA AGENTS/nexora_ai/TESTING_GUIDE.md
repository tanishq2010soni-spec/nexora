# Testing Guide

## Test Structure

```
tests/
├── conftest.py              # Shared fixtures
├── mocks/                   # Mock implementations
│   ├── __init__.py
│   ├── mock_provider.py     # MockProviderAdapter
│   ├── mock_memory.py       # InMemoryMemoryBackend
│   ├── mock_event_bus.py    # MockEventBus
│   ├── mock_runtime.py      # MockRuntime
│   └── mock_config.py       # MockConfigManager
├── unit/                    # Unit tests
│   ├── test_provider_router.py
│   ├── test_glm_adapter.py
│   ├── test_memory_manager.py
│   ├── test_conversation_usecases.py
│   ├── test_planning_service.py
│   ├── test_event_bus.py
│   ├── test_config_manager.py
│   ├── test_json_logger.py
│   ├── test_permission_manager.py
│   ├── test_tool_registry.py
│   ├── test_automation_engine.py
│   ├── test_plugin_loader.py
│   ├── test_retry_service.py
│   └── test_di_container.py
├── integration/             # Integration tests
│   ├── test_sqlite_memory.py
│   ├── test_runtime_lifecycle.py
│   └── test_event_bus_workflow.py
└── contract/               # Contract tests
    └── test_provider_contract.py
```

## Running Tests

### All tests
```bash
pytest
```

### By category
```bash
pytest -m unit           # Unit tests only
pytest -m integration    # Integration tests only
pytest -m contract       # Contract tests only
```

### With coverage
```bash
pytest --cov=nexora_ai --cov-report=term-missing
```

## Mocking Patterns

### Provider Mock
```python
from tests.mocks import MockProviderAdapter

provider = MockProviderAdapter({"model": "test"})
provider.set_response("custom_key", "Custom response")
provider.set_latency(0.1)  # Simulate network delay
```

### Memory Mock
```python
from tests.mocks import InMemoryMemoryBackend
from nexora_ai.domain.entities.memory import MemoryEntry
from nexora_ai.domain.enums.memory_enums import MemoryType

memory = InMemoryMemoryBackend()
await memory.initialize()
await memory.store(MemoryEntry(id="1", type=MemoryType.CONVERSATION, content="test"))
```

### Event Bus Mock
```python
from tests.mocks import MockEventBus

bus = MockEventBus()
received = []

async def handler(event):
    received.append(event)

await bus.subscribe("my.event", handler)
await bus.publish("my.event", {"key": "value"})
assert len(received) == 1

# Inspect published events
events = bus.get_published_events("my.event")
assert len(events) == 1
```

### Config Mock
```python
from tests.mocks import MockConfigManager

config = MockConfigManager({"key": "value"})
assert config.get("key") == "value"
config.set("nested.key", 42)
assert config.get("nested.key") == 42
```

## Integration Test Setup

Integration tests may require:
- `aiosqlite` for SQLite memory tests
- `httpx` for provider integration tests
- Optional provider SDKs (openai, anthropic, etc.)

Use markers to skip tests when dependencies are missing:

```python
import pytest

@pytest.mark.skipif(not HAS_OPENAI, reason="openai not installed")
async def test_openai_provider():
    ...
```

## Contract Testing

Contract tests verify that all implementations satisfy their interface contracts:

```python
# tests/contract/test_provider_contract.py
@pytest.mark.parametrize("name,provider_class", get_all_providers())
def test_all_providers_have_required_methods(name, provider_class):
    for method in ["chat", "complete", "embed", "generate_tool_call"]:
        assert hasattr(provider_class, method)
```

Add new providers to `get_all_providers()` to ensure they meet the contract.

## Performance Testing

Use the `logger.record_metric()` for tracking performance:

```python
import time
start = time.monotonic()
result = await some_operation()
elapsed = (time.monotonic() - start) * 1000
logger.record_metric("operation_time", elapsed, unit="ms")
```

## CI Integration

### GitHub Actions example

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.12"]

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      - run: pip install -e ".[all]"
      - run: pip install pytest pytest-asyncio pytest-cov
      - run: pytest --cov=nexora_ai --cov-report=xml
      - uses: codecov/codecov-action@v4
```
