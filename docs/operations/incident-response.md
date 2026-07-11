# Incident Response Guide

## Severity Levels

| Level | Definition | Response Time | Example |
|-------|-----------|---------------|---------|
| SEV1 | Platform down or data loss | < 15 min | API returning 503, database down |
| SEV2 | Feature degraded | < 60 min | High latency, Ollama down |
| SEV3 | Non-critical bug | < 24 hr | Minor display issue, typo |
| SEV4 | Enhancement | Next sprint | Feature request |

## Incident Lifecycle

```
1. DETECT    → Alert fires or user reports
2. TRIAGE    → Determine severity and impact
3. RESPOND   → Mitigate or fix
4. RESOLVE   → Confirm fix
5. REVIEW    → Post-mortem within 48h
```

## Common Incidents

### 1. API Returns 503 (Health Check Fails)

**Symptoms**: Health endpoint returns 503, monitoring alerts

**Triage**:
1. Check all services: `kubectl get pods -n nexora`
2. Check brain logs: `kubectl logs deployment/nexora-brain-blue -n nexora --tail=100`
3. Check database: `kubectl exec deployment/nexora-postgres -n nexora -- pg_isready`

**Resolution**:
1. If database down: `kubectl rollout restart deployment/nexora-postgres -n nexora`
2. If connection pool exhausted: Restart brain pods
3. If disk full: Clean up old WAL files or expand PVC
4. Verify: `curl https://api.nexora.ai/health`

### 2. High Error Rate (5xx)

**Threshold**: > 5% error rate for 2 minutes

**Triage**:
1. Check Grafana: Request Rate dashboard
2. Check error logs: `{job="nexora-brain"} |= "ERROR"`
3. Check upstream services (Ollama, Qdrant, Redis)

**Resolution**:
1. If Ollama down: Restart ollama, features degrade gracefully
2. If Redis down: Rate limiter fails open, features degrade
3. If database: Check connection pool, restart if needed
4. If code error: Rollback to last known good version

### 3. High Latency (p95 > 5s)

**Threshold**: p95 > 5s for 5 minutes

**Triage**:
1. Check which endpoints are slow in Grafana
2. Check database query performance
3. Check LLM response times
4. Check resource utilization (CPU, memory, IO)

**Resolution**:
1. Scale up: `kubectl scale deployment/nexora-brain-blue --replicas=8 -n nexora`
2. Check for slow queries: `pg_stat_activity`
3. Optimize or disable expensive analytics
4. Restart Ollama if LLM latency is high

### 4. Memory Pressure

**Threshold**: Memory > 85% for 10 minutes

**Triage**:
1. Check container stats: `kubectl top pods -n nexora`
2. Check for memory leaks in recent deployments
3. Check Redis memory usage

**Resolution**:
1. Scale horizontally: Add more replicas
2. Restart affected pods
3. Increase memory limits in deployment YAML
4. If Redis: Adjust maxmemory-policy

### 5. Disk Full

**Threshold**: Disk > 90%

**Triage**:
1. Check disk usage: `kubectl exec deployment/nexora-postgres -n nexora -- df -h`
2. Identify large files: `du -sh /var/lib/postgresql/data/*`
3. Check WAL directory size

**Resolution**:
1. Remove old WAL files
2. Run VACUUM on PostgreSQL
3. Expand PVC: Edit PVC and increase storage
4. Add retention-based cleanup if missing

## Recovery Procedures

### Full Database Restore

```bash
# 1. Stop brain
kubectl scale deployment/nexora-brain-blue --replicas=0 -n nexora
kubectl scale deployment/nexora-brain-green --replicas=0 -n nexora

# 2. Restore from backup
PGPASSWORD=$DB_PASS pg_restore -h localhost -U nexora -d nexora \
    --clean --if-exists /var/backups/nexora/db_20260703_020000.sql.gz

# 3. Run migrations
kubectl run migrate-job --image=ghcr.io/nexora/nexora:latest \
    -- alembic upgrade head

# 4. Restart brain
kubectl scale deployment/nexora-brain-blue --replicas=3 -n nexora

# 5. Verify
curl https://api.nexora.ai/health
```

### Point-in-Time Recovery

```bash
# 1. Find target time from incident log
# 2. Restore base backup
pg_basebackup -D /var/lib/postgresql/data -X fetch -P -v

# 3. Configure recovery
echo "restore_command = 'cp /var/backups/nexora/wal/%f %p'" >> postgresql.conf
echo "recovery_target_time = '2026-07-03 14:30:00 UTC'" >> postgresql.conf
touch /var/lib/postgresql/data/recovery.signal

# 4. Start PostgreSQL
pg_ctl -D /var/lib/postgresql/data start

# 5. Verify data integrity
# 6. Run application smoke tests
```

## Post-Mortem Template

```markdown
# Incident Post-Mortem: INC-XXX

## Summary
- **Date**: YYYY-MM-DD
- **Duration**: HH:MM
- **Severity**: SEV1/SEV2/SEV3
- **Impact**: X users affected, Y errors

## Timeline
- HH:MM - Alert fired
- HH:MM - Engineer responded
- HH:MM - Root cause identified
- HH:MM - Mitigation applied
- HH:MM - Service restored

## Root Cause
[Technical explanation]

## Resolution
[Steps taken to fix]

## Action Items
- [ ] Preventative measure 1
- [ ] Monitoring improvement
- [ ] Documentation update
```
