# Provider Migration

**Phase:** E.5 — Provider Unification  
**Date:** 2026-07-01

---

## Overview

This guide explains how to migrate from per-agent provider configuration to the unified provider system. The migration is non-breaking — both approaches work simultaneously.

---

## Migration Modes

| Mode | Description | When to Use |
|------|-------------|-------------|
| `env` | Providers registered from environment variables | Development |
| `nexora` | Providers fetched from Nexora Brain API | Production |
| `hybrid` | Env vars + Nexora Brain overrides | Transition |

---

## Migration Steps

### Step 1: Set Environment Variables

On each agent, set the provider API keys:

```bash
# All agents share the same keys
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
export GEMINI_API_KEY="AIza..."
# ... etc
```

### Step 2: Verify ProviderRouter

The `ProviderRouter` is already created in each agent's startup. Verify it works:

```python
from nexora_ai.infrastructure.provider_router import ProviderRouter

router = ProviderRouter()
# Providers auto-register from env vars
available = router.get_available_providers()
print(f"Available: {[p.value for p in available]}")
```

### Step 3: Test Provider Access

```python
# Test chat
response = await router.complete("Hello, world!")
print(response)

# Test streaming
async for chunk in router.chat([{"role": "user", "content": "Hi"}]):
    print(chunk.content, end="")
```

### Step 4: Configure Nexora Brain (Production)

1. Create providers in Nexora Brain database
2. Set `NEXORA_CONTROL_PLANE_URL` on agents
3. Agents fetch provider config from Nexora Brain

```bash
export NEXORA_CONTROL_PLANE_URL="http://your-nexora-brain:8000"
```

### Step 5: Switch to Nexora Brain Config

```python
from nexora_ai.infrastructure.provider_config_service import ProviderConfigService

service = ProviderConfigService(
    provider_router=router,
    control_plane_url="http://your-nexora-brain:8000",
    org_id="your-org-id",
)

# Fetch providers from Nexora Brain
count = await service.sync_providers()
print(f"Synced {count} providers")
```

---

## What Changes

### Before (Legacy)

```
Agent A: own OpenAI config, own API key
Agent B: own OpenAI config, own API key
Agent C: own Ollama config
```

### After (Unified)

```
All Agents → ProviderRouter → OpenAI (shared config)
                            → Anthropic (shared config)
                            → Ollama (shared config)
```

---

## Environment Variables

### Required for Unified Providers

| Variable | Description | Example |
|----------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key | `sk-...` |
| `ANTHROPIC_API_KEY` | Anthropic API key | `sk-ant-...` |
| `GEMINI_API_KEY` | Google Gemini API key | `AIza...` |
| `OLLAMA_BASE_URL` | Ollama server URL | `http://localhost:11434` |

### Optional

| Variable | Description | Default |
|----------|-------------|---------|
| `NEXORA_CONTROL_PLANE_URL` | Nexora Brain URL | `http://localhost:8000` |
| `NEXORA_ORG_ID` | Organization ID | (none) |

---

## Agent-Specific Changes

### personal_ai

**Before:** Empty ProviderRouter, no providers registered  
**After:** Providers registered from env vars or Nexora Brain

### whatsapp_agent

**Before:** No AI provider usage  
**After:** Can access providers via shared ProviderRouter

### calling_agent

**Before:** No AI provider usage (phone providers separate)  
**After:** Can access providers via shared ProviderRouter

---

## Rollback Plan

If unified providers cause issues:

1. Remove `NEXORA_CONTROL_PLANE_URL` env var
2. Agents fall back to env-var-only mode
3. Or re-add per-agent provider config

Rollback is instant — no data migration required.

---

## Testing Checklist

- [ ] ProviderRouter creates successfully
- [ ] Providers register from env vars
- [ ] Chat streaming works
- [ ] Completion works
- [ ] Embedding works (where supported)
- [ ] Tool calling works (where supported)
- [ ] Health monitoring runs
- [ ] Failover works on provider failure
- [ ] Cost tracking records usage
- [ ] Nexora Brain sync works (production)
- [ ] All existing tests pass

---

## Troubleshooting

### "No available providers"

**Cause:** No providers registered or all providers DOWN  
**Fix:** Check env vars, verify API keys, check provider health

### "Authentication failed"

**Cause:** Invalid API key  
**Fix:** Verify API key in env var or Nexora Brain

### "Rate limit exceeded"

**Cause:** Too many requests to provider  
**Fix:** Increase rate_limit config or add more providers

### "Timeout connecting"

**Cause:** Provider endpoint unreachable  
**Fix:** Check base_url, verify network connectivity

---

## Migration Timeline

| Phase | Duration | Description |
|-------|----------|-------------|
| 1. Set env vars | Day 0 | Configure API keys |
| 2. Test locally | Day 1 | Verify providers work |
| 3. Deploy to staging | Day 2 | Test in staging env |
| 4. Deploy to production | Day 3 | Monitor for issues |
| 5. Configure Nexora Brain | Day 4-5 | Set up centralized config |
| 6. Remove env vars | Day 6+ | Clean up (optional) |
