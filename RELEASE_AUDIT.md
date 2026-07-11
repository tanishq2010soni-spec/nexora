# RELEASE_AUDIT.md — NEXORA Repository Audit

**Date:** 2026-06-23
**Auditor:** Release Engine

---

## Repository Structure

| Component | Location | Status |
|---|---|---|
| Flutter App | `control_center/` | ✅ Present |
| FastAPI Backend | `src/` | ✅ Present |
| Docker | `Dockerfile`, `Dockerfile.production`, `docker-compose.yml` | ✅ Present |
| Alembic Migrations | `alembic/versions/` (8 migrations) | ✅ Present |
| Environment Config | `.env`, `.env.example` (created) | ✅ Present |
| Tests | `tests/unit/` (136 tests) | ✅ Present |
| Build Scripts | `scripts/backup.py`, `scripts/seed_plans.py` | ✅ Present |

---

## Critical Blockers Found & Fixed

| # | Issue | Severity | Status |
|---|---|---|---|
| 1 | No root `.gitignore` | CRITICAL | ✅ FIXED |
| 2 | No `.env.example` | HIGH | ✅ FIXED |
| 3 | `android:usesCleartextTraffic="true"` | MEDIUM | ✅ FIXED (network_security_config.xml) |
| 4 | iOS display name "Control Center" vs "Nexora" | MEDIUM | ✅ FIXED |
| 5 | `api_constants.dart` hardcoded localhost | CRITICAL | ✅ FIXED (uses Env.apiBaseUrl) |
| 6 | Token refresh not implemented | CRITICAL | ✅ FIXED |
| 7 | Register screen wrong provider name | HIGH | ✅ FIXED |
| 8 | Register screen wrong method name | HIGH | ✅ FIXED |
| 9 | 3 test failures (bcrypt, ollama) | HIGH | ✅ FIXED |

---

## Remaining Items (Non-blocking)

| Item | Priority | Notes |
|---|---|---|
| Flutter SDK not installed on build machine | HIGH | Must install Flutter 3.12.1+ for builds |
| Android `key.properties` missing | MEDIUM | Release signing falls back to debug keystore |
| CI/CD pipeline missing | HIGH | No automated build/test/deploy |
| 2 placeholder screens (system-health, audit-logs) | LOW | Functional but show "Coming Soon" |
| Settings: Security/Backup/Branding tabs are no-ops | LOW | Non-functional placeholders |
| 6 routes defined but not registered in router | MEDIUM | Detail routes for knowledge-base, leads, conversations, tasks, workflows |
| 39 outdated Flutter packages | LOW | Version drift, not blocking |
