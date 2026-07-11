import asyncio
from uuid import uuid4

import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import sessionmaker

from backend.domain.entities import User
from backend.domain.enums import Permission

TEST_DATABASE_URL = "sqlite+aiosqlite://"


@pytest.fixture(scope="session")
def event_loop():
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest_asyncio.fixture
async def db_engine():
    from backend.infrastructure.database.models import Base
    engine = create_async_engine(TEST_DATABASE_URL, echo=False)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()


@pytest_asyncio.fixture
async def db_session(db_engine):
    session_factory = async_sessionmaker(db_engine, class_=AsyncSession, expire_on_commit=False)
    async with session_factory() as session:
        yield session


@pytest_asyncio.fixture
async def test_app(db_engine):
    from backend.main import app
    from backend.infrastructure.database import async_session_factory, engine as main_engine

    import backend.infrastructure.database as db_module
    import backend.infrastructure.database.database as db_core_module

    original_factory = async_session_factory
    original_engine = main_engine
    original_core_factory = db_core_module.async_session_factory
    original_core_engine = db_core_module.engine

    new_factory = async_sessionmaker(db_engine, class_=AsyncSession, expire_on_commit=False)

    db_module.engine = db_engine
    db_module.async_session_factory = new_factory
    db_core_module.engine = db_engine
    db_core_module.async_session_factory = new_factory

    yield app

    db_module.engine = original_engine
    db_module.async_session_factory = original_factory
    db_core_module.engine = original_core_engine
    db_core_module.async_session_factory = original_core_factory


@pytest_asyncio.fixture
async def client(test_app):
    transport = ASGITransport(app=test_app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


@pytest_asyncio.fixture
async def seed_org_and_user(db_session):
    from backend.infrastructure.database.models import OrganizationModel, UserModel
    from passlib.context import CryptContext

    pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
    org_id = str(uuid4())
    user_id = str(uuid4())

    org = OrganizationModel(
        id=org_id,
        name="Test Org",
        slug="test-org",
    )
    db_session.add(org)

    user = UserModel(
        id=user_id,
        organization_id=org_id,
        email="admin@test.com",
        password_hash=pwd_context.hash("password123"),
        name="Admin User",
        role="admin",
        permissions=[p.value for p in Permission],
    )
    db_session.add(user)
    await db_session.commit()
    return {"org_id": org_id, "user_id": user_id, "email": "admin@test.com", "password": "password123"}


@pytest_asyncio.fixture
async def auth_token(client, seed_org_and_user):
    response = await client.post("/api/v1/auth/login", json={
        "email": seed_org_and_user["email"],
        "password": seed_org_and_user["password"],
    })
    assert response.status_code == 200
    data = response.json()
    return data["access_token"]


@pytest_asyncio.fixture
async def auth_headers(auth_token):
    return {"Authorization": f"Bearer {auth_token}"}


@pytest.mark.asyncio
class TestHealth:
    async def test_health_endpoint(self, client, auth_headers):
        response = await client.get("/api/v1/health", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "status" in data
        assert "uptime_seconds" in data
        assert "database" in data
        assert "version" in data


@pytest.mark.asyncio
class TestAuth:
    async def test_login_success(self, client, seed_org_and_user):
        response = await client.post("/api/v1/auth/login", json={
            "email": seed_org_and_user["email"],
            "password": seed_org_and_user["password"],
        })
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "bearer"
        assert data["expires_in"] > 0

    async def test_login_invalid_credentials(self, client):
        response = await client.post("/api/v1/auth/login", json={
            "email": "nonexistent@test.com",
            "password": "wrongpassword",
        })
        assert response.status_code == 401

    async def test_get_me(self, client, auth_headers):
        response = await client.get("/api/v1/auth/me", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["email"] == "admin@test.com"


@pytest.mark.asyncio
class TestOrganizations:
    async def test_create_organization(self, client, auth_headers):
        response = await client.post(
            "/api/v1/organizations/?name=New Org&slug=new-org",
            headers=auth_headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "New Org"
        assert data["slug"] == "new-org"

    async def test_list_organizations(self, client, auth_headers):
        response = await client.get("/api/v1/organizations/", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "items" in data
        assert "total" in data

    async def test_get_organization(self, client, auth_headers, seed_org_and_user):
        org_id = seed_org_and_user["org_id"]
        response = await client.get(f"/api/v1/organizations/{org_id}", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Test Org"

    async def test_get_organization_not_found(self, client, auth_headers):
        response = await client.get(f"/api/v1/organizations/{uuid4()}", headers=auth_headers)
        assert response.status_code == 404

    async def test_update_organization(self, client, auth_headers, seed_org_and_user):
        org_id = seed_org_and_user["org_id"]
        response = await client.put(
            f"/api/v1/organizations/{org_id}?name=Updated Org",
            headers=auth_headers,
        )
        assert response.status_code == 200
        assert response.json()["name"] == "Updated Org"

    async def test_delete_organization(self, client, auth_headers, seed_org_and_user):
        org_id = seed_org_and_user["org_id"]
        response = await client.delete(f"/api/v1/organizations/{org_id}", headers=auth_headers)
        assert response.status_code == 200
        assert response.json()["detail"] == "Organization suspended"

    async def test_get_organization_stats(self, client, auth_headers, seed_org_and_user):
        org_id = seed_org_and_user["org_id"]
        response = await client.get(f"/api/v1/organizations/{org_id}/stats", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "total_conversations" in data
        assert "total_leads" in data
        assert "total_users" in data


@pytest.mark.asyncio
class TestConversations:
    async def test_list_conversations(self, client, auth_headers, seed_org_and_user):
        org_id = seed_org_and_user["org_id"]
        response = await client.get("/api/v1/conversations/", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "items" in data
        assert "total" in data


@pytest.mark.asyncio
class TestLeads:
    async def test_create_lead(self, client, auth_headers, seed_org_and_user):
        response = await client.post(
            "/api/v1/crm/leads?customer_phone=%2B1234567890&customer_name=John",
            headers=auth_headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["customer_phone"] == "+1234567890"
        assert data["customer_name"] == "John"
        assert data["status"] == "new"
        assert data["source"] == "whatsapp"

    async def test_list_leads(self, client, auth_headers, seed_org_and_user):
        response = await client.get("/api/v1/crm/leads", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "items" in data
        assert "total" in data

    async def test_get_lead(self, client, auth_headers, seed_org_and_user):
        create_resp = await client.post(
            "/api/v1/crm/leads?customer_phone=%2B5555555555&customer_name=Jane",
            headers=auth_headers,
        )
        lead_id = create_resp.json()["id"]
        response = await client.get(f"/api/v1/crm/leads/{lead_id}", headers=auth_headers)
        assert response.status_code == 200
        assert response.json()["customer_name"] == "Jane"

    async def test_update_lead(self, client, auth_headers, seed_org_and_user):
        create_resp = await client.post(
            "/api/v1/crm/leads?customer_phone=%2B1111111111",
            headers=auth_headers,
        )
        lead_id = create_resp.json()["id"]
        response = await client.put(
            f"/api/v1/crm/leads/{lead_id}?status=qualified",
            headers=auth_headers,
        )
        assert response.status_code == 200
        assert response.json()["status"] == "qualified"

    async def test_update_lead_stage(self, client, auth_headers, seed_org_and_user):
        create_resp = await client.post(
            "/api/v1/crm/leads?customer_phone=%2B2222222222",
            headers=auth_headers,
        )
        lead_id = create_resp.json()["id"]
        response = await client.patch(
            f"/api/v1/crm/leads/{lead_id}/stage?pipeline_stage=proposal",
            headers=auth_headers,
        )
        assert response.status_code == 200
        assert response.json()["pipeline_stage"] == "proposal"

    async def test_update_lead_score(self, client, auth_headers, seed_org_and_user):
        create_resp = await client.post(
            "/api/v1/crm/leads?customer_phone=%2B3333333333",
            headers=auth_headers,
        )
        lead_id = create_resp.json()["id"]
        response = await client.patch(
            f"/api/v1/crm/leads/{lead_id}/score?score=85.5",
            headers=auth_headers,
        )
        assert response.status_code == 200
        assert response.json()["score"] == 85.5

    async def test_assign_lead(self, client, auth_headers, seed_org_and_user):
        create_resp = await client.post(
            "/api/v1/crm/leads?customer_phone=%2B4444444444",
            headers=auth_headers,
        )
        lead_id = create_resp.json()["id"]
        user_id = seed_org_and_user["user_id"]
        response = await client.patch(
            f"/api/v1/crm/leads/{lead_id}/assign?assigned_to={user_id}",
            headers=auth_headers,
        )
        assert response.status_code == 200
        assert response.json()["assigned_to"] == user_id

    async def test_add_lead_note(self, client, auth_headers, seed_org_and_user):
        create_resp = await client.post(
            "/api/v1/crm/leads?customer_phone=%2B6666666666",
            headers=auth_headers,
        )
        lead_id = create_resp.json()["id"]
        response = await client.post(
            f"/api/v1/crm/leads/{lead_id}/notes?content=Interested in premium plan",
            headers=auth_headers,
        )
        assert response.status_code == 200
        assert len(response.json()["notes"]) == 1

    async def test_lead_convert_to_customer(self, client, auth_headers, seed_org_and_user):
        create_resp = await client.post(
            "/api/v1/crm/leads?customer_phone=%2B7777777777&customer_name=ConvertedUser&customer_email=user@test.com",
            headers=auth_headers,
        )
        lead_id = create_resp.json()["id"]
        response = await client.post(
            f"/api/v1/crm/leads/{lead_id}/convert",
            headers=auth_headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["phone"] == "+7777777777"
        assert data["name"] == "ConvertedUser"


@pytest.mark.asyncio
class TestCustomers:
    async def test_list_customers(self, client, auth_headers, seed_org_and_user):
        response = await client.get("/api/v1/crm/customers", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "items" in data

    async def test_get_customer(self, client, auth_headers, seed_org_and_user):
        create_resp = await client.post(
            "/api/v1/crm/leads?customer_phone=%2B8888888888&customer_name=Customer1",
            headers=auth_headers,
        )
        lead_id = create_resp.json()["id"]
        conv_resp = await client.post(f"/api/v1/crm/leads/{lead_id}/convert", headers=auth_headers)
        customer_id = conv_resp.json()["id"]
        response = await client.get(f"/api/v1/crm/customers/{customer_id}", headers=auth_headers)
        assert response.status_code == 200
        assert response.json()["name"] == "Customer1"


@pytest.mark.asyncio
class TestWhatsApp:
    async def test_create_whatsapp_account(self, client, auth_headers, seed_org_and_user):
        response = await client.post(
            "/api/v1/whatsapp/accounts?phone_number=%2B15551234567&business_name=TestBiz",
            headers=auth_headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["phone_number"] == "+15551234567"
        assert data["business_name"] == "TestBiz"

    async def test_list_whatsapp_accounts(self, client, auth_headers):
        response = await client.get("/api/v1/whatsapp/accounts", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "items" in data


@pytest.mark.asyncio
class TestKnowledge:
    async def test_add_faq(self, client, auth_headers):
        response = await client.post(
            "/api/v1/knowledge/faq?title=Return Policy&content=30 day return policy",
            headers=auth_headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["title"] == "Return Policy"
        assert data["type"] == "faq"

    async def test_list_knowledge(self, client, auth_headers):
        response = await client.get("/api/v1/knowledge/", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "items" in data


@pytest.mark.asyncio
class TestWorkflows:
    async def test_create_workflow(self, client, auth_headers):
        response = await client.post(
            "/api/v1/workflows/?name=Auto Reply&trigger_type=new_message",
            headers=auth_headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "Auto Reply"
        assert data["trigger_type"] == "new_message"

    async def test_list_workflows(self, client, auth_headers):
        response = await client.get("/api/v1/workflows/", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "items" in data


@pytest.mark.asyncio
class TestCampaigns:
    async def test_create_campaign(self, client, auth_headers):
        response = await client.post(
            "/api/v1/campaigns/?name=Summer Sale&message_template=Check out our sale!",
            headers=auth_headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "Summer Sale"
        assert data["status"] == "draft"

    async def test_list_campaigns(self, client, auth_headers):
        response = await client.get("/api/v1/campaigns/", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "items" in data
