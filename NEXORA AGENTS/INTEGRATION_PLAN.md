# NEXORA ECOSYSTEM - Integration Plan

**Date**: July 1, 2026  
**Phase**: E - Platform Integration  
**Status**: PLANNING (Do Not Implement Until Approved)

---

## 1. CURRENT ARCHITECTURE

### 1.1 The Four Projects

```
NEXORA (Business OS)
├── src/                          # Python FastAPI backend (nexora-brain)
│   ├── domain/models/            # 3 domain models (BusinessProfile, Customer, Lead)
│   ├── application/              # 6 services (RAG, Workflow, Document, Auth, Copilot, Audit)
│   ├── infrastructure/           # 33 ORM models, 12+ integrations
│   └── presentation/api/         # 34 routers, 200+ endpoints
│
├── control_center/               # Flutter dashboard (Riverpod)
│   └── lib/features/             # 26 feature modules
│
NEXORA AGENTS/
├── nexora_ai/                    # Shared AI framework (Python SDK)
│   ├── domain/                   # 14 interfaces, 12 entity files, 10 enum files
│   ├── application/              # DI container, 5 services, 6 use cases
│   └── infrastructure/           # 12 providers, memory, events, plugins, tools, security
│
├── personal_ai/                  # Personal assistant (Flutter + Python)
│   ├── lib/                      # Flutter desktop app
│   └── backend/                  # FastAPI server, 40+ tools, no DB
│
├── whatsapp_agent/               # WhatsApp AI agent (Flutter + Python)
│   ├── lib/                      # Flutter desktop app
│   └── backend/                  # FastAPI server, 15 DB tables, 90+ endpoints
│
└── calling_agent/                # Voice calling AI agent (Flutter + Python)
    ├── lib/                      # Flutter desktop app
    └── backend/                  # FastAPI server, 14 DB tables, 100+ endpoints
```

### 1.2 What Each Project Provides

| Capability | Nexora Brain | nexora_ai | personal_ai | whatsapp_agent | calling_agent |
|------------|-------------|-----------|-------------|----------------|---------------|
| Auth | JWT + RBAC (33 tables) | PermissionManager | None | JWT + RBAC | JWT + RBAC |
| Database | PostgreSQL (33 tables) | SQLite/JSON/Vector | None | SQLite (15 tables) | SQLite (14 tables) |
| AI/LLM | Ollama (local) | ProviderRouter (12 providers) | ProviderRouter | Direct API calls | Direct API calls |
| Memory | MemoryEntry table | MemoryManager (3 backends) | In-memory | None | None |
| Plugins | Plugin model + API | PluginLoader (manifest-based) | Interface-based hooks | DB-backed registry | DB-backed registry |
| Events | None (WebSocket only) | AsyncEventBus | AsyncEventBus | None | CallEvent model |
| Logging | structlog + AuditLog | JsonLogger | JsonLogger | AuditLog | Python logging + AuditLog |
| Workflows | Graph-based engine | AutomationEngine | None | Trigger-based | None |
| Knowledge | KnowledgeBase + Qdrant | None | None | KnowledgeDocument | KnowledgeDocument |
| Tools | None | ToolRegistry (10 tools) | 40+ desktop tools | None | None |
| Billing | Stripe + Razorpay | None | None | None | None |
| Realtime | WebSocket (ConnectionManager) | None | WebSocket | None | None |

---

## 2. PROBLEMS

### 2.1 Duplication

| Duplicated Code | Projects | Lines | Impact |
|----------------|----------|-------|--------|
| JWT auth implementation | whatsapp_agent, calling_agent | ~200 each | Maintainability |
| Organization model/table | whatsapp_agent, calling_agent | ~100 each | Schema drift |
| User model/table | whatsapp_agent, calling_agent | ~80 each | Schema drift |
| Permission system | whatsapp_agent, calling_agent | ~150 each | Inconsistent permissions |
| Knowledge document model | whatsapp_agent, calling_agent | ~60 each | Schema drift |
| Plugin model/registry | whatsapp_agent, calling_agent | ~100 each | Divergent implementations |
| AuditLog model | whatsapp_agent, calling_agent | ~40 each | Schema drift |
| Analytics endpoints | whatsapp_agent, calling_agent | ~200 each | Different metrics |
| Settings management | whatsapp_agent, calling_agent | ~100 each | Different configs |
| Campaign engine patterns | whatsapp_agent, calling_agent | ~300 each | Parallel but different |

### 2.2 Isolation

| Problem | Description | Severity |
|---------|-------------|----------|
| No shared auth | Each agent has its own JWT system. Users must create separate accounts per agent. | CRITICAL |
| No shared org | Organization exists in Nexora, whatsapp_agent, calling_agent independently. No sync. | CRITICAL |
| No shared providers | LLM/model config duplicated across all projects. No central provider registry. | HIGH |
| No shared memory | Personal AI uses nexora_ai memory. WhatsApp/calling agents have no memory. Nexora has its own. | HIGH |
| No shared plugins | 3 different plugin systems that can't interoperate. | HIGH |
| No shared events | No cross-project event bus. Agents can't notify Nexora or each other. | HIGH |
| No shared analytics | Each project tracks metrics independently. No unified dashboard. | MEDIUM |
| No shared logging | 3 different logging approaches. No centralized log aggregation. | MEDIUM |
| No shared billing | Only Nexora has billing. Agents have no concept of subscriptions/limits. | MEDIUM |
| No shared licensing | License model exists in Nexora DB but agents don't validate licenses. | MEDIUM |

### 2.3 Architectural Gaps

| Gap | Description | Impact |
|-----|-------------|--------|
| Agent registration | No mechanism for agents to register themselves with Nexora | Can't manage agents centrally |
| Agent heartbeat | Agent health tables exist in Nexora but no heartbeat protocol | Can't monitor agent status |
| Agent configuration | Agent config is per-project, not centrally managed | Can't push config changes |
| Agent versioning | AgentVersion table exists but no update mechanism | Can't manage agent lifecycle |
| Cross-agent communication | No message bus between agents | Can't coordinate workflows |
| Shared file storage | Each agent stores files locally | No centralized document management |
| Shared secrets | Each project has its own .env | Secrets scattered across deployments |

---

## 3. MISSING INTEGRATION POINTS

### 3.1 Agent Registration & Discovery

**Current state**: Agents are standalone. No way for Nexora to know they exist.

**Required**: 
- Agent self-registration on startup
- Nexora maintains agent registry (table exists: `agents`)
- Agent reports capabilities, version, health
- Nexora can push configuration to agents

**Integration points**:
- `nexora_ai` → `AIRuntime` should register with parent platform
- Each agent's `main.py` should call registration endpoint on startup
- Nexora's `/api/v1/agents` router becomes the central registry

### 3.2 Authentication Unification

**Current state**: 3 separate JWT systems. Users have different accounts per agent.

**Required**:
- Single sign-on across all projects
- Nexora is the identity provider
- Agents validate Nexora-issued tokens
- Shared user/role/permission model

**Integration points**:
- Nexora issues JWT with `org_id`, `user_id`, `roles`, `permissions`
- Agents validate JWT using Nexora's public key or shared secret
- `nexora_ai` provides `AuthProviderInterface` that agents implement
- Personal AI gets optional auth when connected to Nexora

### 3.3 Organization Synchronization

**Current state**: Organization exists in Nexora (33-table schema), whatsapp_agent (15 tables), calling_agent (14 tables) independently.

**Required**:
- Nexora is the source of truth for organizations
- Agents sync org data on startup and periodically
- Org settings (limits, branding, working hours) flow from Nexora to agents

**Integration points**:
- Nexora exposes organization API
- Agents pull org config via `nexora_ai` `OrganizationSyncService`
- Org-scoped queries in agents use synced org_id

### 3.4 Shared Provider/Model Configuration

**Current state**: 
- Nexora: Ollama (local), Qdrant, Sentence Transformers
- nexora_ai: 12 provider adapters (OpenAI, Anthropic, Gemini, etc.)
- personal_ai: Uses nexora_ai ProviderRouter
- whatsapp_agent: Direct API calls to OpenAI/etc.
- calling_agent: Direct API calls to OpenAI/etc.

**Required**:
- Nexora manages provider credentials centrally
- Agents query available models from Nexora
- Provider routing decisions made by nexora_ai ProviderRouter
- Cost tracking centralized in Nexora

**Integration points**:
- Nexora `/api/v1/providers` is the provider registry
- Nexora `/api/v1/models` is the model registry
- `nexora_ai` `ProviderRouter` reads provider config from Nexora
- Agents use `nexora_ai` for all LLM calls (not direct API calls)

### 3.5 Shared Memory

**Current state**:
- Nexora: `memory_entries` table
- nexora_ai: `MemoryManager` with 3 backends (SQLite, JSON, Vector stub)
- personal_ai: Uses nexora_ai MemoryManager (in-memory)
- whatsapp_agent: No memory
- calling_agent: No memory

**Required**:
- Unified memory across all agents
- Memory scoped by org_id and optionally user_id/conversation_id
- Cross-agent memory search (e.g., "what did I tell the WhatsApp bot?")

**Integration points**:
- `nexora_ai` `MemoryManager` backed by Nexora's PostgreSQL `memory_entries` table
- Agents store conversation memories via `nexora_ai` MemoryInterface
- Nexora provides memory search API across all agent conversations

### 3.6 Shared Plugin System

**Current state**: 3 different plugin systems:
1. Nexora: Plugin model + `/api/v1/plugins` (DB-backed, no actual loader)
2. nexora_ai: `PluginLoader` (manifest-based, filesystem discovery)
3. whatsapp_agent/calling_agent: DB-backed registry (empty plugins/ dirs)
4. personal_ai: Interface-based hooks via nexora_ai

**Required**:
- Single plugin manifest format
- Nexora manages plugin registry and distribution
- `nexora_ai` PluginLoader is the runtime engine
- Agents load plugins via nexora_ai

**Integration points**:
- Nexora `/api/v1/plugins` manages plugin metadata
- `nexora_ai` `PluginLoader` discovers and loads plugins
- Plugin manifests define which agents a plugin supports
- Plugins can register tools, hooks, and UI extensions

### 3.7 Shared Events

**Current state**:
- Nexora: WebSocket ConnectionManager (real-time only, no persistence)
- nexora_ai: AsyncEventBus (in-memory, per-process)
- whatsapp_agent: No event bus
- calling_agent: CallEvent model (per-call only)
- personal_ai: AsyncEventBus via nexora_ai

**Required**:
- Cross-project event bus (Redis-backed for durability)
- Events: agent_registered, agent_health, conversation_created, lead_created, etc.
- Nexora dashboard shows real-time events from all agents

**Integration points**:
- `nexora_ai` `AsyncEventBus` backed by Redis pub/sub
- Agents publish events on key actions
- Nexora subscribes to agent events for dashboard
- Events enable cross-agent workflows

### 3.8 Shared Analytics

**Current state**: Each project has its own analytics endpoints with different metrics.

**Required**:
- Unified analytics pipeline
- Agents report metrics to Nexora
- Nexora aggregates across all agents
- Control center shows unified dashboard

**Integration points**:
- `nexora_ai` `AnalyticsService` reports to Nexora
- Nexora `/api/v1/analytics` aggregates all agent metrics
- Control center analytics module consumes unified data

### 3.9 Shared Logging & Audit

**Current state**: 3 different logging approaches.

**Required**:
- Centralized log aggregation
- Unified audit trail across all projects
- Structured logging via nexora_ai JsonLogger

**Integration points**:
- `nexora_ai` `JsonLogger` sends logs to Nexora
- Nexora `/api/v1/audit-logs` is the central audit store
- Agents log via nexora_ai LoggingInterface

### 3.10 Shared Billing & Licensing

**Current state**: Only Nexora has billing (Stripe + Razorpay). Agents have no billing concept.

**Required**:
- Agent usage tracked against org subscription
- License validation on agent startup
- Usage-based billing for AI calls

**Integration points**:
- Nexora `/api/v1/billing` manages subscriptions
- Nexora `/api/v1/license` validates agent licenses
- `nexora_ai` checks license on startup
- Agents report usage to Nexora for billing

### 3.11 Shared Dashboard (Control Center)

**Current state**: Control center has 26 feature modules but none for agent management.

**Required**:
- Agent management dashboard
- Real-time agent health monitoring
- Cross-agent analytics
- Unified inbox across WhatsApp + Calling
- Centralized settings management

**Integration points**:
- New Flutter modules: `agent_center`, `agent_management`
- Nexora API provides agent data
- WebSocket for real-time agent status

---

## 4. DEPENDENCIES

### 4.1 Internal Dependencies

```
Nexora Brain
    ├── depends on → nexora_ai (for provider routing, memory, plugins)
    ├── depends on → PostgreSQL, Redis, Qdrant, Ollama
    └── exposes → REST API for agents

nexora_ai (Shared SDK)
    ├── depends on → httpx, aiosqlite, pyyaml, cryptography
    ├── provides → ProviderRouter, MemoryManager, PluginLoader, EventBus, etc.
    └── used by → all 3 agents

personal_ai
    ├── depends on → nexora_ai (deeply integrated)
    ├── depends on → Playwright, pywin32, pytesseract
    └── optional → Nexora Brain (for auth, org sync)

whatsapp_agent
    ├── depends on → aiosqlite, SQLAlchemy, python-jose, passlib
    ├── optional → nexora_ai (for provider routing)
    ├── optional → Nexora Brain (for auth, org sync, shared memory)
    └── external → WhatsApp Cloud API

calling_agent
    ├── depends on → aiosqlite, SQLAlchemy, python-jose, passlib
    ├── optional → nexora_ai (for provider routing)
    ├── optional → Nexora Brain (for auth, org sync, shared memory)
    └── external → Twilio/Exotel/Plivo
```

### 4.2 External Dependencies (must remain compatible)

- Python 3.12+
- Flutter 3.x
- FastAPI
- SQLAlchemy 2.0 (async)
- Pydantic v2
- PostgreSQL 15+
- Redis 7+
- Qdrant (vector search)
- Ollama (local LLM)

---

## 5. REQUIRED APIs

### 5.1 Nexora Brain → Agents

| API | Method | Purpose |
|-----|--------|---------|
| `POST /api/v1/agents/register` | POST | Agent self-registration |
| `POST /api/v1/agents/{id}/heartbeat` | POST | Agent health reporting |
| `GET /api/v1/agents/{id}/config` | GET | Pull agent configuration |
| `POST /api/v1/agents/{id}/events` | POST | Agent event ingestion |
| `POST /api/v1/agents/{id}/metrics` | POST | Agent metric reporting |

### 5.2 Agents → Nexora Brain

| API | Method | Purpose |
|-----|--------|---------|
| `GET /api/v1/auth/validate` | GET | Validate JWT token |
| `GET /api/v1/organizations/{id}` | GET | Get organization config |
| `GET /api/v1/providers` | GET | Get available providers |
| `GET /api/v1/models` | GET | Get available models |
| `POST /api/v1/memory` | POST | Store memory entry |
| `GET /api/v1/memory/search` | GET | Search memory |
| `POST /api/v1/audit-logs` | POST | Write audit entry |
| `GET /api/v1/license/validate` | GET | Validate license |
| `POST /api/v1/analytics/events` | POST | Report analytics event |

### 5.3 Nexora AI SDK → Platform

| Interface | Method | Purpose |
|-----------|--------|---------|
| `AuthProviderInterface` | `validate_token(token)` | Token validation |
| `OrganizationProviderInterface` | `get_org(org_id)` | Org config retrieval |
| `ProviderConfigInterface` | `get_providers(org_id)` | Provider credentials |
| `MemoryBackendInterface` | `store/search/delete` | Centralized memory |
| `EventBusInterface` | `publish/subscribe` | Cross-project events |
| `AnalyticsInterface` | `report_metric()` | Metric reporting |
| `LicenseInterface` | `validate()` | License checking |

---

## 6. REQUIRED SHARED SERVICES

### 6.1 `nexora_ai` Platform Adapters (NEW)

These adapters bridge `nexora_ai` interfaces to Nexora Brain APIs:

| Adapter | Implements | Backs Into | Priority |
|---------|-----------|------------|----------|
| `NexoraAuthProvider` | `SecurityInterface` | Nexora `/auth/validate` | P0 |
| `NexoraOrgProvider` | New interface | Nexora `/organizations/{id}` | P0 |
| `NexoraProviderConfig` | New interface | Nexora `/providers`, `/models` | P1 |
| `NexoraMemoryBackend` | `MemoryInterface` | Nexora PostgreSQL `memory_entries` | P1 |
| `NexoraEventBus` | `EventBusInterface` | Redis pub/sub | P1 |
| `NexoraAnalyticsReporter` | New interface | Nexora `/analytics/events` | P2 |
| `NexoraLicenseChecker` | New interface | Nexora `/license/validate` | P2 |
| `NexoraLogger` | `LoggingInterface` | Nexora PostgreSQL `audit_logs` | P2 |

### 6.2 Agent Registration Protocol

```
Agent Startup:
1. Load local config
2. Call POST /api/v1/agents/register with:
   - agent_type (personal_ai | whatsapp_agent | calling_agent)
   - version
   - capabilities
   - endpoint_url (for callbacks)
   - health_check_interval
3. Receive agent_id + config overrides
4. Start heartbeat loop (POST /api/v1/agents/{id}/heartbeat)
5. Pull provider config from Nexora
6. Initialize nexora_ai with platform adapters
```

### 6.3 Unified Auth Flow

```
User Login (via any agent or control center):
1. POST /api/v1/auth/login with email + password
2. Nexora validates credentials, creates JWT with:
   - sub: user_id
   - org: org_id
   - roles: [admin, agent, viewer]
   - permissions: [view_dashboard, manage_leads, ...]
   - exp: 60min
3. JWT returned to client
4. Client sends JWT to any agent
5. Agent validates JWT via Nexora /auth/validate (or local verification with shared secret)
6. Agent extracts org_id, user_id, permissions from JWT
```

---

## 7. MIGRATION PLAN

### Phase E.1: Foundation (Week 1-2)

**Goal**: Establish shared protocols without breaking existing functionality.

| Task | Effort | Risk | Dependencies |
|------|--------|------|-------------|
| Design agent registration API | 2 days | Low | None |
| Implement registration endpoint in Nexora | 2 days | Low | None |
| Add `nexora_ai` `PlatformConfig` class | 1 day | Low | None |
| Add `nexora_ai` `AuthProviderInterface` | 1 day | Low | None |
| Add `nexora_ai` `OrganizationProviderInterface` | 1 day | Low | None |
| Unit tests for new interfaces | 2 days | Low | Above |

### Phase E.2: Auth Unification (Week 3-4)

**Goal**: Single sign-on across all projects.

| Task | Effort | Risk | Dependencies |
|------|--------|------|-------------|
| Nexora JWT includes org_id + permissions | 1 day | Medium | E.1 |
| Create `NexoraAuthProvider` adapter | 2 days | Medium | E.1 |
| whatsapp_agent: Replace auth with Nexora provider | 3 days | HIGH | E.2 |
| calling_agent: Replace auth with Nexora provider | 3 days | HIGH | E.2 |
| personal_ai: Add optional auth middleware | 2 days | Medium | E.2 |
| Integration tests for SSO | 2 days | Medium | E.2 |

### Phase E.3: Organization Sync (Week 5-6)

**Goal**: Nexora is source of truth for orgs.

| Task | Effort | Risk | Dependencies |
|------|--------|------|-------------|
| Create `NexoraOrgProvider` adapter | 2 days | Medium | E.1 |
| whatsapp_agent: Sync org on startup | 2 days | Medium | E.3 |
| calling_agent: Sync org on startup | 2 days | Medium | E.3 |
| Migrate agent org tables to read from Nexora | 3 days | HIGH | E.3 |
| Org settings cascade to agents | 2 days | Medium | E.3 |

### Phase E.4: Provider Unification (Week 7-8)

**Goal**: Centralized LLM provider management.

| Task | Effort | Risk | Dependencies |
|------|--------|------|-------------|
| Nexora provider CRUD API (exists) | 0 days | Low | None |
| Nexora model registry API (exists) | 0 days | Low | None |
| Create `NexoraProviderConfig` adapter | 2 days | Medium | E.1 |
| whatsapp_agent: Replace direct API calls with nexora_ai ProviderRouter | 3 days | HIGH | E.4 |
| calling_agent: Replace direct API calls with nexora_ai ProviderRouter | 3 days | HIGH | E.4 |
| Cost tracking in Nexora | 2 days | Medium | E.4 |

### Phase E.5: Shared Memory (Week 9-10)

**Goal**: Cross-agent memory.

| Task | Effort | Risk | Dependencies |
|------|--------|------|-------------|
| Create `NexoraMemoryBackend` adapter | 3 days | Medium | E.1 |
| whatsapp_agent: Add memory to conversations | 2 days | Medium | E.5 |
| calling_agent: Add memory to calls | 2 days | Medium | E.5 |
| Memory search API across agents | 2 days | Medium | E.5 |
| Memory UI in control center | 3 days | Low | E.5 |

### Phase E.6: Event Bus (Week 11-12)

**Goal**: Cross-project event system.

| Task | Effort | Risk | Dependencies |
|------|--------|------|-------------|
| Redis-backed EventBus in nexora_ai | 3 days | Medium | E.1 |
| Agent event publishers | 2 days | Low | E.6 |
| Nexora event subscribers | 2 days | Low | E.6 |
| Real-time agent status in dashboard | 3 days | Low | E.6 |

### Phase E.7: Plugin System (Week 13-14)

**Goal**: Unified plugin architecture.

| Task | Effort | Risk | Dependencies |
|------|--------|------|-------------|
| Standardize plugin manifest format | 2 days | Low | None |
| Nexora plugin registry API | 2 days | Low | None |
| nexora_ai PluginLoader reads from Nexora | 2 days | Medium | E.7 |
| whatsapp_agent: Migrate to nexora_ai plugins | 2 days | Medium | E.7 |
| calling_agent: Migrate to nexora_ai plugins | 2 days | Medium | E.7 |

### Phase E.8: Analytics & Dashboard (Week 15-16)

**Goal**: Unified analytics and agent management UI.

| Task | Effort | Risk | Dependencies |
|------|--------|------|-------------|
| Agent metrics ingestion API | 2 days | Low | E.6 |
| Analytics aggregation service | 3 days | Low | E.8 |
| Control center: Agent management module | 5 days | Low | E.8 |
| Control center: Unified analytics | 3 days | Low | E.8 |
| Control center: Real-time health monitor | 2 days | Low | E.8 |

---

## 8. RISK ANALYSIS

### 8.1 HIGH Risk

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Auth migration breaks existing users | Users can't log in | Medium | Dual-mode auth during migration. Keep local auth as fallback. |
| Org sync causes data inconsistency | Wrong org data in agents | Medium | Read-only sync. Agents don't modify org data. |
| ProviderRouter migration breaks LLM calls | Agents can't generate responses | Low | Extensive integration testing. Fallback to direct API calls. |
| Performance degradation from remote calls | Slower agent responses | Medium | Cache org/provider config locally. Refresh periodically. |

### 8.2 MEDIUM Risk

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Breaking existing APIs | Clients can't connect | Low | Additive changes only. Version APIs if needed. |
| Database schema conflicts | Migration failures | Low | Agents keep their own tables. Only shared data goes to Nexora. |
| Plugin system incompatibility | Plugins don't load | Medium | Start with simple plugins. Iterate on manifest format. |
| Memory overhead from centralization | Higher resource usage | Low | Async operations. Connection pooling. |

### 8.3 LOW Risk

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Flutter module compilation issues | Dashboard won't build | Low | Incremental module addition. |
| Test coverage gaps | Bugs in production | Medium | Integration tests for every integration point. |

---

## 9. PRIORITY

### P0 - Must Have (Weeks 1-4)
1. Agent registration protocol
2. Auth unification (SSO)
3. Organization synchronization
4. nexora_ai platform adapters

### P1 - Should Have (Weeks 5-10)
5. Provider unification
6. Shared memory
7. Event bus

### P2 - Nice to Have (Weeks 11-16)
8. Plugin system unification
9. Analytics aggregation
10. Dashboard agent management
11. Billing/licensing integration
12. Centralized logging

---

## 10. ESTIMATED EFFORT

| Phase | Weeks | Effort (person-days) | Deliverable |
|-------|-------|---------------------|-------------|
| E.1 Foundation | 1-2 | 10 | Registration API, platform adapters |
| E.2 Auth | 3-4 | 13 | SSO across all projects |
| E.3 Org Sync | 5-6 | 11 | Centralized org management |
| E.4 Providers | 7-8 | 10 | Unified LLM provider config |
| E.5 Memory | 9-10 | 12 | Cross-agent memory |
| E.6 Events | 11-12 | 10 | Cross-project event bus |
| E.7 Plugins | 13-14 | 10 | Unified plugin system |
| E.8 Dashboard | 15-16 | 15 | Agent management UI |
| **TOTAL** | **16 weeks** | **91 person-days** | |

---

## 11. SUCCESS CRITERIA

After Phase E completion:

- [ ] Users log in once and access all agents
- [ ] Organization config flows from Nexora to all agents
- [ ] LLM providers managed centrally in Nexora
- [ ] Memory search works across WhatsApp + Calling + Personal AI
- [ ] Events from agents visible in Nexora dashboard
- [ ] Plugins installable from Nexora, loadable by agents
- [ ] Agent health monitored in real-time from control center
- [ ] Analytics aggregated across all agents
- [ ] All existing tests continue to pass
- [ ] No breaking changes to existing APIs

---

## 12. NON-GOALS (Phase E)

- Rewriting agent backends
- Changing database schemas of existing tables
- Replacing Flutter apps
- Adding new AI capabilities
- Performance optimization beyond integration needs
- Mobile app development
