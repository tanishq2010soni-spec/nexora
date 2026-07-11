# Model Configuration

**Phase:** E.5 — Provider Unification  
**Date:** 2026-07-01

---

## Overview

All model configuration is centralized in `nexora_ai`. Agents request provider configuration from Nexora Brain — no local API keys, no duplicated routing logic.

---

## Configuration Sources

### 1. Environment Variables (Development)

```bash
# Cloud providers
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
export GEMINI_API_KEY="AIza..."
export DEEPSEEK_API_KEY="sk-..."
export GROQ_API_KEY="gsk_..."
export MISTRAL_API_KEY="..."
export OPENROUTER_API_KEY="sk-or-..."
export GLM_API_KEY="..."

# Local providers
export OLLAMA_BASE_URL="http://localhost:11434"
export LM_STUDIO_BASE_URL="http://localhost:1234"
```

### 2. Nexora Brain API (Production)

```
GET /api/v1/providers/
Authorization: Bearer <token>

Response:
[
  {
    "id": "uuid",
    "name": "OpenAI Production",
    "provider_type": "openai",
    "api_key_encrypted": "sk-...",
    "endpoint_url": "https://api.openai.com/v1",
    "is_active": true,
    "supports_streaming": true,
    "supports_vision": true,
    "supports_tool_calling": true,
    "context_window": 128000,
    "pricing_input_per_1k": 0.005,
    "pricing_output_per_1k": 0.015,
    "health_status": "active"
  }
]
```

### 3. ProviderConfigService

```python
from nexora_ai.infrastructure.provider_config_service import ProviderConfigService
from nexora_ai.infrastructure.provider_router import ProviderRouter

router = ProviderRouter()
service = ProviderConfigService(
    provider_router=router,
    control_plane_url="http://localhost:8000",
    org_id="org-uuid",
)

# Fetch from Nexora Brain
count = await service.sync_providers()

# Or register from env vars
count = service.register_from_env()
```

---

## Model Defaults per Provider

| Provider | Default Chat Model | Default Embedding Model |
|----------|-------------------|------------------------|
| OpenAI | gpt-4o | text-embedding-3-small |
| Anthropic | claude-sonnet-4-20250514 | (none) |
| Gemini | gemini-2.0-flash | text-embedding-004 |
| DeepSeek | deepseek-chat | (none) |
| Groq | llama-3.3-70b-versatile | (none) |
| OpenRouter | openrouter/auto | (none) |
| Mistral | mistral-large-latest | mistral-embed |
| Ollama | llama3 | nomic-embed-text |
| LM Studio | local-model | (none) |
| GLM | glm-4-flash | glm-embedding-v3 |

---

## Provider Capabilities

### Chat Models

| Provider | Models |
|----------|--------|
| OpenAI | gpt-4o, gpt-4o-mini, gpt-4-turbo, gpt-4, gpt-3.5-turbo, o1, o1-mini, o1-pro |
| Anthropic | claude-sonnet-4-20250514, claude-3-5-sonnet, claude-3-5-haiku, claude-3-opus, claude-3-haiku |
| Gemini | gemini-2.0-flash, gemini-2.0-flash-lite, gemini-1.5-pro, gemini-1.5-flash |
| DeepSeek | deepseek-chat, deepseek-coder, deepseek-reasoner |
| Groq | llama-3.3-70b-versatile, llama-3.1-8b-instant, gemma2-9b-it, mixtral-8x7b-32768 |
| Mistral | mistral-large-latest, mistral-medium-latest, mistral-small-latest, open-mixtral-8x22b |
| Ollama | llama3, llama3.1, mistral, codellama, gemma2, phi3, qwen2, deepseek-coder |

### Embedding Models

| Provider | Models |
|----------|--------|
| OpenAI | text-embedding-3-small, text-embedding-3-large, text-embedding-ada-002 |
| Gemini | text-embedding-004 |
| Mistral | mistral-embed |
| Ollama | nomic-embed-text |
| GLM | glm-embedding-v3 |

---

## Configuration Overrides

### Per-Request Override

```python
response = await router.complete(
    "Hello",
    config={
        "model": "gpt-4o-mini",  # Override default model
        "temperature": 0.3,       # Override default temperature
        "max_tokens": 1000,       # Override default max_tokens
    },
)
```

### Per-Provider Config

```python
await router.register_provider(
    ProviderType.OPENAI,
    config={
        "api_key": "sk-...",
        "model": "gpt-4o",
        "embedding_model": "text-embedding-3-small",
        "max_tokens": 8192,
        "temperature": 0.5,
        "timeout": 30.0,
        "retry_max_attempts": 3,
    },
    priority=10,
)
```

---

## Context Windows

| Provider | Model | Context Window |
|----------|-------|---------------|
| OpenAI | gpt-4o | 128,000 |
| OpenAI | gpt-4o-mini | 128,000 |
| OpenAI | gpt-3.5-turbo | 16,384 |
| Anthropic | claude-sonnet-4-20250514 | 200,000 |
| Anthropic | claude-3-opus | 200,000 |
| Gemini | gemini-2.0-flash | 1,000,000 |
| Gemini | gemini-1.5-pro | 2,000,000 |
| DeepSeek | deepseek-chat | 64,000 |
| Mistral | mistral-large-latest | 128,000 |

---

## Pricing Reference

| Provider | Input (per 1K tokens) | Output (per 1K tokens) |
|----------|----------------------|------------------------|
| OpenAI gpt-4o | $0.005 | $0.015 |
| OpenAI gpt-4o-mini | $0.00015 | $0.0006 |
| Anthropic claude-sonnet-4-20250514 | $0.003 | $0.015 |
| Gemini gemini-2.0-flash | $0.0001 | $0.0004 |
| DeepSeek deepseek-chat | $0.00014 | $0.00028 |
| Groq llama-3.3-70b-versatile | $0.00059 | $0.00079 |
| Mistral mistral-large-latest | $0.002 | $0.006 |
| Ollama (local) | $0 | $0 |
