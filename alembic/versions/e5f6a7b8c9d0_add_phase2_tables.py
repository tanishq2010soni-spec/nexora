"""add phase 2 tables (providers, model_registry, tools, workflows, licenses, plugins, knowledge_sources)

Revision ID: e5f6a7b8c9d0
Revises: d4e5f6a7b8c9
Create Date: 2026-07-02

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "e5f6a7b8c9d0"
down_revision: Union[str, None] = "d4e5f6a7b8c9"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # --- providers ---
    op.create_table(
        "providers",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("org_id", sa.Uuid(), sa.ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("provider_type", sa.String(50), nullable=False),
        sa.Column("api_key_encrypted", sa.Text(), nullable=True),
        sa.Column("endpoint_url", sa.String(512), nullable=True),
        sa.Column("is_active", sa.Boolean(), server_default="true"),
        sa.Column("supports_streaming", sa.Boolean(), server_default="false"),
        sa.Column("supports_vision", sa.Boolean(), server_default="false"),
        sa.Column("supports_tool_calling", sa.Boolean(), server_default="false"),
        sa.Column("context_window", sa.Integer(), server_default="0"),
        sa.Column("pricing_input_per_1k", sa.Float(), server_default="0.0"),
        sa.Column("pricing_output_per_1k", sa.Float(), server_default="0.0"),
        sa.Column("latency_p50_ms", sa.Float(), nullable=True),
        sa.Column("latency_p95_ms", sa.Float(), nullable=True),
        sa.Column("capabilities_json", sa.Text(), nullable=True),
        sa.Column("health_status", sa.String(20), server_default="unknown"),
        sa.Column("last_health_check_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    # --- model_registry ---
    op.create_table(
        "model_registry",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("org_id", sa.Uuid(), sa.ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False),
        sa.Column("provider_id", sa.Uuid(), sa.ForeignKey("providers.id", ondelete="CASCADE"), nullable=False),
        sa.Column("model_id", sa.String(255), nullable=False),
        sa.Column("display_name", sa.String(255), nullable=True),
        sa.Column("type", sa.String(20), server_default="remote"),
        sa.Column("version", sa.String(50), nullable=True),
        sa.Column("size_mb", sa.Float(), nullable=True),
        sa.Column("quantization", sa.String(20), nullable=True),
        sa.Column("context_window", sa.Integer(), server_default="0"),
        sa.Column("supports_vision", sa.Boolean(), server_default="false"),
        sa.Column("supports_audio", sa.Boolean(), server_default="false"),
        sa.Column("supports_reasoning", sa.Boolean(), server_default="false"),
        sa.Column("supports_coding", sa.Boolean(), server_default="false"),
        sa.Column("supports_embedding", sa.Boolean(), server_default="false"),
        sa.Column("supports_reranking", sa.Boolean(), server_default="false"),
        sa.Column("is_active", sa.Boolean(), server_default="true"),
        sa.Column("metadata_json", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    # --- tool_definitions ---
    op.create_table(
        "tool_definitions",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("org_id", sa.Uuid(), sa.ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("display_name", sa.String(255), nullable=True),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("version", sa.String(50), server_default="1.0.0"),
        sa.Column("category", sa.String(100), nullable=True),
        sa.Column("permissions_json", sa.Text(), nullable=True),
        sa.Column("is_enabled", sa.Boolean(), server_default="true"),
        sa.Column("health_status", sa.String(20), server_default="unknown"),
        sa.Column("config_json", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    # --- knowledge_sources ---
    op.create_table(
        "knowledge_sources",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("org_id", sa.Uuid(), sa.ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False),
        sa.Column("kb_id", sa.Uuid(), sa.ForeignKey("knowledge_bases.id", ondelete="CASCADE"), nullable=False),
        sa.Column("source_type", sa.String(50), nullable=False),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("config_json", sa.Text(), nullable=True),
        sa.Column("indexing_status", sa.String(20), server_default="pending"),
        sa.Column("last_indexed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    # --- workflow_definitions ---
    op.create_table(
        "workflow_definitions",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("org_id", sa.Uuid(), sa.ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("trigger_type", sa.String(50), nullable=False),
        sa.Column("trigger_config_json", sa.Text(), nullable=True),
        sa.Column("is_active", sa.Boolean(), server_default="true"),
        sa.Column("version", sa.String(50), server_default="1.0.0"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    # --- workflow_steps ---
    op.create_table(
        "workflow_steps",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("workflow_id", sa.Uuid(), sa.ForeignKey("workflow_definitions.id", ondelete="CASCADE"), nullable=False),
        sa.Column("step_type", sa.String(20), nullable=False),
        sa.Column("order", sa.Integer(), server_default="0"),
        sa.Column("config_json", sa.Text(), nullable=True),
        sa.Column("depends_on_step_ids", sa.Text(), nullable=True),
    )

    # --- workflow_definition_executions ---
    op.create_table(
        "workflow_definition_executions",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("workflow_id", sa.Uuid(), sa.ForeignKey("workflow_definitions.id", ondelete="CASCADE"), nullable=False),
        sa.Column("org_id", sa.Uuid(), sa.ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False),
        sa.Column("status", sa.String(20), server_default="running"),
        sa.Column("started_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("input_json", sa.Text(), nullable=True),
        sa.Column("output_json", sa.Text(), nullable=True),
        sa.Column("error_message", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    # --- workflow_variables ---
    op.create_table(
        "workflow_variables",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("workflow_id", sa.Uuid(), sa.ForeignKey("workflow_definitions.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("value_json", sa.Text(), nullable=True),
        sa.Column("type", sa.String(50), server_default="string"),
    )

    # --- licenses ---
    op.create_table(
        "licenses",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("org_id", sa.Uuid(), sa.ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False),
        sa.Column("license_type", sa.String(30), nullable=False),
        sa.Column("seats", sa.Integer(), server_default="1"),
        sa.Column("features_json", sa.Text(), nullable=True),
        sa.Column("usage_json", sa.Text(), nullable=True),
        sa.Column("is_active", sa.Boolean(), server_default="true"),
        sa.Column("is_trial", sa.Boolean(), server_default="false"),
        sa.Column("trial_ends_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("billing_metadata_json", sa.Text(), nullable=True),
        sa.Column("hardware_fingerprint", sa.String(255), nullable=True),
        sa.Column("activation_code", sa.String(255), nullable=True),
        sa.Column("activated_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    # --- plugins ---
    op.create_table(
        "plugins",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("org_id", sa.Uuid(), sa.ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("display_name", sa.String(255), nullable=True),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("version", sa.String(50), server_default="1.0.0"),
        sa.Column("manifest_json", sa.Text(), nullable=True),
        sa.Column("permissions_json", sa.Text(), nullable=True),
        sa.Column("dependencies_json", sa.Text(), nullable=True),
        sa.Column("hooks_json", sa.Text(), nullable=True),
        sa.Column("is_enabled", sa.Boolean(), server_default="true"),
        sa.Column("health_status", sa.String(20), server_default="unknown"),
        sa.Column("category", sa.String(100), nullable=True),
        sa.Column("marketplace_metadata_json", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )


def downgrade() -> None:
    op.drop_table("plugins")
    op.drop_table("licenses")
    op.drop_table("workflow_variables")
    op.drop_table("workflow_definition_executions")
    op.drop_table("workflow_steps")
    op.drop_table("workflow_definitions")
    op.drop_table("knowledge_sources")
    op.drop_table("tool_definitions")
    op.drop_table("model_registry")
    op.drop_table("providers")
