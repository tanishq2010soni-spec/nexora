from __future__ import annotations

import json
import logging
import os
import time
from datetime import datetime, timedelta
from typing import Any, Optional
from uuid import uuid4

logger = logging.getLogger(__name__)


class SessionManager:
    def __init__(self, storage_dir: Optional[str] = None) -> None:
        self._storage_dir = storage_dir or os.path.join(
            os.path.expanduser("~"), ".nexora", "whatsapp_sessions"
        )
        self._ensure_storage_dir()
        self._sessions: dict[str, dict[str, Any]] = {}

    async def save_session(self, account_id: str, session_data: dict[str, Any]) -> bool:
        try:
            session = {
                "account_id": account_id,
                "session_id": str(uuid4()),
                "data": session_data,
                "created_at": datetime.utcnow().isoformat(),
                "updated_at": datetime.utcnow().isoformat(),
                "expires_at": (datetime.utcnow() + timedelta(days=30)).isoformat(),
                "version": 2,
            }
            self._sessions[account_id] = session
            await self._write_session_file(account_id, session)
            logger.info("Saved session for account %s", account_id)
            return True
        except Exception as exc:
            logger.error("Failed to save session for account %s: %s", account_id, exc)
            return False

    async def load_session(self, account_id: str) -> Optional[dict[str, Any]]:
        try:
            cached = self._sessions.get(account_id)
            if cached:
                expires_at = cached.get("expires_at")
                if expires_at and datetime.fromisoformat(expires_at) > datetime.utcnow():
                    logger.debug("Loaded cached session for account %s", account_id)
                    return cached["data"]

            session = await self._read_session_file(account_id)
            if session is None:
                logger.debug("No session file found for account %s", account_id)
                return None

            expires_at = session.get("expires_at")
            if expires_at and datetime.fromisoformat(expires_at) <= datetime.utcnow():
                logger.warning("Session for account %s has expired", account_id)
                await self.delete_session(account_id)
                return None

            self._sessions[account_id] = session
            logger.info("Loaded session for account %s from disk", account_id)
            return session.get("data")
        except Exception as exc:
            logger.error("Failed to load session for account %s: %s", account_id, exc)
            return None

    async def delete_session(self, account_id: str) -> bool:
        try:
            self._sessions.pop(account_id, None)
            file_path = self._get_session_path(account_id)
            if os.path.exists(file_path):
                os.remove(file_path)
            logger.info("Deleted session for account %s", account_id)
            return True
        except Exception as exc:
            logger.error("Failed to delete session for account %s: %s", account_id, exc)
            return False

    async def recover_session(self, account_id: str) -> bool:
        try:
            session_data = await self.load_session(account_id)
            if session_data is None:
                logger.warning("No session data to recover for account %s", account_id)
                return False

            if not session_data.get("phone_number"):
                logger.warning("Session for account %s has no phone_number, cannot recover", account_id)
                return False

            phone_number = session_data.get("phone_number")
            logger.info("Recovering session for account %s (phone: %s)", account_id, phone_number)

            session_data["recovered_at"] = datetime.utcnow().isoformat()
            session_data["recovery_count"] = session_data.get("recovery_count", 0) + 1
            await self.save_session(account_id, session_data)

            logger.info("Session recovered for account %s", account_id)
            return True
        except Exception as exc:
            logger.error("Failed to recover session for account %s: %s", account_id, exc)
            return False

    async def cleanup_expired(self) -> int:
        try:
            count = 0
            expired_ids: list[str] = []

            for account_id, session in self._sessions.items():
                expires_at = session.get("expires_at")
                if expires_at and datetime.fromisoformat(expires_at) <= datetime.utcnow():
                    expired_ids.append(account_id)

            for account_id in expired_ids:
                await self.delete_session(account_id)
                count += 1

            file_based_count = await self._cleanup_expired_files()
            total = count + file_based_count
            if total > 0:
                logger.info("Cleaned up %d expired sessions", total)
            return total
        except Exception as exc:
            logger.error("Failed to cleanup expired sessions: %s", exc)
            return 0

    async def session_exists(self, account_id: str) -> bool:
        if account_id in self._sessions:
            return True
        file_path = self._get_session_path(account_id)
        return os.path.exists(file_path)

    async def get_all_sessions(self) -> list[dict[str, Any]]:
        sessions: list[dict[str, Any]] = []
        for account_id in list(self._sessions.keys()):
            session = await self.load_session(account_id)
            if session:
                sessions.append({
                    "account_id": account_id,
                    "phone_number": session.get("phone_number"),
                    "created_at": self._sessions.get(account_id, {}).get("created_at"),
                    "expires_at": self._sessions.get(account_id, {}).get("expires_at"),
                })
        return sessions

    def _get_session_path(self, account_id: str) -> str:
        safe_name = account_id.replace(":", "_").replace("/", "_").replace("\\", "_")
        return os.path.join(self._storage_dir, f"{safe_name}.json")

    def _ensure_storage_dir(self) -> None:
        try:
            os.makedirs(self._storage_dir, exist_ok=True)
        except OSError as exc:
            logger.warning("Could not create session storage dir %s: %s", self._storage_dir, exc)

    async def _write_session_file(self, account_id: str, session: dict[str, Any]) -> None:
        file_path = self._get_session_path(account_id)
        with open(file_path, "w") as f:
            json.dump(session, f, indent=2, default=str)

    async def _read_session_file(self, account_id: str) -> Optional[dict[str, Any]]:
        file_path = self._get_session_path(account_id)
        if not os.path.exists(file_path):
            return None
        try:
            with open(file_path, "r") as f:
                return json.load(f)
        except (json.JSONDecodeError, OSError) as exc:
            logger.error("Failed to read session file %s: %s", file_path, exc)
            return None

    async def _cleanup_expired_files(self) -> int:
        if not os.path.isdir(self._storage_dir):
            return 0
        count = 0
        now = datetime.utcnow()
        for filename in os.listdir(self._storage_dir):
            if not filename.endswith(".json"):
                continue
            file_path = os.path.join(self._storage_dir, filename)
            try:
                with open(file_path, "r") as f:
                    session = json.load(f)
                expires_at = session.get("expires_at")
                if expires_at and datetime.fromisoformat(expires_at) <= now:
                    os.remove(file_path)
                    count += 1
            except Exception:
                continue
        return count
