# RBAC Matrix

**Phase:** E.4 — Unified Authentication & Organization Federation  
**Date:** 2026-07-01

---

## Role Hierarchy

```
owner > admin > manager > employee > viewer
```

---

## Role Definitions

| Role | Description | Bypass |
|------|-------------|--------|
| `owner` | Full system access. Can manage billing, delete org. | All permissions |
| `admin` | Full operational access. Can manage team, settings, all resources. | All permissions |
| `manager` | Team lead. Can manage inbox, CRM, campaigns, view analytics. | None (explicit perms) |
| `employee` | Standard user. Read-heavy access to operational data. | None (explicit perms) |
| `viewer` | Read-only. Can view dashboard, analytics, logs. | None (explicit perms) |

---

## Permission Matrix

| Permission | owner | admin | manager | employee | viewer |
|-----------|:-----:|:-----:|:-------:|:--------:|:------:|
| **Dashboard** | | | | | |
| `view_dashboard` | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Messaging** | | | | | |
| `view_inbox` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `manage_inbox` | ✅ | ✅ | ✅ | ❌ | ❌ |
| **CRM** | | | | | |
| `view_crm` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `manage_crm` | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Knowledge** | | | | | |
| `view_knowledge` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `manage_knowledge` | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Workflows** | | | | | |
| `view_workflows` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `manage_workflows` | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Campaigns** | | | | | |
| `view_campaigns` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `manage_campaigns` | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Analytics** | | | | | |
| `view_analytics` | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Settings** | | | | | |
| `view_settings` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `manage_settings` | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Team** | | | | | |
| `manage_team` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `manage_permissions` | ✅ | ✅ | ❌ | ❌ | ❌ |
| **WhatsApp** | | | | | |
| `manage_whatsapp` | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Calls** | | | | | |
| `view_live_calls` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `manage_calls` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `view_call_queue` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `manage_call_queue` | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Leads** | | | | | |
| `view_leads` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `manage_leads` | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Recordings** | | | | | |
| `view_recordings` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `manage_recordings` | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Scripts** | | | | | |
| `view_scripts` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `manage_scripts` | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Voice Monitoring** | | | | | |
| `monitor_calls` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `barge_calls` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `whisper_calls` | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Providers** | | | | | |
| `manage_phone_providers` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `manage_voice_providers` | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Logs/Health** | | | | | |
| `view_logs` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `view_health` | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Plugins** | | | | | |
| `manage_plugins` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `manage_models` | ✅ | ✅ | ❌ | ❌ | ❌ |

---

## Permission Counts by Role

| Role | Permissions | Access Level |
|------|------------|--------------|
| owner | 40 (all) | Full |
| admin | 40 (all) | Full |
| manager | 24 | Operational |
| employee | 16 | Read-heavy |
| viewer | 4 | Read-only |

---

## Agent-Specific Permissions

### WhatsApp Agent

| Permission | Description |
|-----------|-------------|
| `view_inbox` | View conversation list |
| `manage_inbox` | Assign, tag, archive conversations |
| `manage_whatsapp` | Connect/disconnect WhatsApp accounts |
| `view_campaigns` | View broadcast campaigns |
| `manage_campaigns` | Create/edit campaigns |

### Calling Agent

| Permission | Description |
|-----------|-------------|
| `view_live_calls` | View active calls |
| `manage_calls` | Transfer, hold, end calls |
| `view_call_queue` | View call queue |
| `manage_call_queue` | Prioritize, reassign calls |
| `monitor_calls` | Listen to live calls |
| `barge_calls` | Join active calls |
| `whisper_calls` | Speak to agent during calls |
| `manage_phone_providers` | Configure Twilio, Exotel, etc. |
| `manage_voice_providers` | Configure STT/TTS providers |

### Personal AI

| Permission | Description |
|-----------|-------------|
| `view_dashboard` | View agent dashboard |
| `view_health` | View system health |
| `manage_settings` | Modify agent settings |

---

## Permission Enforcement

### In Code

```python
from nexora_ai.infrastructure.auth import AuthClient
from nexora_ai.domain.enums.auth_enums import Permission

auth = AuthClient()

# FastAPI dependency
@router.get("/calls")
async def list_calls(user = Depends(auth.require_permission(Permission.view_live_calls))):
    ...

# Manual check
if not auth.check_permission(user, Permission.manage_calls):
    raise HTTPException(403, "Insufficient permissions")
```

### Admin Bypass

`owner` and `admin` roles bypass all permission checks. They always have access to everything.

---

## Custom Roles (Future)

The current system uses fixed roles. Future enhancement:

1. Custom roles stored in database
2. Dynamic permission assignment
3. Role inheritance
4. Time-limited roles
5. Role-based access policies
