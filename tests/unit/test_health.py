from unittest.mock import AsyncMock
import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_health_endpoint_healthy(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    """
    Tests that /health returns 200 and indicates healthy database status under normal operations.
    """
    response = await client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["database"] == "healthy"
    assert "environment" in data


@pytest.mark.asyncio
async def test_health_endpoint_db_unhealthy(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    """
    Tests that /health returns status 'degraded' when database query execution fails.
    """
    # Simulate database query failure
    mock_db_session.execute.side_effect = Exception("Database connection timeout")
    
    response = await client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "degraded"
    assert data["database"] == "unhealthy"


@pytest.mark.asyncio
async def test_root_health_endpoint(client: AsyncClient) -> None:
    """
    Tests that the top-level /health endpoint returns 200 when healthy, or 503 when degraded.
    """
    response = await client.get("/health")
    assert response.status_code in (200, 503)
    data = response.json()
    assert data["status"] in ("healthy", "degraded")

