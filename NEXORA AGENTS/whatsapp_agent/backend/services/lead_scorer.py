from __future__ import annotations

import logging
import math
from datetime import datetime, timedelta
from typing import Any, Optional

from backend.domain.entities import Message
from backend.domain.enums import IntentCategory, SentimentLabel

logger = logging.getLogger(__name__)


class LeadScorer:
    MAX_SCORE = 100.0

    WEIGHT_FREQUENCY = 0.20
    WEIGHT_SENTIMENT = 0.20
    WEIGHT_INTENT = 0.25
    WEIGHT_RESPONSE_TIME = 0.20
    WEIGHT_CUSTOM = 0.15

    async def calculate_score(self, lead_data: dict) -> float:
        message_count = lead_data.get("message_count", 0)
        response_rate = lead_data.get("response_rate", 0.0)
        sentiment = lead_data.get("sentiment")
        intent = lead_data.get("intent")
        avg_response_minutes = lead_data.get("avg_response_minutes", 1440.0)
        custom_fields = lead_data.get("custom_fields", {})

        score = 0.0
        score += self._score_message_frequency(message_count) * self.WEIGHT_FREQUENCY
        score += self._score_response_rate(response_rate) * self.WEIGHT_FREQUENCY
        score += self._score_sentiment(sentiment) * self.WEIGHT_SENTIMENT
        score += self._score_intent(intent) * self.WEIGHT_INTENT
        score += self._score_response_time(avg_response_minutes) * self.WEIGHT_RESPONSE_TIME
        score += self._score_custom_fields(custom_fields) * self.WEIGHT_CUSTOM

        final_score = min(max(round(score, 1), 0.0), self.MAX_SCORE)
        logger.debug("Calculated lead score: %s (raw: %s)", final_score, score)
        return final_score

    async def score_from_conversation(self, messages: list[Message]) -> float:
        if not messages:
            return 0.0

        message_count = len(messages)

        inbound_messages = [m for m in messages if m.direction == "inbound"]
        outbound_messages = [m for m in messages if m.direction == "outbound"]
        total_replied = len(outbound_messages)
        response_rate = total_replied / message_count if message_count > 0 else 0.0

        sentiments = []
        for m in messages:
            if m.extra_data and "sentiment" in m.extra_data:
                sentiments.append(m.extra_data["sentiment"])
        avg_sentiment = None
        if sentiments:
            avg_sentiment = max(set(sentiments), key=sentiments.count)

        intents = []
        for m in messages:
            if m.extra_data and "intent" in m.extra_data:
                intents.append(m.extra_data["intent"])
        top_intent = None
        if intents:
            top_intent = max(set(intents), key=intents.count)

        timestamps = [m.created_at for m in messages if m.created_at]
        avg_response_minutes = 1440.0
        if len(timestamps) >= 4:
            diffs = []
            for i in range(1, len(timestamps)):
                diff = (timestamps[i] - timestamps[i - 1]).total_seconds() / 60.0
                if 0 < diff < 10080:
                    diffs.append(diff)
            if diffs:
                avg_response_minutes = sum(diffs) / len(diffs)

        lead_data: dict[str, Any] = {
            "message_count": message_count,
            "response_rate": response_rate,
            "sentiment": avg_sentiment,
            "intent": top_intent,
            "avg_response_minutes": avg_response_minutes,
            "custom_fields": {},
        }
        return await self.calculate_score(lead_data)

    def _score_message_frequency(self, count: int) -> float:
        if count <= 0:
            return 0.0
        if count >= 50:
            return 100.0
        return min(round((count / 50.0) * 100.0, 1), 100.0)

    def _score_response_rate(self, rate: float) -> float:
        return min(round(rate * 100.0, 1), 100.0)

    def _score_sentiment(self, sentiment: Optional[str]) -> float:
        if sentiment is None:
            return 50.0
        sentiment_map = {
            SentimentLabel.very_positive.value: 100.0,
            SentimentLabel.positive.value: 80.0,
            SentimentLabel.neutral.value: 50.0,
            SentimentLabel.negative.value: 20.0,
            SentimentLabel.very_negative.value: 5.0,
        }
        return sentiment_map.get(sentiment, 50.0)

    def _score_intent(self, intent: Optional[str]) -> float:
        if intent is None:
            return 30.0
        intent_map = {
            IntentCategory.purchase.value: 100.0,
            IntentCategory.support.value: 70.0,
            IntentCategory.information.value: 60.0,
            IntentCategory.feedback.value: 50.0,
            IntentCategory.greeting.value: 20.0,
            IntentCategory.complaint.value: 40.0,
            IntentCategory.handoff.value: 10.0,
            IntentCategory.spam.value: 0.0,
            IntentCategory.unknown.value: 30.0,
        }
        return intent_map.get(intent, 30.0)

    def _score_response_time(self, avg_response_minutes: float) -> float:
        if avg_response_minutes <= 1:
            return 100.0
        if avg_response_minutes >= 10080:
            return 0.0
        score = 100.0 * math.exp(-0.005 * avg_response_minutes)
        return round(max(score, 0.0), 1)

    def _score_custom_fields(self, custom_fields: dict) -> float:
        if not custom_fields:
            return 0.0
        filled = sum(1 for v in custom_fields.values() if v is not None and v != "")
        total = max(len(custom_fields), 1)
        ratio = filled / total
        return min(round(ratio * 100.0, 1), 100.0)
