# Operations Manual

## Service Architecture

```
nexora-brain      (FastAPI, 4 workers, port 8000)
nexora-postgres   (PostgreSQL 15, port 5432)
nexora-redis      (Redis 7, port 6379)
nexora-qdrant     (Qdrant 1.9, port 6333)
nexora-ollama     (Ollama 0.3, port 11434)
nexora-nginx      (nginx, ports 80/443)
```

## Common Operations

### View service status

```bash
# Docker
docker compose ps

# Kubernetes
kubectl get pods -n nexora
kubectl get svc -n nexora
```

### View logs

```bash
# Docker
docker compose logs -f --tail=100 brain
docker compose logs -f --tail=50 postgres

# Kubernetes
kubectl logs -f deployment/nexora-brain-blue -n nexora
kubectl logs -f deployment/nexora-brain-blue -n nexora --tail=100

# Loki (via Grafana)
# Query: {job="nexora-brain"} |= "ERROR"
```

### Restart a service

```bash
# Docker
docker compose restart brain

# Kubernetes
kubectl rollout restart deployment/nexora-brain-blue -n nexora
kubectl rollout status deployment/nexora-brain-blue -n nexora --timeout=5m
```

### Scale

```bash
# Docker
docker compose up -d --scale brain=5

# Kubernetes
kubectl scale deployment/nexora-brain-blue --replicas=5 -n nexora

# HPA (automatic)
kubectl get hpa -n nexora
```

### Database

```bash
# Connect
docker compose exec postgres psql -U postgres -d nexora

# Run migrations
docker compose exec brain alembic upgrade head

# Check migration status
docker compose exec brain alembic history

# Backup
docker compose exec brain python scripts/backup.py
```

## Monitoring

| Tool | URL | Credentials |
|------|-----|-------------|
| Prometheus | http://monitor.nexora.ai:9090 | Internal only |
| Grafana | https://monitor.nexora.ai | Admin / admin |
| Alertmanager | http://monitor.nexora.ai:9093 | Internal only |
| Health | https://api.nexora.ai/health | Public |
| Metrics | https://api.nexora.ai/metrics | Public |

## Backup Schedule

| Backup | Frequency | Retention | Type |
|--------|-----------|-----------|------|
| PostgreSQL (pg_dump) | Daily 02:00 UTC | 30 days | Full |
| PostgreSQL (WAL) | Continuous | 7 days | Incremental |
| Qdrant snapshot | Daily 02:30 UTC | 30 days | Full |
| Base backup | Weekly 03:00 UTC Sun | 4 weeks | Full |
| Config & secrets | Daily | 90 days | Git |

## Capacity Planning

| Resource | Current | Limit | Scaling Action |
|----------|---------|-------|----------------|
| Brain CPU | 0.5-1.5 core | 2 cores | Increase HPA max |
| Brain Memory | 256-512 MB | 2 GB | Increase limit |
| Brain Replicas | 3 | 10 (HPA) | Add more replicas |
| PG Connections | 20-50 | 200 | Pool increase |
| PG Storage | 10 GB | 50 GB | PVC expansion |
| Redis Memory | 100 MB | 400 MB | Cluster mode |
| Qdrant Storage | 5 GB | 50 GB | Shard replication |
