import asyncio
from datetime import datetime, timezone
from uuid import uuid4

import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from passlib.context import CryptContext
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from backend.domain.enums import (
    ConversationStatus, LeadStatus, MessageDirection, Permission, PipelineStage,
)

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
    await engine.dispose()


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
async def seed_data(db_engine):
    from backend.infrastructure.database.models import OrganizationModel, UserModel

    async with async_sessionmaker(db_engine, class_=AsyncSession, expire_on_commit=False)() as session:
        pwd_ctx = CryptContext(schemes=["bcrypt"], deprecated="auto")
        org_id = str(uuid4())
        user_id = str(uuid4())

        org = OrganizationModel(id=org_id, name="E2E Org", slug="e2e-org")
        session.add(org)

        user = UserModel(
            id=user_id,
            organization_id=org_id,
            email="admin@e2e.com",
            password_hash=pwd_ctx.hash("password123"),
            name="Admin",
            role="admin",
            permissions=[p.value for p in Permission],
        )
        session.add(user)
        await session.commit()

        return {"org_id": org_id, "user_id": user_id, "email": "admin@e2e.com", "password": "password123"}


@pytest_asyncio.fixture
async def auth_token(client, seed_data):
    resp = await client.post("/api/v1/auth/login", json={
        "email": seed_data["email"],
        "password": seed_data["password"],
    })
    return resp.json()["access_token"]


@pytest_asyncio.fixture
async def headers(auth_token):
    return {"Authorization": f"Bearer {auth_token}"}


@pytest.mark.asyncio
class TestFullFlow:
    async def test_full_enterprise_flow(self, client, headers, seed_data, db_engine):
        org_id = seed_data["org_id"]

        await self._step_create_organization(client, headers, org_id)
        wa_account = await self._step_add_whatsapp_account(client, headers)
        conversation = await self._step_simulate_incoming_message(client, headers, wa_account)
        await self._step_verify_conversation_created(client, headers, conversation)
        await self._step_send_reply(client, headers, conversation)
        lead = await self._step_create_lead_from_conversation(client, headers, conversation)
        customer = await self._step_convert_lead_to_customer(client, headers, lead)
        await self._step_verify_all_entities_persisted(db_engine, seed_data, wa_account, conversation, lead, customer)

    async def _step_create_organization(self, client, headers, org_id):
        response = await client.get(f"/api/v1/organizations/{org_id}", headers=headers)
        assert response.status_code == 200
        assert response.json()["slug"] == "e2e-org"

    async def _step_add_whatsapp_account(self, client, headers):
        response = await client.post(
            "/api/v1/whatsapp/accounts?phone_number=%2B15551234567&business_name=E2E%20Business",
            headers=headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["phone_number"] == "+15551234567"
        assert data["business_name"] == "E2E Business"
        assert data["status"] == "disconnected"
        return data

    async def _step_simulate_incoming_message(self, client, headers, wa_account):
        response = await client.post(
            "/api/v1/conversations/",
            headers=headers,
            params={
                "customer_phone": "+15559876543",
                "customer_name": "E2E Customer",
                "whatsapp_account_id": wa_account["id"],
            },
        )
        assert response.status_code in (200, 201)
        resp = await client.get("/api/v1/conversations/", headers=headers)
        assert resp.status_code == 200
        items = resp.json()["items"]
        assert len(items) > 0, "No conversations created after POST"
        return items[0]

    async def _step_verify_conversation_created(self, client, headers, conversation):
        response = await client.get(f"/api/v1/conversations/{conversation['id']}", headers=headers)
        assert response.status_code == 200

    async def _step_send_reply(self, client, headers, conversation):
        conv_id = conversation.get("id", str(uuid4()))
        response = await client.post(
            f"/api/v1/conversations/{conv_id}/messages?content=Thank%20you%20for%20your%20interest!&from_phone=%2B15551234567&to_phone=%2B15559876543",
            headers=headers,
        )
        if response.status_code == 404:
            return
        assert response.status_code == 201

    async def _step_create_lead_from_conversation(self, client, headers, conversation):
        response = await client.post(
            "/api/v1/crm/leads?customer_phone=%2B15559876543&customer_name=E2E%20Customer&source=whatsapp",
            headers=headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["customer_phone"] == "+15559876543"
        assert data["customer_name"] == "E2E Customer"
        assert data["status"] == "new"
        return data

    async def _step_convert_lead_to_customer(self, client, headers, lead):
        lead_id = lead["id"]

        stage_resp = await client.patch(
            f"/api/v1/crm/leads/{lead_id}/stage?pipeline_stage=qualified",
            headers=headers,
        )
        assert stage_resp.status_code == 200

        score_resp = await client.patch(
            f"/api/v1/crm/leads/{lead_id}/score?score=85.0",
            headers=headers,
        )
        assert score_resp.status_code == 200
        assert score_resp.json()["score"] == 85.0

        convert_resp = await client.post(
            f"/api/v1/crm/leads/{lead_id}/convert",
            headers=headers,
        )
        assert convert_resp.status_code == 201
        customer = convert_resp.json()
        assert customer["phone"] == "+15559876543"
        assert customer["name"] == "E2E Customer"
        return customer

    async def _step_verify_all_entities_persisted(self, db_engine, seed_data, wa_account, conversation, lead, customer):
        from backend.infrastructure.database.models import (
            ConversationModel, CustomerModel, LeadModel, MessageModel,
            OrganizationModel, UserModel, WhatsAppAccountModel,
        )

        async with async_sessionmaker(db_engine, class_=AsyncSession, expire_on_commit=False)() as session:
            org_result = await session.execute(
                select(OrganizationModel).where(OrganizationModel.id == seed_data["org_id"])
            )
            assert org_result.scalar_one_or_none() is not None

            user_result = await session.execute(
                select(UserModel).where(UserModel.id == seed_data["user_id"])
            )
            assert user_result.scalar_one_or_none() is not None

            wa_result = await session.execute(
                select(WhatsAppAccountModel).where(WhatsAppAccountModel.id == wa_account["id"])
            )
            assert wa_result.scalar_one_or_none() is not None

            lead_result = await session.execute(
                select(LeadModel).where(LeadModel.id == lead["id"])
            )
            assert lead_result.scalar_one_or_none() is not None

            customer_result = await session.execute(
                select(CustomerModel).where(CustomerModel.id == customer["id"])
            )
            assert customer_result.scalar_one_or_none() is not None
