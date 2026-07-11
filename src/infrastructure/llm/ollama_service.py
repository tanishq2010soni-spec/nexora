from typing import Any, Dict, List, Optional

from src.application.interfaces.llm_service import LLMService
from src.infrastructure.llm.ollama_client import OllamaClient, OllamaClientError
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)


class LLMServiceError(Exception):
    """Raised when the LLM service fails to generate a response."""
    pass


class OllamaLLMService(LLMService):
    def __init__(self, client: OllamaClient | None = None):
        self.client = client or OllamaClient()

    async def generate_response(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        history: Optional[List[Dict[str, str]]] = None,
        temperature: float = 0.7,
    ) -> str:
        try:
            return await self.client.generate_response(
                prompt=prompt,
                system_prompt=system_prompt,
                history=history,
                temperature=temperature,
            )
        except OllamaClientError as e:
            logger.error("Ollama LLM generation failed", error=str(e))
            raise LLMServiceError(f"LLM generation failed: {e}") from e

    async def generate_structured_json(
        self,
        prompt: str,
        response_schema: Dict[str, Any],
        system_prompt: Optional[str] = None,
    ) -> Dict[str, Any]:
        try:
            return await self.client.generate_structured(
                prompt=prompt,
                response_schema=response_schema,
                system_prompt=system_prompt,
            )
        except OllamaClientError as e:
            logger.error("Ollama structured JSON generation failed", error=str(e))
            raise LLMServiceError(f"Structured JSON generation failed: {e}") from e
