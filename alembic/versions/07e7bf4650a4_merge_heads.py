"""merge heads

Revision ID: 07e7bf4650a4
Revises: 2e3f4a5b6c7d, f3a2b4c6d8e0
Create Date: 2026-06-24 20:40:37.594229

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '07e7bf4650a4'
down_revision: Union[str, None] = ('2e3f4a5b6c7d', 'f3a2b4c6d8e0')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
