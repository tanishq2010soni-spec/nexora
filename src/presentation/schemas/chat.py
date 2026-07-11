import uuid
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field


class ChatSessionCreate(BaseModel):
    agent_id: uuid.UUID
    customer_phone: str


class ChatSessionResponse(BaseModel):
    session_id: uuid.UUID
    agent_id: uuid.UUID
    customer_phone: str
    status: str


class ChatMessageRequest(BaseModel):
    message: str


class ChatMessageResponse(BaseModel):
    response: str
    sources: List[str]
    lead_captured: bool


class ChatCompletionRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=4096, description="User message to send to the model")
    system_prompt: Optional[str] = Field(None, max_length=8192, description="Optional system prompt override")
    temperature: float = Field(default=0.7, ge=0.0, le=2.0, description="Model temperature (0.0-2.0)")


class ChatCompletionResponse(BaseModel):
    response: str
    model: str
    finish_reason: str = "stop"
