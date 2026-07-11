# Upgrade Guide

## Version Upgrade Procedure

### 1. Pre-Upgrade

```bash
# Backup database
python scripts/backup.py --type db

# Check current migration state
kubectl exec deployment/nexora-brain-blue -n nexora -- alembic history

# Review release notes
cat release/CHANGELOG.md
```

### 2. Database Migration (if applicable)

```bash
# Generate migration
alembic revision --autogenerate -m "description_of_change"

# Review migration SQL
alembic upgrade head --sql

# Test migration on staging
# Deploy to staging → verify → deploy to production
```

### 3. Rolling Upgrade (Docker Compose)

```bash
git pull origin main
docker compose pull brain
docker compose up -d --no-deps --scale brain=1 brain
sleep 10
curl -f http://localhost:8000/health
# If healthy, scale up
docker compose up -d --no-deps --scale brain=4 brain
```

### 4. Blue/Green Upgrade (Kubernetes)

```bash
# Deploy new version to inactive color
bash scripts/deploy/blue-green-deploy.sh ghcr.io/nexora/nexora:new-version

# If successful, old deployment is scaled to 0
# If failed, traffic stays on active color
```

### 5. Post-Upgrade

```bash
# Verify health
curl https://api.nexora.ai/health

# Run smoke tests
python -m pytest tests/e2e/ -v

# Monitor for 15 minutes
# Check Grafana for error rate and latency changes
```

## Upgrade Types

| Type | Downtime | Risk | Procedure |
|------|----------|------|-----------|
| Patch (1.0.0 → 1.0.1) | Zero | Low | Rolling update |
| Minor (1.0 → 1.1) | Zero | Medium | Blue/green |
| Major (1 → 2) | Minutes | High | Blue/green + backup |
| Database schema | Read-only | Medium | Blue/green + migration |
| Infrastructure | Zero | Low | Blue/green |
| Dependencies | Zero | Low | Rolling update |
