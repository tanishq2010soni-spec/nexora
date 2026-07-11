import uuid
from unittest.mock import AsyncMock, MagicMock, patch
import pytest
from httpx import AsyncClient

from src.presentation.api.dependencies import get_current_org_id, get_rag_service
from src.main import app

# Mocks and testing IDs
TEST_ORG_ID = uuid.uuid4()
TEST_AGENT_ID = uuid.uuid4()
TEST_SESSION_ID = uuid.uuid4()


@pytest.mark.asyncio
async def test_create_chat_session_success(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    """
    Tests instantiation of a chat session.
    """
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    # Mock agent validation search (scalar_one_or_none returns a dummy agent model)
    from src.infrastructure.database.models import Agent
    mock_agent = Agent(id=TEST_AGENT_ID, org_id=TEST_ORG_ID)
    
    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = mock_agent
    mock_db_session.execute.return_value = mock_execute

    payload = {
        "agent_id": str(TEST_AGENT_ID),
        "customer_phone": "+123456789"
    }

    response = await client.post("/api/v1/chat/sessions", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert "session_id" in data
    assert data["customer_phone"] == "+123456789"

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_send_chat_message_success(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    """
    Tests that a chat message flows through successfully, mock-executing the RAG pipeline.
    """
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    # Mock session check (returns a active ChatSession model linked to Agent)
    from src.infrastructure.database.models import ChatSession
    mock_session = ChatSession(id=TEST_SESSION_ID, agent_id=TEST_AGENT_ID, external_user_id="+123456789", status="active")
    
    mock_execute = MagicMock()
    mock_execute.scalar_one_or_none.return_value = mock_session
    mock_db_session.execute.return_value = mock_execute

    # Mock the RAG service execution results to isolate from actual AI runtime connections
    mock_rag_result = {
        "response": "Hello, I am Nexora. We offer custom agent setups. How can I help you?",
        "sources": ["kb_services.txt"],
        "lead_captured": True
    }

    mock_rag_service = AsyncMock()
    mock_rag_service.execute_chat_turn.return_value = mock_rag_result
    app.dependency_overrides[get_rag_service] = lambda db=None: mock_rag_service

    payload = {
        "message": "What services do you offer?"
    }

    response = await client.post(f"/api/v1/chat/sessions/{TEST_SESSION_ID}/message", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "response" in data
    assert "Nexora" in data["response"]
    assert data["sources"] == ["kb_services.txt"]
    assert data["lead_captured"] is True

    app.dependency_overrides.clear()
