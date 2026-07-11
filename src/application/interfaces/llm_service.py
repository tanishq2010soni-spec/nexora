from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional


class LLMService(ABC):
    @abstractmethod
    async def generate_response(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        history: Optional[List[Dict[str, str]]] = None,
        temperature: float = 0.7,
    ) -> str:
        """
        Generates text output from model given prompts and chat session histories.
        """
        pass

    @abstractmethod
    async def generate_structured_json(
        self,
        prompt: str,
        response_schema: Dict[str, Any],
        system_prompt: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Queries model forcing response payloads to conform to specific JSON structures.
        """
        pass
