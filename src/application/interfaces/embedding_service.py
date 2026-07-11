from abc import ABC, abstractmethod
from typing import List


class EmbeddingService(ABC):
    @abstractmethod
    async def generate_embedding(self, text: str) -> List[float]:
        """
        Generates a dense vector representation of the provided text.
        """
        pass

    @abstractmethod
    async def generate_embeddings(self, texts: List[str]) -> List[List[float]]:
        """
        Generates list of dense vector representations for multiple texts.
        """
        pass

    @property
    @abstractmethod
    def dimension(self) -> int:
        """
        Returns the dimension size of the generated vectors.
        """
        pass
class VectorDBRepository(ABC):
    @abstractmethod
    async def search(self, org_id: str, vector: List[float], limit: int = 5) -> List[dict]:
        pass

    @abstractmethod
    async def upsert_chunks(self, org_id: str, points: List[dict]) -> None:
        pass

    @abstractmethod
    async def delete_by_document(self, org_id: str, doc_id: str) -> None:
        pass
