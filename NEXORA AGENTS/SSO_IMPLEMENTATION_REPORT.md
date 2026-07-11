# SSO Implementation Report

**Phase:** E.4 — Unified Authentication & Organization Federation  
**Date:** 2026-07-01  
**Status:** COMPLETE

---

## Executive Summary

Implemented Single Sign-On (SSO) across all NEXORA agents. A user logs in once at any agent and receives a JWT token valid across all agents. The shared `AuthClient` in `nexora_ai` handles token validation uniformly.

---

## What Was Built

### 1. Shared AuthClient (`nexora_ai/infrastructure/auth/auth_client.py`)

Single implementation used by all agents:

- JWT token creation (access + refresh)
- JWT token validation (signature, expiry, issuer)
- User context extraction from token
- Organization context resolution
- RBAC permission checking
- FastAPI dependency injection (`require_permission`, `require_role`)

### 2. Auth Enums (`nexora_ai/domain/enums/auth_enums.py`)

- `SystemRole`: owner, admin, manager, employee, viewer
- `AuthMode`: legacy, unified
- `Permission`: 40 permissions across all agent capabilities
- `ROLE_PERMISSIONS`: Default permission set per role

### 3. Auth Entities (`nexora_ai/domain/entities/auth.py`)

- `UserContext`: User identity with role, permissions, org
- `OrganizationContext`: Organization metadata
- `TokenClaims`: Standard JWT claim structure
- `AuthConfig`: Auth mode, JWT settings, control plane URL

### 4. Dual-Mode Agent Migration

All agents updated with `AUTH_MODE` config:

| Agent | Config Variable | Default |
|-------|----------------|---------|
| personal_ai | `NEXORA_AUTH_MODE` | `legacy` |
| whatsapp_agent | `WA_AUTH_MODE` | `legacy` |
| calling_agent | `CA_AUTH_MODE` | `legacy` |

---

## SSO Flow

```
1. User logs in at whatsapp_agent
   POST /api/v1/auth/login {email, password}
   → Returns {access_token, refresh_token}

2. User calls personal_ai with same token
   Authorization: Bearer <access_token>
   → personal_ai validates JWT via AuthClient
   → Extracts user_id, org_id, role, permissions
   → Request proceeds

3. User calls calling_agent with same token
   Authorization: Bearer <access_token>
   → calling_agent validates JWT via AuthClient
   → Same user context extracted
   → Request proceeds
```

---

## Token Structure

### Access Token

```json
{
  "sub": "user-uuid",
  "org_id": "org-uuid",
  "tenant_id": "org-uuid",
  "role": "admin",
  "permissions": ["view_dashboard", "manage_calls"],
  "type": "access",
  "iss": "nexora",
  "exp": 1719856800,
  "iat": 1719853200,
  "jti": "unique-id"
}
```

### Refresh Token

```json
{
  "sub": "user-uuid",
  "type": "refresh",
  "iss": "nexora",
  "exp": 1720458000,
  "iat": 1719853200,
  "jti": "unique-id"
}
```

---

## Backward Compatibility

### Legacy Mode (`AUTH_MODE=legacy`)

- Agent uses its own secret key for JWT
- Existing tokens continue working
- No migration required
- Agents operate independently

### Unified Mode (`AUTH_MODE=unified`)

- Agent validates Nexora-issued JWT
- Shared secret via `NEXORA_JWT_SECRET`
- SSO works across all agents
- Single identity provider

### Migration Strategy

1. Deploy with `AUTH_MODE=legacy` (default)
2. Test unified mode in staging
3. Switch agents one-by-one to `unified`
4. Monitor for auth failures
5. Remove legacy mode after full migration

---

## API Endpoints

### Login (per-agent)

```
POST /api/v1/auth/login
Body: {email, password}
Response: {access_token, refresh_token, token_type, expires_in}
```

### Token Refresh

```
POST /api/v1/auth/refresh
Header: Authorization: Bearer <refresh_token>
Response: {access_token, refresh_token, token_type, expires_in}
```

### Current User

```
GET /api/v1/auth/me
Header: Authorization: Bearer <access_token>
Response: {id, email, name, role, organization_id, permissions}
```

### Auth Status (personal_ai only)

```
GET /api/v1/auth/status
Response: {auth_mode, has_api_key, control_plane_url, jwt_issuer, supported_roles}
```

---

## Security Considerations

1. **Single issuer** — Only Nexora Brain signs tokens in unified mode
2. **Shared secret** — All agents use same `NEXORA_JWT_SECRET`
3. **Short-lived tokens** — Access tokens expire in 60 minutes
4. **Refresh rotation** — New refresh token issued on each refresh
5. **No token storage** — Agents validate but don't store tokens
6. **Rate limiting** — Login endpoints rate-limited (5 attempts / 5 minutes)

---

## Test Results

| Project | Auth Tests | Status |
|---------|-----------|--------|
| nexora_ai | 118 | PASS |
| whatsapp_agent | 134 | PASS |
| calling_agent | 225 | PASS |
| personal_ai | 46 | PASS |
