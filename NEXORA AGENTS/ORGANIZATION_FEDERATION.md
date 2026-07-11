# Organization Federation

**Phase:** E.4 — Unified Authentication & Organization Federation  
**Date:** 2026-07-01

---

## Overview

Organization information comes from Nexora only. Every authenticated request contains organization context. Agents validate that the organization exists and is active.

---

## Organization Context

Every JWT token contains:

```json
{
  "org_id": "org-uuid",
  "tenant_id": "org-uuid",
  "role": "admin",
  "permissions": ["..."]
}
```

### OrganizationContext Dataclass

```python
@dataclass
class OrganizationContext:
    organization_id: str    # UUID
    tenant_id: str          # Same as organization_id
    name: str               # "Acme Corp"
    slug: str               # "acme"
    status: str             # "active" | "suspended" | "trial" | "cancelled"
    timezone: str           # "UTC"
    settings: dict          # Agent-specific settings
    is_active: bool         # Derived from status
```

---

## Federation Rules

### Rule 1: Organization ID in Every Token

Every JWT must contain `org_id`. If missing, the token is rejected.

```python
if not claims.org_id:
    raise HTTPException(401, "Missing organization ID")
```

### Rule 2: Tenant ID = Organization ID

In single-tenant mode, `tenant_id` equals `organization_id`. This allows future multi-tenant expansion without changing the token structure.

### Rule 3: Organization Must Exist

Agents validate that the `org_id` in the token corresponds to a known organization:

```python
org = await auth.get_organization_context(claims.org_id)
if not org:
    raise HTTPException(401, "Unknown organization")
```

### Rule 4: Organization Must Be Active

Agents reject tokens from suspended/cancelled organizations:

```python
if not org.is_active:
    raise HTTPException(403, "Organization suspended")
```

### Rule 5: Organization Metadata from Nexora Only

Agents never create or modify organization data. All org metadata flows from Nexora Brain:

```
Nexora Brain (source of truth)
    ↓
Organization Context
    ↓
All Agents (read-only)
```

---

## Organization Data Model

### Nexora Brain (Source of Truth)

```python
class Organization:
    id: UUID
    name: str
    created_at: datetime
    updated_at: datetime
```

### Agent Organization (Federated)

```python
class Organization(BaseModel):
    id: UUID
    name: str
    slug: str
    status: str = "active"
    timezone: str = "UTC"
    brand_color: str = "#6366f1"
    brand_logo_url: Optional[str] = None
    working_hours_start: time = time(9, 0)
    working_hours_end: time = time(18, 0)
    working_days: list[int] = [0, 1, 2, 3, 4, 5, 6]
    default_language: str = "en"
    max_users: int = 10
    extra_data: dict = {}
    created_at: datetime
    updated_at: datetime
```

---

## Organization Validation Flow

```
Request arrives with JWT
    │
    ▼
Decode JWT → Extract org_id
    │
    ▼
Query OrganizationContext
    │
    ├── Not found → 401 "Unknown organization"
    │
    ├── status == "suspended" → 403 "Organization suspended"
    │
    ├── status == "cancelled" → 403 "Organization cancelled"
    │
    └── status == "active" → Proceed with request
```

---

## Cross-Agent Organization Consistency

### Same Organization, All Agents

When a user belongs to organization "Acme Corp":

1. **whatsapp_agent** — Sees Acme's WhatsApp accounts, conversations, leads
2. **calling_agent** — Sees Acme's phone providers, calls, campaigns
3. **personal_ai** — Sees Acme's agent configuration, tools, memory

### Organization Scoping

Every database query is scoped to the organization:

```python
# WhatsApp Agent
conversations = await session.execute(
    select(Conversation).where(Conversation.organization_id == org_id)
)

# Calling Agent
calls = await session.execute(
    select(Call).where(Call.organization_id == org_id)
)
```

### Data Isolation

Organizations cannot see each other's data. Every query includes `organization_id` filter.

---

## Organization Lifecycle

### Creation

1. User signs up at Nexora Brain
2. Nexora creates Organization + User (admin role)
3. User receives JWT with `org_id`
4. User can now access all agents

### Suspension

1. Admin suspends organization at Nexora Brain
2. Organization status → "suspended"
3. All agents reject requests from this org
4. Users see "Organization suspended" error

### Reactivation

1. Admin reactivates organization
2. Organization status → "active"
3. All agents resume normal operation

### Deletion

1. Owner deletes organization at Nexora Brain
2. Organization status → "cancelled"
3. All agents reject requests
4. Data retained for grace period, then purged

---

## Future Enhancements

1. **Multi-tenant support** — `tenant_id` differs from `org_id`
2. **Organization hierarchy** — Parent/child organizations
3. **Cross-organization sharing** — Shared resources between orgs
4. **Organization templates** — Pre-configured settings per industry
5. **Webhook notifications** — Org status changes pushed to agents
