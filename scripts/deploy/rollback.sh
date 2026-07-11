#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# NEXORA Rollback Script
# =============================================================================
# Usage: ./scripts/deploy/rollback.sh [--color blue|green]
#   --color: Target color to rollback (optional, defaults to inactive)
# =============================================================================

NAMESPACE="${NAMESPACE:-nexora}"
TARGET_COLOR="${1:-}"

echo "=== Nexora Rollback ==="

# ─── Determine current active color ──────────────────────────────────────
ACTIVE=$(kubectl get svc nexora-brain -n "$NAMESPACE" -o jsonpath='{.spec.selector.color}' 2>/dev/null || echo "blue")

if [ -z "$TARGET_COLOR" ]; then
    # Rollback the inactive deployment to its previous revision
    if [ "$ACTIVE" = "blue" ]; then
        TARGET="green"
    else
        TARGET="blue"
    fi
    echo "Rolling back inactive deployment: $TARGET"
    kubectl rollout undo "deployment/nexora-brain-$TARGET" -n "$NAMESPACE"
    kubectl rollout status "deployment/nexora-brain-$TARGET" -n "$NAMESPACE" --timeout=5m
    kubectl scale "deployment/nexora-brain-$TARGET" --replicas=3 -n "$NAMESPACE"
else
    echo "Rolling back $TARGET_COLOR"
    kubectl rollout undo "deployment/nexora-brain-$TARGET_COLOR" -n "$NAMESPACE"
    kubectl rollout status "deployment/nexora-brain-$TARGET_COLOR" -n "$NAMESPACE" --timeout=5m
    kubectl scale "deployment/nexora-brain-$TARGET_COLOR" --replicas=3 -n "$NAMESPACE"
fi

echo "Rollback complete"
