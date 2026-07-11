"""add_lead_status_customer_segment_activity_log

Revision ID: e60970188e11
Revises: 670aaea75810
Create Date: 2026-06-19 21:41:57.378820

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'e60970188e11'
down_revision: Union[str, None] = '670aaea75810'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table('activity_logs',
    sa.Column('id', sa.Uuid(), nullable=False),
    sa.Column('org_id', sa.Uuid(), nullable=False),
    sa.Column('entity_type', sa.String(length=50), nullable=False),
    sa.Column('entity_id', sa.Uuid(), nullable=False),
    sa.Column('activity_type', sa.String(length=50), nullable=False),
    sa.Column('description', sa.Text(), nullable=True),
    sa.Column('metadata_json', sa.Text(), nullable=True),
    sa.Column('performed_by', sa.String(length=255), nullable=True),
    sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
    sa.ForeignKeyConstraint(['org_id'], ['organizations.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.add_column('customers', sa.Column('segment', sa.String(length=100), nullable=True))
    op.add_column('customers', sa.Column('assigned_to', sa.String(length=255), nullable=True))
    op.add_column('leads', sa.Column('status', sa.String(length=50), nullable=True))
    op.add_column('leads', sa.Column('assigned_to', sa.String(length=255), nullable=True))
    op.add_column('leads', sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True))
    op.execute("UPDATE leads SET status = 'new' WHERE status IS NULL")
    op.execute("UPDATE leads SET updated_at = created_at WHERE updated_at IS NULL")
    op.alter_column('leads', 'status', nullable=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column('leads', 'updated_at')
    op.drop_column('leads', 'assigned_to')
    op.drop_column('leads', 'status')
    op.drop_column('customers', 'assigned_to')
    op.drop_column('customers', 'segment')
    op.drop_table('activity_logs')
