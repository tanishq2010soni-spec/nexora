from collections.abc import AsyncGenerator
from unittest.mock import AsyncMock
import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.main import app


@pytest.fixture
def mock_db_session() -> AsyncMock:
    """
    Exposes a mock AsyncSession that returns a successful execution state.
    """
    session = AsyncMock(spec=AsyncSession)
    session.execute = AsyncMock()
    return session


@pytest_asyncio.fixture
async def client(mock_db_session: AsyncMock) -> AsyncGenerator[AsyncClient, None]:
    """
    Dependency overrides the FastAPI get_db_session and provides an HTTPX test client.
    """
    app.dependency_overrides[get_db_session] = lambda: mock_db_session
    
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as ac:
        yield ac
        
    app.dependency_overrides.clear()

