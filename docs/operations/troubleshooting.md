# Troubleshooting Guide

## API Issues

### Health endpoint returns 503

**Check**: Are database and cache healthy?

```bash
curl https://api.nexora.ai/api/v1/health/detailed
# Look for "unhealthy" in database or cache fields
```

**Fix**:
- Database unhealthy: Restart PostgreSQL, check disk space
- Cache unhealthy: Restart Redis, check memory
- Both: Network issue between brain and infrastructure

### Requests timing out

**Check**: Is latency high across all endpoints or specific ones?

```bash
# Check p95 latency in Grafana
# Check database query performance
```

**Fix**:
- Scale up brain replicas
- Check for slow database queries
- Restart Ollama if LLM endpoints are slow
- Increase proxy timeouts in ingress

### 401 Unauthorized

**Check**: Is JWT token valid?

```bash
# Decode and verify JWT
python3 -c "from jose import jwt; print(jwt.decode('token_here', 'secret_key_here', algorithms=['HS256']))"
```

**Fix**:
- Token expired → Refresh token
- Invalid signature → Re-login
- Missing org_id → Re-authenticate

### 429 Too Many Requests

**Check**: Rate limit headers

```bash
curl -v https://api.nexora.ai/api/v1/leads 2>&1 | grep -i rate
# X-RateLimit-Limit: 120
# X-RateLimit-Remaining: 45
```

**Fix**:
- Reduce request rate
- Check if Redis is available (rate limiter fails open when Redis is down)
- Increase rate limits in nginx.conf or rate_limit.py

## Database Issues

### Connection pool exhausted

**Check**:
```bash
kubectl exec deployment/nexora-postgres -n nexora -- psql -c "SELECT count(*) FROM pg_stat_activity;"
kubectl exec deployment/nexora-postgres -n nexora -- psql -c "SELECT state, count(*) FROM pg_stat_activity GROUP BY state;"
```

**Fix**:
- Increase pool_size in connection.py
- Restart brain pods to release idle connections
- Kill long-running queries: `SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE state = 'idle in transaction';`

### Slow queries

**Check**:
```sql
SELECT query, calls, total_time/calls as avg_time, rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;
```

**Fix**:
- Add missing indexes
- Optimize query patterns
- Add query caching with Redis
- Denormalize for read-heavy patterns

## Infrastructure Issues

### Pod CrashLoopBackOff

```bash
kubectl describe pod <pod> -n nexora
kubectl logs <pod> -n nexora --previous
```

**Common causes**:
- Missing secrets
- Database connection failure at startup
- OOMKilled (memory limit too low)
- Configuration error

### Disk pressure

```bash
kubectl exec deployment/nexora-postgres -n nexora -- df -h
# Check WAL directory size
```

**Fix**:
- Remove old WAL files
- Run `VACUUM FULL` on PostgreSQL
- Increase PVC size
- Enable retention-based cleanup

## LLM Issues

### Ollama unavailable

**Check**:
```bash
curl http://nexora-ollama:11434/api/tags
kubectl logs deployment/nexora-ollama -n nexora --tail=20
```

**Fix**:
- Restart Ollama pod
- Check GPU availability (if GPU-accelerated)
- Check disk space for model storage
- Models automatically download on first request

### LLM response timeout

**Check**:
- Is model loaded? (first request loads model)
- Is Ollama under memory pressure?

**Fix**:
- Increase OLLAMA_TIMEOUT in config
- Pre-load model at startup
- Add more RAM to Ollama pod
- Use smaller model (llama3:8b vs llama3:70b)
