import uuid
from typing import Dict, Set, Optional
from fastapi import WebSocket
import structlog

logger = structlog.get_logger(__name__)


class ConnectionManager:
    """Manages WebSocket connections for real-time features."""

    def __init__(self):
        self.active_connections: Dict[uuid.UUID, Set[WebSocket]] = {}
        self.user_connections: Dict[str, Set[WebSocket]] = {}
        self.conversation_subscriptions: Dict[uuid.UUID, Set[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, org_id: uuid.UUID, user_id: str):
        await websocket.accept()
        if org_id not in self.active_connections:
            self.active_connections[org_id] = set()
        self.active_connections[org_id].add(websocket)

        if user_id not in self.user_connections:
            self.user_connections[user_id] = set()
        self.user_connections[user_id].add(websocket)

        logger.info("WebSocket connected", org_id=str(org_id), user_id=user_id)

    def disconnect(self, websocket: WebSocket, org_id: uuid.UUID, user_id: str):
        if org_id in self.active_connections:
            self.active_connections[org_id].discard(websocket)
            if not self.active_connections[org_id]:
                del self.active_connections[org_id]

        if user_id in self.user_connections:
            self.user_connections[user_id].discard(websocket)
            if not self.user_connections[user_id]:
                del self.user_connections[user_id]

        for conv_id in list(self.conversation_subscriptions.keys()):
            self.conversation_subscriptions[conv_id].discard(websocket)
            if not self.conversation_subscriptions[conv_id]:
                del self.conversation_subscriptions[conv_id]

        logger.info("WebSocket disconnected", org_id=str(org_id), user_id=user_id)

    def subscribe_to_conversation(self, websocket: WebSocket, conversation_id: uuid.UUID):
        if conversation_id not in self.conversation_subscriptions:
            self.conversation_subscriptions[conversation_id] = set()
        self.conversation_subscriptions[conversation_id].add(websocket)

    def unsubscribe_from_conversation(self, websocket: WebSocket, conversation_id: uuid.UUID):
        if conversation_id in self.conversation_subscriptions:
            self.conversation_subscriptions[conversation_id].discard(websocket)
            if not self.conversation_subscriptions[conversation_id]:
                del self.conversation_subscriptions[conversation_id]

    async def send_personal_message(self, message: dict, websocket: WebSocket):
        try:
            await websocket.send_json(message)
        except Exception as e:
            logger.warning("Failed to send personal message", error=str(e))

    async def broadcast_to_org(self, org_id: uuid.UUID, message: dict):
        if org_id in self.active_connections:
            disconnected = set()
            for connection in self.active_connections[org_id]:
                try:
                    await connection.send_json(message)
                except Exception:
                    disconnected.add(connection)
            for conn in disconnected:
                self.active_connections[org_id].discard(conn)

    async def broadcast_to_conversation(self, conversation_id: uuid.UUID, message: dict):
        if conversation_id in self.conversation_subscriptions:
            disconnected = set()
            for connection in self.conversation_subscriptions[conversation_id]:
                try:
                    await connection.send_json(message)
                except Exception:
                    disconnected.add(connection)
            for conn in disconnected:
                self.conversation_subscriptions[conversation_id].discard(conn)

    async def broadcast_typing_indicator(
        self,
        conversation_id: uuid.UUID,
        user_id: str,
        user_name: str,
        is_typing: bool
    ):
        message = {
            "type": "typing_indicator",
            "conversation_id": str(conversation_id),
            "user_id": user_id,
            "user_name": user_name,
            "is_typing": is_typing,
        }
        await self.broadcast_to_conversation(conversation_id, message)

    async def broadcast_new_message(self, conversation_id: uuid.UUID, message: dict):
        message["type"] = "new_message"
        await self.broadcast_to_conversation(conversation_id, message)

    async def broadcast_conversation_update(self, org_id: uuid.UUID, conversation: dict):
        message = {
            "type": "conversation_update",
            "conversation": conversation,
        }
        await self.broadcast_to_org(org_id, message)

    async def broadcast_unread_count(self, org_id: uuid.UUID, user_id: str, count: int):
        message = {
            "type": "unread_count",
            "user_id": user_id,
            "count": count,
        }
        if user_id in self.user_connections:
            for connection in self.user_connections[user_id]:
                try:
                    await connection.send_json(message)
                except Exception:
                    pass


manager = ConnectionManager()
