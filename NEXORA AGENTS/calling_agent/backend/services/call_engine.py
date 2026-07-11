from __future__ import annotations

from datetime import datetime
from typing import Any, Optional
from uuid import UUID, uuid4

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from backend.domain.entities import Call, CallEvent, Organization
from backend.infrastructure.database.models import CallModel, CallEventModel
from backend.infrastructure.phone.base import PhoneProvider
from backend.infrastructure.voice.pipeline import VoicePipeline


class CallEngine:
    def __init__(self, phone_provider: PhoneProvider, voice_pipeline: VoicePipeline) -> None:
        self._phone = phone_provider
        self._pipeline = voice_pipeline
        self._active_calls: dict[str, dict] = {}

    async def initiate_call(self, call: Call, session: AsyncSession) -> Call:
        call.status = "queued"
        call.started_at = datetime.utcnow()

        result = await self._phone.make_call(
            from_number=call.from_number,
            to_number=call.to_number,
            timeout=60,
            record=True,
        )

        call.provider_call_id = result.get("provider_call_id", "")
        call.status = self._map_provider_status(result.get("status", "queued"))

        db_call = CallModel(
            id=str(call.id),
            organization_id=str(call.organization_id),
            user_id=str(call.user_id) if call.user_id else None,
            campaign_id=str(call.campaign_id) if call.campaign_id else None,
            lead_id=str(call.lead_id) if call.lead_id else None,
            contact_id=str(call.contact_id) if call.contact_id else None,
            direction=call.direction,
            from_number=call.from_number,
            to_number=call.to_number,
            status=call.status,
            provider_call_id=call.provider_call_id,
            started_at=call.started_at,
        )
        session.add(db_call)

        call_event = CallEvent(
            call_id=call.id,
            organization_id=call.organization_id,
            event_type="call_initiated",
            data={
                "provider_call_id": call.provider_call_id,
                "from_number": call.from_number,
                "to_number": call.to_number,
            },
        )
        db_event = CallEventModel(
            id=str(call_event.id),
            call_id=str(call_event.call_id),
            organization_id=str(call_event.organization_id),
            event_type=call_event.event_type,
            data=call_event.data,
        )
        session.add(db_event)

        self._active_calls[str(call.id)] = {
            "call": call.model_dump() if hasattr(call, "model_dump") else call.__dict__,
            "started_at": datetime.utcnow().isoformat(),
        }

        return call

    async def handle_incoming(self, provider_call_id: str, from_number: str, to_number: str, session: AsyncSession) -> Call:
        org_result = await session.execute(
            select(Organization).limit(1)
        )
        org = org_result.scalar_one_or_none()
        org_id = org.id if org else uuid4()

        call = Call(
            organization_id=org_id,
            direction="inbound",
            from_number=from_number,
            to_number=to_number,
            status="ringing",
            provider_call_id=provider_call_id,
            started_at=datetime.utcnow(),
        )

        db_call = CallModel(
            id=str(call.id),
            organization_id=str(call.organization_id),
            direction=call.direction,
            from_number=call.from_number,
            to_number=call.to_number,
            status=call.status,
            provider_call_id=call.provider_call_id,
            started_at=call.started_at,
        )
        session.add(db_call)

        call_event = CallEvent(
            call_id=call.id,
            organization_id=call.organization_id,
            event_type="incoming_call",
            data={"provider_call_id": provider_call_id, "from": from_number, "to": to_number},
        )
        db_event = CallEventModel(
            id=str(call_event.id),
            call_id=str(call_event.call_id),
            organization_id=str(call_event.organization_id),
            event_type=call_event.event_type,
            data=call_event.data,
        )
        session.add(db_event)

        self._active_calls[str(call.id)] = {
            "call": call.model_dump() if hasattr(call, "model_dump") else call.__dict__,
            "started_at": datetime.utcnow().isoformat(),
        }

        return call

    async def end_call(self, call_id: str, session: AsyncSession) -> Call:
        call_data = self._active_calls.pop(call_id, None)
        if call_data and call_data.get("call", {}).get("provider_call_id"):
            await self._phone.end_call(call_data["call"]["provider_call_id"])

        result = await session.execute(
            select(CallModel).where(CallModel.id == call_id)
        )
        db_call = result.scalar_one_or_none()
        if db_call:
            db_call.status = "completed"
            db_call.ended_at = datetime.utcnow()
            if db_call.started_at:
                duration = int((datetime.utcnow() - db_call.started_at).total_seconds())
                db_call.duration_seconds = duration
            await session.flush()

        call = self._db_call_to_entity(db_call) if db_call else Call(
            organization_id=uuid4(), direction="outbound", from_number="", to_number="", status="completed"
        )
        return call

    async def put_on_hold(self, call_id: str) -> bool:
        call_data = self._active_calls.get(call_id)
        if not call_data:
            return False
        provider_call_id = call_data.get("call", {}).get("provider_call_id")
        if not provider_call_id:
            return False
        result = await self._phone.hold_call(provider_call_id)
        if result:
            call_data["call"]["status"] = "hold"
        return result

    async def resume(self, call_id: str) -> bool:
        call_data = self._active_calls.get(call_id)
        if not call_data:
            return False
        provider_call_id = call_data.get("call", {}).get("provider_call_id")
        if not provider_call_id:
            return False
        result = await self._phone.resume_call(provider_call_id)
        if result:
            call_data["call"]["status"] = "in_progress"
        return result

    async def transfer(self, call_id: str, target: str) -> bool:
        call_data = self._active_calls.get(call_id)
        if not call_data:
            return False
        provider_call_id = call_data.get("call", {}).get("provider_call_id")
        if not provider_call_id:
            return False
        result = await self._phone.transfer_call(provider_call_id, target)
        if result:
            call_data["call"]["status"] = "transferring"
        return result

    async def start_conference(self, call_id: str, participants: list[str]) -> dict:
        call_data = self._active_calls.get(call_id)
        if not call_data:
            return {"error": "call not found"}
        provider_call_id = call_data.get("call", {}).get("provider_call_id")
        if not provider_call_id:
            return {"error": "no provider call id"}
        result = await self._phone.start_conference(provider_call_id, participants)
        if result:
            call_data["call"]["status"] = "conferencing"
        return result

    async def get_active_calls(self) -> list[dict]:
        return [
            {
                "call_id": cid,
                "status": data.get("call", {}).get("status", "unknown"),
                "from_number": data.get("call", {}).get("from_number", ""),
                "to_number": data.get("call", {}).get("to_number", ""),
                "direction": data.get("call", {}).get("direction", ""),
                "started_at": data.get("started_at", ""),
            }
            for cid, data in self._active_calls.items()
        ]

    async def get_call(self, call_id: str) -> Optional[dict]:
        data = self._active_calls.get(call_id)
        if data:
            return {
                "call_id": call_id,
                "status": data.get("call", {}).get("status", "unknown"),
                "from_number": data.get("call", {}).get("from_number", ""),
                "to_number": data.get("call", {}).get("to_number", ""),
                "direction": data.get("call", {}).get("direction", ""),
                "started_at": data.get("started_at", ""),
            }
        return None

    async def stream_audio_to_call(self, call_id: str, audio: bytes) -> bool:
        call_data = self._active_calls.get(call_id)
        if not call_data:
            return False
        provider_call_id = call_data.get("call", {}).get("provider_call_id")
        if not provider_call_id:
            return False
        return await self._phone.stream_audio(provider_call_id, audio)

    async def process_webhook(self, provider_type: str, payload: dict) -> dict:
        return await self._phone.process_webhook(payload)

    def _map_provider_status(self, status: str) -> str:
        mapping = {
            "queued": "queued",
            "ringing": "ringing",
            "in-progress": "in_progress",
            "in_progress": "in_progress",
            "completed": "completed",
            "failed": "failed",
            "busy": "busy",
            "no-answer": "no_answer",
            "no_answer": "no_answer",
            "canceled": "cancelled",
            "cancelled": "cancelled",
        }
        return mapping.get(status, status)

    def _db_call_to_entity(self, db_call: CallModel) -> Call:
        return Call(
            id=UUID(db_call.id),
            organization_id=UUID(db_call.organization_id),
            user_id=UUID(db_call.user_id) if db_call.user_id else None,
            campaign_id=UUID(db_call.campaign_id) if db_call.campaign_id else None,
            lead_id=UUID(db_call.lead_id) if db_call.lead_id else None,
            contact_id=UUID(db_call.contact_id) if db_call.contact_id else None,
            direction=db_call.direction,
            from_number=db_call.from_number,
            to_number=db_call.to_number,
            status=db_call.status,
            disposition=db_call.disposition,
            duration_seconds=db_call.duration_seconds,
            provider_call_id=db_call.provider_call_id,
            started_at=db_call.started_at,
            ended_at=db_call.ended_at,
        )
