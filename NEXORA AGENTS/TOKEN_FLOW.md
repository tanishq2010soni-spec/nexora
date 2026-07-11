# Token Flow

**Phase:** E.4 — Unified Authentication & Organization Federation  
**Date:** 2026-07-01

---

## Token Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                      TOKEN LIFECYCLE                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Login                                                    │
│     POST /api/v1/auth/login                                  │
│     → Verify credentials (bcrypt)                           │
│     → Create access token (60 min)                          │
│     → Create refresh token (7 days)                         │
│     → Return token pair                                     │
│                                                              │
│  2. Access Resource                                          │
│     GET /api/v1/resource                                     │
│     Header: Authorization: Bearer <access_token>            │
│     → Decode JWT                                             │
│     → Verify signature, expiry, issuer                      │
│     → Extract user context                                  │
│     → Check permissions                                     │
│     → Return resource                                       │
│                                                              │
│  3. Token Refresh                                            │
│     POST /api/v1/auth/refresh                                │
│     Header: Authorization: Bearer <refresh_token>           │
│     → Decode refresh token                                  │
│     → Verify type == "refresh"                              │
│     → Create new access token                               │
│     → Create new refresh token                              │
│     → Return new token pair                                 │
│                                                              │
│  4. Logout                                                   │
│     (Client-side)                                            │
│     → Discard tokens                                        │
│     → Clear session                                         │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Token Types

### Access Token

**Purpose:** Authenticate API requests  
**TTL:** 60 minutes  
**Usage:** `Authorization: Bearer <access_token>`

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
  "jti": "unique-token-id"
}
```

### Refresh Token

**Purpose:** Obtain new access token  
**TTL:** 7 days  
**Usage:** `Authorization: Bearer <refresh_token>` (refresh endpoint only)

```json
{
  "sub": "user-uuid",
  "type": "refresh",
  "iss": "nexora",
  "exp": 1720458000,
  "iat": 1719853200,
  "jti": "unique-token-id"
}
```

---

## Token Claims

| Claim | Type | Description |
|-------|------|-------------|
| `sub` | string | User ID (UUID) |
| `org_id` | string | Organization ID (UUID) |
| `tenant_id` | string | Tenant ID (same as org_id) |
| `role` | string | User role (owner/admin/manager/employee/viewer) |
| `permissions` | list | List of permission strings |
| `type` | string | Token type ("access" or "refresh") |
| `iss` | string | Token issuer ("nexora") |
| `exp` | int | Expiration time (Unix timestamp) |
| `iat` | int | Issued at time (Unix timestamp) |
| `jti` | string | Unique token ID (UUID) |

---

## Token Validation Steps

```
Token received
    │
    ▼
1. Decode JWT (verify signature)
    │
    ├── Invalid signature → 401 "Invalid token"
    │
    ▼
2. Check expiry
    │
    ├── Expired → 401 "Token expired"
    │
    ▼
3. Check issuer
    │
    ├── Wrong issuer → 401 "Invalid token issuer"
    │
    ▼
4. Check token type
    │
    ├── Not "access" → 401 "Invalid token type"
    │
    ▼
5. Extract claims
    │
    ├── Missing sub → 401 "Invalid token"
    ├── Missing org_id → 401 "Missing organization"
    │
    ▼
6. Load user context
    │
    ├── User not found → 401 "User not found"
    ├── User inactive → 401 "User inactive"
    │
    ▼
7. Check permissions
    │
    ├── Missing permission → 403 "Insufficient permissions"
    │
    ▼
8. Proceed with request
```

---

## Cross-Agent Token Flow

```
User logs in at whatsapp_agent
    │
    ▼
POST /api/v1/auth/login
    │
    ├── Verify password (bcrypt)
    ├── Create JWT with user_id, org_id, role
    │
    ◄── {access_token, refresh_token}
    │
    ▼
User calls personal_ai
    │
    ├── Authorization: Bearer <access_token>
    ├── personal_ai validates JWT via AuthClient
    ├── Extracts user context from token
    │
    ◄── 200 OK
    │
    ▼
User calls calling_agent
    │
    ├── Authorization: Bearer <access_token>
    ├── calling_agent validates JWT via AuthClient
    ├── Same user context extracted
    │
    ◄── 200 OK
```

---

## Token Refresh Flow

```
Access token expires
    │
    ▼
Client sends refresh request
    │
    POST /api/v1/auth/refresh
    Authorization: Bearer <refresh_token>
    │
    ├── Verify refresh token
    ├── Check type == "refresh"
    ├── Load user from DB
    │
    ├── Create new access token
    ├── Create new refresh token
    │
    ◄── {new_access_token, new_refresh_token}
    │
    ▼
Client uses new access token
```

---

## Security Measures

### Token Signing

- Algorithm: HS256 (HMAC-SHA256)
- Secret: `NEXORA_JWT_SECRET` (shared across all agents)
- Signature prevents token tampering

### Token Expiry

- Access tokens: 60 minutes
- Refresh tokens: 7 days
- Expired tokens rejected immediately

### Token Revocation

- Current: No revocation (tokens valid until expiry)
- Future: Redis-backed token blacklist

### Rate Limiting

- Login: 5 attempts per IP per 5 minutes
- Refresh: Standard rate limiting

---

## Error Responses

### 401 Unauthorized

```json
{
  "detail": "Invalid token"
}
```

### 401 Token Expired

```json
{
  "detail": "Token expired"
}
```

### 403 Forbidden

```json
{
  "detail": "Insufficient permissions"
}
```

### 429 Too Many Requests

```json
{
  "detail": "Too many login attempts. Try again later."
}
```

---

## Token Storage (Client-Side)

### Recommended

- Access token: Memory only (not persisted)
- Refresh token: Secure HTTP-only cookie or secure storage

### Not Recommended

- LocalStorage (XSS vulnerable)
- SessionStorage (XSS vulnerable)
- Plain cookies (CSRF vulnerable)

---

## Future Enhancements

1. **Token blacklist** — Redis-backed revocation
2. **Token rotation** — Automatic refresh before expiry
3. **Device tracking** — Token bound to device
4. **IP binding** — Token valid only from originating IP
5. **Session management** — View/revoke active sessions
