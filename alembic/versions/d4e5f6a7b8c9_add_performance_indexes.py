"""add performance indexes for org_id, status, and created_at

Revision ID: d4e5f6a7b8c9
Revises: c20dd995286a
Create Date: 2026-07-02

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "d4e5f6a7b8c9"
down_revision: Union[str, None] = "c20dd995286a"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # --- org_id indexes (most critical — every list endpoint filters by org_id) ---
    op.create_index("ix_leads_org_id", "leads", ["org_id"])
    op.create_index("ix_customers_org_id", "customers", ["org_id"])
    op.create_index("ix_chat_sessions_org_id", "chat_sessions", ["org_id"])
    op.create_index("ix_inbox_conversations_org_id", "inbox_conversations", ["org_id"])
    op.create_index("ix_inbox_messages_conversation_id", "inbox_messages", ["conversation_id"])
    op.create_index("ix_audit_logs_org_id", "audit_logs", ["org_id"])
    op.create_index("ix_activity_logs_org_id", "activity_logs", ["org_id"])
    op.create_index("ix_calls_org_id", "calls", ["org_id"])
    op.create_index("ix_memory_entries_org_id", "memory_entries", ["org_id"])
    op.create_index("ix_workflows_org_id", "workflows", ["org_id"])
    op.create_index("ix_tasks_org_id", "tasks", ["org_id"])
    op.create_index("ix_agents_org_id", "agents", ["org_id"])
    op.create_index("ix_agent_versions_agent_id", "agent_versions", ["agent_id"])
    op.create_index("ix_agent_capabilities_agent_id", "agent_capabilities", ["agent_id"])
    op.create_index("ix_agent_health_agent_id", "agent_health", ["agent_id"])
    op.create_index("ix_agent_configurations_agent_id", "agent_configurations", ["agent_id"])
    op.create_index("ix_agent_logs_agent_id", "agent_logs", ["agent_id"])
    op.create_index("ix_agent_heartbeats_agent_id", "agent_heartbeats", ["agent_id"])
    op.create_index("ix_providers_org_id", "providers", ["org_id"])
    op.create_index("ix_model_registry_org_id", "model_registry", ["org_id"])
    op.create_index("ix_tool_definitions_org_id", "tool_definitions", ["org_id"])
    op.create_index("ix_workflow_definitions_org_id", "workflow_definitions", ["org_id"])
    op.create_index("ix_workflow_definition_executions_workflow_id", "workflow_definition_executions", ["workflow_id"])
    op.create_index("ix_licenses_org_id", "licenses", ["org_id"])
    op.create_index("ix_plugins_org_id", "plugins", ["org_id"])
    op.create_index("ix_knowledge_sources_org_id", "knowledge_sources", ["org_id"])
    op.create_index("ix_knowledge_bases_org_id", "knowledge_bases", ["org_id"])
    op.create_index("ix_documents_org_id", "documents", ["org_id"])
    op.create_index("ix_plans_org_id", "plans", ["org_id"])
    op.create_index("ix_subscriptions_org_id", "subscriptions", ["org_id"])
    op.create_index("ix_invoices_org_id", "invoices", ["org_id"])
    op.create_index("ix_notifications_org_id", "notifications", ["org_id"])
    op.create_index("ix_organization_settings_org_id", "organization_settings", ["org_id"])
    op.create_index("ix_api_keys_org_id", "api_keys", ["org_id"])
    op.create_index("ix_integrations_org_id", "integrations", ["org_id"])
    op.create_index("ix_departments_org_id", "departments", ["org_id"])
    op.create_index("ix_teams_org_id", "teams", ["org_id"])
    op.create_index("ix_roles_org_id", "roles", ["org_id"])
    op.create_index("ix_notes_org_id", "notes", ["org_id"])

    # --- status indexes (frequently filtered) ---
    op.create_index("ix_leads_status", "leads", ["status"])
    op.create_index("ix_inbox_conversations_status", "inbox_conversations", ["status"])
    op.create_index("ix_calls_status", "calls", ["status"])
    op.create_index("ix_tasks_status", "tasks", ["status"])
    op.create_index("ix_subscriptions_status", "subscriptions", ["status"])
    op.create_index("ix_agent_health_status", "agent_health", ["status"])
    op.create_index("ix_agent_heartbeats_status", "agent_heartbeats", ["status"])

    # --- created_at indexes (used for sorting and time-range queries) ---
    op.create_index("ix_audit_logs_created_at", "audit_logs", ["created_at"])
    op.create_index("ix_leads_created_at", "leads", ["created_at"])
    op.create_index("ix_customers_created_at", "customers", ["created_at"])
    op.create_index("ix_inbox_conversations_created_at", "inbox_conversations", ["created_at"])
    op.create_index("ix_calls_created_at", "calls", ["created_at"])
    op.create_index("ix_tasks_created_at", "tasks", ["created_at"])
    op.create_index("ix_agents_created_at", "agents", ["created_at"])


def downgrade() -> None:
    # Drop all indexes in reverse order
    op.drop_index("ix_agents_created_at", "agents")
    op.drop_index("ix_tasks_created_at", "tasks")
    op.drop_index("ix_calls_created_at", "calls")
    op.drop_index("ix_inbox_conversations_created_at", "inbox_conversations")
    op.drop_index("ix_customers_created_at", "customers")
    op.drop_index("ix_leads_created_at", "leads")
    op.drop_index("ix_audit_logs_created_at", "audit_logs")

    op.drop_index("ix_agent_heartbeats_status", "agent_heartbeats")
    op.drop_index("ix_agent_health_status", "agent_health")
    op.drop_index("ix_subscriptions_status", "subscriptions")
    op.drop_index("ix_tasks_status", "tasks")
    op.drop_index("ix_calls_status", "calls")
    op.drop_index("ix_inbox_conversations_status", "inbox_conversations")
    op.drop_index("ix_leads_status", "leads")

    op.drop_index("ix_notes_org_id", "notes")
    op.drop_index("ix_roles_org_id", "roles")
    op.drop_index("ix_teams_org_id", "teams")
    op.drop_index("ix_departments_org_id", "departments")
    op.drop_index("ix_integrations_org_id", "integrations")
    op.drop_index("ix_api_keys_org_id", "api_keys")
    op.drop_index("ix_organization_settings_org_id", "organization_settings")
    op.drop_index("ix_notifications_org_id", "notifications")
    op.drop_index("ix_invoices_org_id", "invoices")
    op.drop_index("ix_subscriptions_org_id", "subscriptions")
    op.drop_index("ix_plans_org_id", "plans")
    op.drop_index("ix_documents_org_id", "documents")
    op.drop_index("ix_knowledge_bases_org_id", "knowledge_bases")
    op.drop_index("ix_knowledge_sources_org_id", "knowledge_sources")
    op.drop_index("ix_plugins_org_id", "plugins")
    op.drop_index("ix_licenses_org_id", "licenses")
    op.drop_index("ix_workflow_definition_executions_workflow_id", "workflow_definition_executions")
    op.drop_index("ix_workflow_definitions_org_id", "workflow_definitions")
    op.drop_index("ix_tool_definitions_org_id", "tool_definitions")
    op.drop_index("ix_model_registry_org_id", "model_registry")
    op.drop_index("ix_providers_org_id", "providers")
    op.drop_index("ix_agent_heartbeats_agent_id", "agent_heartbeats")
    op.drop_index("ix_agent_logs_agent_id", "agent_logs")
    op.drop_index("ix_agent_configurations_agent_id", "agent_configurations")
    op.drop_index("ix_agent_health_agent_id", "agent_health")
    op.drop_index("ix_agent_capabilities_agent_id", "agent_capabilities")
    op.drop_index("ix_agent_versions_agent_id", "agent_versions")
    op.drop_index("ix_agents_org_id", "agents")
    op.drop_index("ix_tasks_org_id", "tasks")
    op.drop_index("ix_workflows_org_id", "workflows")
    op.drop_index("ix_memory_entries_org_id", "memory_entries")
    op.drop_index("ix_calls_org_id", "calls")
    op.drop_index("ix_activity_logs_org_id", "activity_logs")
    op.drop_index("ix_audit_logs_org_id", "audit_logs")
    op.drop_index("ix_inbox_messages_conversation_id", "inbox_messages")
    op.drop_index("ix_inbox_conversations_org_id", "inbox_conversations")
    op.drop_index("ix_chat_sessions_org_id", "chat_sessions")
    op.drop_index("ix_customers_org_id", "customers")
    op.drop_index("ix_leads_org_id", "leads")
