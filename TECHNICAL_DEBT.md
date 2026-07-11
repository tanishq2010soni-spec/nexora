# Nexora — Technical Debt Analysis

## Executive Summary

A Phase 1.5 audit of the Nexora codebase (backend Python/FastAPI and Flutter frontend) identified **15 issues**, of which **12 have been repaid**. Three items of remaining technical debt — including a missing database migration system, a Flutter settings endpoint bug, and a lack of integration tests — are the highest-priority targets for Phase 2. Code quality baselines are strong: all 142 backend tests pass, Flutter analysis is clean, and the lone Flutter smoke test is green.

---

## Debt Repaid (Phase 1.5)

| Item | Severity | Effort | Description |
|------|----------|--------|-------------|
| Duplicate router | HIGH | Low | `business_profile.py` vs `business.py` were identical |
| Duplicate lead scoring | MEDIUM | Low | `_compute_lead_score` imported from private module |
| Missing config field | HIGH | Low | `BASE_URL` referenced but undefined |
| N+1 queries | HIGH | Medium | Individual message loads per conversation |
| Broken filter | MEDIUM | Low | `platform != platform` self-comparison |
| Double rate-limiting | MEDIUM | Medium | Stacked in-memory + Redis rate limiters |
| Singleton proliferation | LOW | Low | New `MemoryVectorService` per request |
| Missing dependency | MEDIUM | Low | `psutil` used but not declared |
| Production validation | HIGH | Medium | Invalid production env detection |
| Flutter race condition | HIGH | Medium | Session `build()` flash of wrong state |
| Flutter redirect loop | MEDIUM | Low | Counter-based loop detection |
| Flutter null-aware lints | LOW | Low | 12 info-level lints |

---

## Remaining Debt

### HIGH Priority

#### 1. No database migration system
No Alembic or auto-migration tooling is configured. Schema changes must be applied via raw SQL, which is error-prone and unrepeatable.

| Field | Value |
|-------|-------|
| File | — |
| Fix | Add Alembic, create initial migration |
| Effort | Medium |

#### 2. Flutter settings endpoint bug
`settings_remote_datasource.dart` builds its URL as `$_baseUrl/settings` but `_baseUrl` already contains `/settings`, producing the doubled path `/settings/settings`.

| Field | Value |
|-------|-------|
| File | `control_center/lib/features/settings/data/datasources/settings_remote_datasource.dart:12` |
| Fix | Change `$_baseUrl/settings` to `$_baseUrl/` or simply `/settings` |
| Effort | Low |

#### 3. No Flutter integration tests
Only a single widget test (default smoke test) exists. There are no API mock tests or widget integration tests covering real feature flows.

| Field | Value |
|-------|-------|
| File | `test/widget_test.dart` |
| Effort | High |

#### 4. Hardcoded strings in session_manager
Token storage keys `"accessToken"` and `"refreshToken"` are bare string literals scattered throughout the session manager.

| Field | Value |
|-------|-------|
| File | `control_center/lib/core/auth/session_manager.dart` |
| Effort | Low |

---

### MEDIUM Priority

#### 5. `to_domain_profile` / `to_domain_lead` tightly coupled to ORM
Converters in the repository layer manually map every ORM field to domain models. Every schema change requires a corresponding update in these mapper functions.

| Field | Value |
|-------|-------|
| File | `src/infrastructure/database/repositories.py:22-46` |
| Fix | Use dataclass-based or automated mapping |
| Effort | Medium |

#### 6. No Qdrant or Ollama health checks
The health endpoint only verifies database reachability. Vector store (Qdrant) and LLM (Ollama) service health is not reported.

| Field | Value |
|-------|-------|
| File | `src/presentation/api/v1/health.py` |
| Effort | Low |

#### 7. No pagination limits on all list endpoints
Some list-style endpoints may lack pagination, posing a risk of unbounded result sets under load.

| Effort | Medium |
|--------|--------|

---

### LOW Priority

#### 8. Graceful Redis degradation
When Redis is unreachable, caching silently falls back to no-op. No warning log or metric is emitted, making the degradation invisible in production monitoring.

| Effort | Low |
|--------|-----|

#### 9. `Settings` singleton
`settings = Settings()` at module level (`src/config.py:140`) prevents per-test configuration injection.

| File | Fix | Effort |
|------|-----|--------|
| `src/config.py:140` | Use dependency injection pattern | Low |

#### 10. Flutter error handling
The API client may lack structured error handling for every HTTP status code, potentially surfacing raw server errors to users.

| Effort | Medium |
|--------|--------|

---

## Code Quality Metrics

| Metric | Value |
|--------|-------|
| Backend test pass rate | 142/142 (100%) |
| Flutter `dart analyze` | 0 issues |
| Flutter test pass rate | 1/1 (100%) |
| Python files audited | ~25 source + 10 test |
| Flutter files audited | ~40 source + 1 test |
| Issues found | 15 |
| Issues fixed | 12 |

---

## Repayment Roadmap

| Phase | Target | Est. Effort |
|-------|--------|-------------|
| **Phase 2a** | Alembic migration system + initial migration | Medium |
| **Phase 2b** | Fix `settings` endpoint double-path bug | Low |
| **Phase 2c** | Add Flutter integration tests (API mock layer + 3–5 key flows) | High |
| **Phase 2d** | Extract hardcoded token keys into named constants | Low |
| **Phase 3** | Automated ORM mapping, Qdrant/Ollama health checks, pagination audit | Medium |
| **Backlog** | Redis degradation observability, DI for `Settings`, Flutter error-handling | Low–Medium |
