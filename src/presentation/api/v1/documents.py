import uuid
from typing import List
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.application.services.document_service import DocumentService
from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import Document, KnowledgeBase
from src.presentation.api.dependencies import get_current_org_id, get_document_service

router = APIRouter()


@router.post("/upload", status_code=status.HTTP_201_CREATED)
async def upload_document(
    kb_id: uuid.UUID,
    file: UploadFile = File(...),
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    doc_service: DocumentService = Depends(get_document_service),
) -> dict:
    """
    Accepts and processes PDF, DOCX, or TXT file uploads.
    Extracts text, builds embeddings, registers vector indexes inside Qdrant, and logs status.
    """
    filename = file.filename or "unknown_file"
    ext = filename.split(".")[-1].lower()
    
    if ext not in ["pdf", "docx", "txt"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported file extension. Only PDF, DOCX, and TXT are accepted."
        )

    # Verify Knowledge Base belongs to organization (tenant segregation check)
    kb_stmt = select(KnowledgeBase).where(KnowledgeBase.id == kb_id, KnowledgeBase.org_id == org_id)
    kb_result = await db.execute(kb_stmt)
    kb = kb_result.scalar_one_or_none()
    
    if not kb:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Knowledge Base not found or access is unauthorized."
        )

    # Read uploaded file bytes
    file_bytes = await file.read()
    if len(file_bytes) > 10 * 1024 * 1024:  # 10MB limits
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File size exceeds the maximum upload limit of 10MB."
        )

    try:
        doc = await doc_service.ingest_document(
            db=db,
            kb_id=kb_id,
            filename=filename,
            file_bytes=file_bytes,
            org_id=org_id
        )
        return {
            "document_id": str(doc.id),
            "filename": doc.filename,
            "status": doc.status,
            "chunk_count": doc.chunk_count,
            "message": "File parsed and indexed into vector database successfully."
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"In-line processing failed: {str(e)}"
        )


@router.get("/", status_code=status.HTTP_200_OK)
async def list_documents(
    kb_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session)
) -> List[dict]:
    """
    Lists all processed files registered within a specific knowledge base.
    """
    # Verify KB ownership
    kb_stmt = select(KnowledgeBase).where(KnowledgeBase.id == kb_id, KnowledgeBase.org_id == org_id)
    kb_result = await db.execute(kb_stmt)
    kb = kb_result.scalar_one_or_none()
    
    if not kb:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Knowledge Base not found or unauthorized access."
        )

    stmt = select(Document).where(Document.kb_id == kb_id)
    result = await db.execute(stmt)
    docs = result.scalars().all()
    
    return [
        {
            "id": str(doc.id),
            "filename": doc.filename,
            "file_type": doc.file_type,
            "file_size": doc.file_size,
            "status": doc.status,
            "chunk_count": doc.chunk_count,
            "created_at": doc.created_at.isoformat()
        } for doc in docs
    ]


@router.delete("/{doc_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_document(
    doc_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    doc_service: DocumentService = Depends(get_document_service),
) -> None:
    """
    Unregisters document vectors from Qdrant and drops metadata entries from PostgreSQL.
    """
    # Verify document ownership via linked knowledge base
    stmt = select(Document).join(KnowledgeBase).where(
        Document.id == doc_id, KnowledgeBase.org_id == org_id
    )
    result = await db.execute(stmt)
    doc = result.scalar_one_or_none()
    
    if not doc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Document not found or unauthorized access."
        )

    success = await doc_service.delete_document(db, doc_id, org_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to remove document database records."
        )
