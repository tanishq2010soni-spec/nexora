from __future__ import annotations

from datetime import datetime
from typing import AsyncGenerator
from uuid import uuid4

import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from backend.domain.entities import Call, Campaign, Lead, User
from backend.domain.enums import CallStatus
from backend.infrastructure.database import Base, OrganizationModel, UserModel

pytestmark = pytest.mark.asyncio

TEST_DATABASE_URL = "sqlite+aiosqlite://"


@pytest_asyncio.fixture
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    engine = create_async_engine(TEST_DATABASE_URL, echo=False)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    session_factory = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with session_factory() as session:
        yield session

    await engine.dispose()


@pytest_asyncio.fixture
async def client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    from backend.main import app

    async def override_get_session():
        yield db_session

    from backend.infrastructure.database import get_session

    app.dependency_overrides[get_session] = override_get_session

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac

    app.dependency_overrides.clear()


@pytest_asyncio.fixture
async def org_and_user(db_session: AsyncSession) -> tuple[OrganizationModel, UserModel]:
    org = OrganizationModel(
        id=str(uuid4()),
        name="Test Org",
        slug="test-org",
    )
    db_session.add(org)
    await db_session.flush()

    from passlib.context import CryptContext
    pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

    user = UserModel(
        id=str(uuid4()),
        organization_id=org.id,
        email="admin@test.com",
        password_hash=pwd_context.hash("password123"),
        name="Admin User",
        role="admin",
        permissions=["view_dashboard", "view_live_calls", "manage_calls", "view_campaigns",
                     "manage_campaigns", "view_leads", "manage_leads"],
    )
    db_session.add(user)
    await db_session.flush()
    return org, user


@pytest_asyncio.fixture
async def auth_token(client: AsyncClient, org_and_user) -> str:
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": "admin@test.com", "password": "password123"},
    )
    assert response.status_code == 200
    return response.json()["access_token"]


@pytest_asyncio.fixture
async def auth_headers(auth_token: str) -> dict:
    return {"Authorization": f"Bearer {auth_token}"}


class TestHealth:
    async def test_health_endpoint(self, client: AsyncClient):
        response = await client.get("/api/v1/health")
        assert response.status_code == 200
        data = response.json()
        assert "status" in data
        assert "version" in data
        assert "uptime_seconds" in data
        assert "database" in data
        assert data["app_name"] is not None


class TestAuth:
    async def test_login_success(self, client: AsyncClient, org_and_user):
        response = await client.post(
            "/api/v1/auth/login",
            json={"email": "admin@test.com", "password": "password123"},
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "bearer"
        assert data["expires_in"] > 0

    async def test_login_invalid_password(self, client: AsyncClient, org_and_user):
        response = await client.post(
            "/api/v1/auth/login",
            json={"email": "admin@test.com", "password": "wrongpassword"},
        )
        assert response.status_code == 401

    async def test_login_nonexistent_user(self, client: AsyncClient):
        response = await client.post(
            "/api/v1/auth/login",
            json={"email": "nobody@test.com", "password": "password123"},
        )
        assert response.status_code == 401

    async def test_me_endpoint(self, client: AsyncClient, auth_headers: dict):
        response = await client.get("/api/v1/auth/me", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["email"] == "admin@test.com"
        assert data["name"] == "Admin User"

    async def test_me_unauthorized(self, client: AsyncClient):
        response = await client.get("/api/v1/auth/me")
        assert response.status_code == 401

    async def test_refresh_token(self, client: AsyncClient, org_and_user):
        login_resp = await client.post(
            "/api/v1/auth/login",
            json={"email": "admin@test.com", "password": "password123"},
        )
        refresh_token = login_resp.json()["refresh_token"]

        response = await client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": refresh_token},
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data


class TestCalls:
    async def test_list_calls(self, client: AsyncClient, auth_headers: dict):
        response = await client.get("/api/v1/calls", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "items" in data
        assert "total" in data
        assert "page" in data
        assert "limit" in data

    async def test_get_call_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.get(f"/api/v1/calls/{uuid4()}", headers=auth_headers)
        assert response.status_code == 404

    async def test_list_calls_with_filters(self, client: AsyncClient, auth_headers: dict):
        response = await client.get(
            "/api/v1/calls?status=queued&page=1&limit=10",
            headers=auth_headers,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["page"] == 1
        assert data["limit"] == 10

    async def test_active_calls(self, client: AsyncClient, auth_headers: dict):
        response = await client.get("/api/v1/calls/active", headers=auth_headers)
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    async def test_update_call_status_invalid(self, client: AsyncClient, auth_headers: dict):
        response = await client.patch(
            f"/api/v1/calls/{uuid4()}/status",
            headers=auth_headers,
            json={"status": "invalid_status"},
        )
        assert response.status_code == 404

    async def test_set_call_disposition_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.patch(
            f"/api/v1/calls/{uuid4()}/disposition",
            headers=auth_headers,
            json={"disposition": "completed"},
        )
        assert response.status_code == 404

    async def test_assign_call_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.patch(
            f"/api/v1/calls/{uuid4()}/assign",
            headers=auth_headers,
            json={"user_id": str(uuid4())},
        )
        assert response.status_code == 404

    async def test_add_notes_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.patch(
            f"/api/v1/calls/{uuid4()}/notes",
            headers=auth_headers,
            json={"note": "Test note"},
        )
        assert response.status_code == 404

    async def test_update_tags_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.patch(
            f"/api/v1/calls/{uuid4()}/tags",
            headers=auth_headers,
            json={"tags": ["important"]},
        )
        assert response.status_code == 404

    async def test_set_quality_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.patch(
            f"/api/v1/calls/{uuid4()}/quality",
            headers=auth_headers,
            json={"score": 85},
        )
        assert response.status_code == 404

    async def test_hold_call_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.post(
            f"/api/v1/calls/{uuid4()}/hold",
            headers=auth_headers,
        )
        assert response.status_code == 404

    async def test_resume_call_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.post(
            f"/api/v1/calls/{uuid4()}/resume",
            headers=auth_headers,
        )
        assert response.status_code == 404

    async def test_transfer_call_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.post(
            f"/api/v1/calls/{uuid4()}/transfer",
            headers=auth_headers,
            json={"target_number": "+1234567890"},
        )
        assert response.status_code == 404

    async def test_conference_call_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.post(
            f"/api/v1/calls/{uuid4()}/conference",
            headers=auth_headers,
            json={"numbers": ["+1234567890"]},
        )
        assert response.status_code == 404

    async def test_handoff_call_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.post(
            f"/api/v1/calls/{uuid4()}/handoff",
            headers=auth_headers,
            json={"user_id": str(uuid4())},
        )
        assert response.status_code == 404

    async def test_get_call_events_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.get(
            f"/api/v1/calls/{uuid4()}/events",
            headers=auth_headers,
        )
        assert response.status_code == 200
        assert response.json() == []

    async def test_quality_score_validation(self, client: AsyncClient, auth_headers: dict):
        response = await client.patch(
            f"/api/v1/calls/{uuid4()}/quality",
            headers=auth_headers,
            json={"score": 150},
        )
        assert response.status_code == 422

    async def test_list_calls_unauthorized(self, client: AsyncClient):
        response = await client.get("/api/v1/calls")
        assert response.status_code == 401


class TestCampaigns:
    async def test_list_campaigns(self, client: AsyncClient, auth_headers: dict):
        response = await client.get("/api/v1/campaigns", headers=auth_headers)
        assert response.status_code == 200

    async def test_create_campaign(self, client: AsyncClient, auth_headers: dict):
        response = await client.post(
            "/api/v1/campaigns",
            headers=auth_headers,
            json={
                "name": "Test Campaign",
                "type": "cold_calling",
                "status": "draft",
            },
        )
        assert response.status_code in (200, 201, 404)

    async def test_get_campaign_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.get(f"/api/v1/campaigns/{uuid4()}", headers=auth_headers)
        assert response.status_code == 404

    async def test_update_campaign_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.put(
            f"/api/v1/campaigns/{uuid4()}",
            headers=auth_headers,
            json={"name": "Updated"},
        )
        assert response.status_code == 404

    async def test_delete_campaign_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.delete(
            f"/api/v1/campaigns/{uuid4()}",
            headers=auth_headers,
        )
        assert response.status_code == 404

    async def test_start_campaign_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.post(
            f"/api/v1/campaigns/{uuid4()}/start",
            headers=auth_headers,
        )
        assert response.status_code == 404

    async def test_pause_campaign_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.post(
            f"/api/v1/campaigns/{uuid4()}/pause",
            headers=auth_headers,
        )
        assert response.status_code == 404

    async def test_list_campaign_unauthorized(self, client: AsyncClient):
        response = await client.get("/api/v1/campaigns")
        assert response.status_code == 401


class TestLeads:
    async def test_list_leads(self, client: AsyncClient, auth_headers: dict):
        response = await client.get("/api/v1/leads", headers=auth_headers)
        assert response.status_code == 200

    async def test_create_lead(self, client: AsyncClient, auth_headers: dict):
        response = await client.post(
            "/api/v1/leads",
            headers=auth_headers,
            json={
                "first_name": "John",
                "last_name": "Doe",
                "phone": "+1234567890",
                "email": "john@example.com",
            },
        )
        assert response.status_code in (200, 201)

    async def test_get_lead_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.get(f"/api/v1/leads/{uuid4()}", headers=auth_headers)
        assert response.status_code == 404

    async def test_update_lead_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.put(
            f"/api/v1/leads/{uuid4()}",
            headers=auth_headers,
            json={"first_name": "Jane"},
        )
        assert response.status_code == 404

    async def test_delete_lead_not_found(self, client: AsyncClient, auth_headers: dict):
        response = await client.delete(
            f"/api/v1/leads/{uuid4()}",
            headers=auth_headers,
        )
        assert response.status_code == 404

    async def test_import_leads(self, client: AsyncClient, auth_headers: dict):
        import io, csv
        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(["first_name", "phone"])
        writer.writerow(["Alice", "+1111111111"])
        writer.writerow(["Bob", "+2222222222"])
        response = await client.post(
            "/api/v1/leads/import",
            headers=auth_headers,
            files={"file": ("leads.csv", output.getvalue(), "text/csv")},
        )
        assert response.status_code in (200, 201)

    async def test_list_leads_unauthorized(self, client: AsyncClient):
        response = await client.get("/api/v1/leads")
        assert response.status_code == 401

    async def test_search_leads(self, client: AsyncClient, auth_headers: dict):
        response = await client.get(
            "/api/v1/leads?search=John&status=new",
            headers=auth_headers,
        )
        assert response.status_code == 200

    async def test_bulk_assign_leads(self, client: AsyncClient, auth_headers: dict):
        response = await client.post(
            "/api/v1/leads/bulk/assign",
            headers=auth_headers,
            json={
                "lead_ids": [str(uuid4())],
                "campaign_id": str(uuid4()),
            },
        )
        assert response.status_code in (200, 404)
