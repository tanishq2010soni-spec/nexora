import uuid
from unittest.mock import AsyncMock, MagicMock, patch

import httpx
import pytest
from httpx import AsyncClient

from src.config import settings
from src.infrastructure.llm.ollama_client import (
    OllamaClient,
    OllamaClientError,
    OllamaConnectionError,
    OllamaResponseError,
    OllamaTimeoutError,
)
from src.infrastructure.llm.ollama_service import OllamaLLMService, LLMServiceError
from src.presentation.api.dependencies import get_current_org_id
from src.main import app

TEST_ORG_ID = uuid.uuid4()

SAMPLE_CHAT_RESPONSE = {
    "model": "llama3",
    "message": {"role": "assistant", "content": "Hello! I am Nexora. How can I help you today?"},
    "done": True,
}

SAMPLE_STRUCTURED_RESPONSE = {
    "model": "llama3",
    "message": {
        "role": "assistant",
        "content": '{"name": "John", "intent": "booking", "product_interest": "AI agent"}',
    },
    "done": True,
}

SAMPLE_TAGS_RESPONSE = {"models": [{"name": "llama3:latest"}]}


# ==================== OllamaClient Tests ====================


class TestOllamaClient:
    @pytest.mark.asyncio
    async def test_chat_success(self):
        client = OllamaClient(max_retries=0)
        client._request = AsyncMock(return_value=SAMPLE_CHAT_RESPONSE)

        result = await client.chat(
            messages=[{"role": "user", "content": "hello"}],
            temperature=0.7,
        )

        assert result["message"]["content"] == "Hello! I am Nexora. How can I help you today?"
        assert result["model"] == "llama3"

    @pytest.mark.asyncio
    async def test_generate_response_success(self):
        client = OllamaClient(max_retries=0)
        client._request = AsyncMock(return_value=SAMPLE_CHAT_RESPONSE)

        response = await client.generate_response(prompt="hello")

        assert response == "Hello! I am Nexora. How can I help you today?"

    @pytest.mark.asyncio
    async def test_generate_response_with_system_prompt(self):
        client = OllamaClient(max_retries=0)
        mock = AsyncMock(return_value=SAMPLE_CHAT_RESPONSE)
        client._request = mock

        await client.generate_response(prompt="hello", system_prompt="You are a helpful assistant.")

        call_args = mock.call_args_list[0]
        json_data = call_args[1]["json_data"]
        messages = json_data["messages"]
        assert messages[0]["role"] == "system"
        assert messages[0]["content"] == "You are a helpful assistant."
        assert messages[-1]["role"] == "user"
        assert messages[-1]["content"] == "hello"

    @pytest.mark.asyncio
    async def test_generate_response_with_history(self):
        client = OllamaClient(max_retries=0)
        mock = AsyncMock(return_value=SAMPLE_CHAT_RESPONSE)
        client._request = mock

        history = [
            {"role": "user", "content": "previous question"},
            {"role": "assistant", "content": "previous answer"},
        ]
        await client.generate_response(prompt="new question", history=history)

        call_args = mock.call_args_list[0]
        messages = call_args[1]["json_data"]["messages"]
        assert len(messages) == 3
        assert messages[0]["role"] == "user"
        assert messages[2]["role"] == "user"
        assert messages[2]["content"] == "new question"

    @pytest.mark.asyncio
    async def test_generate_structured_success(self):
        client = OllamaClient(max_retries=0)
        client._request = AsyncMock(return_value=SAMPLE_STRUCTURED_RESPONSE)

        schema = {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "intent": {"type": "string"},
            },
        }
        result = await client.generate_structured(
            prompt="Extract details from conversation",
            response_schema=schema,
        )

        assert result["name"] == "John"
        assert result["intent"] == "booking"

    @pytest.mark.asyncio
    async def test_health_check_success(self):
        client = OllamaClient(max_retries=0)
        client._request = AsyncMock(return_value=SAMPLE_TAGS_RESPONSE)

        is_healthy = await client.health_check()
        assert is_healthy is True

    @pytest.mark.asyncio
    async def test_health_check_failure(self):
        client = OllamaClient(max_retries=0)
        client._request = AsyncMock(side_effect=OllamaConnectionError("Connection refused"))

        is_healthy = await client.health_check()
        assert is_healthy is False

    @pytest.mark.asyncio
    async def test_retry_on_connection_error(self):
        client = OllamaClient(max_retries=2, retry_delay=0.01)

        mock_http = AsyncMock(spec=httpx.AsyncClient)
        mock_http.request.side_effect = [
            httpx.ConnectError("Connection refused"),
            httpx.ConnectError("Connection refused"),
            AsyncMock(
                status_code=200,
                json=lambda: SAMPLE_CHAT_RESPONSE,
            ),
        ]
        client._client = mock_http

        response = await client.generate_response(prompt="hello")

        assert response == "Hello! I am Nexora. How can I help you today?"
        assert mock_http.request.call_count == 3

    @pytest.mark.asyncio
    async def test_exhaust_retries(self):
        client = OllamaClient(max_retries=2, retry_delay=0.01)

        mock_http = AsyncMock(spec=httpx.AsyncClient)
        mock_http.request.side_effect = httpx.ConnectError("Connection refused")
        client._client = mock_http

        with pytest.raises(OllamaClientError):
            await client.generate_response(prompt="hello")

        assert mock_http.request.call_count == 3

    @pytest.mark.asyncio
    async def test_timeout_raises_ollama_timeout_error(self):
        client = OllamaClient(max_retries=0)
        mock = AsyncMock()
        mock.side_effect = OllamaTimeoutError("Timed out")
        client._request = mock

        with pytest.raises(OllamaTimeoutError):
            await client.generate_response(prompt="hello")

    @pytest.mark.asyncio
    async def test_http_error_raises_ollama_response_error(self):
        client = OllamaClient(max_retries=0)
        mock = AsyncMock()
        mock.side_effect = OllamaResponseError(status_code=500, detail="Internal error")
        client._request = mock

        with pytest.raises(OllamaResponseError) as exc_info:
            await client.generate_response(prompt="hello")

        assert exc_info.value.status_code == 500

    @pytest.mark.asyncio
    async def test_close_client(self):
        client = OllamaClient(max_retries=0)
        mock_http = AsyncMock(spec=httpx.AsyncClient)
        client._client = mock_http

        await client.close()

        mock_http.aclose.assert_awaited_once()
        assert client._client is None


# ==================== OllamaLLMService Tests ====================


class TestOllamaLLMService:
    @pytest.mark.asyncio
    async def test_generate_response_success(self):
        client = AsyncMock(spec=OllamaClient)
        client.generate_response.return_value = "Hello! I am Nexora."
        service = OllamaLLMService(client=client)

        response = await service.generate_response(prompt="hello")

        assert response == "Hello! I am Nexora."

    @pytest.mark.asyncio
    async def test_generate_response_fallback_on_error(self):
        client = AsyncMock(spec=OllamaClient)
        client.generate_response.side_effect = OllamaConnectionError("Connection refused")
        service = OllamaLLMService(client=client)

        with pytest.raises(LLMServiceError, match="LLM generation failed"):
            await service.generate_response(prompt="hello")

    @pytest.mark.asyncio
    async def test_generate_structured_json_success(self):
        client = AsyncMock(spec=OllamaClient)
        client.generate_structured.return_value = {"name": "John", "intent": "booking"}
        service = OllamaLLMService(client=client)

        result = await service.generate_structured_json(
            prompt="Extract",
            response_schema={"type": "object", "properties": {}},
        )

        assert result == {"name": "John", "intent": "booking"}

    @pytest.mark.asyncio
    async def test_generate_structured_json_fallback_on_error(self):
        client = AsyncMock(spec=OllamaClient)
        client.generate_structured.side_effect = OllamaConnectionError("Connection refused")
        service = OllamaLLMService(client=client)

        with pytest.raises(LLMServiceError, match="Structured JSON generation failed"):
            await service.generate_structured_json(
                prompt="Extract",
                response_schema={"type": "object", "properties": {}},
            )


# ==================== Chat Completion Endpoint Tests ====================


class TestChatCompletionEndpoint:
    @pytest.mark.asyncio
    async def test_completion_success(self, client: AsyncClient):
        app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

        mock_client = AsyncMock(spec=OllamaClient)
        mock_client.generate_response.return_value = "Hello! I am Nexora. How can I help you?"

        with patch(
            "src.presentation.api.v1.chat.ollama_client_singleton",
            mock_client,
        ):
            payload = {"message": "Who are you?"}
            response = await client.post("/api/v1/chat/completions", json=payload)

            assert response.status_code == 200
            data = response.json()
            assert data["response"] == "Hello! I am Nexora. How can I help you?"
            assert data["model"] == settings.OLLAMA_MODEL
            assert data["finish_reason"] == "stop"

        app.dependency_overrides.clear()

    @pytest.mark.asyncio
    async def test_completion_with_system_prompt(self, client: AsyncClient):
        app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

        mock_client = AsyncMock(spec=OllamaClient)
        mock_client.generate_response.return_value = "You are speaking with TestBot."

        with patch(
            "src.presentation.api.v1.chat.ollama_client_singleton",
            mock_client,
        ):
            payload = {
                "message": "Who are you?",
                "system_prompt": "You are TestBot, a test assistant.",
                "temperature": 0.5,
            }
            response = await client.post("/api/v1/chat/completions", json=payload)

            assert response.status_code == 200
            data = response.json()
            assert data["response"] == "You are speaking with TestBot."

            # Verify the system_prompt was forwarded to the client
            mock_client.generate_response.assert_called_once_with(
                prompt="Who are you?",
                system_prompt="You are TestBot, a test assistant.",
                temperature=0.5,
            )

        app.dependency_overrides.clear()

    @pytest.mark.asyncio
    async def test_completion_unavailable(self, client: AsyncClient):
        app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

        mock_client = AsyncMock(spec=OllamaClient)
        mock_client.generate_response.side_effect = OllamaConnectionError("Connection refused")

        with patch(
            "src.presentation.api.v1.chat.ollama_client_singleton",
            mock_client,
        ):
            payload = {"message": "hello"}
            response = await client.post("/api/v1/chat/completions", json=payload)

            assert response.status_code == 503

        app.dependency_overrides.clear()

    @pytest.mark.asyncio
    async def test_completion_validation_empty_message(self, client: AsyncClient):
        app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

        payload = {"message": ""}
        response = await client.post("/api/v1/chat/completions", json=payload)

        assert response.status_code == 422

        app.dependency_overrides.clear()

    @pytest.mark.asyncio
    async def test_completion_validation_missing_message(self, client: AsyncClient):
        app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

        response = await client.post("/api/v1/chat/completions", json={})

        assert response.status_code == 422

        app.dependency_overrides.clear()

    @pytest.mark.asyncio
    async def test_completion_unauthenticated(self, client: AsyncClient):
        payload = {"message": "hello"}
        response = await client.post("/api/v1/chat/completions", json=payload)

        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_completion_with_invalid_temperature(self, client: AsyncClient):
        app.dependency_overrides[get_current_org_id] = lambda: TEST_ORG_ID

        payload = {"message": "hello", "temperature": 99.0}
        response = await client.post("/api/v1/chat/completions", json=payload)

        assert response.status_code == 422

        app.dependency_overrides.clear()