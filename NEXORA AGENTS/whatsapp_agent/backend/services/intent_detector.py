from __future__ import annotations

import logging
import re
from typing import Optional

from backend.domain.enums import IntentCategory

logger = logging.getLogger(__name__)


class IntentDetector:
    _patterns: dict[IntentCategory, list[str]] = {
        IntentCategory.greeting: [
            r"\bhi\b", r"\bhello\b", r"\bhey\b", r"\bgood morning\b",
            r"\bgood evening\b", r"\bgood afternoon\b", r"\bhowdy\b",
            r"\bwhat's up\b", r"\bwasup\b", r"\b^hi\b", r"\b^hey\b",
        ],
        IntentCategory.purchase: [
            r"\bbuy\b", r"\border\b", r"\bprice\b", r"\bcost\b", r"\bquote\b",
            r"\bpurchase\b", r"\bhow much\b", r"\bpricing\b", r"\bpayment\b",
            r"\bbilling\b", r"\binvoice\b", r"\bcheckout\b", r"\bcart\b",
        ],
        IntentCategory.complaint: [
            r"\bcomplaint\b", r"\bissue\b", r"\bproblem\b", r"\bnot working\b",
            r"\bbroken\b", r"\berror\b", r"\bbug\b", r"\bfrustrated\b",
            r"\bunacceptable\b", r"\bwrong\b", r"\bfault\b", r"\bnot happy\b",
        ],
        IntentCategory.support: [
            r"\bhelp\b", r"\bsupport\b", r"\bhow do I\b", r"\bcan you\b",
            r"\bguide\b", r"\btutorial\b", r"\bassist\b", r"\bhow to\b",
            r"\bstuck\b", r"\bconfused\b", r"\bnot sure\b", r"\bexplain\b",
        ],
        IntentCategory.handoff: [
            r"\bspeaker\b", r"\bhuman\b", r"\bperson\b", r"\bagent\b",
            r"\breal person\b", r"\btalk to\b", r"\btransfer\b",
            r"\boperator\b", r"\bmanager\b", r"\bsupervisor\b",
            r"\brepresentative\b", r"\bcustomer service\b",
        ],
        IntentCategory.feedback: [
            r"\bfeedback\b", r"\bsuggestion\b", r"\breview\b",
            r"\brating\b", r"\bcomment\b", r"\brecommend\b",
            r"\bimprove\b", r"\bopinion\b", r"\bexperience\b",
        ],
        IntentCategory.information: [
            r"\bwhat is\b", r"\bwhat are\b", r"\binformation\b",
            r"\bdetails\b", r"\btell me\b", r"\babout\b",
            r"\bwhere\b", r"\bwhen\b", r"\bwhy\b", r"\bhow does\b",
            r"\bmeaning\b", r"\bdefine\b", r"\bexplain\b",
        ],
        IntentCategory.spam: [
            r"\bclick here\b", r"\bwin free\b", r"\bcongratulations\b",
            r"\byou won\b", r"\bclaim your\b", r"\blimited time\b",
            r"\bact now\b", r"\b buy now\b", r"\bdiscount \d+%\b",
            r"\bviagra\b", r"\bcasino\b", r"\bwire transfer\b",
        ],
    }

    _unknown_keywords: list[str] = [
        r"\bidk\b", r"\bno idea\b", r"\bnot sure\b",
        r"\bi don't know\b", r"\bi dunno\b",
    ]

    async def detect(self, text: str, language: str = "en") -> IntentCategory:
        if not text or not text.strip():
            return IntentCategory.unknown

        lower_text = text.lower().strip()

        scores: dict[IntentCategory, int] = {}
        for category, patterns in self._patterns.items():
            score = 0
            for pattern in patterns:
                matches = re.findall(pattern, lower_text)
                score += len(matches)
            if score > 0:
                scores[category] = score

        if not scores:
            for pattern in self._unknown_keywords:
                if re.search(pattern, lower_text):
                    return IntentCategory.unknown

            word_count = len(lower_text.split())
            if word_count <= 3:
                return IntentCategory.greeting

            fallback_result = await self._nexora_fallback(text, language)
            if fallback_result is not None:
                return fallback_result

            return IntentCategory.unknown

        best_category = max(scores, key=scores.get)
        logger.debug(
            "Detected intent '%s' for text (lang=%s) with scores: %s",
            best_category.value, language, scores
        )
        return best_category

    async def detect_with_context(
        self, text: str, history: list[str]
    ) -> tuple[IntentCategory, float]:
        current_intent = await self.detect(text)

        confidence = 1.0
        if current_intent == IntentCategory.unknown and history:
            for hist_text in history[-5:]:
                hist_intent = await self.detect(hist_text)
                if hist_intent != IntentCategory.unknown:
                    current_intent = hist_intent
                    confidence = 0.5
                    break
            else:
                confidence = 0.2
        elif current_intent in (IntentCategory.greeting, IntentCategory.spam) and history:
            non_greeting_count = 0
            for hist_text in history[-3:]:
                hi = await self.detect(hist_text)
                if hi not in (IntentCategory.greeting, IntentCategory.spam, IntentCategory.unknown):
                    non_greeting_count += 1
            if non_greeting_count >= 2:
                current_intent = await self.detect(text + " " + " ".join(history[-2:]))

        return current_intent, round(confidence, 2)

    async def _nexora_fallback(self, text: str, language: str) -> Optional[IntentCategory]:
        try:
            from nexora_ai import classify_intent
            result = await classify_intent(text, language=language)
            if result and isinstance(result, str):
                for cat in IntentCategory:
                    if cat.value == result.lower():
                        return cat
            return None
        except ImportError:
            return None
        except Exception as exc:
            logger.warning("Nexora AI fallback failed: %s", exc)
            return None
