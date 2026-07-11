import uuid
from unittest.mock import AsyncMock, MagicMock
import pytest
from httpx import AsyncClient

from src.presentation.api.dependencies import get_current_org_id
from src.main import app

TEST_ORG_ID = uuid.uuid4()
TEST_PROFILE_ID = uuid.uuid4()


def make_mock_profile(overrides: dict | None = None) -> dict:
    base = {
        "id": TEST_PROFILE_ID,
        "org_id": TEST_ORG_ID,
        "name": "Nexora Solutions",
        "business_type": "AI Automation",
        "address": "123 Tech Avenue",
        "phone": "+1234567890",
        "email": "contact@nexora.ai",
        "website": "https://nexora.ai",
        "working_hours": "Mon-Fri 9AM-5PM",
        "services": "Custom agent setups",
        "policies": "No spam",
        "description": "Leading AI automation provider",
    }
    if overrides:
        base.update(overrides)
    return base


VALID_PAYLOAD = {
    "name": "Nexora Solutions",
    "business_type": "AI Automation",
    "address": "123 Tech Avenue",
    "phone": "+1234567890",
    "email": "contact@nexora.ai",
    "website": "https://nexora.ai",
    "working_hours": "Mon-Fri 9AM-5PM",
    "services": "Custom agent setups",
    "policies": "No spam",
    "description": "Leading AI automation provider",
}


# ========== /api/v1/business/ tests ==========


@pytest.mark.asyncio
async def test_business_get_not_found(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = None
    mock_db_session.execute.return_value = mock_execute

    response = await client.get("/api/v1/business/")
    assert response.status_code == 404
    assert "not found" in response.json()["detail"].lower()

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_business_get_success(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    mock_profile_row = MagicMock()
    for field, value in make_mock_profile().items():
        setattr(mock_profile_row, field, value)

    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = mock_profile_row
    mock_db_session.execute.return_value = mock_execute

    response = await client.get("/api/v1/business/")
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Nexora Solutions"
    assert data["description"] == "Leading AI automation provider"
    assert data["org_id"] == str(TEST_ORG_ID)

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_business_create_success(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = None
    mock_db_session.execute.return_value = mock_execute

    response = await client.post("/api/v1/business/", json=VALID_PAYLOAD)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Nexora Solutions"
    assert data["description"] == "Leading AI automation provider"
    assert data["org_id"] == str(TEST_ORG_ID)

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_business_create_already_exists(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    mock_profile_row = MagicMock()
    for field, value in make_mock_profile().items():
        setattr(mock_profile_row, field, value)

    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = mock_profile_row
    mock_db_session.execute.return_value = mock_execute

    response = await client.post("/api/v1/business/", json=VALID_PAYLOAD)
    assert response.status_code == 400
    assert "already exists" in response.json()["detail"]

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_business_update_success(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    mock_profile_row = MagicMock()
    for field, value in make_mock_profile().items():
        setattr(mock_profile_row, field, value)

    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = mock_profile_row
    mock_db_session.execute.return_value = mock_execute

    profile_id = str(TEST_PROFILE_ID)
    response = await client.put(
        f"/api/v1/business/{profile_id}",
        json={"name": "Updated Business", "description": "Updated description"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Updated Business"
    assert data["description"] == "Updated description"

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_business_update_not_found(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = None
    mock_db_session.execute.return_value = mock_execute

    profile_id = str(uuid.uuid4())
    response = await client.put(
        f"/api/v1/business/{profile_id}",
        json={"name": "Updated Business"},
    )
    assert response.status_code == 404
    assert "not found" in response.json()["detail"].lower()

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_business_delete_success(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    mock_profile_row = MagicMock()
    for field, value in make_mock_profile().items():
        setattr(mock_profile_row, field, value)

    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = mock_profile_row
    mock_execute.rowcount = 1
    mock_db_session.execute.return_value = mock_execute

    profile_id = str(TEST_PROFILE_ID)
    response = await client.delete(f"/api/v1/business/{profile_id}")
    assert response.status_code == 204

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_business_delete_not_found(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = None
    mock_db_session.execute.return_value = mock_execute

    profile_id = str(uuid.uuid4())
    response = await client.delete(f"/api/v1/business/{profile_id}")
    assert response.status_code == 404
    assert "not found" in response.json()["detail"].lower()

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_business_delete_wrong_org(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    mock_profile_row = MagicMock()
    for field, value in make_mock_profile({"org_id": uuid.uuid4()}).items():
        setattr(mock_profile_row, field, value)

    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = mock_profile_row
    mock_db_session.execute.return_value = mock_execute

    profile_id = str(uuid.uuid4())
    response = await client.delete(f"/api/v1/business/{profile_id}")
    assert response.status_code == 404

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_business_update_wrong_org(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    mock_profile_row = MagicMock()
    for field, value in make_mock_profile({"org_id": uuid.uuid4()}).items():
        setattr(mock_profile_row, field, value)

    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = mock_profile_row
    mock_db_session.execute.return_value = mock_execute

    profile_id = str(uuid.uuid4())
    response = await client.put(
        f"/api/v1/business/{profile_id}",
        json={"name": "Hacker Attack"},
    )
    assert response.status_code == 404

    app.dependency_overrides.clear()
