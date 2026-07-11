# Deployment Guide

## Environment Prerequisites

- Kubernetes 1.28+ cluster (EKS, AKS, GKE, or self-managed)
- kubectl configured with cluster access
- cert-manager installed for TLS certificates
- ingress-nginx installed
- Prometheus Operator (kube-prometheus-stack) installed
- Persistent volumes for PostgreSQL, Qdrant, Redis

## Initial Deployment

```bash
# 1. Create namespace
kubectl apply -f k8s/namespace/namespace.yml

# 2. Create secrets (see secret-template.yml for all keys)
kubectl create secret generic nexora-brain-secrets -n nexora \
    --from-literal=JWT_SECRET_KEY=$(openssl rand -hex 32) \
    --from-literal=DATABASE_URL=postgresql+asyncpg://nexora:<pass>@nexora-postgres:5432/nexora \
    --from-literal=AGENT_REGISTRATION_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))") \
    --from-literal=PROVIDER_ENCRYPTION_KEY=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")

kubectl create secret generic nexora-postgres-secret -n nexora \
    --from-literal=POSTGRES_PASSWORD=$(openssl rand -hex 16)

# 3. Apply ConfigMaps
kubectl apply -f k8s/configmap/

# 4. Deploy infrastructure
kubectl apply -f k8s/deployment/postgres.yml
kubectl apply -f k8s/deployment/redis.yml
kubectl apply -f k8s/deployment/qdrant.yml
kubectl apply -f k8s/deployment/ollama.yml

# Wait for infrastructure
kubectl rollout status statefulset/nexora-postgres -n nexora --timeout=5m
kubectl rollout status deployment/nexora-redis -n nexora --timeout=2m
kubectl rollout status deployment/nexora-qdrant -n nexora --timeout=2m

# 5. Apply services
kubectl apply -f k8s/service/

# 6. Deploy brain
kubectl apply -f k8s/deployment/brain-blue.yml

# Wait for brain
kubectl rollout status deployment/nexora-brain-blue -n nexora --timeout=5m

# 7. Run initial database migration
kubectl exec deployment/nexora-brain-blue -n nexora -- alembic upgrade head

# 8. Apply ingress, HPA, PDB, NetworkPolicies
kubectl apply -f k8s/ingress/
kubectl apply -f k8s/hpa/
kubectl apply -f k8s/pdb/
kubectl apply -f k8s/network-policy/

# 9. Verify deployment
curl https://api.nexora.ai/health
```

## Blue/Green Deployment

```bash
# Deploy new version to inactive color
bash scripts/deploy/blue-green-deploy.sh ghcr.io/nexora/nexora:abc1234

# Or via GitHub Actions (recommended)
# Push to main branch → automatic blue/green
```

## Monitoring Stack Deployment

```bash
# Deploy monitoring stack
docker compose -f docker-compose.monitoring.yml up -d

# Or deploy ServiceMonitor for Prometheus Operator
kubectl apply -f k8s/servicemonitor/
```

## Rollback

```bash
# Rollback to previous version
bash scripts/deploy/rollback.sh

# Or manually
kubectl rollout undo deployment/nexora-brain-blue -n nexora
```

## Post-Deployment Verification

```bash
# 1. Health check
curl https://api.nexora.ai/health
curl https://api.nexora.ai/api/v1/health/detailed

# 2. Metrics
curl https://api.nexora.ai/metrics | head -30

# 3. Smoke test
python -m pytest tests/e2e/ -v

# 4. Verify migrations
kubectl exec deployment/nexora-brain-blue -n nexora -- alembic check

# 5. Monitor rollout
kubectl rollout status deployment/nexora-brain-blue -n nexora
```
