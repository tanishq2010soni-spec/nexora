#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# NEXORA Database Migration Script
# =============================================================================
# Usage: ./scripts/deploy/migrate.sh [up|down|check|history]
# =============================================================================

ACTION="${1:-up}"
NAMESPACE="${NAMESPACE:-nexora}"
DEPLOYMENT="${DEPLOYMENT:-nexora-brain-blue}"

echo "=== Nexora Database Migration ==="
echo "Action: $ACTION"
echo "Namespace: $NAMESPACE"
echo "Deployment: $DEPLOYMENT"

case "$ACTION" in
    up)
        echo "Running: alembic upgrade head"
        kubectl exec "deployment/$DEPLOYMENT" -n "$NAMESPACE" -- alembic upgrade head
        echo "Migration complete"
        ;;
    down)
        REVISION="${2:--1}"
        echo "Running: alembic downgrade $REVISION"
        kubectl exec "deployment/$DEPLOYMENT" -n "$NAMESPACE" -- alembic downgrade "$REVISION"
        echo "Downgrade complete"
        ;;
    check)
        echo "Running: alembic check"
        kubectl exec "deployment/$DEPLOYMENT" -n "$NAMESPACE" -- alembic check
        echo "Check complete"
        ;;
    history)
        echo "Running: alembic history"
        kubectl exec "deployment/$DEPLOYMENT" -n "$NAMESPACE" -- alembic history
        ;;
    dry-run)
        echo "Generating SQL (dry run)..."
        kubectl exec "deployment/$DEPLOYMENT" -n "$NAMESPACE" -- alembic upgrade head --sql
        ;;
    *)
        echo "Usage: $0 [up|down|check|history|dry-run]"
        echo ""
        echo "  up           Apply all pending migrations (default)"
        echo "  down <rev>   Rollback N revisions (default: -1)"
        echo "  check        Check if migrations are up to date"
        echo "  history      Show migration history"
        echo "  dry-run      Show SQL without applying"
        exit 1
        ;;
esac
