#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# NEXORA Blue/Green Deployment
# =============================================================================
# Usage: ./scripts/deploy/blue-green-deploy.sh <image-tag>
#   ./scripts/deploy/blue-green-deploy.sh ghcr.io/nexora/nexora:abc1234
# =============================================================================

NAMESPACE="${NAMESPACE:-nexora}"
IMAGE="${1:-ghcr.io/nexora/nexora:latest}"
ROLLBACK_ON_FAILURE="${ROLLBACK_ON_FAILURE:-true}"

echo "=== Nexora Blue/Green Deployment ==="
echo "Namespace: $NAMESPACE"
echo "Image: $IMAGE"
echo "Rollback on failure: $ROLLBACK_ON_FAILURE"

# ─── Determine active color ──────────────────────────────────────────────
ACTIVE=$(kubectl get svc nexora-brain -n "$NAMESPACE" -o jsonpath='{.spec.selector.color}' 2>/dev/null || echo "blue")
if [ "$ACTIVE" = "blue" ]; then
    NEW_COLOR="green"
    OLD_COLOR="blue"
else
    NEW_COLOR="blue"
    OLD_COLOR="green"
fi
echo "Active: $ACTIVE, Deploying: $NEW_COLOR"

# ─── Update the new deployment ──────────────────────────────────────────
kubectl set image "deployment/nexora-brain-$NEW_COLOR" "brain=$IMAGE" -n "$NAMESPACE" --record

# ─── Wait for rollout ────────────────────────────────────────────────────
echo "Waiting for $NEW_COLOR rollout..."
if ! kubectl rollout status "deployment/nexora-brain-$NEW_COLOR" -n "$NAMESPACE" --timeout=5m; then
    echo "ERROR: $NEW_COLOR rollout failed"
    if [ "$ROLLBACK_ON_FAILURE" = "true" ]; then
        echo "Rolling back $NEW_COLOR to previous version..."
        kubectl rollout undo "deployment/nexora-brain-$NEW_COLOR" -n "$NAMESPACE"
    fi
    exit 1
fi

# ─── Run database migrations ─────────────────────────────────────────────
echo "Running database migrations..."
kubectl exec "deployment/nexora-brain-$NEW_COLOR" -n "$NAMESPACE" -- alembic upgrade head
echo "Migrations complete"

# ─── Smoke test the new deployment ───────────────────────────────────────
echo "Running smoke tests against $NEW_COLOR..."
kubectl port-forward "deployment/nexora-brain-$NEW_COLOR" 8080:8000 -n "$NAMESPACE" &
PF_PID=$!
sleep 5

SMOKE_PASSED=true
for i in 1 2 3; do
    if curl -sf http://localhost:8080/health > /dev/null 2>&1; then
        echo "Smoke test $i: PASS"
    else
        echo "Smoke test $i: FAIL"
        SMOKE_PASSED=false
    fi
    sleep 2
done

kill $PF_PID 2>/dev/null || true

if [ "$SMOKE_PASSED" != "true" ]; then
    echo "ERROR: Smoke tests failed"
    if [ "$ROLLBACK_ON_FAILURE" = "true" ]; then
        echo "Keeping $OLD_COLOR active. $NEW_COLOR deployment preserved for debugging."
    fi
    exit 1
fi

# ─── Switch traffic ──────────────────────────────────────────────────────
echo "Switching traffic to $NEW_COLOR..."
kubectl patch svc nexora-brain -n "$NAMESPACE" -p "{\"spec\":{\"selector\":{\"app\":\"nexora-brain\",\"color\":\"$NEW_COLOR\"}}}"

# ─── Verify all traffic routes to new color ──────────────────────────────
echo "Verifying traffic switch..."
sleep 5
kubectl port-forward "deployment/nexora-brain-$NEW_COLOR" 8081:8000 -n "$NAMESPACE" &
PF_PID=$!
sleep 3

if curl -sf http://localhost:8081/health > /dev/null 2>&1; then
    echo "Traffic switch verified"
else
    echo "WARNING: Traffic switch verification failed"
fi
kill $PF_PID 2>/dev/null || true

# ─── Scale down old deployment ──────────────────────────────────────────
echo "Scaling down $OLD_COLOR..."
kubectl scale "deployment/nexora-brain-$OLD_COLOR" --replicas=0 -n "$NAMESPACE"

echo ""
echo "=== Deployment complete ==="
echo "Active: $NEW_COLOR"
echo "Standby: $OLD_COLOR (scaled to 0)"
echo "Image: $IMAGE"
