# PERFORMANCE_BENCHMARK.md

## Phase F — Performance Benchmark

### Date: 2026-07-02

---

## Note

Performance benchmarks require a running system with all dependencies (PostgreSQL, Redis, Qdrant, Ollama). The numbers below are estimated based on the codebase analysis.

---

## Estimated Latencies

| Operation | Estimated Latency | Notes |
|---|---|---|
| Brain startup | ~5-10s | DB migrations + Redis init |
| Agent registration | ~50-100ms | DB write + audit log |
| Agent heartbeat | ~30-60ms | DB write + health update |
| Health check (root) | ~10-30ms | DB ping + Redis ping |
| Health check (detailed) | ~20-50ms | DB + Redis + version |
| Metrics endpoint | ~50-200ms | Multiple DB queries |

---

## Bottlenecks Identified

| Bottleneck | Impact | Mitigation |
|---|---|---|
| Double `db.commit()` pattern | ~2x DB round-trips per mutation | Audit log committed separately |
| No DB connection pooling config | Default pool size | Already configured in `connection.py` |
| SentenceTransformer model loading | ~5-10s cold start | Loaded once at startup |

---

## Recommendations

1. **Batch audit commits** — combine entity + audit into single transaction
2. **Add Redis caching** for health checks
3. **Profile heartbeat under load** — each heartbeat creates a new `AgentHeartbeat` row (append-only table)

---

## Measuring in Production

```bash
# Time registration
time curl -X POST http://localhost:8000/api/v1/agents/register \
  -H "X-Agent-Key: your-key" \
  -H "Content-Type: application/json" \
  -d '{"agent_id":"test","agent_name":"test","agent_type":"whatsapp","capabilities":[]}'

# Time heartbeat
time curl -X POST http://localhost:8000/api/v1/agents/heartbeat \
  -H "X-Agent-Key: your-key" \
  -H "Content-Type: application/json" \
  -d '{"agent_id":"test","status":"online"}'
```
