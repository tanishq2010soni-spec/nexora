from unittest.mock import AsyncMock, MagicMock, patch
import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
@patch("src.application.services.auth_service.AuthService.hash_password", return_value="$2b$12$fakehashedpassword")
@patch("src.application.services.auth_service.AuthService.create_access_token", return_value="fake.jwt.token")
@patch("src.application.services.auth_service.AuthService.create_refresh_token", return_value="fake.refresh.token")
async def test_signup_successful(mock_refresh, mock_access, mock_hash, client: AsyncClient, mock_db_session: AsyncMock) -> None:
    """
    Tests registering a new user is successful and returns token details.
    """
    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = None
    mock_db_session.execute.return_value = mock_execute

    payload = {
        "email": "test@nexora.ai",
        "password": "Secure_Pass_123!",
        "organization_name": "Nexora Corp"
    }
    
    response = await client.post("/api/v1/auth/signup", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert "access_token" in data
    assert data["email"] == "test@nexora.ai"
    assert "org_id" in data


@pytest.mark.asyncio
async def test_signup_duplicate_email(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    """
    Tests registering fails with 400 when user email already exists in DB.
    """
    # Mock database check returning a dummy user object (email exists)
    from src.infrastructure.database.models import User
    existing_user = User(email="test@nexora.ai")
    
    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = existing_user
    mock_db_session.execute.return_value = mock_execute


    payload = {
        "email": "test@nexora.ai",
        "password": "Secure_Pass_123!",
        "organization_name": "Nexora Corp"
    }
    
    response = await client.post("/api/v1/auth/signup", json=payload)
    assert response.status_code == 400
    assert "already exists" in response.json()["detail"]
