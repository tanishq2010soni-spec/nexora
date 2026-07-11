# System Topology

**Phase:** E.3 — Agent Registration Protocol  
**Date:** 2026-07-01

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        NEXORA PLATFORM                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    CONTROL PLANE                             │   │
│  │                  (personal_ai:8000)                          │   │
│  │                                                              │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │   │
│  │  │ AgentManager │  │ Dashboard API│  │  Auth Layer  │      │   │
│  │  │  (in-memory) │  │  (summary)   │  │  (API key)   │      │   │
│  │  └──────┬───────┘  └──────────────┘  └──────────────┘      │   │
│  │         │                                                    │   │
│  └─────────┼────────────────────────────────────────────────────┘   │
│            │                                                        │
│            │ Registration + Heartbeat                               │
│            │                                                        │
│  ┌─────────┼──────────────────────────────────────────────────┐    │
│  │         ▼                                                    │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │    │
│  │  │ personal_ai  │  │ whatsapp_    │  │ calling_     │      │    │
│  │  │ -001         │  │ agent-001    │  │ agent-001    │      │    │
│  │  │ :8000        │  │ :5003        │  │ :8000        │      │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘      │    │
│  │                                                              │    │
│  │                     AGENTS                                  │    │
│  └──────────────────────────────────────────────────────────────┘    │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    SHARED FRAMEWORK                          │   │
│  │                     (nexora_ai)                              │   │
│  │                                                              │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │   │
│  │  │ Domain Layer │  │Infrastructure│  │  Agent Client│      │   │
│  │  │  (entities,  │  │  (AgentMgr)  │  │  (heartbeat) │      │   │
│  │  │   enums)     │  │              │  │              │      │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘      │   │
│  │                                                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Component Roles

### Control Plane (personal_ai)

**Port:** 8000  
**Role:** Central hub for agent management

- Hosts `AgentManager` (in-memory registry)
- Exposes agent management API (`/agents/*`)
- Provides dashboard summary
- Detects stale agents
- Also runs its own desktop automation capabilities

### personal_ai Agent

**Agent ID:** `personal-ai-001`  
**Type:** `desktop`  
**Port:** 8000

- Registers itself with the control plane on startup
- Sends heartbeats every 30s
- Provides desktop automation (screenshots, file management, clipboard)
- Shares the control plane process (embedded)

### whatsapp_agent

**Agent ID:** `whatsapp-agent-001`  
**Type:** `whatsapp`  
**Port:** 5003

- Registers itself with the control plane on startup
- Sends heartbeats every 30s
- Handles WhatsApp messaging, webhook management
- Manages WhatsApp accounts and templates

### calling_agent

**Agent ID:** `calling-agent-001`  
**Type:** `voice`  
**Port:** 8000

- Registers itself with the control plane on startup
- Sends heartbeats every 30s
- Handles voice calls, call management, phone numbers
- Integrates with Twilio and other telephony providers

---

## Data Flow

### Registration Flow

```
Agent starts
    │
    ▼
POST /agents/register ──────────► Control Plane
    │                                    │
    │                              Store in memory
    │                                    │
    ◄────────────── Response ────────────┘
    │
    ▼
Start heartbeat loop (30s)
```

### Heartbeat Flow

```
Every 30 seconds:
    │
    ▼
POST /agents/heartbeat ──────────► Control Plane
    │                                    │
    │                              Update last_heartbeat
    │                              Check staleness
    │                                    │
    ◄────────────── Response ────────────┘
```

### Dashboard Query Flow

```
Dashboard polls:
    │
    ▼
GET /agents/dashboard ──────────► Control Plane
    │                                    │
    │                              Aggregate metrics
    │                              Count by status
    │                              Count by type
    │                                    │
    ◄────────────── Response ────────────┘
```

---

## Network Topology

### Ports

| Service | Port | Protocol |
|---------|------|----------|
| personal_ai (control plane) | 8000 | HTTP |
| whatsapp_agent | 5003 | HTTP |
| calling_agent | 8000 | HTTP |

### Connectivity

```
┌──────────────┐      ┌──────────────┐
│ personal_ai  │─────►│ whatsapp_    │
│ :8000        │      │ agent :5003  │
└──────┬───────┘      └──────────────┘
       │
       │
┌──────▼───────┐
│ calling_     │
│ agent :8000  │
└──────────────┘
```

All agents connect to the control plane at `http://localhost:8000`.

---

## Failure Modes

### Single Agent Failure

- Control plane detects stale heartbeat after 60s
- Other agents continue operating normally
- Dashboard shows failed agent as `offline`
- Agent can re-register by restarting

### Control Plane Failure

- All agents lose heartbeat target
- Agents continue serving requests (standalone mode)
- On control plane restart, agents re-register on next heartbeat
- No data loss (registry is in-memory, rebuilt from registrations)

### Network Partition

- Heartbeats fail in both directions
- Both sides continue independently
- On恢复, normal operation resumes

---

## Scaling Considerations

### Current State (In-Memory)

- Single control plane instance
- All agent state lost on restart
- Suitable for development and small deployments

### Future Enhancements

- Persistent storage (PostgreSQL/Redis) for agent registry
- Multiple control plane instances (leader election)
- Agent load balancing across control plane instances
- Geographic distribution with edge agents

---

## Security Boundaries

```
┌─────────────────────────────────────────┐
│              TRUST BOUNDARY              │
├─────────────────────────────────────────┤
│                                         │
│  Control Plane                          │
│  ├── API Key authentication             │
│  ├── Rate limiting (auth endpoints)     │
│  └── CORS: localhost only               │
│                                         │
│  Agents                                 │
│  ├── Unauthenticated standard endpoints │
│  ├── Authenticated internal endpoints   │
│  └── JWT secrets via env vars           │
│                                         │
└─────────────────────────────────────────┘
```

---

## Agent Lifecycle States

| State | Description | Dashboard Icon |
|-------|-------------|----------------|
| STARTING | Agent is initializing | 🟡 Yellow |
| RUNNING | Agent is healthy and serving | 🟢 Green |
| DEGRADED | Agent is running but unhealthy | 🟠 Orange |
| OFFLINE | Agent is not responding | 🔴 Red |

---

## Summary

The NEXORA platform is a hub-and-spoke architecture:

- **Hub:** Control plane (personal_ai) manages all agents
- **Spokes:** Individual agents register, heartbeat, and report status
- **Framework:** nexora_ai provides shared domain models and infrastructure
- **Discovery:** Agents are self-registering; no manual configuration needed
- **Health:** Real-time monitoring via heartbeat protocol
- **Resilience:** Agents operate independently; control plane failure is non-fatal
