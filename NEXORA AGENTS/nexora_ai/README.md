# Nexora AI

**Production-grade AI framework for building intelligent agents.**

[![Python 3.12](https://img.shields.io/badge/python-3.12-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Code style: ruff](https://img.shields.io/badge/code%20style-ruff-000000.svg)](https://github.com/astral-sh/ruff)

---

## Quick Start

```bash
pip install nexora-ai

echo '{"provider": {"type": "openai", "api_key": "sk-..."}}' > config.yaml
nexora --config config.yaml
```

## Architecture

Nexora AI follows Clean Architecture principles with four layers:

```
Presentation (UI)  →  Application (Use Cases / Services)
                           ↓
                     Domain (Entities / Interfaces)
                           ↓
                     Infrastructure (Providers / Memory / Tools)
```

- **Domain** — Core entities, enums, and interface contracts.
- **Application** — Use cases and orchestrating services.
- **Infrastructure** — Concrete implementations: LLM providers, memory backends, tool execution, event bus, logging.
- **Presentation** — Framework adapters (CLI, API, GUI — none bundled by default).

Dependencies flow **inward**: outer layers depend on inner layers, never the reverse. The DI container wires everything together.

## Modules

| Module | Description |
|--------|-------------|
| `domain` | Entities, enums, interfaces, events, exceptions |
| `application/use_cases` | Conversation, planning, memory orchestration |
| `application/services` | Tool registry, automation, plugin loader, retry |
| `infrastructure/providers` | LLM adapters (OpenAI, Anthropic, GLM, Gemini, Groq, Mistral, Ollama, LM Studio, DeepSeek, OpenRouter) |
| `infrastructure/event_bus` | Async pub/sub with priority, DLQ, retry |
| `infrastructure/memory` | SQLite, vector, and in-memory backends |
| `infrastructure/config` | Layered config (YAML, env, CLI, encryption) |
| `infrastructure/logging` | Structured JSON logging with spans, metrics, correlation IDs |
| `infrastructure/tools` | Tool registry, execution, sandboxing |
| `infrastructure/security` | Permission manager, audit, constraints |
| `infrastructure/automation` | Workflow engine, scheduling, conditions |
| `infrastructure/runtime` | AI agent lifecycle, hot-reload, health |
| `infrastructure/plugin_sdk` | Plugin manifest, hooks, lifecycle |
| `infrastructure/screen` | Screen capture, OCR, clipboard, automation |

## Installation

### Basic
```bash
pip install nexora-ai
```

### With LLM providers
```bash
pip install "nexora-ai[openai]"
pip install "nexora-ai[anthropic]"
pip install "nexora-ai[gemini]"
pip install "nexora-ai[all]"
```

### With vector stores
```bash
pip install "nexora-ai[vector]"
```

### With browser/desktop automation
```bash
pip install "nexora-ai[browser]"
pip install "nexora-ai[desktop]"
```

## Usage Example

```python
import asyncio
from nexora_ai.infrastructure.providers import ProviderFactory

async def main():
    factory = ProviderFactory()
    provider = factory.create({
        "type": "openai",
        "api_key": "sk-...",
        "model": "gpt-4o",
    })

    async for chunk in provider.chat([
        {"role": "user", "content": "Hello, world!"}
    ]):
        print(chunk.content, end="")

    await provider.close()

asyncio.run(main())
```

## Documentation

- [Architecture](ARCHITECTURE.md)
- [Module Reference](MODULES.md)
- [API Reference](API_REFERENCE.md)
- [Plugin Guide](PLUGIN_GUIDE.md)
- [Memory Guide](MEMORY_GUIDE.md)
- [Tool Guide](TOOL_GUIDE.md)
- [Testing Guide](TESTING_GUIDE.md)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)
