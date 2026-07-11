from __future__ import annotations

import json
import re
from datetime import datetime
from typing import Any, Optional
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from backend.infrastructure.database.models import RecordingModel, CallModel
from backend.infrastructure.voice.stt.base import STTProvider


class TranscriptionService:
    async def transcribe_recording(self, recording_id: str, stt: STTProvider, session: AsyncSession) -> str:
        result = await session.execute(
            select(RecordingModel).where(RecordingModel.id == recording_id)
        )
        db_recording = result.scalar_one_or_none()
        if not db_recording:
            raise ValueError(f"Recording {recording_id} not found")

        db_recording.transcription_status = "processing"
        await session.flush()

        try:
            if db_recording.file_path:
                transcript = await stt.transcribe_file(db_recording.file_path)
            else:
                raise ValueError(f"Recording {recording_id} has no file path")

            db_recording.transcription_text = transcript
            db_recording.transcription_status = "completed"

            call_result = await session.execute(
                select(CallModel).where(CallModel.id == db_recording.call_id)
            )
            db_call = call_result.scalar_one_or_none()
            if db_call:
                db_call.transcript = transcript
                db_call.transcription_status = "completed"

            await session.flush()
            return transcript
        except Exception as e:
            db_recording.transcription_status = "failed"
            await session.flush()
            raise RuntimeError(f"Transcription failed for recording {recording_id}: {e}")

    async def generate_summary(self, transcript: str, call_id: str, session: Optional[AsyncSession] = None) -> str:
        if not transcript.strip():
            return ""

        sentences = re.split(r"[.!?]+", transcript)
        sentences = [s.strip() for s in sentences if s.strip()]

        if not sentences:
            return ""

        word_count = len(transcript.split())

        topics = self._extract_topics(transcript)
        action_items = self._extract_action_items(transcript)
        sentiment = self._detect_sentiment(transcript)

        summary_parts = [f"Call Summary ({sentiment} sentiment)"]

        if topics:
            summary_parts.append(f"Topics: {', '.join(topics[:5])}")

        first_sentences = sentences[:3]
        summary_parts.append("Key points:")
        for i, sent in enumerate(first_sentences, 1):
            cleaned = sent.strip()
            if cleaned:
                summary_parts.append(f"  {i}. {cleaned}")

        if action_items:
            summary_parts.append("Action items:")
            for item in action_items[:3]:
                summary_parts.append(f"  - {item}")

        summary_parts.append(f"Total words: {word_count}")

        summary = "\n".join(summary_parts)

        if session:
            call_result = await session.execute(
                select(CallModel).where(CallModel.id == call_id)
            )
            db_call = call_result.scalar_one_or_none()
            if db_call:
                db_call.summary = summary
                await session.flush()

        return summary

    async def extract_entities(self, transcript: str) -> dict:
        entities: dict[str, list[str]] = {
            "names": [],
            "organizations": [],
            "phone_numbers": [],
            "emails": [],
            "dates": [],
            "amounts": [],
            "locations": [],
        }

        phone_pattern = re.compile(r"\+?1?\d{10,15}")
        phones = phone_pattern.findall(transcript)
        if phones:
            entities["phone_numbers"] = list(set(phones))

        email_pattern = re.compile(r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
        emails = email_pattern.findall(transcript)
        if emails:
            entities["emails"] = list(set(emails))

        date_pattern = re.compile(
            r"\b(\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\d{4}[/-]\d{1,2}[/-]\d{1,2}|"
            r"(?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|"
            r"Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)"
            r"\s+\d{1,2},?\s+\d{4})\b"
        )
        dates = date_pattern.findall(transcript)
        if dates:
            entities["dates"] = list(set(dates))

        amount_pattern = re.compile(r"\$\s?\d+(?:,\d{3})*(?:\.\d{2})?")
        amounts = amount_pattern.findall(transcript)
        if amounts:
            entities["amounts"] = list(set(amounts))

        name_prefixes = ["mr", "mrs", "ms", "dr", "prof"]
        name_pattern = re.compile(
            rf"(?:{'|'.join(name_prefixes)})\.?\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)",
            re.IGNORECASE,
        )
        names = name_pattern.findall(transcript)
        if names:
            entities["names"] = list(set(names))

        org_keywords = ["inc", "corp", "ltd", "llc", "gmbh", "llp", "company", "technologies", "solutions"]
        org_pattern = re.compile(
            rf"([A-Z][a-zA-Z]+(?:\s+[A-Z][a-zA-Z]+)*)\s+(?:{'|'.join(org_keywords)})",
        )
        orgs = org_pattern.findall(transcript)
        if orgs:
            entities["organizations"] = list(set(orgs))

        location_pattern = re.compile(r"\bin\s+([A-Z][a-zA-Z]+(?:\s+[A-Z][a-zA-Z]+)?)\b")
        locations = location_pattern.findall(transcript)
        if locations:
            entities["locations"] = list(set(locations))

        return entities

    def _extract_topics(self, transcript: str) -> list[str]:
        topic_keywords = {
            "pricing": ["price", "pricing", "cost", "budget", "afford", "expensive", "cheap", "subscription"],
            "features": ["feature", "functionality", "capability", "integration", "api", "platform"],
            "support": ["support", "help", "assist", "service", "issue", "problem", "bug", "error"],
            "contract": ["contract", "agreement", "terms", "renew", "cancel", "termination", "notice"],
            "schedule": ["meeting", "appointment", "schedule", "calendar", "call back", "demo"],
            "product": ["product", "solution", "offer", "service", "tool", "software"],
            "competition": ["competitor", "alternative", "other vendor", "switching", "migrate"],
        }

        topics_found = []
        transcript_lower = transcript.lower()

        for topic, keywords in topic_keywords.items():
            for keyword in keywords:
                if keyword in transcript_lower:
                    topics_found.append(topic)
                    break

        return topics_found

    def _extract_action_items(self, transcript: str) -> list[str]:
        action_patterns = [
            r"(?:I'?ll|we'?ll|I will|we will)\s+([^.!?]+)",
            r"(?:please|kindly|make sure to|don't forget to)\s+([^.!?]+)",
            r"(?:follow[- ]up|send|email|call back|schedule|upload|share|provide|check|confirm|update)\s+([^.!?]+)",
            r"(?:next steps?|action items?|to[- ]do)\s*:?\s*([^.!?]+)",
            r"(?:need to|have to|must|should)\s+([^.!?]+)",
        ]

        items = []
        for pattern in action_patterns:
            matches = re.findall(pattern, transcript, re.IGNORECASE)
            for m in matches:
                cleaned = m.strip().strip(".").strip()
                if cleaned and len(cleaned) > 10 and cleaned not in items:
                    items.append(cleaned)

        return items

    def _detect_sentiment(self, transcript: str) -> str:
        positive_words = [
            "great", "excellent", "amazing", "wonderful", "fantastic", "good", "best",
            "love", "happy", "pleased", "satisfied", "perfect", "awesome", "thank",
            "appreciate", "helpful", "interested", "yes", "sure", "absolutely",
        ]
        negative_words = [
            "bad", "terrible", "awful", "horrible", "worst", "poor", "hate",
            "unhappy", "disappointed", "frustrated", "angry", "upset", "problem",
            "issue", "error", "bug", "broken", "not interested", "no", "never",
            "cannot", "can't", "won't", "refuse", "decline",
        ]

        transcript_lower = transcript.lower()
        words = transcript_lower.split()

        positive_count = sum(1 for w in words if w in positive_words)
        negative_count = sum(1 for w in words if w in negative_words)

        if positive_count > negative_count:
            return "positive"
        if negative_count > positive_count:
            return "negative"
        return "neutral"
