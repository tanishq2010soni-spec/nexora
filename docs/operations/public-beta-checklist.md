# Public Beta Readiness Checklist

## CI/CD
- [ ] GitHub Actions CI workflows created (`.github/workflows/ci.yml`)
- [ ] Lint job passes (black, isort, ruff, flake8)
- [ ] Type checking job passes (pyright, mypy)
- [ ] Security scan job passes (bandit, safety, semgrep)
- [ ] Dependency scan job passes (pip-audit, trivy)
- [ ] Tests pass on Python 3.11 and 3.12
- [ ] Coverage gate: ≥ 85% enforced
- [ ] Migration validation: up/down/up tested
- [ ] Docker build succeeds
- [ ] OpenAPI schema change detection
- [ ] Deployment workflow (`.github/workflows/deploy.yml`)
- [ ] Security workflow (`.github/workflows/security.yml`)
- [ ] Nightly workflow (`.github/workflows/nightly.yml`)
- [ ] Gitleaks config (`.github/gitleaks.toml`)

## Kubernetes
- [ ] Namespace defined (`k8s/namespace/namespace.yml`)
- [ ] ConfigMaps created (`k8s/configmap/`)
- [ ] Secret template created (`k8s/secret/secret-template.yml`)
- [ ] Brain deployment (blue/green) (`k8s/deployment/brain-blue.yml`)
- [ ] PostgreSQL StatefulSet (`k8s/deployment/postgres.yml`)
- [ ] Redis deployment (`k8s/deployment/redis.yml`)
- [ ] Qdrant deployment (`k8s/deployment/qdrant.yml`)
- [ ] Ollama deployment (`k8s/deployment/ollama.yml`)
- [ ] Services created (`k8s/service/`)
- [ ] Ingress with TLS (`k8s/ingress/brain-ingress.yml`)
- [ ] HPA configured (`k8s/hpa/brain-hpa.yml`)
- [ ] PDB created (`k8s/pdb/`)
- [ ] NetworkPolicies (default-deny) (`k8s/network-policy/`)
- [ ] ServiceMonitor for Prometheus (`k8s/servicemonitor/`)

## Monitoring
- [ ] Prometheus running (`monitoring/prometheus/prometheus.yml`)
- [ ] Alert rules created (`monitoring/prometheus/rules/nexora-alerts.yml`)
- [ ] Grafana provisioned (`monitoring/grafana/provisioning/`)
- [ ] Platform overview dashboard (`monitoring/grafana/dashboards/nexora-platform-overview.json`)
- [ ] Database dashboard (`monitoring/grafana/dashboards/nexora-database.json`)
- [ ] LLM dashboard (`monitoring/grafana/dashboards/nexora-llm.json`)
- [ ] Alertmanager configured (`monitoring/alertmanager/alertmanager.yml`)
- [ ] Alert templates created (`monitoring/alertmanager/templates/`)
- [ ] Loki configured (`monitoring/loki/loki.yml`)
- [ ] Promtail configured (`monitoring/promtail/promtail.yml`)
- [ ] OpenTelemetry Collector configured (`monitoring/otel-collector/otel-collector.yml`)
- [ ] Node Exporter deployed
- [ ] cAdvisor deployed
- [ ] Monitoring stack docker-compose (`docker-compose.monitoring.yml`)
- [ ] Alert routes configured (Slack / PagerDuty)
- [ ] Metrics endpoint accessible without auth (`/metrics`)

## Metrics & Observability
- [ ] HTTP request count (by method, path, status)
- [ ] HTTP request duration (histogram with buckets)
- [ ] HTTP request/response size
- [ ] HTTP active requests gauge
- [ ] DB query duration (by operation, table)
- [ ] DB connection pool gauge
- [ ] Redis operation duration
- [ ] LLM request count (by model, operation, status)
- [ ] LLM request duration (histogram with buckets)
- [ ] LLM token usage counter
- [ ] LLM health gauge
- [ ] Business metrics (leads, customers, conversations, revenue)
- [ ] Tenant and agent count
- [ ] Queue depth and worker status
- [ ] System metrics (CPU, memory, disk, uptime)

## Distributed Tracing
- [ ] OpenTelemetry SDK initialized (`src/infrastructure/telemetry/tracing.py`)
- [ ] FastAPI instrumented
- [ ] SQLAlchemy instrumented
- [ ] httpx instrumented
- [ ] Redis instrumented
- [ ] Logging instrumented
- [ ] Traces exported to Tempo/OTLP endpoint
- [ ] Trace context propagated via HTTP headers

## Load Testing
- [ ] k6 smoke test (`load-testing/k6/smoke-test.js`)
- [ ] k6 load test (`load-testing/k6/load-test.js`)
- [ ] k6 stress test (`load-testing/k6/stress-test.js`)
- [ ] k6 spike test (`load-testing/k6/spike-test.js`)
- [ ] k6 soak test (`load-testing/k6/soak-test.js`)
- [ ] Performance regression check (`load-testing/k6/check-regression.py`)
- [ ] Locust test (`load-testing/locust/locustfile.py`)
- [ ] Load test executed with 100 concurrent users (p95 < 2s)
- [ ] Load test executed with 500 concurrent users (p95 < 5s)
- [ ] Soak test executed for 4 hours (no degradation)
- [ ] Spike test executed (survives 3000 concurrent connections)

## Disaster Recovery
- [ ] Daily pg_dump backup script (`scripts/backup.py`)
- [ ] WAL archiving configured (`scripts/backup/postgres-wal.sh`)
- [ ] Base backup script (`pg-base-backup.sh`)
- [ ] Restore verification script (`scripts/backup/restore-verify.sh`)
- [ ] Backup cron installed
- [ ] Backup retention policy configured
- [ ] Restore tested and verified
- [ ] RPO ≤ 1 hour documented
- [ ] RTO ≤ 30 minutes documented
- [ ] DR runbook documented

## Deployment
- [ ] Blue/green deployment script (`scripts/deploy/blue-green-deploy.sh`)
- [ ] Rollback script (`scripts/deploy/rollback.sh`)
- [ ] Migration script (`scripts/deploy/migrate.sh`)
- [ ] Secret rotation script (`scripts/deploy/secret-rotate.sh`)
- [ ] Zero-downtime deployment verified
- [ ] Rollback tested

## Security
- [ ] JWT access token expiry (15 min)
- [ ] JWT refresh token with rotation
- [ ] Password policy enforced
- [ ] Rate limiting at nginx (30/5 req/s)
- [ ] Rate limiting at application layer
- [ ] CORS restricted
- [ ] Security headers on all responses
- [ ] Request size limit (10 MB)
- [ ] Webhook signature verification
- [ ] Tenant isolation verified
- [ ] Role-based access control
- [ ] Fernet provider key encryption
- [ ] Docker secrets / K8s secrets
- [ ] Secret rotation procedure
- [ ] TLS certificates configured
- [ ] Network policies (default-deny)
- [ ] GitLeaks scanning in CI

## Documentation
- [ ] Architecture guide (`docs/architecture/overview.md`)
- [ ] Developer guide (`docs/development/guide.md`)
- [ ] Deployment guide (`docs/operations/deployment-guide.md`)
- [ ] Operations manual (`docs/operations/runbook.md`)
- [ ] Incident response guide (`docs/operations/incident-response.md`)
- [ ] SRE runbook (`docs/operations/sre-runbook.md`)
- [ ] Security runbook (`docs/security/runbook.md`)
- [ ] Upgrade guide (`docs/operations/upgrade-guide.md`)
- [ ] Backup guide (`docs/operations/backup-guide.md`)
- [ ] Troubleshooting guide (`docs/operations/troubleshooting.md`)
- [ ] Installation guide (`release/INSTALLATION_GUIDE.md`)
- [ ] Changelog (`release/CHANGELOG.md`)

## Verification
- [ ] 148+ tests passing
- [ ] Coverage ≥ 85%
- [ ] All lint checks passing
- [ ] All type checks passing
- [ ] Security scans passing
- [ ] Docker build succeeding
- [ ] Migration up/down verified
- [ ] Health endpoint returning healthy
- [ ] Metrics endpoint returning data
- [ ] Kubernetes manifests validate
- [ ] Load test KPIs met
- [ ] Backup and restore verified
- [ ] Blue/green deployment verified
- [ ] Rollback verified
- [ ] Secret rotation verified
- [ ] Alert rules firing correctly
- [ ] Grafana dashboards rendering
- [ ] Logs flowing to Loki
- [ ] Traces flowing to Tempo
