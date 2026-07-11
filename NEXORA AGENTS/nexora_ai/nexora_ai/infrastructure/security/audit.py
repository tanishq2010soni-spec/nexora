from __future__ import annotations

import hashlib
import json
from datetime import date, datetime, timezone
from pathlib import Path
from typing import Any

from nexora_ai.domain.enums.security_enums import AuditAction


class AuditEntry:
    def __init__(
        self,
        timestamp: str,
        action: str,
        user_id: str,
        resource: str,
        details: dict[str, Any] | None = None,
        previous_hash: str = "",
    ) -> None:
        self.timestamp = timestamp
        self.action = action
        self.user_id = user_id
        self.resource = resource
        self.details = details or {}
        self.previous_hash = previous_hash
        self.hash = self._compute_hash()

    def _compute_hash(self) -> str:
        data = f"{self.timestamp}|{self.action}|{self.user_id}|{self.resource}|{json.dumps(self.details, sort_keys=True)}|{self.previous_hash}"
        return hashlib.sha256(data.encode("utf-8")).hexdigest()

    def to_dict(self) -> dict[str, Any]:
        return {
            "timestamp": self.timestamp,
            "action": self.action,
            "user_id": self.user_id,
            "resource": self.resource,
            "details": self.details,
            "previous_hash": self.previous_hash,
            "hash": self.hash,
        }


import asyncio


class AuditLogger:
    def __init__(
        self,
        log_dir: str | Path = "audit_logs",
        max_file_size: int = 10 * 1024 * 1024,
    ) -> None:
        self._log_dir = Path(log_dir)
        self._max_file_size = max_file_size
        self._lock: asyncio.Lock = asyncio.Lock()
        self._last_hash: str = ""

    async def log(
        self,
        action: AuditAction | str,
        user_id: str,
        resource: str,
        details: dict[str, Any] | None = None,
    ) -> AuditEntry:
        action_str = action.value if isinstance(action, AuditAction) else action
        entry = AuditEntry(
            timestamp=datetime.now(timezone.utc).isoformat(),
            action=action_str,
            user_id=user_id,
            resource=resource,
            details=details,
            previous_hash=self._last_hash,
        )
        async with self._lock:
            await self._append_entry(entry)
            self._last_hash = entry.hash
        return entry

    async def query(
        self,
        start_date: date | None = None,
        end_date: date | None = None,
        action: str | None = None,
        user_id: str | None = None,
        resource: str | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[dict[str, Any]]:
        results: list[dict[str, Any]] = []
        files = sorted(self._log_dir.glob("audit_*.jsonl"))
        for file_path in files:
            if not file_path.exists():
                continue
            content = file_path.read_text(encoding="utf-8")
            for line in content.strip().split("\n"):
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if action and entry.get("action") != action:
                    continue
                if user_id and entry.get("user_id") != user_id:
                    continue
                if resource and entry.get("resource") != resource:
                    continue
                if start_date or end_date:
                    ts = entry.get("timestamp", "")
                    entry_date = ts[:10] if ts else ""
                    if start_date and entry_date < start_date.isoformat():
                        continue
                    if end_date and entry_date > end_date.isoformat():
                        continue
                results.append(entry)
        results.sort(key=lambda e: e.get("timestamp", ""))
        return results[offset:offset + limit]

    async def verify_chain(self) -> bool:
        previous_hash = ""
        files = sorted(self._log_dir.glob("audit_*.jsonl"))
        for file_path in files:
            if not file_path.exists():
                continue
            content = file_path.read_text(encoding="utf-8")
            for line in content.strip().split("\n"):
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    return False
                if entry.get("previous_hash", "") != previous_hash:
                    return False
                expected_hash = AuditEntry(
                    timestamp=entry["timestamp"],
                    action=entry["action"],
                    user_id=entry["user_id"],
                    resource=entry["resource"],
                    details=entry.get("details"),
                    previous_hash=previous_hash,
                ).hash
                if entry.get("hash") != expected_hash:
                    return False
                previous_hash = entry["hash"]
        return True

    async def _append_entry(self, entry: AuditEntry) -> None:
        self._log_dir.mkdir(parents=True, exist_ok=True)
        today = date.today().isoformat()
        file_path = self._log_dir / f"audit_{today}.jsonl"
        if file_path.exists() and file_path.stat().st_size >= self._max_file_size:
            file_path = self._log_dir / f"audit_{today}_{int(datetime.now(timezone.utc).timestamp())}.jsonl"
        with open(file_path, "a", encoding="utf-8") as f:
                    f.write(json.dumps(entry.to_dict(), default=str) + "\n")
