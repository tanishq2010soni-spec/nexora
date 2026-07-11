# Cost Routing

**Phase:** E.5 — Provider Unification  
**Date:** 2026-07-01

---

## Overview

The CostTracker monitors per-provider costs and enables cost-aware routing. When using COST_AWARE strategy, requests automatically route to the cheapest available provider.

---

## Cost Tracking

### CostTracker

Tracks three metrics per provider:

| Metric | Description |
|--------|-------------|
| `cost_per_token` | Cost per token (updated on each request) |
| `total_tokens` | Total tokens used |
| `total_cost` | Total cost (tokens × cost_per_token) |

### Recording Usage

```python
router._cost_tracker.record_usage(
    provider_id="openai",
    tokens=1500,
    cost_per_token=0.000015,  # $0.015 per 1K tokens
)
# Total cost: $0.0225
```

### Querying Costs

```python
# Per-provider cost
cost = router._cost_tracker.get_total_cost("openai")  # 0.0225

# All costs
all_costs = router._cost_tracker.get_all_costs()
# {"openai": 0.0225, "anthropic": 0.015, "gemini": 0.001}

# Cost estimation
estimated = router._cost_tracker.estimate_cost("openai", 5000)
# 5000 * 0.000015 = 0.075
```

---

## Cost-Aware Routing

### Strategy

When using `RoutingStrategy.COST_AWARE`:

```python
router.set_routing_strategy(RoutingStrategy.COST_AWARE)
```

Providers are sorted by cost-per-token (cheapest first):

```
Provider A: $0.0001/1K tokens ← routed first
Provider B: $0.005/1K tokens
Provider C: $0.015/1K tokens  ← routed last
```

### Example

```python
router = ProviderRouter()
router.set_routing_strategy(RoutingStrategy.COST_AWARE)

await router.register_provider(ProviderType.OPENAI, {"api_key": "..."})
await router.register_provider(ProviderType.GEMINI, {"api_key": "..."})
await router.register_provider(ProviderType.GROQ, {"api_key": "..."})

# First request: routes to cheapest (Groq at $0.00059/1K)
response = await router.complete("Hello")

# After recording usage, costs update
router._cost_tracker.record_usage("groq", 1000, 0.00000059)
router._cost_tracker.record_usage("gemini", 1000, 0.0000001)
router._cost_tracker.record_usage("openai", 1000, 0.000015)

# Next request: routes to Gemini (cheapest at $0.0001/1K)
response = await router.complete("Hello")
```

---

## Pricing Configuration

### Per-Provider Pricing

Set during provider registration:

```python
await router.register_provider(
    ProviderType.OPENAI,
    config={"api_key": "..."},
    # Pricing tracked automatically via CostTracker
)
```

### From Nexora Brain

```json
{
  "provider_type": "openai",
  "pricing_input_per_1k": 0.005,
  "pricing_output_per_1k": 0.015
}
```

---

## Cost Dashboard

### API Endpoint

```
GET /api/v1/providers/costs

{
  "costs": {
    "openai": 0.05,
    "anthropic": 0.02,
    "gemini": 0.001,
    "groq": 0.0005
  },
  "latencies": {
    "openai": 0.25,
    "anthropic": 0.45,
    "gemini": 0.30,
    "groq": 0.15
  }
}
```

### Cost Optimization Tips

1. **Use COST_AWARE routing** for non-latency-sensitive requests
2. **Use PRIORITY routing** for latency-sensitive requests
3. **Use FALLBACK routing** for maximum availability
4. **Set up GROQ/DeepSeek** for cost-effective bulk processing
5. **Use Ollama** for zero-cost local inference
6. **Monitor costs** via the dashboard endpoint

---

## Cost Comparison

| Provider | Input (per 1K) | Output (per 1K) | Relative Cost |
|----------|---------------|-----------------|---------------|
| Ollama (local) | $0.00 | $0.00 | 0x |
| Gemini Flash | $0.0001 | $0.0004 | 0.02x |
| DeepSeek | $0.00014 | $0.00028 | 0.03x |
| Groq | $0.00059 | $0.00079 | 0.12x |
| Mistral Small | $0.001 | $0.003 | 0.2x |
| OpenAI Mini | $0.00015 | $0.0006 | 0.03x |
| OpenAI GPT-4o | $0.005 | $0.015 | 1x (baseline) |
| Anthropic Sonnet | $0.003 | $0.015 | 0.8x |
| Anthropic Opus | $0.015 | $0.075 | 4x |
