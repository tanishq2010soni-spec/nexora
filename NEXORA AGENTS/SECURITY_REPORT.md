# NEXORA AGENTS - Security Report

**Date**: July 1, 2026  
**Phase**: D.5 - Production Stabilization

---

## Security Audit Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 3 | OPEN |
| HIGH | 6 | OPEN |
| MEDIUM | 8 | OPEN |
| LOW | 4 | OPEN |
| **TOTAL** | **21** | |

---

## CRITICAL Issues

### 1. Hardcoded Default Secret Key
- **Files**: `whatsapp_agent/backend/config.py:25`, `calling_agent/backend/config.py:22`
- **Impact**: JWT tokens can be forged by anyone who knows the default key
- **Fix**: Require secret key via environment variable; fail startup if unset

### 2. Command Injection via shell=True
- **File**: `personal_ai/backend/services/desktop_controller.py:84, 283, 381, 433`
- **Impact**: Arbitrary OS command execution via user input
- **Fix**: Remove `shell=True`; use list arguments; enforce command allowlist

### 3. Unauthenticated System Shutdown
- **File**: `personal_ai/backend/agent_server.py:237-242`
- **Impact**: Any caller can shut down the agent server
- **Fix**: Add authentication middleware to all endpoints

---

## HIGH Issues

### 4. Wildcard CORS Configuration
- **Files**: All 3 backend projects
- **Impact**: Any website can make authenticated cross-origin requests
- **Fix**: Restrict to specific trusted domains

### 5. No Authentication on Personal AI
- **File**: `personal_ai/backend/agent_server.py`
- **Impact**: Unrestricted access to chat, memory, tools, settings
- **Fix**: Add JWT/API key authentication

### 6. Unrestricted Tool Execution
- **File**: `personal_ai/backend/agent_server.py:295-301`
- **Impact**: Execute arbitrary terminal commands remotely
- **Fix**: Add auth + tool allowlist for remote execution

### 7. SSRF via webhook_url
- **File**: `whatsapp_agent/backend/api/whatsapp.py:251-272`
- **Impact**: Can point webhooks to internal network
- **Fix**: Validate URL scheme, restrict to public IPs

### 8. Refresh Tokens Never Invalidated
- **Files**: Both auth.py files
- **Impact**: Compromised tokens remain valid until expiry
- **Fix**: Implement token denylist (Redis-backed)

### 9. No Rate Limiting on Auth
- **Files**: Both auth.py files
- **Impact**: Brute-force password attacks possible
- **Fix**: Add `slowapi` or similar rate limiter

---

## MEDIUM Issues

### 10. Path Traversal in Session Manager
- **File**: `whatsapp_agent/backend/infrastructure/whatsapp/session_manager.py`
- **Fix**: Use `os.path.basename()` or validate final path

### 11. Information Leakage in Errors
- **Files**: Multiple service files
- **Fix**: Log internally; return generic messages

### 12. Unsanitized Screenshot Path
- **File**: `personal_ai/backend/services/desktop_controller.py:331-371`
- **Fix**: Restrict output to designated directory

### 13. Missing Phone Number Validation
- **File**: `whatsapp_agent/backend/api/whatsapp.py:43-69`
- **Fix**: Add E.164 regex validation

### 14. Weak Bcrypt Cost
- **Files**: Both auth.py files
- **Fix**: Set `bcrypt__rounds=12` or higher

### 15. Unsanitized QR Content
- **File**: `whatsapp_agent/backend/infrastructure/whatsapp/adapter.py:24`
- **Fix**: URL-encode all interpolated values

### 16. Missing Version Pins
- **Files**: All requirements.txt
- **Fix**: Pin exact versions or use `~=`

### 17. Stale Default Secret
- **File**: `calling_agent/backend/config.py:22`
- **Fix**: Same as #1

---

## LOW Issues

### 18. Debug Info in Exception Handlers
### 19. No CSRF (mitigated by Bearer tokens)
### 20. Terminal Tool Env Leakage
### 21. No HTTPS Enforcement

---

## Recommendations

### Immediate (Week 1)
1. Remove all hardcoded secret keys
2. Fix shell=True subprocess calls
3. Add authentication to personal_ai

### Short-term (Week 2-4)
4. Restrict CORS origins
5. Add rate limiting on auth endpoints
6. Implement refresh token revocation
7. Add input validation on all API endpoints

### Long-term (Month 2+)
8. Implement comprehensive RBAC
9. Add audit logging
10. Security penetration testing
