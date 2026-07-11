# Heartbeat Protocol

**Phase:** E.3 — Agent Registration Protocol  
**Date:** 2026-07-01

---

## Overview

The heartbeat mechanism ensures the control plane maintains real-time awareness of agent health. Every registered agent sends periodic heartbeats; missed heartbeats trigger stale detection and status transitions.

---

## Timing

| Parameter | Value | Configurable |
|-----------|-------|--------------|
| Heartbeat interval | 30 seconds | Yes (`heartbeat_interval` param) |
| Warning threshold | 30 seconds missed | No |
| Offline threshold | 60 seconds missed | No |

### Why 30 seconds?

- Fast enough to detect failures within 1 minute
- Slow enough to avoid excessive HTTP traffic
- Balances responsiveness with resource usage

---

## Heartbeat Data

Each heartbeat carries:

```python
@dataclass
class AgentHeartbeat:
    agent_id: str
    status: AgentStatus          # starting | running | degraded | offline
    is_active: bool              # False = shutting down
    timestamp: datetime          # ISO 8601 UTC
    metrics: Optional[AgentMetrics]  # CPU, memory, connections, etc.
```

### Metrics in Heartbeat

```python
@dataclass
class AgentMetrics:
    cpu_usage_percent: float
    memory_usage_mb: float
    memory_usage_percent: Optional[float]
    disk_usage_mb: Optional[float]
    active_connections: int
    requests_per_minute: int
    avg_response_time_ms: Optional[float]
    error_rate_percent: Optional[float]
```

---

## State Machine

```
                    ┌─────────────┐
                    │  STARTING   │
                    └──────┬──────┘
                           │ registration OK
                           ▼
                    ┌─────────────┐
              ┌─────│  RUNNING    │─────┐
              │     └──────┬──────┘     │
              │            │            │
              │    health check fail    │ health check OK
              │            │            │
              │            ▼            │
              │     ┌─────────────┐    │
              └────▶│  DEGRADED   │────┘
                    └──────┬──────┘
                           │ heartbeat missed > 60s
                           ▼
                    ┌─────────────┐
                    │   OFFLINE   │
                    └─────────────┘
```

### Transitions

| From | To | Trigger |
|------|----|---------|
| STARTING | RUNNING | Registration succeeds |
| RUNNING | DEGRADED | Health check fails |
| DEGRADED | RUNNING | Health check recovers |
| Any | OFFLINE | Heartbeat missed > 60s |
| OFFLINE | STARTING | Agent re-registers |

---

## Stale Detection

### How It Works

1. Each heartbeat updates the agent's `last_heartbeat` timestamp
2. On each new heartbeat, the control plane checks all agents
3. If `now - last_heartbeat > 30s`: mark as `WARNING`
4. If `now - last_heartbeat > 60s`: mark as `OFFLINE`

### Detection Methods

**Synchronous (on heartbeat):**
```python
async def heartbeat(self, heartbeat: AgentHeartbeat) -> HeartbeatState:
    # ... update agent ...
    return self._check_staleness(agent)
```

**Asynchronous (periodic scan):**
```python
async def detect_stale_agents(self) -> List[str]:
    """Check all agents for staleness. Returns list of stale agent IDs."""
    stale = []
    for agent_id, agent in self._agents.items():
        state = self._check_staleness(agent)
        if state in (HeartbeatState.WARNING, HeartbeatState.OFFLINE):
            stale.append(agent_id)
    return stale
```

---

## Shutdown Behavior

When an agent shuts down gracefully:

1. Agent receives SIGTERM or `shutdown()` is called
2. Client sends final heartbeat: `is_active=False, status=offline`
3. Control plane marks agent as `OFFLINE`
4. Client stops the background heartbeat task
5. Agent exits

If agent crashes (no graceful shutdown):
- Control plane detects missed heartbeat after 60s
- Marks agent as `OFFLINE`
- Dashboard shows agent as stale

---

## Dashboard Integration

The control plane exposes stale agents via:

```
GET /agents/stale
```

Response:
```json
{
  "stale_agents": ["calling-agent-001"],
  "timestamp": "2026-07-01T12:05:00Z",
  "threshold_seconds": 60
}
```

Dashboard summary (`GET /agents/dashboard`) includes:
- `stale_count`: Number of agents that missed heartbeats
- `agents_by_status`: Breakdown including `warning` and `offline`

---

## Failure Scenarios

### Control Plane Down

- Agent heartbeat fails with connection error
- Agent continues serving requests normally
- Agent retries on next heartbeat interval
- No data loss (in-memory, not persisted)

### Agent Down

- Control plane stops receiving heartbeats
- After 60s: agent marked `OFFLINE`
- Dashboard shows agent as stale
- No impact on other agents

### Network Partition

- Heartbeats fail in both directions
- Both sides continue operating independently
- When connectivity restored, agent re-registers on next heartbeat

---

## Metrics Collection

Heartbeats provide real-time metrics for:

1. **Resource monitoring** — CPU, memory, disk usage per agent
2. **Performance tracking** — Response times, error rates, request throughput
3. **Capacity planning** — Active connections, requests per minute
4. **Alerting** — High error rates, low available memory

---

## Future Enhancements

- Persistent storage (SQLite/PostgreSQL) for agent registry
- Configurable stale thresholds per agent type
- Webhook notifications when agents go offline
- Historical metrics storage and trending
- Agent-to-agent heartbeat verification (mesh health)
