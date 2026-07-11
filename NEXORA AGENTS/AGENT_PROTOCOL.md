# Agent Protocol

**Phase:** E.3 — Agent Registration Protocol  
**Date:** 2026-07-01

---

## Overview

Every NEXORA agent follows a standard protocol for registration, discovery, health checking, and status reporting. This document defines the contract.

---

## Standard Endpoints

Every agent MUST expose these endpoints:

### GET /health

Returns liveness status. No authentication required.

```json
{
  "status": "healthy",
  "timestamp": "2026-07-01T12:00:00Z",
  "uptime_seconds": 3600,
  "checks": {
    "database": "healthy",
    "ai_providers": "healthy"
  }
}
```

### GET /capabilities

Returns what the agent can do.

```json
{
  "agent_id": "whatsapp-agent-001",
  "agent_type": "whatsapp",
  "name": "WhatsApp Agent",
  "version": "1.0.0",
  "capabilities": [
    "message_sending",
    "message_receiving",
    "webhook_management"
  ],
  "supported_channels": ["whatsapp"],
  "ai_providers": ["openai"],
  "max_concurrent_tasks": 10,
  "supports_streaming": true,
  "supports_batch": false
}
```

### GET /metrics

Returns resource metrics.

```json
{
  "cpu_usage_percent": 12.5,
  "memory_usage_mb": 256.0,
  "memory_usage_percent": 8.2,
  "disk_usage_mb": 1024.0,
  "active_connections": 5,
  "requests_per_minute": 120,
  "avg_response_time_ms": 45.2,
  "error_rate_percent": 0.1
}
```

### GET /version

Returns version and build information.

```json
{
  "version": "1.0.0",
  "build_hash": "abc123",
  "build_date": "2026-06-30",
  "python_version": "3.11.0",
  "framework": "custom"
}
```

### GET /status

Returns full status report combining health, metrics, and version.

```json
{
  "status": "healthy",
  "timestamp": "2026-07-01T12:00:00Z",
  "uptime_seconds": 3600,
  "version": "1.0.0",
  "metrics": { ... }
}
```

---

## Registration Protocol

### Startup Sequence

1. Agent starts and initializes its FastAPI app
2. Agent creates `AgentRegistrationClient` with its metadata
3. Client sends `POST /agents/register` to control plane
4. Control plane stores registration in memory
5. Client starts background heartbeat task (every 30s)
6. Agent begins serving requests

### Registration Payload

```json
{
  "agent_id": "whatsapp-agent-001",
  "agent_type": "whatsapp",
  "name": "WhatsApp Agent",
  "version": "1.0.0",
  "host": "localhost",
  "port": 5003,
  "protocol": "http",
  "health_endpoint": "/health",
  "metrics_endpoint": "/metrics",
  "capabilities_endpoint": "/capabilities",
  "version_endpoint": "/version",
  "status_endpoint": "/status",
  "description": "WhatsApp messaging agent",
  "tags": ["messaging", "whatsapp"],
  "metadata": {}
}
```

### Response

```json
{
  "status": "registered",
  "agent_id": "whatsapp-agent-001",
  "registered_at": "2026-07-01T12:00:00Z"
}
```

---

## Heartbeat Protocol

### Heartbeat Payload

```json
{
  "agent_id": "whatsapp-agent-001",
  "status": "running",
  "is_active": true,
  "timestamp": "2026-07-01T12:00:30Z",
  "metrics": {
    "cpu_usage_percent": 12.5,
    "memory_usage_mb": 256.0,
    "active_connections": 5,
    "requests_per_minute": 120,
    "error_rate_percent": 0.1
  }
}
```

### State Transitions

```
STARTING → RUNNING (after successful registration)
RUNNING → DEGRADED (if health checks fail)
DEGRADED → RUNNING (if health checks recover)
ANY → OFFLINE (if heartbeat misses > 60s)
```

### Shutdown Sequence

1. Agent receives SIGTERM
2. Client sends final heartbeat with `is_active=False`
3. Client stops heartbeat task
4. Control plane marks agent as `offline`
5. Agent exits cleanly

---

## Authentication

### Control Plane → Agents

- Standard endpoints (`/health`, `/metrics`, `/version`, `/capabilities`, `/status`) are **unauthenticated**
- Internal endpoints use `PERSONAL_AI_API_KEY` header

### Agents → Control Plane

- Registration and heartbeat calls go to control plane's `/agents/*` endpoints
- Control plane authenticates via API key if configured

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Control plane unreachable on startup | Agent logs warning and starts normally (standalone mode) |
| Heartbeat fails | Client retries on next interval; agent continues serving |
| Control plane restarts | Agent re-registers on next heartbeat (graceful reconnection) |
| Agent crashes | Control plane detects stale heartbeat after 60s → marks offline |

---

## Implementation Details

### AgentManager (Control Plane)

- **Storage:** In-memory dictionary keyed by agent_id
- **Thread safety:** `asyncio.Lock` for concurrent access
- **Stale detection:** Synchronous check on each heartbeat; async `detect_stale_agents()` method
- **Metrics:** Aggregate counts (total, by status, by type)

### AgentRegistrationClient (Agents)

- **HTTP client:** `httpx.AsyncClient` (optional dependency)
- **Background task:** `asyncio.create_task` for heartbeat loop
- **Graceful shutdown:** Final heartbeat sent in `shutdown()` method
- **Retry logic:** None — heartbeat retries naturally on next interval

---

## Adding a New Agent

1. Import from `nexora_ai`:

```python
from nexora_ai.infrastructure.agent_client.registration_client import (
    AgentRegistrationClient, AgentRegistrationPayload
)
```

2. Create payload:

```python
payload = AgentRegistrationPayload(
    agent_id="my-agent-001",
    agent_type="custom",
    name="My Agent",
    version="1.0.0",
    host="localhost",
    port=8000,
    capabilities=["custom_task"],
)
```

3. Create client and register:

```python
client = AgentRegistrationClient(payload, control_plane_url="http://localhost:8000")
await client.startup()
```

4. Add standard endpoints (copy from any existing agent's `main.py`).

5. Stop on shutdown:

```python
await client.shutdown()
```
