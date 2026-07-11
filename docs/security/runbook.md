# Security Runbook

## Security Controls Summary

| Control | Implementation | Verification |
|---------|---------------|--------------|
| Authentication | JWT (HS256, 15min access, 7d refresh) | `test_auth.py` |
| Authorization | org_id in JWT, role-based (admin/member) | `test_security.py` |
| Tenant Isolation | org_id scoping on all queries | `test_security.py` |
| Rate Limiting | Redis sliding window + nginx | `test_security.py` |
| Password Policy | 8+ chars, upper, lower, digit, special | `test_auth.py` |
| Password Hashing | bcrypt (72-byte truncation) | `test_auth.py` |
| Webhook Verification | Stripe/Twilio/Razorpay/Meta signatures | `test_integration_verification.py` |
| Request Size Limit | 10 MB | middleware |
| CORS | Restricted origins, methods, headers | `test_security.py` |
| Security Headers | HSTS, X-Frame, X-Content-Type, etc. | middleware |
| Secrets Management | Docker secrets / K8s secrets | configuration |
| API Key Encryption | Fernet symmetric encryption | `provider_encryption.py` |

## Secret Rotation

Rotation schedule and commands are in `scripts/deploy/secret-rotate.sh`.

| Secret | Rotation | Command |
|--------|----------|---------|
| JWT_SECRET_KEY | Quarterly | `secret-rotate.sh jwt` |
| DATABASE_URL | Yearly | `secret-rotate.sh db` |
| AGENT_REGISTRATION_KEY | Quarterly | `secret-rotate.sh agent` |
| PROVIDER_ENCRYPTION_KEY | Yearly | `secret-rotate.sh encryption` |
| Third-party API keys | On compromise | Manual update |

## Security Incident Response

### Unauthorized Access

1. Revoke JWT secret: `secret-rotate.sh jwt`
2. Revoke all sessions: Rotate JWT_SECRET_KEY
3. Rotate affected API keys
4. Review audit logs: `GET /api/v1/audit-logs`
5. Determine scope of breach
6. Notify affected tenants

### API Key Leak

1. Rotate compromised key
2. Check usage logs for unusual patterns
3. Update integration configuration
4. Notify vendor if applicable

### Rate Limit Abuse

1. Check nginx logs: `{job="nexora-nginx"} |= "limiting"`
2. Check Redis rate limit keys: `redis-cli KEYS 'rl:*'`
3. Block offending IP in nginx
4. Consider adjusting rate limits

## Compliance

| Requirement | Status | Evidence |
|-------------|--------|----------|
| HTTPS/TLS | Implemented | nginx + cert-manager |
| Password Hashing | Implemented | bcrypt |
| Data Encryption at Rest | Implemented | PG TDE, Fernet |
| Audit Logging | Implemented | audit_logs table |
| Rate Limiting | Implemented | Redis + nginx |
| Input Validation | Implemented | Pydantic schemas |
| Session Management | Implemented | JWT with expiry |
| CORS | Implemented | Restricted origins |
| Security Headers | Implemented | HSTS, X-Frame, etc. |
| Dependency Scanning | CI pipeline | pip-audit, trivy |
| Secret Scanning | CI pipeline | gitleaks, trufflehog |
