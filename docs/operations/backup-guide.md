# Backup & Disaster Recovery Guide

## Backup Schedule

| Backup Type | Frequency | Retention | Storage | Tool |
|-------------|-----------|-----------|---------|------|
| PostgreSQL (pg_dump) | Daily 02:00 UTC | 30 days | Local + S3 | `scripts/backup.py` |
| PostgreSQL (WAL) | Continuous | 7 days | Local | WAL archiving |
| PostgreSQL (Base) | Weekly Sun 03:00 UTC | 4 weeks | Local + S3 | `pg-base-backup.sh` |
| Qdrant Snapshot | Daily 02:30 UTC | 30 days | Local + S3 | `scripts/backup.py` |
| Uploaded Documents | Daily 03:00 UTC | 30 days | S3 | `scripts/backup.py` |
| Config & Secrets | On change | 90 days | Git | `git` |
| Grafana Dashboards | On change | 90 days | Git | `git` |

## Recovery Objectives

| Metric | Target |
|--------|--------|
| RPO (Recovery Point Objective) | 1 hour (WAL) |
| RTO (Recovery Time Objective) | 30 minutes |
| RTO (Full restore) | 2 hours |
| RTO (Point-in-time) | 1 hour |

## Backup Verification

Daily automated verification:
1. Restore latest backup to verification database
2. Run `alembic upgrade head` to verify migration compatibility
3. Run row count comparison
4. Send report to #ops channel

## Disaster Recovery Scenarios

### Scenario A: Database corruption

**RPO**: 1 hour | **RTO**: 30 minutes

```bash
# 1. Stop application
kubectl scale deployment/nexora-brain-blue --replicas=0 -n nexora

# 2. Find latest valid backup
ls -lt /var/backups/nexora/db_*.sql.gz

# 3. Restore
PGPASSWORD=$DB_PASS pg_restore -h localhost -U nexora -d nexora \
    --clean --if-exists /var/backups/nexora/db_20260703_020000.sql.gz

# 4. Apply WAL
# (Replay WAL files from archive)

# 5. Start application
kubectl scale deployment/nexora-brain-blue --replicas=3 -n nexora
```

### Scenario B: Full region failure

**RTO**: 2 hours | **RPO**: 1 hour

1. Provision new cluster in secondary region
2. Restore PostgreSQL from S3 backup
3. Restore Qdrant from S3 snapshot
4. Deploy brain with `kubectl apply -f k8s/`
5. Update DNS to point to new ingress
6. Run smoke tests

### Scenario C: Accidental data deletion

**RTO**: 1 hour | **RPO**: Point-in-time

1. Determine time of deletion
2. Perform PITR to just before deletion
3. Extract lost data
4. Merge into production database
5. Verify data integrity

## Backup Commands

```bash
# Full backup (daily)
docker compose exec brain python scripts/backup.py --type all

# Database only
docker compose exec brain python scripts/backup.py --type db

# Qdrant only
docker compose exec brain python scripts/backup.py --type qdrant

# With custom retention
docker compose exec brain python scripts/backup.py --retention 7

# Upload to S3
docker compose exec brain python scripts/backup.py --s3-bucket nexora-backups

# WAL base backup
bash scripts/backup/pg-base-backup.sh

# Verify restore
bash scripts/backup/restore-verify.sh /var/backups/nexora/db_20260703_020000.sql.gz
```

## Cron Configuration

```cron
# Daily full backup at 2 AM
0 2 * * * cd /app && python scripts/backup.py --type all >> /var/log/nexora/backup.log 2>&1

# Weekly base backup at 3 AM Sunday
0 3 * * 0 /usr/local/bin/pg-base-backup.sh >> /var/log/nexora/backup.log 2>&1

# Backup verification at 5 AM daily
0 5 * * * bash /app/scripts/backup/restore-verify.sh /var/backups/nexora/db_latest.sql.gz >> /var/log/nexora/verify.log 2>&1
```
