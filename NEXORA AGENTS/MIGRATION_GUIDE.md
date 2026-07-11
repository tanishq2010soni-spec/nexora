# Migration Guide

**Phase:** E.4 — Unified Authentication & Organization Federation  
**Date:** 2026-07-01

---

## Overview

This guide explains how to migrate from legacy (per-agent) authentication to unified (Nexora-issued) authentication. The migration is non-breaking — both modes work simultaneously.

---

## Migration Modes

| Mode | Description | When to Use |
|------|-------------|-------------|
| `legacy` | Agent uses its own JWT signing | Default, backward compatible |
| `unified` | Agent validates Nexora-issued JWT | After migration complete |

---

## Prerequisites

1. All agents deployed and running
2. `NEXORA_JWT_SECRET` environment variable set on all agents
3. Shared secret must be identical across all agents

---

## Migration Steps

### Step 1: Deploy AuthClient

The shared `AuthClient` is already deployed as part of `nexora_ai`. No action needed.

### Step 2: Set Shared Secret

Set the same JWT secret on all agents:

```bash
# All agents must use the same secret
export NEXORA_JWT_SECRET="your-shared-secret-here"

# Legacy agent-specific secrets (can remain for backward compatibility)
export WA_SECRET_KEY="your-shared-secret-here"
export CA_SECRET_KEY="your-shared-secret-here"
```

### Step 3: Test Unified Mode (Staging)

On a staging environment, switch one agent to unified mode:

```bash
# whatsapp_agent
export WA_AUTH_MODE=unified

# calling_agent
export CA_AUTH_MODE=unified

# personal_ai
export NEXORA_AUTH_MODE=unified
```

### Step 4: Verify SSO Works

1. Login at whatsapp_agent → get token
2. Use same token at calling_agent → should work
3. Use same token at personal_ai → should work

### Step 5: Switch Production Agents

Switch agents one-by-one:

1. Switch whatsapp_agent to `WA_AUTH_MODE=unified`
2. Monitor for 24 hours
3. Switch calling_agent to `CA_AUTH_MODE=unified`
4. Monitor for 24 hours
5. Switch personal_ai to `NEXORA_AUTH_MODE=unified`

### Step 6: Remove Legacy Mode (Optional)

Once all agents are unified and stable:

1. Remove `AUTH_MODE` config (defaults to `unified`)
2. Remove per-agent secret keys
3. Only `NEXORA_JWT_SECRET` remains

---

## Rollback Plan

If unified mode causes issues:

1. Set `AUTH_MODE=legacy` on affected agent
2. Restore per-agent secret keys
3. Agent resumes independent JWT validation

Rollback is instant — no data migration required.

---

## Environment Variables

### Required for Unified Mode

| Variable | Description | Example |
|----------|-------------|---------|
| `NEXORA_JWT_SECRET` | Shared JWT signing secret | `abc123...` |

### Agent-Specific Config

| Agent | Variable | Default | Options |
|-------|----------|---------|---------|
| personal_ai | `NEXORA_AUTH_MODE` | `legacy` | `legacy`, `unified` |
| whatsapp_agent | `WA_AUTH_MODE` | `legacy` | `legacy`, `unified` |
| calling_agent | `CA_AUTH_MODE` | `legacy` | `legacy`, `unified` |

---

## What Changes in Each Agent

### whatsapp_agent

**Before (Legacy):**
- JWT signed with `WA_SECRET_KEY`
- Token contains `sub` (user_id), `org` (org_id)
- No `iss` claim

**After (Unified):**
- JWT signed with `NEXORA_JWT_SECRET`
- Token contains `sub`, `org_id`, `tenant_id`, `role`, `permissions`
- `iss` = "nexora"

### calling_agent

**Before (Legacy):**
- JWT signed with `CA_SECRET_KEY`
- Token contains `sub` (user_id)
- No `org_id` in token

**After (Unified):**
- JWT signed with `NEXORA_JWT_SECRET`
- Token contains `sub`, `org_id`, `tenant_id`, `role`, `permissions`
- `iss` = "nexora"

### personal_ai

**Before (Legacy):**
- API key only (`PERSONAL_AI_API_KEY`)
- No JWT support

**After (Unified):**
- API key still works (backward compatible)
- JWT validation via AuthClient (new capability)
- Both methods work simultaneously

---

## Testing Checklist

- [ ] Login at whatsapp_agent returns valid JWT
- [ ] JWT works at calling_agent (SSO)
- [ ] JWT works at personal_ai (SSO)
- [ ] Token refresh works at all agents
- [ ] RBAC permissions enforced correctly
- [ ] Organization context extracted from token
- [ ] Invalid tokens rejected (401)
- [ ] Expired tokens rejected (401)
- [ ] Wrong issuer rejected (401)
- [ ] Legacy mode still works when `AUTH_MODE=legacy`
- [ ] All existing tests pass

---

## Troubleshooting

### "Invalid token issuer"

**Cause:** Agent is in legacy mode but token has `iss: "nexora"`  
**Fix:** Set `AUTH_MODE=unified` or reissue token without `iss` claim

### "Missing organization ID"

**Cause:** Token doesn't contain `org_id` claim  
**Fix:** Ensure login endpoint includes `org_id` in token payload

### "Insufficient permissions"

**Cause:** User role doesn't have required permission  
**Fix:** Check RBAC matrix, assign appropriate role

### "Organization suspended"

**Cause:** Organization status is not "active"  
**Fix:** Reactivate organization at Nexora Brain

---

## Migration Timeline

| Phase | Duration | Description |
|-------|----------|-------------|
| 1. Deploy AuthClient | Day 0 | Shared auth available |
| 2. Set shared secret | Day 0 | All agents configured |
| 3. Test staging | Day 1-2 | Verify SSO in staging |
| 4. Switch production | Day 3-5 | One agent per day |
| 5. Monitor | Day 6-10 | Watch for issues |
| 6. Remove legacy | Day 11+ | Clean up (optional) |

---

## Support

If you encounter issues during migration:

1. Check agent logs for auth errors
2. Verify `NEXORA_JWT_SECRET` matches across agents
3. Verify `AUTH_MODE` is set correctly
4. Test with a fresh login (don't reuse old tokens)
5. Rollback to legacy mode if needed
