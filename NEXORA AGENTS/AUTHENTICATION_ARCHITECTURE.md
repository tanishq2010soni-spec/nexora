# Authentication Architecture

**Phase:** E.4 — Unified Authentication & Organization Federation  
**Date:** 2026-07-01  
**Status:** COMPLETE

---

## Overview

NEXORA now has a single Identity Provider. No agent owns authentication. All agents trust Nexora-issued JWT tokens. The shared `AuthClient` in `nexora_ai` handles token validation, RBAC, and organization resolution for all agents.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│              NEXORA AUTHENTICATION                   │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────────┐                                   │
│  │  Nexora Brain │ ← Only JWT issuer                │
│  │  (Control     │                                  │
│  │   Plane)      │                                  │
│  └──────┬───────┘                                   │
│         │                                           │
│         │ JWT + Refresh Token                       │
│         │                                           │
│  ┌──────▼───────────────────────────────────────┐   │
│  │         SHARED AuthClient (nexora_ai)        │   │
│  │                                               │   │
│  │  ├── Token validation (JWT decode + verify)  │   │
│  │  ├── RBAC (5 roles, permission checks)       │   │
│  │  ├── Organization resolution                  │   │
│  │  ├── User context creation                    │   │
│  │  └── Token creation (access + refresh)        │   │
│  └──────┬────────┬────────┬────────────────────┘   │
│         │        │        │                         │
│    ┌────▼──┐ ┌───▼───┐ ┌─▼──────────┐             │
│    │personal│ │whats- │ │  calling   │             │
│    │  _ai   │ │app_   │ │  _agent    │             │
│    │        │ │agent  │ │            │             │
│    └────────┘ └───────┘ └────────────┘             │
│                                                      │
└─────────────────────────────────────────────────────┘
```

---

## Key Components

### AuthClient (nexora_ai)

**Location:** `nexora_ai/infrastructure/auth/auth_client.py`

Single shared implementation used by all agents:

- **Token validation** — Decodes JWT, verifies signature, checks issuer
- **RBAC** — 5 roles with permission sets
- **Organization resolution** — Maps org_id to OrganizationContext
- **User context** — Creates UserContext from JWT claims
- **FastAPI dependencies** — `require_permission()`, `require_role()`

### JWT Token Claims (Standard)

```json
{
  "sub": "user_id",
  "org_id": "organization_id",
  "tenant_id": "organization_id",
  "role": "admin",
  "permissions": ["view_dashboard", "manage_calls"],
  "type": "access",
  "iss": "nexora",
  "exp": 1719856800,
  "iat": 1719853200,
  "jti": "unique-token-id"
}
```

### Dual-Mode Migration

| Mode | Behavior |
|------|----------|
| `legacy` | Agent uses local JWT signing (existing behavior) |
| `unified` | Agent validates Nexora-issued JWT via shared AuthClient |

Configured per-agent via `AUTH_MODE` env var:
- `WA_AUTH_MODE=legacy|unified`
- `CA_AUTH_MODE=legacy|unified`
- `NEXORA_AUTH_MODE=legacy|unified` (personal_ai)

---

## RBAC System

### 5 Roles

| Role | Access Level |
|------|-------------|
| `owner` | Full access to everything |
| `admin` | Full access to everything |
| `manager` | Operational access (inbox, CRM, campaigns, calls, analytics) |
| `employee` | Read-heavy access (view dashboard, inbox, CRM, calls) |
| `viewer` | Read-only (dashboard, analytics, logs) |

### Permission Set (40 permissions)

- **Dashboard:** `view_dashboard`
- **Messaging:** `view_inbox`, `manage_inbox`
- **CRM:** `view_crm`, `manage_crm`
- **Knowledge:** `view_knowledge`, `manage_knowledge`
- **Workflows:** `view_workflows`, `manage_workflows`
- **Campaigns:** `view_campaigns`, `manage_campaigns`
- **Analytics:** `view_analytics`
- **Settings:** `view_settings`, `manage_settings`
- **Team:** `manage_team`, `manage_permissions`
- **WhatsApp:** `manage_whatsapp`
- **Calls:** `view_live_calls`, `manage_calls`, `view_call_queue`, `manage_call_queue`
- **Leads:** `view_leads`, `manage_leads`
- **Recordings:** `view_recordings`, `manage_recordings`
- **Scripts:** `view_scripts`, `manage_scripts`
- **Voice Monitoring:** `monitor_calls`, `barge_calls`, `whisper_calls`
- **Providers:** `manage_phone_providers`, `manage_voice_providers`
- **Logs/Health:** `view_logs`, `view_health`
- **Plugins:** `manage_plugins`, `manage_models`

---

## Organization Federation

### Organization Context

```python
OrganizationContext(
    organization_id="org-123",
    tenant_id="org-123",
    name="Acme Corp",
    slug="acme",
    status="active",
    timezone="UTC",
    settings={},
    is_active=True,
)
```

### Federation Rules

1. **Organization ID** is in every JWT token (`org_id` claim)
2. **Tenant ID** equals Organization ID (single-tenant model)
3. **Organization must exist** — agents reject tokens with unknown org_id
4. **Organization must be active** — agents check `status == "active"`
5. **Organization metadata** comes from Nexora Brain only

---

## Security Boundaries

### Token Issuance

- Only Nexora Brain creates JWT tokens
- Tokens are signed with `NEXORA_JWT_SECRET` (shared secret)
- Access token TTL: 60 minutes
- Refresh token TTL: 7 days

### Token Validation

- Each agent validates JWT using shared AuthClient
- AuthClient verifies: signature, expiry, issuer, token type
- Invalid tokens → 401 Unauthorized

### Password Handling

- Passwords hashed with bcrypt (12 rounds)
- Passwords never stored in JWT tokens
- Password validation only at login time

---

## Migration Path

### Phase 1: Deploy AuthClient

1. Deploy nexora_ai with AuthClient
2. All agents have access to shared auth

### Phase 2: Enable Unified Mode

1. Set `AUTH_MODE=unified` on agents one at a time
2. Agents switch from local JWT to Nexora-issued JWT
3. Monitor for auth failures

### Phase 3: Remove Legacy Auth

1. Once all agents are unified, remove legacy auth code
2. Remove per-agent secret keys (`WA_SECRET_KEY`, `CA_SECRET_KEY`)
3. Only `NEXORA_JWT_SECRET` remains

---

## Test Results

| Project | Tests | Status |
|---------|-------|--------|
| nexora_ai | 118 | PASS |
| whatsapp_agent | 134 | PASS (1 pre-existing e2e fail) |
| calling_agent | 225 | PASS |
| personal_ai | 46 | PASS |
| **Total** | **523** | **522 PASS + 1 pre-existing** |
