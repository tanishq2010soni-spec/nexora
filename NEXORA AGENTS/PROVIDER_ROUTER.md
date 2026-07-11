# Provider Router

**Phase:** E.5 — Provider Unification  
**Date:** 2026-07-01

---

## Overview

The `ProviderRouter` is the central routing engine for all AI provider access. It implements `ProviderInterface` itself, so any code using a single provider can seamlessly switch to the router.

---

## Routing Strategies

### PRIORITY (Default)

Routes to the highest-priority healthy provider. Round-robins within the same priority group.

```
Provider A (priority=10) ← primary
Provider B (priority=10) ← round-robin with A
Provider C (priority=5)  ← fallback only
```

### FALLBACK

Returns all providers sorted by priority. The caller iterates through them on failure.

```
Request → Provider A (priority=10)
              ↓ fails
         Provider B (priority=5)
              ↓ fails
         Provider C (priority=1)
```

### LOAD_BALANCE

Round-robins across all healthy providers equally.

```
Request 1 → Provider A
Request 2 → Provider B
Request 3 → Provider C
Request 4 → Provider A (cycle)
```

### COST_AWARE

Routes to the cheapest provider first.

```
Provider C ($0.001/1K tokens) ← first
Provider A ($0.01/1K tokens)
Provider B ($0.03/1K tokens)  ← last
```

### LATENCY

Routes to the fastest provider based on recent response times.

```
Provider B (avg 120ms) ← first
Provider A (avg 250ms)
Provider C (avg 800ms) ← last
```

### CAPABILITY

Scores providers by how many required capabilities they support.

```
Required: [CHAT, VISION, TOOL_CALL]
Provider A: [CHAT, VISION, TOOL_CALL, STREAMING] → score 3
Provider B: [CHAT, TOOL_CALL] → score 2
Provider C: [CHAT] → score 1
```

---

## Health Monitoring

### HealthMonitor

Background task that pings providers every 30 seconds:

- **Success:** Resets failure count, sets status to ACTIVE
- **Failure:** Increments failure count
- **Threshold:** After 3 consecutive failures, sets status to DOWN
- **Recovery:** After 60 seconds in DOWN, auto-recovers to DEGRADED
- **Maintenance:** Providers in MAINTENANCE are skipped

### Health States

| State | Description | Routes To |
|-------|-------------|-----------|
| ACTIVE | Healthy | ✅ Yes |
| DEGRADED | Recovering | ✅ Yes |
| DOWN | Failed | ❌ No |
| MAINTENANCE | Manual disable | ❌ No |
| INACTIVE | Not configured | ❌ No |
| ERROR | Unexpected state | ❌ No |

---

## Cost Tracking

### CostTracker

Tracks per-provider costs:

```python
cost_tracker.record_usage(
    provider_id="openai",
    tokens=1000,
    cost_per_token=0.00001,
)
# Total cost: $0.01
```

### Cost-Aware Routing

When using COST_AWARE strategy, providers are sorted by cost-per-token:

```python
router.set_routing_strategy(RoutingStrategy.COST_AWARE)
# Automatically routes to cheapest provider
```

---

## Rate Limiting

### RateLimiter

Token bucket rate limiter per provider:

```python
await router.register_provider(
    ProviderType.OPENAI,
    config={"api_key": "..."},
    rate_limit={
        "tokens_per_second": 10.0,  # 10 requests/sec
        "max_tokens": 100.0,        # burst capacity
    },
)
```

---

## Failover

### Non-FALLBACK Strategies

Tries only the top candidate. Records failure in HealthMonitor.

### FALLBACK Strategy

Iterates through all candidates:

```
Provider A → fails → record failure
Provider B → fails → record failure
Provider C → succeeds → record success
```

---

## API Usage

### Register a Provider

```python
from nexora_ai.infrastructure.provider_router import ProviderRouter
from nexora_ai.domain.enums.provider_enums import ProviderType

router = ProviderRouter()
await router.register_provider(
    ProviderType.OPENAI,
    config={"api_key": "sk-...", "model": "gpt-4o"},
    priority=10,
)
```

### Chat (Streaming)

```python
async for chunk in router.chat(
    messages=[{"role": "user", "content": "Hello"}],
    config={"stream": True},
):
    print(chunk.content, end="")
```

### Complete (Non-streaming)

```python
response = await router.complete("What is 2+2?")
print(response)  # "4"
```

### Embed

```python
embeddings = await router.embed(["Hello", "World"])
# [[0.1, 0.2, ...], [0.3, 0.4, ...]]
```

### Tool Call

```python
result = await router.generate_tool_call(
    messages=[{"role": "user", "content": "What's the weather?"}],
    tools=[{
        "type": "function",
        "function": {
            "name": "get_weather",
            "parameters": {"location": {"type": "string"}},
        },
    }],
)
```

### Health Check

```python
health = router.get_health()
# {
#   "providers": {"openai": {"status": "active", ...}},
#   "costs": {"openai": 0.05},
#   "latencies": {"openai": 0.25},
#   "routing_strategy": "priority",
# }
```

---

## Adding Custom Providers

```python
from nexora_ai.domain.enums.provider_enums import ProviderType
from nexora_ai.infrastructure.providers.factory import ProviderFactory
from nexora_ai.infrastructure.providers.base import BaseProviderAdapter

class MyCustomProvider(BaseProviderAdapter):
    async def chat(self, messages, config=None):
        # Implement chat
        ...

ProviderFactory.register(ProviderType.CUSTOM, MyCustomProvider)
```
