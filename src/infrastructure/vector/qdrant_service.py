import asyncio
from typing import List
from qdrant_client import QdrantClient
from qdrant_client.http import models as qmodels
from qdrant_client.http.exceptions import UnexpectedResponse

from src.application.interfaces.embedding_service import VectorDBRepository
from src.config import settings
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)


class QdrantVectorRepository(VectorDBRepository):
    def __init__(self, collection_name: str | None = None):
        self.collection_name = collection_name or settings.QDRANT_COLLECTION
        self.vector_size = settings.EMBEDDING_DIMENSION
        try:
            self.client = QdrantClient(url=settings.QDRANT_URL)
            self._ensure_collection_exists()
        except Exception as e:
            logger.error("Failed to connect to Qdrant", error=str(e))
            self.client = None

    def _ensure_collection_exists(self) -> None:
        """Ensures target vector collection exists in Qdrant."""
        if not self.client:
            return
        try:
            self.client.get_collection(self.collection_name)
        except (UnexpectedResponse, Exception):
            logger.info(
                "Vector collection does not exist. Initializing",
                collection=self.collection_name,
                vector_size=self.vector_size,
            )
            try:
                self.client.create_collection(
                    collection_name=self.collection_name,
                    vectors_config=qmodels.VectorParams(
                        size=self.vector_size,
                        distance=qmodels.Distance.COSINE,
                    ),
                )
                logger.info("Created Qdrant collection", collection=self.collection_name)
            except Exception as e:
                logger.error("Failed to create Qdrant collection", error=str(e))

    async def _run_sync(self, func, *args, **kwargs):
        """Run a synchronous Qdrant call in a thread pool to avoid blocking the event loop."""
        return await asyncio.to_thread(func, *args, **kwargs)

    async def search(self, org_id: str, vector: List[float], limit: int = 5) -> List[dict]:
        if not self.client:
            logger.warning("Qdrant client unavailable, returning empty results")
            return []
        try:
            filter_query = qmodels.Filter(
                must=[
                    qmodels.FieldCondition(
                        key="org_id",
                        match=qmodels.MatchValue(value=org_id),
                    )
                ]
            )

            results = await self._run_sync(
                self.client.query_points,
                collection_name=self.collection_name,
                query=vector,
                query_filter=filter_query,
                limit=limit,
                with_payload=True,
            )

            response_chunks = []
            for item in results.points:
                payload = item.payload or {}
                response_chunks.append({
                    "id": item.id,
                    "score": item.score,
                    "text": payload.get("text", ""),
                    "metadata": payload.get("metadata", {}),
                    "document_id": payload.get("document_id", ""),
                })
            return response_chunks
        except Exception as e:
            logger.error("Failed to query Qdrant vector search", error=str(e))
            return []

    async def upsert_chunks(self, org_id: str, points: List[dict]) -> None:
        if not self.client:
            raise Exception("Qdrant client unavailable")
        try:
            q_points = []
            for pt in points:
                payload = {
                    "org_id": org_id,
                    "text": pt["text"],
                    "document_id": pt["document_id"],
                    "metadata": pt.get("metadata", {}),
                }
                q_points.append(
                    qmodels.PointStruct(
                        id=pt["id"],
                        vector=pt["vector"],
                        payload=payload,
                    )
                )

            await self._run_sync(
                self.client.upsert,
                collection_name=self.collection_name,
                points=q_points,
            )
            logger.info("Upserted points to Qdrant", count=len(points))
        except Exception as e:
            logger.error("Failed to upsert to Qdrant", error=str(e))
            raise

    async def delete_by_document(self, org_id: str, doc_id: str) -> None:
        if not self.client:
            raise Exception("Qdrant client unavailable")
        try:
            filter_query = qmodels.Filter(
                must=[
                    qmodels.FieldCondition(
                        key="org_id",
                        match=qmodels.MatchValue(value=org_id),
                    ),
                    qmodels.FieldCondition(
                        key="document_id",
                        match=qmodels.MatchValue(value=doc_id),
                    ),
                ]
            )
            await self._run_sync(
                self.client.delete,
                collection_name=self.collection_name,
                points_selector=qmodels.FilterSelector(filter=filter_query),
            )
            logger.info("Deleted vector chunks", doc_id=doc_id)
        except Exception as e:
            logger.error("Failed to delete from Qdrant", error=str(e))
            raise
