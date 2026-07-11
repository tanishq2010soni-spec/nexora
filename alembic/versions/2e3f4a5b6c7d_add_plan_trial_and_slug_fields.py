"""Add plan slug, trial_days, max_users, max_leads, currency + subscription trial_ends_at

Revision ID: 2e3f4a5b6c7d
Revises: 1d15e0d75a64
Create Date: 2026-06-23
"""
from alembic import op
import sqlalchemy as sa

revision = "2e3f4a5b6c7d"
down_revision = "1d15e0d75a64"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Plan table: add new columns
    op.add_column("plans", sa.Column("slug", sa.String(50), nullable=True))
    op.add_column("plans", sa.Column("currency", sa.String(10), server_default="usd"))
    op.add_column("plans", sa.Column("trial_days", sa.Integer(), server_default="0"))
    op.add_column("plans", sa.Column("max_users", sa.Integer(), server_default="1"))
    op.add_column("plans", sa.Column("max_leads", sa.Integer(), server_default="500"))

    # Create unique index on slug
    op.create_index("ix_plans_slug", "plans", ["slug"], unique=True)

    # Subscription table: add trial_ends_at
    op.add_column("subscriptions", sa.Column("trial_ends_at", sa.DateTime(timezone=True), nullable=True))


def downgrade() -> None:
    op.drop_column("subscriptions", "trial_ends_at")
    op.drop_index("ix_plans_slug", table_name="plans")
    op.drop_column("plans", "max_leads")
    op.drop_column("plans", "max_users")
    op.drop_column("plans", "trial_days")
    op.drop_column("plans", "currency")
    op.drop_column("plans", "slug")
