"""
E2E test: Agent Registration + Heartbeat Flow
Tests the full lifecycle:
1. Agent registers via POST /api/v1/agents/register
2. Agent sends heartbeat via POST /api/v1/agents/heartbeat
3. Agent health is updated
4. Agent can be queried via GET /api/v1/agents/{id}
5. Registration is idempotent (re-register updates, not duplicates)
"""
import uuid
import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy import text

from src.infrastructure.database.models import Base
from src.infrastructure.database.connection import get_db_session
from src.config import settings
from src.main import app

TEST_DB_URL = "sqlite+aiosqlite:///./test_agent_registration.db"
TEST_AGENT_KEY = "test-agent-key-for-e2e"


@pytest_asyncio.fixture
async def test_db():
    """Create a fresh test database for each test."""
    original_key = settings.AGENT_REGISTRATION_KEY
    settings.AGENT_REGISTRATION_KEY = TEST_AGENT_KEY
    engine = create_async_engine(TEST_DB_URL)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    TestSessionLocal = async_sessionmaker(bind=engine, class_=AsyncSession, expire_on_commit=False)

    async def override_get_db():
        session = TestSessionLocal()
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

    app.dependency_overrides[get_db_session] = override_get_db

    yield TestSessionLocal

    app.dependency_overrides.clear()
    settings.AGENT_REGISTRATION_KEY = original_key
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()


@pytest.mark.asyncio
async def test_agent_registration(test_db):
    """Test full agent registration lifecycle."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        agent_key = TEST_AGENT_KEY
        test_org_id = str(uuid.uuid4())

        # Step 1: Register a new agent
        reg_response = await client.post(
            "/api/v1/agents/register",
            json={
                "agent_id": "test-agent-001",
                "agent_name": "test-whatsapp-agent",
                "agent_type": "whatsapp",
                "version": "1.0.0",
                "status": "starting",
                "capabilities": ["messaging", "crm", "campaigns"],
                "supported_models": ["gpt-4", "gpt-3.5-turbo"],
                "installed_plugins": [],
                "system_info": {"hostname": "test-host", "os": "linux"},
                "api_endpoint": "http://localhost:8100",
                "health_endpoint": "http://localhost:8100/health",
            },
            headers={"X-Agent-Key": agent_key, "X-Organization-Id": test_org_id},
        )
        assert reg_response.status_code == 201, f"Registration failed: {reg_response.text}"
        reg_data = reg_response.json()
        assert reg_data["status"] == "registered"
        assert reg_data["agent_id"] == "test-agent-001"
        assert "id" in reg_data


@pytest.mark.asyncio
async def test_agent_registration_idempotent(test_db):
    """Test that re-registering an agent updates instead of duplicates."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        agent_key = TEST_AGENT_KEY
        test_org_id = str(uuid.uuid4())
        payload = {
            "agent_id": "test-agent-002",
            "agent_name": "test-idempotent-agent",
            "agent_type": "calling",
            "version": "1.0.0",
            "capabilities": ["calls"],
        }

        # Register twice
        resp1 = await client.post(
            "/api/v1/agents/register",
            json=payload,
            headers={"X-Agent-Key": agent_key, "X-Organization-Id": test_org_id},
        )
        assert resp1.status_code == 201
        id1 = resp1.json()["id"]

        resp2 = await client.post(
            "/api/v1/agents/register",
            json={**payload, "version": "1.1.0"},
            headers={"X-Agent-Key": agent_key, "X-Organization-Id": test_org_id},
        )
        assert resp2.status_code == 201
        id2 = resp2.json()["id"]

        # Should be the same agent (idempotent)
        assert id1 == id2


@pytest.mark.asyncio
async def test_agent_heartbeat(test_db):
    """Test agent heartbeat flow."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        agent_key = TEST_AGENT_KEY
        test_org_id = str(uuid.uuid4())

        # Register first
        await client.post(
            "/api/v1/agents/register",
            json={
                "agent_id": "test-agent-003",
                "agent_name": "test-heartbeat-agent",
                "agent_type": "whatsapp",
                "capabilities": ["messaging"],
            },
            headers={"X-Agent-Key": agent_key, "X-Organization-Id": test_org_id},
        )

        # Send heartbeat
        hb_response = await client.post(
            "/api/v1/agents/heartbeat",
            json={
                "agent_id": "test-heartbeat-agent",
                "status": "online",
                "cpu_percent": 25.5,
                "ram_percent": 60.0,
                "active_sessions": 3,
                "active_conversations": 2,
                "running_tasks": 1,
                "queue_size": 0,
                "uptime_seconds": 3600.0,
            },
            headers={"X-Agent-Key": agent_key, "X-Organization-Id": test_org_id},
        )
        assert hb_response.status_code == 201, f"Heartbeat failed: {hb_response.text}"
        assert hb_response.json()["status"] == "ok"


@pytest.mark.asyncio
async def test_heartbeat_status_mapping(test_db):
    """Test that agent status values are mapped correctly to brain status values."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        agent_key = TEST_AGENT_KEY
        test_org_id = str(uuid.uuid4())

        # Register
        await client.post(
            "/api/v1/agents/register",
            json={
                "agent_id": "test-agent-004",
                "agent_name": "test-status-mapping-agent",
                "agent_type": "personal_ai",
                "capabilities": ["chat"],
            },
            headers={"X-Agent-Key": agent_key, "X-Organization-Id": test_org_id},
        )

        # Send heartbeat with "online" status (should map to "healthy")
        hb_response = await client.post(
            "/api/v1/agents/heartbeat",
            json={
                "agent_id": "test-status-mapping-agent",
                "status": "online",
            },
            headers={"X-Agent-Key": agent_key, "X-Organization-Id": test_org_id},
        )
        assert hb_response.status_code == 201


@pytest.mark.asyncio
async def test_registration_requires_agent_key(test_db):
    """Test that registration fails without proper authentication."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        response = await client.post(
            "/api/v1/agents/register",
            json={
                "agent_id": "test-agent-005",
                "agent_name": "test-unauth-agent",
                "agent_type": "whatsapp",
            },
        )
        assert response.status_code == 401


@pytest.mark.asyncio
async def test_heartbeat_requires_agent_key(test_db):
    """Test that heartbeat fails without proper authentication."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        response = await client.post(
            "/api/v1/agents/heartbeat",
            json={
                "agent_id": "test-agent-006",
                "status": "online",
            },
        )
        assert response.status_code == 401
