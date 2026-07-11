from typing import List
import httpx
from src.application.interfaces.embedding_service import EmbeddingService
from src.config import settings
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)


class SentenceTransformersEmbeddingService(EmbeddingService):
    def __init__(self, model_name: str = "all-MiniLM-L6-v2"):
        self._dimension = 384  # default all-MiniLM-L6-v2 embedding dimension size
        self.model = None
        self.model_name = model_name

        try:
            from sentence_transformers import SentenceTransformer
            logger.info("Initializing SentenceTransformer model locally", model_name=model_name)
            self.model = SentenceTransformer(model_name)
            logger.info("SentenceTransformer model loaded successfully")
        except Exception as e:
            logger.warning(
                "Could not load SentenceTransformer model locally, falling back to Ollama API for embeddings.",
                error=str(e)
            )

    async def generate_embedding(self, text: str) -> List[float]:
        """
        Generates embedding using sentence-transformers if loaded locally,
        otherwise falls back to Ollama embeddings endpoint.
        """
        if self.model:
            # Sync generation using SentenceTransformer run inside threadpool
            import asyncio
            return await asyncio.to_thread(self._generate_local, text)
        else:
            return await self._generate_ollama(text)

    async def generate_embeddings(self, texts: List[str]) -> List[List[float]]:
        if self.model:
            import asyncio
            return await asyncio.to_thread(self._generate_batch_local, texts)
        else:
            embeddings = []
            for text in texts:
                emb = await self._generate_ollama(text)
                embeddings.append(emb)
            return embeddings

    @property
    def dimension(self) -> int:
        return self._dimension

    def _generate_local(self, text: str) -> List[float]:
        assert self.model is not None
        vector = self.model.encode(text, convert_to_numpy=True)
        return vector.tolist()

    def _generate_batch_local(self, texts: List[str]) -> List[List[float]]:
        assert self.model is not None
        vectors = self.model.encode(texts, convert_to_numpy=True)
        return vectors.tolist()

    async def _generate_ollama(self, text: str) -> List[float]:
        """
        Fallback embedding generation using local Ollama instance nomic-embed-text.
        """
        url = f"{settings.OLLAMA_URL}/api/embeddings"
        payload = {
            "model": "nomic-embed-text",
            "prompt": text
        }
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.post(url, json=payload)
                if response.status_code == 200:
                    data = response.json()
                    embedding = data.get("embedding")
                    if embedding:
                        self._dimension = len(embedding)  # update size dynamically based on model
                        return embedding
                raise ValueError(f"Ollama embedding response error: {response.text}")
        except Exception as e:
            logger.error("Failed to generate fallback Ollama embeddings", error=str(e))
            # Return a dummy vector if all AI systems fail, to avoid completely breaking the process
            return [0.0] * self._dimension
