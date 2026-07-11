import asyncio
import json
from typing import Any, Dict, List, Optional

import httpx

from src.config import settings
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)


class OllamaClientError(Exception):
    pass


class OllamaConnectionError(OllamaClientError):
    pass


class OllamaTimeoutError(OllamaClientError):
    pass


class OllamaResponseError(OllamaClientError):
    def __init__(self, status_code: int, detail: str) -> None:
        self.status_code = status_code
        self.detail = detail
        super().__init__(f"Ollama returned HTTP {status_code}: {detail}")


class OllamaClient:
    def __init__(
        self,
        base_url: str | None = None,
        model_name: str | None = None,
        timeout: int | None = None,
        max_retries: int | None = None,
        retry_delay: float | None = None,
    ) -> None:
        self.base_url = (base_url or settings.OLLAMA_URL).rstrip("/")
        self.model_name = model_name or settings.OLLAMA_MODEL
        self.timeout = timeout or settings.OLLAMA_TIMEOUT
        self.max_retries = max_retries or settings.OLLAMA_MAX_RETRIES
        self.retry_delay = retry_delay or settings.OLLAMA_RETRY_DELAY

        self._client: httpx.AsyncClient | None = None

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None:
            self._client = httpx.AsyncClient(timeout=self.timeout)
        return self._client

    async def close(self) -> None:
        if self._client:
            await self._client.aclose()
            self._client = None

    async def _request(
        self, method: str, path: str, json_data: dict[str, Any] | None = None
    ) -> dict[str, Any]:
        url = f"{self.base_url}{path}"
        last_exception: Exception | None = None

        for attempt in range(self.max_retries + 1):
            try:
                client = await self._get_client()
                response = await client.request(method, url, json=json_data)

                if response.status_code == 200:
                    return response.json()

                raise OllamaResponseError(
                    status_code=response.status_code,
                    detail=response.text[:500],
                )

            except httpx.TimeoutException as e:
                last_exception = OllamaTimeoutError(
                    f"Ollama request timed out after {self.timeout}s"
                )
                logger.warning(
                    "Ollama request timed out",
                    attempt=attempt + 1,
                    max_retries=self.max_retries,
                    path=path,
                )
            except httpx.ConnectError as e:
                last_exception = OllamaConnectionError(
                    f"Cannot connect to Ollama at {self.base_url}"
                )
                logger.warning(
                    "Ollama connection refused",
                    attempt=attempt + 1,
                    max_retries=self.max_retries,
                    url=self.base_url,
                )
            except OllamaResponseError:
                raise
            except Exception as e:
                last_exception = OllamaClientError(f"Unexpected Ollama error: {e}")
                logger.error(
                    "Unexpected Ollama request failure",
                    attempt=attempt + 1,
                    error=str(e),
                )

            if attempt < self.max_retries:
                delay = self.retry_delay * (2 ** attempt)
                logger.info(
                    "Retrying Ollama request",
                    attempt=attempt + 1,
                    delay_seconds=delay,
                )
                await asyncio.sleep(delay)

        raise last_exception or OllamaClientError("Ollama request failed after all retries")

    async def chat(
        self,
        messages: List[Dict[str, str]],
        temperature: float = 0.7,
        format: str | None = None,
    ) -> Dict[str, Any]:
        payload: dict[str, Any] = {
            "model": self.model_name,
            "messages": messages,
            "stream": False,
            "options": {
                "temperature": temperature,
            },
        }
        if format:
            payload["format"] = format

        logger.info(
            "Sending chat request to Ollama",
            model=self.model_name,
            message_count=len(messages),
            temperature=temperature,
        )
        return await self._request("POST", "/api/chat", json_data=payload)

    async def generate_response(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        history: Optional[List[Dict[str, str]]] = None,
        temperature: float = 0.7,
    ) -> str:
        messages: List[Dict[str, str]] = []

        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})

        if history:
            messages.extend(history)

        messages.append({"role": "user", "content": prompt})

        data = await self.chat(messages=messages, temperature=temperature)
        content = data.get("message", {}).get("content", "")
        return content.strip()

    async def generate_structured(
        self,
        prompt: str,
        response_schema: Dict[str, Any],
        system_prompt: Optional[str] = None,
    ) -> Dict[str, Any]:
        json_instruction = (
            f"You are a strict data extractor. You MUST return ONLY valid JSON output "
            f"that matches the schema: {json.dumps(response_schema)}. "
            f"Do NOT include any explanations, markdown code blocks, or extra text."
        )

        messages: List[Dict[str, str]] = []
        combined = system_prompt + "\n" + json_instruction if system_prompt else json_instruction
        messages.append({"role": "system", "content": combined})
        messages.append({"role": "user", "content": prompt})

        data = await self.chat(messages=messages, temperature=0.0, format="json")
        content = data.get("message", {}).get("content", "")

        try:
            return json.loads(content)
        except json.JSONDecodeError as e:
            logger.error("Failed to parse structured JSON from Ollama output", error=str(e), content=content[:200])
            return {}

    async def health_check(self) -> bool:
        try:
            data = await self._request("GET", "/api/tags")
            return True
        except OllamaClientError:
            return False