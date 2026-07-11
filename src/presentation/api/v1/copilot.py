import uuid
from typing import Any, Dict, List, Optional
from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.presentation.api.dependencies import get_current_org_id

router = APIRouter()


class CopilotRequest(BaseModel):
    command: str = Field(..., min_length=1, max_length=500)


class CopilotResponseModel(BaseModel):
    text: str
    data: Optional[Any] = None
    actions: List[Dict[str, Any]] = []
    suggestions: List[str] = []


@router.post("/command", response_model=CopilotResponseModel)
async def process_command(
    data: CopilotRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> CopilotResponseModel:
    from src.application.services.ai_copilot import AICopilotService

    copilot = AICopilotService(db=db, org_id=org_id)
    response = await copilot.process_command(data.command)

    return CopilotResponseModel(
        text=response.text,
        data=response.data,
        actions=response.actions,
        suggestions=response.suggestions,
    )


@router.get("/suggestions")
async def get_suggestions(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    return {
        "suggestions": [
            "Show leads",
            "Show customers",
            "Show conversations",
            "Create a task",
            "Show analytics",
            "Generate report",
            "Go to inbox",
            "Go to analytics",
        ]
    }
