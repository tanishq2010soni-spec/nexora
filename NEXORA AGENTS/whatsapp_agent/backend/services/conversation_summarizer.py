from __future__ import annotations

import logging
import re
from datetime import datetime
from typing import Any, Optional

from backend.domain.entities import Message

logger = logging.getLogger(__name__)


class ConversationSummarizer:
    _MAX_SUMMARY_LENGTH = 500
    _KEY_SENTENCE_LIMIT = 5

    async def summarize(self, messages: list[Message]) -> str:
        if not messages:
            return ""

        if len(messages) == 1:
            return self._truncate(messages[0].content)

        sorted_msgs = sorted(messages, key=lambda m: m.created_at or datetime.utcnow())
        texts = [msg.content for msg in sorted_msgs if msg.content and msg.content.strip()]

        if not texts:
            return ""

        all_text = " ".join(texts)
        if len(all_text.split()) <= 30:
            return self._truncate(all_text)

        sentences = self._split_sentences(all_text)
        if len(sentences) <= self._KEY_SENTENCE_LIMIT:
            return self._truncate(all_text)

        scored_sentences = self._score_sentences(sentences, all_text)
        scored_sentences.sort(key=lambda x: x[1], reverse=True)

        top_sentences = [s[0] for s in scored_sentences[:self._KEY_SENTENCE_LIMIT]]
        top_sentences.sort(key=lambda x: all_text.index(x) if x in all_text else 0)

        summary = " ".join(top_sentences)

        direction_info = self._extract_direction_info(sorted_msgs)
        if direction_info:
            summary = f"{direction_info}. {summary}"

        summary = self._truncate(summary)

        logger.debug("Generated extractive summary (%d chars)", len(summary))
        return summary

    async def summarize_with_nexora(self, messages: list[Message], ai_runtime: Any) -> str:
        if not messages:
            return ""

        conversation_text = self._build_conversation_text(messages)

        try:
            if hasattr(ai_runtime, "generate") and callable(ai_runtime.generate):
                prompt = (
                    "Summarize the following WhatsApp conversation in 2-3 sentences. "
                    "Focus on the customer's main request, key issues discussed, and any action items.\n\n"
                    f"Conversation:\n{conversation_text}"
                )
                result = await ai_runtime.generate(prompt, max_tokens=200)
                if result and isinstance(result, str) and result.strip():
                    return self._truncate(result.strip())
        except Exception as exc:
            logger.warning("Nexora AI summarization failed, falling back to extractive: %s", exc)

        return await self.summarize(messages)

    def _build_conversation_text(self, messages: list[Message]) -> str:
        sorted_msgs = sorted(messages, key=lambda m: m.created_at or datetime.utcnow())
        lines: list[str] = []
        for msg in sorted_msgs:
            sender = "Customer" if msg.direction == "inbound" else "Agent"
            time_str = msg.created_at.strftime("%H:%M") if msg.created_at else ""
            content = msg.content or ""
            lines.append(f"[{time_str}] {sender}: {content}")
        return "\n".join(lines)

    def _split_sentences(self, text: str) -> list[str]:
        sentences = re.split(r'(?<=[.!?])\s+', text)
        return [s.strip() for s in sentences if s.strip()]

    def _score_sentences(self, sentences: list[str], full_text: str) -> list[tuple[str, float]]:
        words = full_text.lower().split()
        word_freq: dict[str, int] = {}
        for w in words:
            w_clean = re.sub(r'[^a-zA-Z0-9]', '', w)
            if w_clean and len(w_clean) > 2:
                word_freq[w_clean] = word_freq.get(w_clean, 0) + 1

        total_words = sum(word_freq.values()) or 1
        scored: list[tuple[str, float]] = []
        for sentence in sentences:
            sentence_lower = sentence.lower()
            freq_score = 0.0
            for word, count in word_freq.items():
                if word in sentence_lower:
                    freq_score += count / total_words

            length_score = min(len(sentence.split()) / 20.0, 1.0)
            position_score = 1.0 - (sentences.index(sentence) / max(len(sentences), 1)) * 0.3

            question_score = 0.2 if "?" in sentence else 0.0
            total_score = (freq_score * 0.4) + (length_score * 0.2) + (position_score * 0.3) + (question_score * 0.1)
            scored.append((sentence, total_score))

        return scored

    def _extract_direction_info(self, messages: list[Message]) -> Optional[str]:
        participant_info: list[str] = []
        customer_msgs = [m for m in messages if m.direction == "inbound"]
        agent_msgs = [m for m in messages if m.direction == "outbound"]

        if customer_msgs:
            participant_info.append(f"{len(customer_msgs)} customer messages")
        if agent_msgs:
            participant_info.append(f"{len(agent_msgs)} agent messages")

        if participant_info:
            return f"Conversation with {' and '.join(participant_info)}"
        return None

    def _truncate(self, text: str) -> str:
        if len(text) <= self._MAX_SUMMARY_LENGTH:
            return text
        limit = self._MAX_SUMMARY_LENGTH - 3  # Reserve space for "..."
        truncated = text[:limit]
        last_space = truncated.rfind(" ")
        if last_space > 0:
            truncated = truncated[:last_space]
        return truncated + "..."
