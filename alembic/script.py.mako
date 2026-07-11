"""${message}

Revision ID: ${up_revision}
Revises: ${down_revision | comma,n}
Create Date: ${create_date}

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
% if 'imports' in context.keys():
${imports}
% endif

# revision identifiers, used by Alembic.
revision: str = ${repr(up_revision)}
down_revision: Union[str, None] = ${repr(down_revision)}
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    % if 'upgrades' in context.keys():
    ${upgrades}
    % else:
    pass
    % endif


def downgrade() -> None:
    """Downgrade schema."""
    % if 'downgrades' in context.keys():
    ${downgrades}
    % else:
    pass
    % endif