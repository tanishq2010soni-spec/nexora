# NEXORA AGENTS - Release Checklist

**Date**: July 1, 2026  
**Phase**: D.5 - Production Stabilization

---

## Pre-Release Checklist

### Code Quality
- [x] All unit tests passing
- [ ] All integration tests passing (whatsapp_agent, calling_agent have UUID serialization issues)
- [ ] All E2E tests passing
- [ ] Zero lint issues (ruff)
- [ ] Zero type errors (mypy)
- [ ] Zero TODOs in codebase
- [ ] Zero placeholders
- [ ] No duplicated code

### Testing
- [x] nexora_ai: 118 tests passing
- [x] calling_agent: 225 tests passing
- [x] whatsapp_agent: 230 unit tests passing
- [x] personal_ai: 46 tests passing
- [ ] Coverage above 90% (currently 51% average)
- [x] HTML coverage reports generated

### Security
- [ ] All CRITICAL issues resolved (3 open)
- [ ] All HIGH issues resolved (6 open)
- [ ] No hardcoded secrets
- [ ] No command injection vulnerabilities
- [ ] Authentication on all endpoints
- [ ] CORS restricted to trusted domains
- [ ] Rate limiting on auth endpoints
- [ ] Input validation on all API endpoints

### Dependencies
- [x] All dependencies verified
- [x] Lock files present
- [x] No unused packages
- [x] Version pinning (recommendation: use `~=` or exact pins)

### Documentation
- [ ] Architecture docs updated
- [ ] API docs updated
- [ ] User guide updated
- [ ] Developer guide updated
- [ ] Changelog updated
- [ ] Release notes written

### Packaging
- [x] nexora_ai installable
- [x] whatsapp_agent standalone
- [x] calling_agent standalone
- [x] personal_ai standalone (requires nexora_ai)
- [ ] Clean installation verified
- [ ] Independent startup verified

### Performance
- [ ] Startup time measured
- [ ] Memory usage measured
- [ ] CPU utilization measured
- [ ] Latency measured
- [ ] Streaming performance measured
- [ ] Large conversation handling tested
- [ ] Large knowledge base handling tested
- [ ] Stress tests completed

---

## Blockers for Release

### CRITICAL
1. Hardcoded secret keys in whatsapp_agent and calling_agent
2. Command injection in personal_ai desktop_controller
3. Unauthenticated shutdown endpoint in personal_ai

### HIGH
4. Wildcard CORS across all projects
5. No authentication on personal_ai
6. No rate limiting on auth endpoints

---

## Sign-Off

| Role | Name | Date | Status |
|------|------|------|--------|
| Developer | | | PENDING |
| QA | | | PENDING |
| Security | | | PENDING |
| Product | | | PENDING |
