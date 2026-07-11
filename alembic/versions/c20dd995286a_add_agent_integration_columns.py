"""add agent integration columns

Revision ID: c20dd995286a
Revises: 07e7bf4650a4
Create Date: 2026-07-02

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c20dd995286a'
down_revision: Union[str, None] = '07e7bf4650a4'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # AgentVersion: add status column
    op.add_column('agent_versions', sa.Column('status', sa.String(20), nullable=False, server_default='draft'))

    # AgentCapability: add description and updated_at
    op.add_column('agent_capabilities', sa.Column('description', sa.Text(), nullable=True))
    op.add_column('agent_capabilities', sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True))

    # AgentHealth: add metrics_json and updated_at
    op.add_column('agent_health', sa.Column('metrics_json', sa.Text(), nullable=True))
    op.add_column('agent_health', sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True))

    # AgentHeartbeat: add created_at
    op.add_column('agent_heartbeats', sa.Column('created_at', sa.DateTime(timezone=True), nullable=True))


def downgrade() -> None:
    op.drop_column('agent_heartbeats', 'created_at')
    op.drop_column('agent_health', 'updated_at')
    op.drop_column('agent_health', 'metrics_json')
    op.drop_column('agent_capabilities', 'updated_at')
    op.drop_column('agent_capabilities', 'description')
    op.drop_column('agent_versions', 'status')
