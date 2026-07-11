import json
import uuid
import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import datetime, timezone


@pytest.fixture
def mock_db():
    return AsyncMock()


@pytest.fixture
def org_id():
    return uuid.uuid4()


class TestMetaService:
    def test_verify_signature_valid(self):
        import hmac
        import hashlib
        from src.infrastructure.integrations.meta_service import MetaWebhookVerifier

        payload = b"test payload"
        secret = "test_secret"
        expected = hmac.new(secret.encode(), payload, hashlib.sha256).hexdigest()
        signature = f"sha256={expected}"

        assert MetaWebhookVerifier.verify_signature(payload, signature, secret) is True

    def test_verify_signature_invalid(self):
        from src.infrastructure.integrations.meta_service import MetaWebhookVerifier

        payload = b"test payload"
        assert MetaWebhookVerifier.verify_signature(payload, "sha256=invalid", "secret") is False


class TestTwilioService:
    def test_generate_twiml_response(self):
        from src.infrastructure.integrations.twilio_service import TwilioVoiceService
        svc = TwilioVoiceService(account_sid="test", auth_token="test")

        twiml = svc.generate_twiml_response("Hello world")
        assert "<?xml" in twiml
        assert "Hello world" in twiml
        assert "<Say" in twiml
        assert "<Gather" in twiml

    def test_generate_twiml_transfer(self):
        from src.infrastructure.integrations.twilio_service import TwilioVoiceService
        svc = TwilioVoiceService(account_sid="test", auth_token="test")

        twiml = svc.generate_twiml_transfer("Transferring", "+1234567890")
        assert "Transferring" in twiml
        assert "+1234567890" in twiml
        assert "<Dial" in twiml

    def test_generate_twiml_recording(self):
        from src.infrastructure.integrations.twilio_service import TwilioVoiceService
        svc = TwilioVoiceService(account_sid="test", auth_token="test")

        twiml = svc.generate_twiml_recording("Recording now", "/callback")
        assert "Recording now" in twiml
        assert "<Record" in twiml
        assert "/callback" in twiml


class TestPaymentService:
    def test_stripe_verify_signature_valid(self):
        import hmac
        import hashlib
        import time
        from src.infrastructure.integrations.payment_service import StripeService

        payload = b"test"
        secret = "whsec_test"
        timestamp = str(int(time.time()))
        signed_payload = f"{timestamp}.{payload.decode()}"
        expected_sig = hmac.new(secret.encode(), signed_payload.encode(), hashlib.sha256).hexdigest()
        sig_header = f"t={timestamp},v1={expected_sig}"

        svc = StripeService.__new__(StripeService)
        assert svc.verify_webhook_signature(payload, sig_header, secret) is True

    def test_stripe_verify_signature_invalid(self):
        from src.infrastructure.integrations.payment_service import StripeService

        svc = StripeService.__new__(StripeService)
        assert svc.verify_webhook_signature(b"test", "v1=invalid", "secret") is False

    def test_razorpay_verify_signature_valid(self):
        import hmac
        import hashlib
        import base64
        from src.infrastructure.integrations.payment_service import RazorpayService

        payload = b"test"
        secret = "test_secret"
        expected = hmac.new(secret.encode(), payload, hashlib.sha256).digest()
        expected_b64 = base64.b64encode(expected).decode()

        svc = RazorpayService.__new__(RazorpayService)
        assert svc.verify_webhook_signature(payload, expected_b64, secret) is True


class TestMemoryVectorService:
    def test_memory_entry_response_model(self):
        from src.presentation.api.v1.memory import MemoryEntryResponse

        resp = MemoryEntryResponse(
            id=uuid.uuid4(),
            org_id=uuid.uuid4(),
            memory_type="long_term",
            category="preference",
            content="User prefers dark mode",
            confidence=0.8,
            is_active=True,
            created_at="2026-01-01T00:00:00",
            updated_at="2026-01-01T00:00:00",
        )
        assert resp.memory_type == "long_term"
        assert resp.confidence == 0.8

    def test_search_request_defaults(self):
        from src.presentation.api.v1.memory import SearchMemoryRequest

        req = SearchMemoryRequest(query="test query")
        assert req.limit == 20
        assert req.use_vector is True
        assert req.customer_id is None
