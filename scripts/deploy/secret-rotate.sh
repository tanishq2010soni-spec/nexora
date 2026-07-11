#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# NEXORA Secret Rotation
# =============================================================================
# Usage: ./scripts/deploy/secret-rotate.sh [--key-type jwt|all]
# =============================================================================

NAMESPACE="${NAMESPACE:-nexora}"
KEY_TYPE="${1:-all}"

echo "=== Nexora Secret Rotation ==="

rotate_jwt() {
    echo "Rotating JWT_SECRET_KEY..."
    NEW_SECRET=$(openssl rand -hex 32)
    kubectl patch secret nexora-brain-secrets -n "$NAMESPACE" \
        -p "{\"stringData\":{\"JWT_SECRET_KEY\":\"$NEW_SECRET\"}}"
    echo "JWT_SECRET_KEY rotated"
}

rotate_db() {
    echo "Rotating DATABASE_URL..."
    NEW_PASS=$(openssl rand -hex 16)
    NEW_URL="postgresql+asyncpg://nexora:${NEW_PASS}@nexora-postgres:5432/nexora"

    kubectl patch secret nexora-postgres-secret -n "$NAMESPACE" \
        -p "{\"stringData\":{\"POSTGRES_PASSWORD\":\"$NEW_PASS\"}}"
    kubectl patch secret nexora-brain-secrets -n "$NAMESPACE" \
        -p "{\"stringData\":{\"DATABASE_URL\":\"$NEW_URL\"}}"
    echo "DATABASE_URL rotated"
}

rotate_agent_key() {
    echo "Rotating AGENT_REGISTRATION_KEY..."
    NEW_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
    kubectl patch secret nexora-brain-secrets -n "$NAMESPACE" \
        -p "{\"stringData\":{\"AGENT_REGISTRATION_KEY\":\"$NEW_KEY\"}}"
    echo "AGENT_REGISTRATION_KEY rotated"
}

rotate_provider_encryption() {
    echo "Rotating PROVIDER_ENCRYPTION_KEY..."
    NEW_KEY=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")
    kubectl patch secret nexora-brain-secrets -n "$NAMESPACE" \
        -p "{\"stringData\":{\"PROVIDER_ENCRYPTION_KEY\":\"$NEW_KEY\"}}"
    echo "PROVIDER_ENCRYPTION_KEY rotated"
}

case "$KEY_TYPE" in
    jwt)
        rotate_jwt
        ;;
    db)
        rotate_db
        ;;
    agent)
        rotate_agent_key
        ;;
    encryption)
        rotate_provider_encryption
        ;;
    all)
        rotate_jwt
        rotate_db
        rotate_agent_key
        rotate_provider_encryption
        ;;
    *)
        echo "Usage: $0 [--key-type jwt|db|agent|encryption|all]"
        exit 1
        ;;
esac

# ─── Rolling restart to pick up new secrets ──────────────────────────────
echo "Restarting brain pods to pick up new secrets..."
kubectl rollout restart deployment/nexora-brain-blue -n "$NAMESPACE"
kubectl rollout restart deployment/nexora-brain-green -n "$NAMESPACE"
kubectl rollout status deployment/nexora-brain-blue -n "$NAMESPACE" --timeout=5m
kubectl rollout status deployment/nexora-brain-green -n "$NAMESPACE" --timeout=5m

echo "Secret rotation complete"
