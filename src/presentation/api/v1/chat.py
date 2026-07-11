import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.application.services.rag_service import RAGService
from src.config import settings
from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import ChatSession, Agent
from src.infrastructure.llm.ollama_client import OllamaClientError
from src.presentation.api.dependencies import get_current_org_id, get_rag_service, ollama_client_singleton
from src.presentation.schemas.chat import (
    ChatSessionCreate,
    ChatSessionResponse,
    ChatMessageRequest,
    ChatMessageResponse,
    ChatCompletionRequest,
    ChatCompletionResponse,
)

router = APIRouter()


@router.post("/sessions", response_model=ChatSessionResponse, status_code=status.HTTP_201_CREATED)
async def create_session(
    data: ChatSessionCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session)
) -> ChatSessionResponse:
    """
    Creates a new chat session linked to a specific agent and customer phone number identifier.
    """
    # Verify agent exists and belongs to the user organization
    agent_stmt = select(Agent).where(Agent.id == data.agent_id, Agent.org_id == org_id)
    agent_result = await db.execute(agent_stmt)
    agent = agent_result.scalar_one_or_none()
    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found or unauthorized access."
        )

    session = ChatSession(
        id=uuid.uuid4(),
        agent_id=data.agent_id,
        external_user_id=data.customer_phone,
        status="active"
    )
    db.add(session)
    await db.commit()
    await db.refresh(session)

    return ChatSessionResponse(
        session_id=session.id,
        agent_id=session.agent_id,
        customer_phone=session.external_user_id,
        status=session.status
    )


@router.post(
    "/sessions/{session_id}/message",
    response_model=ChatMessageResponse,
)
async def send_message(

    session_id: uuid.UUID,
    data: ChatMessageRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    rag_service: RAGService = Depends(get_rag_service),
) -> ChatMessageResponse:
    """
    Processes a chat query, running dense vector searches, fetching context, invoking
    the local llama3 model, capturing potential leads, and updating memory records.
    """
    # Verify session details and ownership
    session_stmt = select(ChatSession).join(Agent).where(
        ChatSession.id == session_id, Agent.org_id == org_id
    )
    session_result = await db.execute(session_stmt)
    session = session_result.scalar_one_or_none()
    
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Chat Session not found or unauthorized access."
        )

    if session.status == "closed":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This chat session is closed."
        )

    try:
        result = await rag_service.execute_chat_turn(
            db=db,
            org_id=org_id,
            session_id=session_id,
            agent_id=session.agent_id,
            user_message=data.message,
            customer_phone=session.external_user_id
        )
        return ChatMessageResponse(
            response=result["response"],
            sources=result["sources"],
            lead_captured=result["lead_captured"]
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Chat execution failed: {str(e)}"
        )


@router.post(
    "/completions",
    response_model=ChatCompletionResponse,
    status_code=status.HTTP_200_OK,
)
async def chat_completion(
    data: ChatCompletionRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
) -> ChatCompletionResponse:
    """
    Direct Ollama chat completion. Sends a message to the LLM model and returns the response.
    Does not use RAG, session history, or lead extraction.
    """
    try:
        response_text = await ollama_client_singleton.generate_response(
            prompt=data.message,
            system_prompt=data.system_prompt,
            temperature=data.temperature,
        )
        return ChatCompletionResponse(
            response=response_text,
            model=settings.OLLAMA_MODEL,
            finish_reason="stop",
        )
    except OllamaClientError as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Ollama service is unavailable: {str(e)}",
        )
