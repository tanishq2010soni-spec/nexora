from __future__ import annotations

import enum


class AuthMode(str, enum.Enum):
    LEGACY = "legacy"
    UNIFIED = "unified"


class SystemRole(str, enum.Enum):
    OWNER = "owner"
    ADMIN = "admin"
    MANAGER = "manager"
    EMPLOYEE = "employee"
    VIEWER = "viewer"


class Permission(str, enum.Enum):
    view_dashboard = "view_dashboard"
    view_inbox = "view_inbox"
    manage_inbox = "manage_inbox"
    view_crm = "view_crm"
    manage_crm = "manage_crm"
    view_knowledge = "view_knowledge"
    manage_knowledge = "manage_knowledge"
    view_workflows = "view_workflows"
    manage_workflows = "manage_workflows"
    view_campaigns = "view_campaigns"
    manage_campaigns = "manage_campaigns"
    view_analytics = "view_analytics"
    view_settings = "view_settings"
    manage_settings = "manage_settings"
    manage_team = "manage_team"
    manage_permissions = "manage_permissions"
    manage_whatsapp = "manage_whatsapp"
    view_logs = "view_logs"
    view_health = "view_health"
    manage_plugins = "manage_plugins"
    manage_models = "manage_models"
    view_live_calls = "view_live_calls"
    manage_calls = "manage_calls"
    view_call_queue = "view_call_queue"
    manage_call_queue = "manage_call_queue"
    view_leads = "view_leads"
    manage_leads = "manage_leads"
    view_recordings = "view_recordings"
    manage_recordings = "manage_recordings"
    view_scripts = "view_scripts"
    manage_scripts = "manage_scripts"
    monitor_calls = "monitor_calls"
    barge_calls = "barge_calls"
    whisper_calls = "whisper_calls"
    manage_phone_providers = "manage_phone_providers"
    manage_voice_providers = "manage_voice_providers"


ROLE_PERMISSIONS: dict[SystemRole, set[Permission]] = {
    SystemRole.OWNER: set(Permission),
    SystemRole.ADMIN: set(Permission),
    SystemRole.MANAGER: {
        Permission.view_dashboard,
        Permission.view_inbox,
        Permission.manage_inbox,
        Permission.view_crm,
        Permission.manage_crm,
        Permission.view_knowledge,
        Permission.manage_knowledge,
        Permission.view_workflows,
        Permission.manage_workflows,
        Permission.view_campaigns,
        Permission.manage_campaigns,
        Permission.view_analytics,
        Permission.view_settings,
        Permission.view_live_calls,
        Permission.manage_calls,
        Permission.view_call_queue,
        Permission.manage_call_queue,
        Permission.view_leads,
        Permission.manage_leads,
        Permission.view_recordings,
        Permission.view_scripts,
        Permission.manage_scripts,
        Permission.monitor_calls,
        Permission.view_logs,
        Permission.view_health,
    },
    SystemRole.EMPLOYEE: {
        Permission.view_dashboard,
        Permission.view_inbox,
        Permission.manage_inbox,
        Permission.view_crm,
        Permission.view_knowledge,
        Permission.view_workflows,
        Permission.view_campaigns,
        Permission.view_analytics,
        Permission.view_live_calls,
        Permission.view_call_queue,
        Permission.view_leads,
        Permission.view_recordings,
        Permission.view_scripts,
        Permission.view_logs,
        Permission.view_health,
    },
    SystemRole.VIEWER: {
        Permission.view_dashboard,
        Permission.view_analytics,
        Permission.view_logs,
        Permission.view_health,
    },
}
