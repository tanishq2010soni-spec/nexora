# Provider Health

**Phase:** E.5 — Provider Unification  
**Date:** 2026-07-01

---

## Overview

Every provider is continuously monitored. Unhealthy providers are automatically disabled. Failed requests automatically fail over to the next available provider.

---

## Health Monitoring

### HealthMonitor

Runs as a background async task:

- **Check interval:** 30 seconds (configurable)
- **Failure threshold:** 3 consecutive failures → DOWN
- **Recovery delay:** 60 seconds in DOWN → auto-recover to DEGRADED
- **Health check method:** `provider.complete("ping")`

### Health States

```
         ┌─────────┐
    ┌───►│  ACTIVE  │◄─── success
    │    └────┬─────┘
    │         │ 3 failures
    │         ▼
    │    ┌─────────┐
    │    │   DOWN  │
    │    └────┬────┘
    │         │ 60s elapsed
    │         ▼
    │    ┌──────────┐
    └────│ DEGRADED │
         └──────────┘
```

| State | Description | Used for Routing |
|-------|-------------|:----------------:|
| ACTIVE | Healthy, responding normally | Yes |
| DEGRADED | Recovering from failure | Yes |
| DOWN | Failed 3+ times consecutively | No |
| MAINTENANCE | Manually disabled | No |
| INACTIVE | Not configured | No |

---

## Failure Detection

### Automatic Detection

```python
# Background task runs every 30s
for provider_id, record in self._records.items():
    try:
        provider = self._providers.get(provider_id)
        _ = await provider.complete("ping")
        self.record_success(provider_id)
    except Exception:
        self.record_failure(provider_id)
```

### Failure Threshold

After 3 consecutive failures:

```python
if record.consecutive_failures >= self._failure_threshold:
    record.status = ProviderStatus.DOWN
    record.maintenance_until = time.monotonic() + self._recovery_delay
```

### Auto-Recovery

After 60 seconds in DOWN state:

```python
if record.status == ProviderStatus.DOWN:
    if time.monotonic() >= record.maintenance_until:
        record.status = ProviderStatus.DEGRADED
        return True  # Available for routing
```

---

## Failover

### Non-FALLBACK Strategies

Tries only the top candidate. On failure:
1. Records failure in HealthMonitor
2. Raises exception to caller

### FALLBACK Strategy

Iterates through all candidates:

```
Provider A → fails → record failure → try next
Provider B → fails → record failure → try next
Provider C → succeeds → record success → return
All failed → raise RuntimeError
```

---

## Dashboard

### Health Status Endpoint

```
GET /api/v1/providers/health

{
  "providers": {
    "openai": {
      "status": "active",
      "consecutive_failures": 0,
      "last_success": 1719853200.0,
      "last_failure": 0.0
    },
    "anthropic": {
      "status": "down",
      "consecutive_failures": 3,
      "last_success": 1719850000.0,
      "last_failure": 1719853100.0
    }
  },
  "costs": {
    "openai": 0.05,
    "anthropic": 0.02
  },
  "latencies": {
    "openai": 0.25,
    "anthropic": 0.45
  },
  "routing_strategy": "fallback"
}
```

### Provider List Endpoint

```
GET /api/v1/providers

{
  "providers": [
    {
      "type": "openai",
      "status": "active",
      "available": true,
      "latency": 0.25,
      "cost": 0.05
    },
    {
      "type": "anthropic",
      "status": "down",
      "available": false,
      "latency": 0.45,
      "cost": 0.02
    }
  ],
  "routing_strategy": "priority",
  "total": 2
}
```

---

## Manual Health Check

### Force Health Check

```python
# Check specific provider
status = await router.get_provider([ModelCapability.CHAT]).get_status()
```

### Disable Provider

```python
router.remove_provider(ProviderType.OPENAI)
```

### Set Maintenance Mode

```python
# Not directly supported, but can be achieved by:
router._health_monitor._records["openai"].status = ProviderStatus.MAINTENANCE
```

---

## Monitoring Metrics

### Per-Provider Metrics

| Metric | Description |
|--------|-------------|
| `status` | Current health state |
| `consecutive_failures` | Number of consecutive failures |
| `last_success` | Timestamp of last successful request |
| `last_failure` | Timestamp of last failed request |
| `recovery_attempts` | Number of recovery attempts |
| `maintenance_until` | Auto-recovery timestamp |

### Aggregate Metrics

| Metric | Description |
|--------|-------------|
| `total_providers` | Number of registered providers |
| `active_providers` | Number of ACTIVE providers |
| `down_providers` | Number of DOWN providers |
| `average_latency` | Average latency across all providers |
| `total_cost` | Total cost across all providers |
