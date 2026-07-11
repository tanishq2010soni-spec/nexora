# SRE Runbook

## SLIs and SLOs

| SLI | SLO Target | Measurement |
|-----|-----------|-------------|
| API Availability | 99.9% | Health endpoint, 5xx rate |
| API Latency (p95) | < 2s | Prometheus histograms |
| API Latency (p99) | < 5s | Prometheus histograms |
| Error Rate | < 1% | 5xx / total requests |
| Database Uptime | 99.95% | pg_up metric |
| Database Latency (p95) | < 100ms | DB query duration |
| LLM Latency (p95) | < 30s | LLM request duration |
| Cache Hit Rate | > 80% | Redis keyspace hits/misses |

## Key Metrics

### Request Volume

```promql
# Total requests per second
rate(nexora_http_requests_total[5m])

# By status code
rate(nexora_http_requests_total{status_code="5xx"}[5m])

# Active requests
nexora_http_active_requests
```

### Latency

```promql
# p95 latency by endpoint
histogram_quantile(0.95, rate(nexora_http_request_duration_seconds_bucket[5m]))

# p99 latency
histogram_quantile(0.99, rate(nexora_http_request_duration_seconds_bucket[5m]))
```

### Resource Usage

```promql
# CPU by pod
avg by (pod) (rate(container_cpu_usage_seconds_total[5m]))

# Memory by pod
avg by (pod) (container_memory_usage_bytes)
```

### Database

```promql
# Connections
pg_stat_activity_count

# Cache hit ratio
rate(pg_stat_database_blks_hit[5m]) / (rate(pg_stat_database_blks_hit[5m]) + rate(pg_stat_database_blks_read[5m]))
```

## Runbooks by Alert

### BrainDown

1. Identify which instance: `kubectl get pods -n nexora | grep brain`
2. Check logs: `kubectl logs <pod> -n nexora --tail=50`
3. Restart: `kubectl rollout restart deployment/nexora-brain-blue -n nexora`
4. Verify: `curl https://api.nexora.ai/health`

### HighErrorRate (> 5%)

1. Check Grafana error rate dashboard
2. Check logs for ERROR level
3. Check upstream dependencies
4. If code issue, rollback: `scripts/deploy/rollback.sh`
5. If dependency issue, restart dependency

### HighLatency (p95 > 5s)

1. Identify slow endpoints in Grafana
2. Check database query performance
3. Check LLM response times
4. Scale up: `kubectl scale deployment/nexora-brain-blue --replicas=8 -n nexora`
5. Consider enabling query caching

### PostgresDown

1. Check PG pod: `kubectl get pods -n nexora | grep postgres`
2. Check PG logs: `kubectl logs deployment/nexora-postgres -n nexora --tail=50`
3. Check disk space: `kubectl exec deployment/nexora-postgres -n nexora -- df -h`
4. Restart: `kubectl rollout restart statefulset/nexora-postgres -n nexora`
5. If data corruption, restore from backup

### RedisMemoryHigh (> 85%)

1. Check Redis memory: `kubectl exec deployment/nexora-redis -n nexora -- redis-cli INFO memory`
2. Identify large keys: `redis-cli --bigkeys`
3. Flush if necessary: `redis-cli FLUSHALL` (cache only, will be rebuilt)
4. Increase maxmemory in config

## Maintenance Windows

| Activity | Frequency | Expected Impact | Window |
|----------|-----------|----------------|--------|
| Secret rotation | Quarterly | Rolling restart (30s) | Sun 04:00 UTC |
| Database migration | As needed | Read-only (blue/green) | Anytime |
| OS patching | Monthly | Pod restart | Sun 04:00 UTC |
| Certificate renewal | Every 60d | None (auto) | - |
| Backup verification | Daily | None | 05:00 UTC |

## On-Call Checklist

### Daily
- [ ] Check all alerts in last 24h
- [ ] Verify health endpoint: `curl https://api.nexora.ai/health`
- [ ] Check Prometheus targets are all UP
- [ ] Review error logs in Loki
- [ ] Check disk usage

### Weekly
- [ ] Review capacity metrics (CPU, memory, storage)
- [ ] Check backup logs
- [ ] Review failed CI runs
- [ ] Check dependency vulnerabilities

### Monthly
- [ ] Review incident post-mortems
- [ ] Test restore from backup
- [ ] Rotate secrets
- [ ] Review and update runbooks
- [ ] Capacity planning review
