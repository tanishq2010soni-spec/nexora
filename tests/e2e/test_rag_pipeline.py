import uuid
from unittest.mock import AsyncMock, MagicMock, patch
import pytest
from httpx import AsyncClient

from src.application.services.rag_service import RAGService
from src.domain.models.lead import Lead
from src.domain.models.customer import Customer
from src.presentation.api.dependencies import get_current_org_id, get_rag_service, get_document_service
from src.main import app

TEST_ORG_ID = uuid.uuid4()
TEST_AGENT_ID = uuid.uuid4()
TEST_SESSION_ID = uuid.uuid4()
TEST_KB_ID = uuid.uuid4()


@pytest.mark.asyncio
async def test_rag_document_upload_validation(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    """Verify document upload validates file type and size."""
    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    mock_execute = MagicMock()
    mock_kb = MagicMock()
    mock_kb.id = TEST_KB_ID
    mock_kb.org_id = TEST_ORG_ID
    mock_execute.scalar_one_or_none.return_value = mock_kb
    mock_db_session.execute.return_value = mock_execute

    response = await client.post(
        f"/api/v1/documents/upload?kb_id={TEST_KB_ID}",
        files={"file": ("test.exe", b"fake binary content", "application/x-msdownload")},
    )
    assert response.status_code == 400
    assert "Unsupported file extension" in response.json()["detail"]

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_rag_embedding_generation_and_indexing(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    """Verify the RAG pipeline generates embeddings and indexes into vector DB."""
    from src.infrastructure.embeddings.transformer_embeddings import SentenceTransformersEmbeddingService
    from src.infrastructure.vector.qdrant_service import QdrantVectorRepository

    mock_embedding = AsyncMock(spec=SentenceTransformersEmbeddingService)
    mock_embedding.generate_embedding.return_value = [0.1] * 384
    mock_embedding.dimension = 384

    mock_vector_db = AsyncMock(spec=QdrantVectorRepository)
    mock_vector_db.search.return_value = [
        {
            "id": str(uuid.uuid4()),
            "score": 0.95,
            "text": "Our business hours are Mon-Fri 9AM-5PM.",
            "metadata": {"filename": "policies.txt", "org_id": str(TEST_ORG_ID)},
            "document_id": str(uuid.uuid4()),
        }
    ]

    mock_llm = AsyncMock()
    mock_llm.generate_response.return_value = "Our business hours are Monday to Friday, 9AM to 5PM."
    mock_llm.generate_structured_json.return_value = {
        "name": None,
        "email": None,
        "intent": "inquiry",
        "product_interest": None,
        "budget": None,
    }

    mock_customer_repo = AsyncMock()
    mock_customer_repo.get_by_phone.return_value = Customer(
        org_id=TEST_ORG_ID,
        phone="+1234567890",
        name="Test User",
        preferences="Interested in AI agents",
    )

    mock_lead_repo = AsyncMock()
    mock_lead_repo.find_duplicate.return_value = None

    rag_service = RAGService(
        embedding_service=mock_embedding,
        vector_db=mock_vector_db,
        llm_service=mock_llm,
        customer_repo=mock_customer_repo,
        lead_repo=mock_lead_repo,
    )

    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID
    app.dependency_overrides[get_rag_service] = lambda db=None: rag_service

    mock_execute = MagicMock()
    mock_session = MagicMock()
    mock_session.id = TEST_SESSION_ID
    mock_session.agent_id = TEST_AGENT_ID
    mock_session.external_user_id = "+1234567890"
    mock_session.status = "active"
    mock_execute.scalar_one_or_none.return_value = mock_session
    mock_db_session.execute.return_value = mock_execute

    response = await client.post(
        f"/api/v1/chat/sessions/{TEST_SESSION_ID}/message",
        json={"message": "What are your business hours?"},
    )

    assert response.status_code == 200
    data = response.json()
    assert "response" in data
    assert "sources" in data
    assert data["sources"] == ["policies.txt"]

    mock_embedding.generate_embedding.assert_awaited_once_with("What are your business hours?")
    mock_vector_db.search.assert_awaited_once()

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_rag_context_injection_and_lead_extraction(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    """Verify context injection and lead extraction work end-to-end."""
    mock_embedding = AsyncMock()
    mock_embedding.generate_embedding.return_value = [0.1] * 384
    mock_embedding.dimension = 384

    mock_vector_db = AsyncMock()
    mock_vector_db.search.return_value = [
        {
            "id": str(uuid.uuid4()),
            "score": 0.92,
            "text": "We offer AI receptionist services starting at $499/month.",
            "metadata": {"filename": "services.pdf", "org_id": str(TEST_ORG_ID)},
            "document_id": str(uuid.uuid4()),
        }
    ]

    mock_llm = AsyncMock()
    mock_llm.generate_response.return_value = (
        "Thank you for your interest, John! Our AI receptionist service starts at $499 per month."
    )
    mock_llm.generate_structured_json.return_value = {
        "name": "John Doe",
        "email": "john@example.com",
        "intent": "purchase",
        "product_interest": "AI receptionist",
        "budget": 500.0,
    }

    mock_customer_repo = AsyncMock()
    mock_customer_repo.get_by_phone.return_value = Customer(
        org_id=TEST_ORG_ID,
        phone="+1987654321",
        name=None,
        preferences="First interaction",
    )

    mock_lead_repo = AsyncMock()
    mock_lead_repo.find_duplicate.return_value = None
    mock_lead_repo.create.return_value = Lead(
        org_id=TEST_ORG_ID,
        session_id=TEST_SESSION_ID,
        name="John Doe",
        phone="+1987654321",
        email="john@example.com",
        intent="purchase",
        product_interest="AI receptionist",
        budget=500.0,
    )

    rag_service = RAGService(
        embedding_service=mock_embedding,
        vector_db=mock_vector_db,
        llm_service=mock_llm,
        customer_repo=mock_customer_repo,
        lead_repo=mock_lead_repo,
    )

    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID
    app.dependency_overrides[get_rag_service] = lambda db=None: rag_service

    mock_execute = MagicMock()
    mock_session = MagicMock()
    mock_session.id = TEST_SESSION_ID
    mock_session.agent_id = TEST_AGENT_ID
    mock_session.external_user_id = "+1987654321"
    mock_session.status = "active"
    mock_execute.scalar_one_or_none.return_value = mock_session
    mock_db_session.execute.return_value = mock_execute

    response = await client.post(
        f"/api/v1/chat/sessions/{TEST_SESSION_ID}/message",
        json={"message": "I'm John Doe, interested in your AI receptionist. My budget is $500."},
    )

    assert response.status_code == 200
    data = response.json()
    assert "response" in data
    assert "AI receptionist" in data["response"]
    assert data["lead_captured"] is True
    assert "$499" in data["response"]

    mock_llm.generate_structured_json.assert_awaited_once()
    mock_lead_repo.create.assert_awaited_once()
    mock_customer_repo.update.assert_awaited_once()

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_rag_lead_deduplication(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    """Verify duplicate leads are not created for the same customer."""
    mock_embedding = AsyncMock()
    mock_embedding.generate_embedding.return_value = [0.1] * 384

    mock_vector_db = AsyncMock()
    mock_vector_db.search.return_value = []

    mock_llm = AsyncMock()
    mock_llm.generate_response.return_value = "I see you're interested John. Let me help you."
    mock_llm.generate_structured_json.return_value = {
        "name": "John Doe",
        "email": "john@example.com",
        "intent": "purchase",
        "product_interest": "AI receptionist",
        "budget": 500.0,
    }

    mock_customer_repo = AsyncMock()
    mock_customer_repo.get_by_phone.return_value = Customer(
        org_id=TEST_ORG_ID,
        phone="+1987654321",
        name="John Doe",
        preferences="Interested in AI receptionist",
    )

    existing_lead = Lead(
        org_id=TEST_ORG_ID,
        session_id=TEST_SESSION_ID,
        name="John Doe",
        phone="+1987654321",
        email="john@example.com",
    )
    mock_lead_repo = AsyncMock()
    mock_lead_repo.find_duplicate.return_value = existing_lead

    rag_service = RAGService(
        embedding_service=mock_embedding,
        vector_db=mock_vector_db,
        llm_service=mock_llm,
        customer_repo=mock_customer_repo,
        lead_repo=mock_lead_repo,
    )

    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID
    app.dependency_overrides[get_rag_service] = lambda db=None: rag_service

    mock_execute = MagicMock()
    mock_session = MagicMock()
    mock_session.id = TEST_SESSION_ID
    mock_session.agent_id = TEST_AGENT_ID
    mock_session.external_user_id = "+1987654321"
    mock_session.status = "active"
    mock_execute.scalar_one_or_none.return_value = mock_session
    mock_db_session.execute.return_value = mock_execute

    response = await client.post(
        f"/api/v1/chat/sessions/{TEST_SESSION_ID}/message",
        json={"message": "I want the AI receptionist."},
    )

    assert response.status_code == 200
    mock_lead_repo.find_duplicate.assert_awaited_once()
    mock_lead_repo.create.assert_not_awaited()

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_rag_llama3_response_generation(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    """Verify the LLM response generation via the direct completion endpoint."""
    from src.infrastructure.llm.ollama_client import OllamaClient

    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

    mock_client = AsyncMock(spec=OllamaClient)
    mock_client.generate_response.return_value = (
        "I am Nexora, your AI receptionist. How can I help you today?"
    )

    with patch("src.presentation.api.v1.chat.ollama_client_singleton", mock_client):
        response = await client.post(
            "/api/v1/chat/completions",
            json={"message": "Who are you?"},
        )

        assert response.status_code == 200
        data = response.json()
        assert data["response"] == "I am Nexora, your AI receptionist. How can I help you today?"
        assert data["model"] == "llama3"
        assert data["finish_reason"] == "stop"

    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_rag_pipeline_full_flow(client: AsyncClient, mock_db_session: AsyncMock) -> None:
    """Full end-to-end RAG pipeline including all steps."""
    mock_embedding = AsyncMock()
    mock_embedding.generate_embedding.return_value = [0.1] * 384
    mock_embedding.dimension = 384

    mock_vector_db = AsyncMock()
    mock_vector_db.search.return_value = [
        {
            "id": str(uuid.uuid4()),
            "score": 0.88,
            "text": "Our return policy allows returns within 30 days of purchase.",
            "metadata": {"filename": "returns.pdf", "org_id": str(TEST_ORG_ID)},
            "document_id": str(uuid.uuid4()),
        }
    ]

    mock_llm = AsyncMock()
    mock_llm.generate_response.return_value = (
        "Our return policy allows returns within 30 days of purchase. Would you like more details?"
    )
    mock_llm.generate_structured_json.return_value = {
        "name": "Jane",
        "email": "jane@test.com",
        "intent": "return inquiry",
        "product_interest": "AI receptionist",
        "budget": None,
    }

    mock_customer_repo = AsyncMock()
    mock_customer_repo.get_by_phone.return_value = Customer(
        org_id=TEST_ORG_ID,
        phone="+1112223333",
        name=None,
        preferences="First interaction",
    )

    mock_lead_repo = AsyncMock()
    mock_lead_repo.find_duplicate.return_value = None
    mock_lead_repo.create.return_value = Lead(
        org_id=TEST_ORG_ID,
        session_id=TEST_SESSION_ID,
        name="Jane",
        phone="+1112223333",
        email="jane@test.com",
        intent="return inquiry",
        product_interest="AI receptionist",
    )

    rag_service = RAGService(
        embedding_service=mock_embedding,
        vector_db=mock_vector_db,
        llm_service=mock_llm,
        customer_repo=mock_customer_repo,
        lead_repo=mock_lead_repo,
    )

    app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID
    app.dependency_overrides[get_rag_service] = lambda db=None: rag_service

    # Setup mock DB returns for all queries in the request: session check, agent, profile, history
    mock_session_magic = MagicMock()
    mock_session_magic.id = TEST_SESSION_ID
    mock_session_magic.agent_id = TEST_AGENT_ID
    mock_session_magic.external_user_id = "+1112223333"
    mock_session_magic.status = "active"

    mock_agent_magic = MagicMock()
    mock_agent_magic.id = TEST_AGENT_ID
    mock_agent_magic.org_id = TEST_ORG_ID
    mock_agent_magic.temperature = 0.7

    def make_exec(return_val):
        m = MagicMock()
        m.scalar_one_or_none.return_value = return_val
        return m

    def make_scalars(return_list):
        m = MagicMock()
        m.scalars.return_value.all.return_value = return_list
        return m

    mock_db_session.execute.side_effect = [
        make_exec(mock_session_magic),  # session check in chat router
        make_exec(mock_agent_magic),     # agent query in RAG
        make_exec(None),                 # profile query
        make_scalars([]),                # history query
    ]

    response = await client.post(
        f"/api/v1/chat/sessions/{TEST_SESSION_ID}/message",
        json={"message": "What is your return policy?"},
    )

    assert response.status_code == 200
    data = response.json()
    assert "return policy" in data["response"].lower()
    assert data["lead_captured"] is True

    mock_embedding.generate_embedding.assert_called_once()
    mock_vector_db.search.assert_called_once()
    mock_llm.generate_response.assert_called_once()
    mock_llm.generate_structured_json.assert_called_once()
    mock_lead_repo.create.assert_called_once()

    app.dependency_overrides.clear()
