from uuid import uuid4

import pytest

from backend.domain.entities import Message
from backend.domain.enums import SentimentLabel, IntentCategory, LanguageCode
from backend.services.lead_scorer import LeadScorer
from backend.services.sentiment_analyzer import SentimentAnalyzer
from backend.services.intent_detector import IntentDetector
from backend.services.language_detector import LanguageDetector
from backend.services.conversation_summarizer import ConversationSummarizer


@pytest.fixture
def lead_scorer():
    return LeadScorer()


@pytest.fixture
def sentiment_analyzer():
    return SentimentAnalyzer()


@pytest.fixture
def intent_detector():
    return IntentDetector()


@pytest.fixture
def language_detector():
    return LanguageDetector()


@pytest.fixture
def summarizer():
    return ConversationSummarizer()


class TestLeadScorer:
    pytestmark = pytest.mark.asyncio

    async def test_calculate_score_max_values(self, lead_scorer):
        score = await lead_scorer.calculate_score({
            "message_count": 50,
            "response_rate": 1.0,
            "sentiment": "very_positive",
            "intent": "purchase",
            "avg_response_minutes": 0.5,
        })
        assert score == 100.0

    async def test_calculate_score_min_values(self, lead_scorer):
        score = await lead_scorer.calculate_score({
            "message_count": 0,
            "response_rate": 0.0,
            "sentiment": "very_negative",
            "intent": "spam",
            "avg_response_minutes": 10080,
        })
        assert score == 1.0

    async def test_calculate_score_mid_range(self, lead_scorer):
        score = await lead_scorer.calculate_score({
            "message_count": 10,
            "response_rate": 0.5,
            "sentiment": "neutral",
            "intent": "information",
            "avg_response_minutes": 60,
        })
        assert 20.0 <= score <= 80.0

    async def test_calculate_score_none_sentiment_and_intent(self, lead_scorer):
        score = await lead_scorer.calculate_score({
            "message_count": 5,
            "response_rate": 0.3,
            "sentiment": None,
            "intent": None,
            "avg_response_minutes": 1440,
        })
        assert 0.0 <= score <= 100.0

    async def test_calculate_score_custom_fields(self, lead_scorer):
        score = await lead_scorer.calculate_score({
            "message_count": 0,
            "response_rate": 0.0,
            "sentiment": None,
            "intent": None,
            "avg_response_minutes": 1440,
            "custom_fields": {"industry": "tech", "budget": "5000"},
        })
        assert score > 0.0

    async def test_score_from_conversation_empty(self, lead_scorer):
        score = await lead_scorer.score_from_conversation([])
        assert score == 0.0

    async def test_score_from_conversation_with_messages(self, lead_scorer):
        from datetime import datetime
        org_id = uuid4()
        conv_id = uuid4()
        messages = [
            Message(
                organization_id=org_id,
                conversation_id=conv_id,
                direction="inbound",
                from_phone="+1",
                to_phone="+2",
                content="I want to buy something",
                created_at=datetime(2025, 1, 1, 10, 0),
            ),
            Message(
                organization_id=org_id,
                conversation_id=conv_id,
                direction="outbound",
                from_phone="+2",
                to_phone="+1",
                content="Sure, let me help",
                created_at=datetime(2025, 1, 1, 10, 5),
            ),
        ]
        score = await lead_scorer.score_from_conversation(messages)
        assert 0.0 <= score <= 100.0

    def test_score_message_frequency(self, lead_scorer):
        assert lead_scorer._score_message_frequency(0) == 0.0
        assert lead_scorer._score_message_frequency(50) == 100.0
        assert lead_scorer._score_message_frequency(25) == 50.0

    def test_score_response_rate(self, lead_scorer):
        assert lead_scorer._score_response_rate(0.0) == 0.0
        assert lead_scorer._score_response_rate(1.0) == 100.0
        assert lead_scorer._score_response_rate(0.5) == 50.0

    def test_score_sentiment(self, lead_scorer):
        assert lead_scorer._score_sentiment("very_positive") == 100.0
        assert lead_scorer._score_sentiment("positive") == 80.0
        assert lead_scorer._score_sentiment("neutral") == 50.0
        assert lead_scorer._score_sentiment("negative") == 20.0
        assert lead_scorer._score_sentiment("very_negative") == 5.0
        assert lead_scorer._score_sentiment(None) == 50.0

    def test_score_intent(self, lead_scorer):
        assert lead_scorer._score_intent("purchase") == 100.0
        assert lead_scorer._score_intent("support") == 70.0
        assert lead_scorer._score_intent("spam") == 0.0
        assert lead_scorer._score_intent(None) == 30.0

    def test_score_response_time(self, lead_scorer):
        assert lead_scorer._score_response_time(1) == 100.0
        assert lead_scorer._score_response_time(10080) == 0.0
        assert 0.0 < lead_scorer._score_response_time(60) < 100.0

    def test_score_custom_fields(self, lead_scorer):
        assert lead_scorer._score_custom_fields({}) == 0.0
        assert lead_scorer._score_custom_fields({"a": "val", "b": "val2"}) == 100.0
        assert lead_scorer._score_custom_fields({"a": "", "b": "val"}) == 50.0


class TestSentimentAnalyzer:
    pytestmark = pytest.mark.asyncio

    async def test_analyze_positive(self, sentiment_analyzer):
        result = await sentiment_analyzer.analyze("I love this product! It's amazing!")
        assert result in (SentimentLabel.positive, SentimentLabel.very_positive)

    async def test_analyze_very_positive(self, sentiment_analyzer):
        result = await sentiment_analyzer.analyze("This is absolutely wonderful and fantastic!")
        assert result == SentimentLabel.very_positive

    async def test_analyze_negative(self, sentiment_analyzer):
        result = await sentiment_analyzer.analyze("This is terrible and awful.")
        assert result in (SentimentLabel.negative, SentimentLabel.very_negative)

    async def test_analyze_neutral(self, sentiment_analyzer):
        result = await sentiment_analyzer.analyze("The meeting is at 3 PM.")
        assert result == SentimentLabel.neutral

    async def test_analyze_empty_text(self, sentiment_analyzer):
        result = await sentiment_analyzer.analyze("")
        assert result == SentimentLabel.neutral

    async def test_analyze_whitespace(self, sentiment_analyzer):
        result = await sentiment_analyzer.analyze("   ")
        assert result == SentimentLabel.neutral

    async def test_analyze_batch(self, sentiment_analyzer):
        results = await sentiment_analyzer.analyze_batch(["Good", "Bad", "Okay"])
        assert len(results) == 3
        assert all(isinstance(r, SentimentLabel) for r in results)

    async def test_analyze_conversation_empty(self, sentiment_analyzer):
        result = await sentiment_analyzer.analyze_conversation([])
        assert result["average_polarity"] == 0.0
        assert result["trend"] == "neutral"
        assert result["label"] == "neutral"

    async def test_analyze_conversation_with_messages(self, sentiment_analyzer):
        messages = [
            Message(organization_id=uuid4(), conversation_id=uuid4(), direction="inbound", from_phone="+1", to_phone="+2", content="I love this"),
            Message(organization_id=uuid4(), conversation_id=uuid4(), direction="outbound", from_phone="+2", to_phone="+1", content="Glad you like it"),
        ]
        result = await sentiment_analyzer.analyze_conversation(messages)
        assert "average_polarity" in result
        assert "label" in result
        assert "message_counts" in result

    def test_polarity_to_label(self, sentiment_analyzer):
        assert sentiment_analyzer._polarity_to_label(0.8) == SentimentLabel.very_positive
        assert sentiment_analyzer._polarity_to_label(0.3) == SentimentLabel.positive
        assert sentiment_analyzer._polarity_to_label(0.0) == SentimentLabel.neutral
        assert sentiment_analyzer._polarity_to_label(-0.3) == SentimentLabel.negative
        assert sentiment_analyzer._polarity_to_label(-0.8) == SentimentLabel.very_negative


class TestIntentDetector:
    pytestmark = pytest.mark.asyncio

    async def test_detect_greeting(self, intent_detector):
        result = await intent_detector.detect("Hello, how are you?")
        assert result == IntentCategory.greeting

    async def test_detect_purchase(self, intent_detector):
        result = await intent_detector.detect("I want to buy a new phone. What is the price?")
        assert result == IntentCategory.purchase

    async def test_detect_support(self, intent_detector):
        result = await intent_detector.detect("Can you help me with my account?")
        assert result == IntentCategory.support

    async def test_detect_complaint(self, intent_detector):
        result = await intent_detector.detect("This product is broken and not working. I have a problem.")
        assert result == IntentCategory.complaint

    async def test_detect_handoff(self, intent_detector):
        result = await intent_detector.detect("I want to talk to a real person.")
        assert result == IntentCategory.handoff

    async def test_detect_spam(self, intent_detector):
        result = await intent_detector.detect("Click here to win free money! Congratulations you won!")
        assert result == IntentCategory.spam

    async def test_detect_feedback(self, intent_detector):
        result = await intent_detector.detect("I want to give feedback about your service.")
        assert result == IntentCategory.feedback

    async def test_detect_information(self, intent_detector):
        result = await intent_detector.detect("What is your return policy? Tell me the details.")
        assert result == IntentCategory.information

    async def test_detect_unknown(self, intent_detector):
        result = await intent_detector.detect("")
        assert result == IntentCategory.unknown

    async def test_detect_empty_text(self, intent_detector):
        result = await intent_detector.detect("")
        assert result == IntentCategory.unknown

    async def test_detect_short_text_defaults_to_greeting(self, intent_detector):
        result = await intent_detector.detect("hi")
        assert result == IntentCategory.greeting

    async def test_detect_with_context_inherits_from_history(self, intent_detector):
        intent, confidence = await intent_detector.detect_with_context(
            "I'm not sure", ["What is the price?", "Tell me about your products."]
        )
        assert intent in (IntentCategory.purchase, IntentCategory.information, IntentCategory.support)

    async def test_detect_with_context_unknown(self, intent_detector):
        intent, confidence = await intent_detector.detect_with_context("xyzabc", [])
        assert confidence <= 1.0


class TestLanguageDetector:
    pytestmark = pytest.mark.asyncio

    async def test_detect_english(self, language_detector):
        result = await language_detector.detect("Hello, how are you today?")
        assert result == LanguageCode.en

    async def test_detect_spanish(self, language_detector):
        result = await language_detector.detect("Hola, ¿cómo estás?")
        assert result == LanguageCode.es

    async def test_detect_french(self, language_detector):
        result = await language_detector.detect("Bonjour, comment allez-vous?")
        assert result == LanguageCode.fr

    async def test_detect_german(self, language_detector):
        result = await language_detector.detect("Guten Tag, wie geht es Ihnen?")
        assert result == LanguageCode.de

    async def test_detect_empty_text(self, language_detector):
        result = await language_detector.detect("")
        assert result == LanguageCode.unknown

    async def test_detect_whitespace(self, language_detector):
        result = await language_detector.detect("   ")
        assert result == LanguageCode.unknown

    async def test_detect_batch(self, language_detector):
        results = await language_detector.detect_batch(["Hello", "Hola", "Bonjour"])
        assert len(results) == 3
        assert all(isinstance(r, LanguageCode) for r in results)


class TestConversationSummarizer:
    pytestmark = pytest.mark.asyncio

    async def test_summarize_empty(self, summarizer):
        result = await summarizer.summarize([])
        assert result == ""

    async def test_summarize_single_message(self, summarizer):
        from datetime import datetime
        msg = Message(
            organization_id=uuid4(), conversation_id=uuid4(),
            direction="inbound", from_phone="+1", to_phone="+2",
            content="Hello, I need help with my order.",
            created_at=datetime(2025, 1, 1, 10, 0),
        )
        result = await summarizer.summarize([msg])
        assert "Hello, I need help with my order." in result

    async def test_summarize_short_conversation(self, summarizer):
        from datetime import datetime
        msgs = [
            Message(organization_id=uuid4(), conversation_id=uuid4(), direction="inbound", from_phone="+1", to_phone="+2", content="Hi", created_at=datetime(2025, 1, 1, 10, 0)),
            Message(organization_id=uuid4(), conversation_id=uuid4(), direction="outbound", from_phone="+2", to_phone="+1", content="Hello, how can I help?", created_at=datetime(2025, 1, 1, 10, 1)),
        ]
        result = await summarizer.summarize(msgs)
        assert len(result) > 0
        assert "customer messages" in result or "agent messages" in result or "Hi" in result

    async def test_summarize_long_conversation(self, summarizer):
        from datetime import datetime
        msgs = [
            Message(organization_id=uuid4(), conversation_id=uuid4(), direction="inbound", from_phone="+1", to_phone="+2", content=f"Message {i}", created_at=datetime(2025, 1, 1, 10, i))
            for i in range(20)
        ]
        result = await summarizer.summarize(msgs)
        assert isinstance(result, str)
        assert len(result) > 0

    async def test_summarize_respects_max_length(self, summarizer):
        from datetime import datetime
        long_text = "word " * 500
        msgs = [
            Message(organization_id=uuid4(), conversation_id=uuid4(), direction="inbound", from_phone="+1", to_phone="+2", content=long_text, created_at=datetime(2025, 1, 1, 10, 0)),
        ]
        result = await summarizer.summarize(msgs)
        assert len(result) <= 500

    def test_extract_direction_info(self, summarizer):
        from datetime import datetime
        msgs = [
            Message(organization_id=uuid4(), conversation_id=uuid4(), direction="inbound", from_phone="+1", to_phone="+2", content="Hi", created_at=datetime(2025, 1, 1, 10, 0)),
            Message(organization_id=uuid4(), conversation_id=uuid4(), direction="outbound", from_phone="+2", to_phone="+1", content="Hello", created_at=datetime(2025, 1, 1, 10, 1)),
        ]
        info = summarizer._extract_direction_info(msgs)
        assert info is not None
        assert "customer messages" in info
        assert "agent messages" in info
