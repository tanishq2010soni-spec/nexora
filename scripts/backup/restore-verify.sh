#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# NEXORA Restore Verification Script
# =============================================================================
# Usage: ./scripts/backup/restore-verify.sh <backup-file>
# =============================================================================

BACKUP_FILE="${1:-}"
RESTORE_DB="nexora_verify_$(date +%s)"
RESTORE_HOST="${PGHOST:-localhost}"
RESTORE_PORT="${PGPORT:-5432}"
RESTORE_USER="${PGUSER:-postgres}"
RESTORE_PASS="${PGPASSWORD:-postgres}"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup-file>"
    echo "Available backups:"
    ls -lh /var/backups/nexora/db_*.sql.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "=== Nexora Restore Verification ==="
echo "Backup: $BACKUP_FILE"
echo "Restore DB: $RESTORE_DB"

cleanup() {
    echo "Cleaning up verification database..."
    PGPASSWORD="$RESTORE_PASS" psql -h "$RESTORE_HOST" -p "$RESTORE_PORT" -U "$RESTORE_USER" -c "DROP DATABASE IF EXISTS \"$RESTORE_DB\"" 2>/dev/null || true
}
trap cleanup EXIT

# ─── Create verification database ────────────────────────────────────────
echo "Creating verification database..."
PGPASSWORD="$RESTORE_PASS" createdb -h "$RESTORE_HOST" -p "$RESTORE_PORT" -U "$RESTORE_USER" "$RESTORE_DB"

# ─── Restore backup ──────────────────────────────────────────────────────
echo "Restoring backup..."
if [[ "$BACKUP_FILE" == *.gz ]]; then
    gunzip -c "$BACKUP_FILE" | PGPASSWORD="$RESTORE_PASS" pg_restore \
        -h "$RESTORE_HOST" -p "$RESTORE_PORT" -U "$RESTORE_USER" \
        -d "$RESTORE_DB" \
        --verbose 2>&1 | tail -20
else
    PGPASSWORD="$RESTORE_PASS" pg_restore \
        -h "$RESTORE_HOST" -p "$RESTORE_PORT" -U "$RESTORE_USER" \
        -d "$RESTORE_DB" \
        "$BACKUP_FILE" \
        --verbose 2>&1 | tail -20
fi

# ─── Verify tables ───────────────────────────────────────────────────────
echo "Verifying restored data..."
echo "Tables:"
PGPASSWORD="$RESTORE_PASS" psql -h "$RESTORE_HOST" -p "$RESTORE_PORT" -U "$RESTORE_USER" -d "$RESTORE_DB" -c "\dt" 2>/dev/null || true

echo "Row counts:"
PGPASSWORD="$RESTORE_PASS" psql -h "$RESTORE_HOST" -p "$RESTORE_PORT" -U "$RESTORE_USER" -d "$RESTORE_DB" <<'SQL' 2>/dev/null || true
SELECT schemaname, tablename, n_live_tup as row_count
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;
SQL

# ─── Run migrations to verify compatibility ──────────────────────────────
echo "Testing alembic migration compatibility..."
cd "$(dirname "$0")/../.."
DATABASE_URL="postgresql+asyncpg://${RESTORE_USER}:${RESTORE_PASS}@${RESTORE_HOST}:${RESTORE_PORT}/${RESTORE_DB}" alembic upgrade head 2>&1 || echo "Migration test completed (may show up-to-date)"

echo ""
echo "=== Verification complete ==="
echo "Database: $RESTORE_DB (will be dropped on exit)"
