"""add_description_to_business_profiles

Revision ID: b3c5d64f7a9e
Revises: a2d4e53e5b8c
Create Date: 2026-06-16 20:15:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'b3c5d64f7a9e'
down_revision: Union[str, None] = 'a2d4e53e5b8c'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "business_profiles",
        sa.Column("description", sa.Text(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("business_profiles", "description")
