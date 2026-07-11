# Provider Architecture

**Phase:** E.5 — Provider Unification  
**Date:** 2026-07-01  
**Status:** COMPLETE

---

## Overview

NEXORA now has a single centralized AI Provider System. All provider configuration flows through `nexora_ai`. Agents never maintain independent provider configuration, API keys, or routing logic.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                NEXORA PROVIDER SYSTEM                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              ProviderConfigService                    │   │
│  │  Fetches config from Nexora Brain or env vars        │   │
│  │  Registers providers with ProviderRouter              │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         │                                    │
│  ┌──────────────────────▼───────────────────────────────┐   │
│  │              ProviderRouter                           │   │
│  │  Routing: PRIORITY | FALLBACK | LOAD_BALANCE          │   │
│  │  Health: HealthMonitor (30s interval)                 │   │
│  │  Cost: CostTracker (per-provider)                     │   │
│  │  Rate: RateLimiter (token bucket)                     │   │
│  └──────┬────────┬────────┬────────┬────────┬──────────┘   │
│         │        │        │        │        │                │
│  ┌──────▼──┐ ┌───▼───┐ ┌─▼─────┐ ┌▼──────┐ ┌▼──────────┐  │
│  │ OpenAI  │ │Anthrop│ │Gemini │ │DeepSeek│ │  Ollama   │  │
│  │ Adapter │ │  ic   │ │Adapter│ │Adapter │ │  Adapter  │  │
│  └─────────┘ └───────┘ └───────┘ └────────┘ └───────────┘  │
│                                                              │
│  Also: Groq, OpenRouter, Mistral, GLM, LM Studio, Mock     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Components

### ProviderRouter (`nexora_ai/infrastructure/provider_router.py`)

Central routing engine implementing `ProviderInterface`:

- **Registration:** `register_provider(type, config, priority, capabilities, rate_limit)`
- **Routing Strategies:** PRIORITY, FALLBACK, LOAD_BALANCE, COST_AWARE, LATENCY, CAPABILITY
- **Health Monitoring:** Background task pinging providers every 30s
- **Cost Tracking:** Per-provider cost-per-token and total cost
- **Rate Limiting:** Token bucket rate limiter per provider
- **Failover:** Automatic retry with next provider on failure

### ProviderFactory (`nexora_ai/infrastructure/providers/factory.py`)

Creates provider adapters from `ProviderType` enum:

| Provider | Adapter | Base URL |
|----------|---------|----------|
| OPENAI | OpenAIProviderAdapter | api.openai.com/v1 |
| ANTHROPIC | AnthropicProviderAdapter | api.anthropic.com/v1 |
| GEMINI | GeminiProviderAdapter | generativelanguage.googleapis.com/v1beta/openai |
| DEEPSEEK | DeepSeekProviderAdapter | api.deepseek.com/v1 |
| GROQ | GroqProviderAdapter | api.groq.com/openai/v1 |
| OPENROUTER | OpenRouterProviderAdapter | openrouter.ai/api/v1 |
| MISTRAL | MistralProviderAdapter | api.mistral.ai/v1 |
| OLLAMA | OllamaProviderAdapter | localhost:11434 |
| LM_STUDIO | LMStudioProviderAdapter | localhost:1234/v1 |
| GLM | GLMProviderAdapter | open.bigmodel.cn/api/paas/v4 |
| MOCK | MockProviderAdapter | (test) |

### ProviderConfigService (`nexora_ai/infrastructure/provider_config_service.py`)

Fetches provider configuration from two sources:

1. **Nexora Brain API** — `GET /api/v1/providers/` (production)
2. **Environment Variables** — `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, etc. (development)

### Provider Adapters

All adapters implement `ProviderInterface`:
- `chat(messages, config)` → Streaming chat
- `complete(prompt, config)` → Single-shot completion
- `embed(texts, config)` → Embedding generation
- `generate_tool_call(messages, tools, config)` → Function calling
- `get_models()` → Available models
- `get_status()` → Health status
- `get_capabilities()` → Supported capabilities

---

## Supported Providers

| Provider | Chat | Stream | Embed | Tools | Vision | Reasoning | Code |
|----------|:----:|:------:|:-----:|:-----:|:------:|:---------:|:----:|
| OpenAI | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Anthropic | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ |
| Gemini | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| DeepSeek | ✅ | ✅ | ❌ | ✅ | ❌ | ✅ | ✅ |
| Groq | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| OpenRouter | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Mistral | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| Ollama | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| LM Studio | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| GLM | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |

---

## Environment Variables

| Variable | Provider | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | OpenAI | API key |
| `ANTHROPIC_API_KEY` | Anthropic | API key |
| `GEMINI_API_KEY` | Gemini | API key |
| `DEEPSEEK_API_KEY` | DeepSeek | API key |
| `OPENROUTER_API_KEY` | OpenRouter | API key |
| `GROQ_API_KEY` | Groq | API key |
| `MISTRAL_API_KEY` | Mistral | API key |
| `GLM_API_KEY` | GLM | API key |
| `OLLAMA_BASE_URL` | Ollama | Base URL (default: localhost:11434) |
| `LM_STUDIO_BASE_URL` | LM Studio | Base URL (default: localhost:1234) |

---

## Agent Integration

### personal_ai

- Creates `ProviderRouter` at startup
- Registers providers from env vars or Nexora Brain
- Uses `provider_router.chat()` for inference
- Exposes provider dashboard endpoints

### whatsapp_agent

- No direct AI provider usage (uses local NLP)
- Can access providers via shared ProviderRouter when needed

### calling_agent

- No direct AI provider usage (phone providers are separate)
- Can access providers via shared ProviderRouter when needed

---

## Test Results

| Project | Tests | Status |
|---------|-------|--------|
| nexora_ai | 118 | PASS |
| whatsapp_agent | 134 | PASS (1 pre-existing e2e fail) |
| calling_agent | 225 | PASS |
| personal_ai | 46 | PASS |
| **Total** | **523** | **522 PASS + 1 pre-existing** |
