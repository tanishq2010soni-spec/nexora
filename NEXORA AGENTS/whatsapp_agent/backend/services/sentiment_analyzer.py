from __future__ import annotations

import logging
from typing import Any

from textblob import TextBlob

from backend.domain.entities import Message
from backend.domain.enums import SentimentLabel

logger = logging.getLogger(__name__)


class SentimentAnalyzer:
    async def analyze(self, text: str) -> SentimentLabel:
        if not text or not text.strip():
            return SentimentLabel.neutral

        try:
            blob = TextBlob(text)
            polarity = blob.sentiment.polarity
            label = self._polarity_to_label(polarity)
            logger.debug("Sentiment for text (len=%d): polarity=%.3f -> %s", len(text), polarity, label.value)
            return label
        except Exception as exc:
            logger.error("Error analyzing sentiment: %s", exc)
            return SentimentLabel.neutral

    async def analyze_batch(self, texts: list[str]) -> list[SentimentLabel]:
        results: list[SentimentLabel] = []
        for text in texts:
            label = await self.analyze(text)
            results.append(label)
        return results

    async def analyze_conversation(self, messages: list[Message]) -> dict[str, Any]:
        if not messages:
            return {
                "average_polarity": 0.0,
                "trend": "neutral",
                "label": SentimentLabel.neutral.value,
                "message_counts": {label.value: 0 for label in SentimentLabel},
            }

        polarities: list[float] = []
        sentiment_counts: dict[str, int] = {label.value: 0 for label in SentimentLabel}

        for message in messages:
            if message.content and message.content.strip():
                try:
                    blob = TextBlob(message.content)
                    polarity = blob.sentiment.polarity
                    polarities.append(polarity)
                    label = self._polarity_to_label(polarity)
                    sentiment_counts[label.value] = sentiment_counts.get(label.value, 0) + 1
                except Exception:
                    continue

        if not polarities:
            return {
                "average_polarity": 0.0,
                "trend": "neutral",
                "label": SentimentLabel.neutral.value,
                "message_counts": sentiment_counts,
            }

        avg_polarity = sum(polarities) / len(polarities)
        overall_label = self._polarity_to_label(avg_polarity)

        trend = "neutral"
        if len(polarities) >= 2:
            first_half = sum(polarities[:len(polarities)//2]) / max(len(polarities)//2, 1)
            second_half = sum(polarities[len(polarities)//2:]) / max(len(polarities) - len(polarities)//2, 1)
            diff = second_half - first_half
            if diff > 0.2:
                trend = "improving"
            elif diff < -0.2:
                trend = "declining"

        return {
            "average_polarity": round(avg_polarity, 3),
            "trend": trend,
            "label": overall_label.value,
            "message_counts": sentiment_counts,
        }

    def _polarity_to_label(self, polarity: float) -> SentimentLabel:
        if polarity > 0.5:
            return SentimentLabel.very_positive
        elif polarity > 0.1:
            return SentimentLabel.positive
        elif polarity >= -0.1:
            return SentimentLabel.neutral
        elif polarity >= -0.5:
            return SentimentLabel.negative
        else:
            return SentimentLabel.very_negative
