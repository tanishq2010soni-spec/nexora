import uuid
import json
from typing import Optional
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import AsyncSessionLocal
from src.infrastructure.realtime.connection_manager import manager

router = APIRouter()


def get_user_from_token(token: str) -> Optional[dict]:
    from src.application.services.auth_service import AuthService
    return AuthService.decode_access_token(token)


@router.websocket("/ws")
async def inbox_websocket(
    websocket: WebSocket,
    token: str = Query(...),
):
    payload = get_user_from_token(token)
    if not payload:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    org_id_str = payload.get("org_id")
    user_id = payload.get("sub", payload.get("email", "unknown"))
    user_name = payload.get("name", "Unknown User")

    if not org_id_str:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    try:
        org_id = uuid.UUID(org_id_str)
    except ValueError:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    await manager.connect(websocket, org_id, user_id)

    try:
        while True:
            data = await websocket.receive_text()
            try:
                message = json.loads(data)
                await _handle_message(websocket, org_id, user_id, user_name, message)
            except json.JSONDecodeError:
                await websocket.send_json({"type": "error", "message": "Invalid JSON"})
            except Exception as e:
                await websocket.send_json({"type": "error", "message": str(e)})
    except WebSocketDisconnect:
        manager.disconnect(websocket, org_id, user_id)
    except Exception:
        manager.disconnect(websocket, org_id, user_id)


async def _handle_message(
    websocket: WebSocket,
    org_id: uuid.UUID,
    user_id: str,
    user_name: str,
    message: dict,
):
    msg_type = message.get("type")

    if msg_type == "subscribe":
        conversation_id = message.get("conversation_id")
        if conversation_id:
            try:
                conv_id = uuid.UUID(conversation_id)
                manager.subscribe_to_conversation(websocket, conv_id)
                await websocket.send_json({"type": "subscribed", "conversation_id": conversation_id})
            except ValueError:
                await websocket.send_json({"type": "error", "message": "Invalid conversation ID"})

    elif msg_type == "unsubscribe":
        conversation_id = message.get("conversation_id")
        if conversation_id:
            try:
                conv_id = uuid.UUID(conversation_id)
                manager.unsubscribe_from_conversation(websocket, conv_id)
                await websocket.send_json({"type": "unsubscribed", "conversation_id": conversation_id})
            except ValueError:
                await websocket.send_json({"type": "error", "message": "Invalid conversation ID"})

    elif msg_type == "typing":
        conversation_id = message.get("conversation_id")
        is_typing = message.get("is_typing", False)
        if conversation_id:
            try:
                conv_id = uuid.UUID(conversation_id)
                await manager.broadcast_typing_indicator(conv_id, user_id, user_name, is_typing)
            except ValueError:
                pass

    elif msg_type == "mark_read":
        conversation_id = message.get("conversation_id")
        if conversation_id:
            try:
                conv_id = uuid.UUID(conversation_id)
                async with AsyncSessionLocal() as session:
                    from src.infrastructure.database.models import InboxMessage, InboxConversation
                    from sqlalchemy import update as sa_update, select
                    stmt = (
                        sa_update(InboxMessage)
                        .where(
                            InboxMessage.conversation_id == conv_id,
                            InboxMessage.is_read == False,
                            InboxMessage.sender_type != "agent",
                        )
                        .values(is_read=True)
                    )
                    await session.execute(stmt)
                    conv_stmt = select(InboxConversation).where(InboxConversation.id == conv_id)
                    conv_result = await session.execute(conv_stmt)
                    conv = conv_result.scalar_one_or_none()
                    if conv:
                        conv.unread_count = 0
                    await session.commit()
                await websocket.send_json({"type": "marked_read", "conversation_id": conversation_id})
            except ValueError:
                pass

    elif msg_type == "ping":
        await websocket.send_json({"type": "pong"})


@router.websocket("/ws/unread-count")
async def unread_count_websocket(
    websocket: WebSocket,
    token: str = Query(...),
):
    payload = get_user_from_token(token)
    if not payload:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    org_id_str = payload.get("org_id")
    user_id = payload.get("sub", payload.get("email", "unknown"))

    if not org_id_str:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    try:
        org_id = uuid.UUID(org_id_str)
    except ValueError:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    await manager.connect(websocket, org_id, user_id)

    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket, org_id, user_id)
    except Exception:
        manager.disconnect(websocket, org_id, user_id)
