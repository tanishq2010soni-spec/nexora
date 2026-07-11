#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# NEXORA PostgreSQL WAL Archiving & Point-in-Time Recovery
# =============================================================================
# This script configures continuous WAL archiving for point-in-time recovery.
# Run on the PostgreSQL host or mount as an init script.
# =============================================================================

WAL_ARCHIVE_DIR="${WAL_ARCHIVE_DIR:-/var/backups/nexora/wal}"
PG_DATA_DIR="${PG_DATA_DIR:-/var/lib/postgresql/data}"
RETENTION_HOURS="${RETENTION_HOURS:-168}"  # 7 days

mkdir -p "$WAL_ARCHIVE_DIR"

# ─── WAL Archiving Configuration ─────────────────────────────────────────
# Add to postgresql.conf:
# wal_level = replica
# archive_mode = on
# archive_command = '/usr/local/bin/archive-wal.sh %f %p'
# archive_timeout = 60

cat > /usr/local/bin/archive-wal.sh << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
WAL_FILE="$1"
WAL_PATH="$2"
ARCHIVE_DIR="${WAL_ARCHIVE_DIR:-/var/backups/nexora/wal}"

cp "$WAL_PATH" "${ARCHIVE_DIR}/${WAL_FILE}"
gzip "${ARCHIVE_DIR}/${WAL_FILE}"
test -f "${ARCHIVE_DIR}/${WAL_FILE}.gz" && echo "Archived: ${WAL_FILE}" || echo "Failed: ${WAL_FILE}"
SCRIPT

chmod +x /usr/local/bin/archive-wal.sh

# ─── Retention: Remove old WAL files ─────────────────────────────────────
find "$WAL_ARCHIVE_DIR" -name "*.gz" -mtime +$((RETENTION_HOURS / 24)) -delete
echo "WAL retention cleanup complete (${RETENTION_HOURS}h retention)"

# ─── Base Backup Script ──────────────────────────────────────────────────
cat > /usr/local/bin/pg-base-backup.sh << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
BACKUP_DIR="${1:-/var/backups/nexora/base}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

pg_basebackup \
    -D "${BACKUP_DIR}/base_${TIMESTAMP}" \
    -Ft -z \
    -P -v \
    -U postgres \
    -h localhost

echo "Base backup complete: base_${TIMESTAMP}"
# Keep last 7 base backups
ls -dt "${BACKUP_DIR}"/base_* | tail -n +8 | xargs -r rm -rf
SCRIPT

chmod +x /usr/local/bin/pg-base-backup.sh

echo "WAL archiving configured"
echo "Archive dir: $WAL_ARCHIVE_DIR"
echo "Add to postgresql.conf:"
echo "  wal_level = replica"
echo "  archive_mode = on"
echo "  archive_command = '/usr/local/bin/archive-wal.sh %f %p'"
echo "  archive_timeout = 60"
echo ""
echo "Run base backup: pg-base-backup.sh"
echo "PITR restore: pg_ctl -D /var/lib/postgresql/data stop"
echo "  rm -rf /var/lib/postgresql/data"
echo "  pg_basebackup -D /var/lib/postgresql/data -X fetch -P -v"
echo "  Edit postgresql.conf: restore_command = 'cp /var/backups/nexora/wal/%f %p'"
echo "  Create recovery.signal: touch /var/lib/postgresql/data/recovery.signal"
echo "  Set recovery_target_time in postgresql.conf"
echo "  pg_ctl -D /var/lib/postgresql/data start"
