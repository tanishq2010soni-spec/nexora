# SECURITY_HARDENING_REPORT.md

## Security Hardening Report — Phase G

### Date: 2026-07-02

---

## Findings Fixed

### 1. Cross-Tenant Data Leak in Metrics (CRITICAL → FIXED)

**File:** `src/presentation/api/v1/metrics.py:30-46`
**Issue:** Prometheus metrics endpoint returned aggregate data across all tenants.
**Fix:** Added `.where(Model.org_id == org_id)` to all 5 business metric queries.
**Verification:** Authenticated user now sees only their organization's data.

### 2. Hardcoded Agent Registration Key (CRITICAL → FIXED)

**File:** `src/config.py:94`
**Issue:** Default key `"nexora-agent-internal-key-2026"` was static and predictable.
**Fix:** Default changed to empty string. Production mode requires explicit configuration.
**Verification:** Startup fails in production mode if `AGENT_REGISTRATION_KEY` is not set.

### 3. Agent Registration org_id Spoofing (CRITICAL → FIXED)

**File:** `src/presentation/api/v1/agents.py:357-361`
**Issue:** Agent key auth accepted arbitrary `organization_id` from request body.
**Fix:** Removed body-based org_id fallback. Added `X-Organization-Id` header requirement.
**Verification:** Agent must present valid org_id via header; body field ignored for auth.

### 4. Session Cleanup Cross-Tenant Deletion (CRITICAL → FIXED)

**File:** `src/infrastructure/jobs/worker.py:97`
**Issue:** Cleanup job deleted sessions across ALL tenants without org filter.
**Fix:** Job now iterates org_ids and deletes per-tenant.
**Verification:** Each organization's sessions are cleaned independently.

### 5. Plaintext Provider API Keys (CRITICAL → FIXED)

**File:** `src/presentation/api/v1/providers.py:122`, `src/infrastructure/database/models.py:797`
**Issue:** API keys stored in plaintext despite column named `api_key_encrypted`.
**Fix:** Implemented Fernet encryption. Keys encrypted on write, decrypted on read.
**Backward compat:** Existing plaintext data decrypted automatically (Fernet returns original if not encrypted).
**Key management:** `PROVIDER_ENCRYPTION_KEY` env var.

---

## Remaining Security Notes (Not Fixed — By Design)

These items were identified but are acceptable for current deployment:

1. **No token revocation** — Acceptable for single-service architecture with short token expiry (15min access, 7-day refresh).
2. **No account lockout** — Rate limiter provides 20 req/min on auth endpoints.
3. **RBAC on read endpoints** — Many read endpoints rely on org_id isolation rather than role checks. This is a design choice; all write endpoints have role checks.
4. **CORS with localhost** — Only in development config. Production must configure `CORS_ORIGINS`.
5. **Redis/Qdrant no auth** — Acceptable on internal Docker network. Production should add auth.
6. **No Sentry initialization** — DSN configured but not initialized. Optional enhancement.

---

## Security Posture After Phase G

| Area | Before | After |
|---|---|---|
| Tenant isolation (metrics) | Leaking all tenants | Scoped to authenticated org |
| Agent auth | Static shared secret, body-spoofable | Header-based, production-validated |
| Session cleanup | Cross-tenant deletion | Per-tenant isolation |
| API key storage | Plaintext | Fernet encrypted |
| Production validation | Missing key validation | Fails fast on missing secrets |
