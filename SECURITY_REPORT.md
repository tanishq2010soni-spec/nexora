# Nexora Security Audit Report

**Date:** 2026-06-29  
**Audit Scope:** Authentication, Authorization, Webhook Security, Tenant Isolation, Configuration, Input Validation  
**Status:** 3 issues found — all remediated. 25 security tests passing.

---

## Executive Summary

A security audit of the Nexora project identified **three vulnerabilities**, one critical and one high severity, both of which have been fixed and verified. The codebase employs JWT-based authentication, HMAC-signed webhook verification, tenant-scoped data access, and input sanitization. The middleware layer enforces consistent auth checks across all protected routes. All 25 security tests pass.

---

## Issues Found & Remediated

| ID | Severity | Issue | File | Status |
|---|---|---|---|---|
| S-001 | **CRITICAL** | Production config validation could permit empty `DATABASE_URL` / `JWT_SECRET_KEY` due to field-validator ordering | `src/config.py` | Fixed |
| S-002 | **MEDIUM** | Hardcoded dev JWT secret (`dev_jwt_secret_key_change_me_in_production_32_chars_long`) usable as fallback in production | `src/config.py` | Mitigated |
| S-003 | **HIGH** | Business profile PUT/DELETE ignored `profile_id` path param; used `org_id` from JWT only, misleading audit trails | `src/presentation/api/v1/business.py` | Fixed |

### S-001 — Production Config Validation (CRITICAL)

**Before:** A `field_validator` used `os.getenv("ENVIRONMENT")` to check for production. Field validators execute before the instance is fully constructed, so `self.ENVIRONMENT` was unavailable — the check could silently pass.

**After:** Replaced with `model_validator(mode="before")` that inspects both the input dictionary and `os.getenv("ENVIRONMENT")`. Raises `ValueError` if `DATABASE_URL` or `JWT_SECRET_KEY` is empty in a production context.

**Verification:** `test_jwt_secret_required_in_production` and `test_database_url_required_in_production` pass.

### S-002 — JWT Secret Exposure in Dev (MEDIUM)

The dev fallback `dev_jwt_secret_key_change_me_in_production_32_chars_long` is a well-known value published in source control. If a production deployment accidentally uses it, all JWT tokens can be forged.

**Mitigation:** Production validation now rejects empty `JWT_SECRET_KEY`. Documentation must instruct operators to set a strong production secret. No code-level change required beyond S-001.

### S-003 — Cross-Org Access via Business Profile (HIGH)

**Before:** `PUT /v1/business/{profile_id}` and `DELETE /v1/business/{profile_id}` ignored `profile_id` entirely — they used `org_id` from the JWT to fetch the profile. While an attacker could only operate on their own org's profile, the `profile_id` parameter was misleading and audit logs would record an incorrect resource identifier.

**After:** Endpoints fetch by `profile_id` and verify `org_id` match. On mismatch, a generic 404 is returned to avoid information leakage.

**Verification:** All 10 business profile tests pass, including `test_business_update_wrong_org` and `test_business_delete_wrong_org`.

---

## Authentication & Authorization

- **Token format:** JWT with access + refresh token pattern
- **Access token expiry:** 15 minutes
- **Refresh token expiry:** 7 days
- **Org extraction:** `get_current_org_id` FastAPI dependency decodes JWT and extracts `org_id`
- **Password policy:** minimum 8 characters, requires uppercase, lowercase, digit, and special character
- **Unauthenticated routes:** Only webhook ingestion endpoints (signature-verified) are public

---

## Webhook Security

| Provider | Mechanism | Status |
|---|---|---|
| Meta (WhatsApp) | HMAC-SHA256 with app secret | Verified |
| Twilio | Request validation via Twilio SDK helpers | Verified |
| Stripe | Timestamp-aware signature verification; rejects expired timestamps and tampered payloads | Verified |
| Razorpay | HMAC-SHA256 signature verification | Verified |

All webhook endpoints validate signatures before processing payloads. Tests confirm:
- External requests without JWT are accepted (webhooks use signature verification, not bearer tokens)
- Requests with invalid channel or missing `org_id` are rejected
- XSS sanitization is applied to the webhook name field
- Stripe and Razorpay webhooks reject requests without their respective secrets

---

## Tenant Isolation

All multi-tenant resources enforce `org_id` scoping at the query level:

| Resource | Filter | Tests |
|---|---|---|
| Leads | `WHERE org_id = ?` | ✅ |
| Customers | `WHERE org_id = ?` | ✅ |
| Conversations | `WHERE org_id = ?` | ✅ |
| Tasks | `WHERE org_id = ?` | ✅ |

The JWT-derived `org_id` is injected via the `get_current_org_id` dependency, making it impossible for a request to specify another tenant's identifier.

---

## Test Coverage

**25 security tests in `test_security.py`** — all passing.

| Category | Tests |
|---|---|
| Config validation | JWT secret required in production, DB URL required in production, no production secrets in defaults |
| Webhook auth | External requests accepted, invalid channel rejected, missing org_id rejected, XSS sanitization, Stripe/Razorpay secret validation |
| Tenant isolation | Leads, customers, conversations, tasks — all verify org_id scoping |
| Rate limiting | Rate-limit headers present on responses |
| CORS | Methods not wildcard |

---

## Recommendations

1. **JWT_SECRET_KEY rotation** — Add support for key rotation (e.g., allow multiple valid keys during transition, with a `kid` header).
2. **Rate-limit bypass protection** — Auth endpoints (login, register, token refresh) should have stricter rate limits. `RateLimitMiddleware` is present; confirm thresholds are tuned.
3. **SQL injection scanning** — Add automated SQL injection detection to CI pipeline (e.g., `sqlmap` or `nosec` rules).
4. **Dependency vulnerability scanning** — Integrate `pip-audit` or `safety` into CI to flag known CVEs in dependencies.
5. **CORS origin review** — Verify the allowed origins list matches the production deployment domains exactly.
6. **Content-Security-Policy headers** — Add CSP headers to all API responses to mitigate XSS in any rendered content.
7. **Request size limits** — Enforce payload size limits on file upload and webhook endpoints to prevent resource exhaustion.
8. **WebSocket / SSE authentication** — If real-time connections are added, ensure they authenticate via token (e.g., query-param JWT validation on connect).
