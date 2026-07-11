"""
Phase 6A — Integration Verification Tests

Tests that verify real integration logic, webhook handling, and error handling.
These are unit tests using mocked HTTP clients — they verify the integration code
is correctly wired and would work against real APIs.
"""

import hmac
import hashlib
import base64
import json
import time
import uuid
import pytest
from unittest.mock import AsyncMock, MagicMock, patch, AsyncMock


# ==================== Meta / WhatsApp ====================

class TestMetaWebhookVerifier:
    def test_valid_signature(self):
        from src.infrastructure.integrations.meta_service import MetaWebhookVerifier
        payload = b'{"object":"page","entry":[]}'
        secret = "my_app_secret"
        expected = hmac.new(secret.encode(), payload, hashlib.sha256).hexdigest()
        sig = f"sha256={expected}"
        assert MetaWebhookVerifier.verify_signature(payload, sig, secret) is True

    def test_invalid_signature(self):
        from src.infrastructure.integrations.meta_service import MetaWebhookVerifier
        assert MetaWebhookVerifier.verify_signature(b"test", "sha256=invalid", "secret") is False

    def test_malformed_signature(self):
        from src.infrastructure.integrations.meta_service import MetaWebhookVerifier
        assert MetaWebhookVerifier.verify_signature(b"test", "not_a_signature", "secret") is False

    def test_empty_signature(self):
        from src.infrastructure.integrations.meta_service import MetaWebhookVerifier
        assert MetaWebhookVerifier.verify_signature(b"test", "", "secret") is False


class TestWhatsAppCloudAPI:
    @pytest.mark.asyncio
    async def test_send_text_message_calls_correct_url(self):
        from src.infrastructure.integrations.meta_service import WhatsAppCloudAPI
        api = WhatsAppCloudAPI(access_token="test_token", phone_number_id="12345")

        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"messages": [{"id": "msg_123"}]}

        with patch("httpx.AsyncClient") as mock_client_cls:
            mock_client = AsyncMock()
            mock_client.post.return_value = mock_response
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=False)
            mock_client_cls.return_value = mock_client

            result = await api.send_text_message(to="919876543210", text="Hello!")

            call_args = mock_client.post.call_args
            assert "12345/messages" in call_args[0][0]
            assert result["messages"][0]["id"] == "msg_123"

    @pytest.mark.asyncio
    async def test_send_text_message_raises_on_error(self):
        from src.infrastructure.integrations.meta_service import WhatsAppCloudAPI
        api = WhatsAppCloudAPI(access_token="test_token", phone_number_id="12345")

        mock_response = MagicMock()
        mock_response.status_code = 401
        mock_response.text = "Invalid access token"

        with patch("httpx.AsyncClient") as mock_client_cls:
            mock_client = AsyncMock()
            mock_client.post.return_value = mock_response
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=False)
            mock_client_cls.return_value = mock_client

            with pytest.raises(Exception, match="WhatsApp API error 401"):
                await api.send_text_message(to="919876543210", text="Hello!")


class TestFacebookMessengerAPI:
    @pytest.mark.asyncio
    async def test_send_text_message_payload(self):
        from src.infrastructure.integrations.meta_service import FacebookMessengerAPI
        api = FacebookMessengerAPI(page_access_token="page_token", page_id="page_123")

        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"recipient_id": "user_123", "message_id": "msg_456"}

        with patch("httpx.AsyncClient") as mock_client_cls:
            mock_client = AsyncMock()
            mock_client.post.return_value = mock_response
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=False)
            mock_client_cls.return_value = mock_client

            result = await api.send_text_message(recipient_id="user_123", text="Hi there!")
            call_payload = mock_client.post.call_args[1]["json"]
            assert call_payload["recipient"]["id"] == "user_123"
            assert call_payload["message"]["text"] == "Hi there!"
            assert call_payload["messaging_type"] == "RESPONSE"


class TestInstagramMessagingAPI:
    @pytest.mark.asyncio
    async def test_send_message_correct_endpoint(self):
        from src.infrastructure.integrations.meta_service import InstagramMessagingAPI
        api = InstagramMessagingAPI(access_token="ig_token", instagram_account_id="ig_123")

        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {}

        with patch("httpx.AsyncClient") as mock_client_cls:
            mock_client = AsyncMock()
            mock_client.post.return_value = mock_response
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=False)
            mock_client_cls.return_value = mock_client

            await api.send_message(recipient_id="user_456", text="Hello from IG!")
            call_url = mock_client.post.call_args[0][0]
            assert "ig_123/messages" in call_url


# ==================== Twilio ====================

class TestTwilioWebhookVerifier:
    def test_valid_signature(self):
        from src.infrastructure.integrations.twilio_service import TwilioWebhookVerifier
        url = "https://example.com/webhook"
        params = {"CallSid": "CA123", "CallStatus": "completed"}
        auth_token = "my_auth_token"

        # Compute expected signature the same way Twilio does
        data_str = url
        for key in sorted(params.keys()):
            data_str += key + str(params[key])
        expected = base64.b64encode(
            hmac.new(auth_token.encode(), data_str.encode(), hashlib.sha1).digest()
        ).decode()

        assert TwilioWebhookVerifier.verify_signature(url, params, expected, auth_token) is True

    def test_invalid_signature(self):
        from src.infrastructure.integrations.twilio_service import TwilioWebhookVerifier
        assert TwilioWebhookVerifier.verify_signature(
            "https://example.com/webhook", {}, "invalid", "secret"
        ) is False


class TestTwilioVoiceService:
    @pytest.mark.asyncio
    async def test_initiate_call_sends_correct_data(self):
        from src.infrastructure.integrations.twilio_service import TwilioVoiceService
        svc = TwilioVoiceService(account_sid="AC123", auth_token="auth_token")

        mock_response = MagicMock()
        mock_response.status_code = 201
        mock_response.json.return_value = {"sid": "CA_new_call", "status": "queued"}

        with patch("httpx.AsyncClient") as mock_client_cls:
            mock_client = AsyncMock()
            mock_client.post.return_value = mock_response
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=False)
            mock_client_cls.return_value = mock_client

            result = await svc.initiate_outbound_call(
                to_number="+1234567890",
                from_number="+0987654321",
                webhook_url="https://example.com/twiml",
            )
            call_data = mock_client.post.call_args[1]["data"]
            assert call_data["To"] == "+1234567890"
            assert call_data["From"] == "+0987654321"
            assert result["sid"] == "CA_new_call"

    @pytest.mark.asyncio
    async def test_initiate_call_raises_on_error(self):
        from src.infrastructure.integrations.twilio_service import TwilioVoiceService, TwilioAPIError
        svc = TwilioVoiceService(account_sid="AC123", auth_token="auth_token")

        mock_response = MagicMock()
        mock_response.status_code = 401
        mock_response.text = "Authentication Error"

        with patch("httpx.AsyncClient") as mock_client_cls:
            mock_client = AsyncMock()
            mock_client.post.return_value = mock_response
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=False)
            mock_client_cls.return_value = mock_client

            with pytest.raises(TwilioAPIError):
                await svc.initiate_outbound_call(
                    to_number="+1234567890",
                    from_number="+0987654321",
                    webhook_url="https://example.com/twiml",
                )


# ==================== Stripe ====================

class TestStripeWebhookVerification:
    def test_valid_signature_with_timestamp(self):
        import time
        from src.infrastructure.integrations.payment_service import StripeService
        svc = StripeService.__new__(StripeService)

        payload = b'{"type":"checkout.session.completed"}'
        secret = "whsec_test123"
        timestamp = str(int(time.time()))
        signed_payload = f"{timestamp}.{payload.decode()}"
        sig = hmac.new(secret.encode(), signed_payload.encode(), hashlib.sha256).hexdigest()
        header = f"t={timestamp},v1={sig}"

        assert svc.verify_webhook_signature(payload, header, secret) is True

    def test_rejects_expired_timestamp(self):
        from src.infrastructure.integrations.payment_service import StripeService
        svc = StripeService.__new__(StripeService)

        payload = b"test"
        secret = "whsec_test"
        timestamp = "1000000"  # 1970
        signed_payload = f"{timestamp}.{payload.decode()}"
        sig = hmac.new(secret.encode(), signed_payload.encode(), hashlib.sha256).hexdigest()
        header = f"t={timestamp},v1={sig}"

        assert svc.verify_webhook_signature(payload, header, secret) is False

    def test_rejects_tampered_payload(self):
        import time
        from src.infrastructure.integrations.payment_service import StripeService
        svc = StripeService.__new__(StripeService)

        secret = "whsec_test"
        timestamp = str(int(time.time()))
        signed_payload = f"{timestamp}.original_payload"
        sig = hmac.new(secret.encode(), signed_payload.encode(), hashlib.sha256).hexdigest()
        header = f"t={timestamp},v1={sig}"

        assert svc.verify_webhook_signature(b"tampered_payload", header, secret) is False


# ==================== Razorpay ====================

class TestRazorpayWebhookVerification:
    def test_valid_signature(self):
        from src.infrastructure.integrations.payment_service import RazorpayService
        svc = RazorpayService.__new__(RazorpayService)

        payload = b'{"event":"payment.captured"}'
        secret = "razorpay_secret"
        expected = hmac.new(secret.encode(), payload, hashlib.sha256).digest()
        expected_b64 = base64.b64encode(expected).decode()

        assert svc.verify_webhook_signature(payload, expected_b64, secret) is True

    def test_invalid_signature(self):
        from src.infrastructure.integrations.payment_service import RazorpayService
        svc = RazorpayService.__new__(RazorpayService)
        assert svc.verify_webhook_signature(b"test", "invalid_b64", "secret") is False


# ==================== PaymentService Webhook Handlers ====================

class TestPaymentServiceWebhookHandling:
    @pytest.mark.asyncio
    async def test_stripe_checkout_session_resolves_plan(self):
        from src.infrastructure.integrations.payment_service import PaymentService
        from src.infrastructure.database.models import Plan

        mock_db = AsyncMock()
        mock_plan = Plan(id=uuid.uuid4(), name="Pro", price_monthly=49.99, price_yearly=499.99)
        mock_plan.id = uuid.uuid4()

        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_plan
        mock_db.execute.return_value = mock_result

        svc = PaymentService(db=mock_db)
        data = {
            "object": {
                "metadata": {"org_id": str(uuid.uuid4()), "price_id": "price_stripe_123"},
                "subscription": "sub_stripe_123",
            }
        }

        result = await svc.handle_stripe_webhook("checkout.session.completed", data)
        assert result["status"] == "activated"

    @pytest.mark.asyncio
    async def test_stripe_subscription_deleted_cancels(self):
        from src.infrastructure.integrations.payment_service import PaymentService
        from src.infrastructure.database.models import Subscription

        mock_db = AsyncMock()
        mock_sub = MagicMock(spec=Subscription)
        mock_sub.status = "active"

        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_sub
        mock_db.execute.return_value = mock_result

        svc = PaymentService(db=mock_db)
        data = {"object": {"id": "sub_123"}}

        result = await svc.handle_stripe_webhook("customer.subscription.deleted", data)
        assert result["status"] == "cancelled"
        assert mock_sub.status == "cancelled"


# ==================== LLM Service Error Propagation ====================

class TestLLMServiceErrorPropagation:
    @pytest.mark.asyncio
    async def test_generate_response_raises_on_failure(self):
        from src.infrastructure.llm.ollama_service import OllamaLLMService, LLMServiceError
        from src.infrastructure.llm.ollama_client import OllamaClientError

        mock_client = AsyncMock()
        mock_client.generate_response.side_effect = OllamaClientError("Connection refused")

        svc = OllamaLLMService(client=mock_client)
        with pytest.raises(LLMServiceError, match="LLM generation failed"):
            await svc.generate_response("Hello")

    @pytest.mark.asyncio
    async def test_generate_structured_json_raises_on_failure(self):
        from src.infrastructure.llm.ollama_service import OllamaLLMService, LLMServiceError
        from src.infrastructure.llm.ollama_client import OllamaClientError

        mock_client = AsyncMock()
        mock_client.generate_structured.side_effect = OllamaClientError("Timeout")

        svc = OllamaLLMService(client=mock_client)
        with pytest.raises(LLMServiceError, match="Structured JSON generation failed"):
            await svc.generate_structured_json("Hello", {"type": "object"})


# ==================== Config Validation ====================

class TestConfigValidation:
    def test_all_api_keys_have_config_fields(self):
        from src.config import Settings
        s = Settings()
        # Verify all API key fields exist (they may be empty in dev)
        assert hasattr(s, "META_APP_ID")
        assert hasattr(s, "META_APP_SECRET")
        assert hasattr(s, "TWILIO_ACCOUNT_SID")
        assert hasattr(s, "TWILIO_AUTH_TOKEN")
        assert hasattr(s, "STRIPE_SECRET_KEY")
        assert hasattr(s, "STRIPE_WEBHOOK_SECRET")
        assert hasattr(s, "RAZORPAY_KEY_ID")
        assert hasattr(s, "RAZORPAY_KEY_SECRET")
        assert hasattr(s, "RAZORPAY_WEBHOOK_SECRET")
        assert hasattr(s, "SENTRY_DSN")
        assert hasattr(s, "SMTP_HOST")

    def test_no_hardcoded_password_in_config_defaults(self):
        """Verify config.py defaults don't contain hardcoded passwords."""
        from src.config import Settings
        # Create a Settings instance without loading .env to test just the defaults
        s = Settings(_env_file=None)
        assert "secure_db_pass" not in s.DATABASE_URL

    def test_embedding_dimension_configurable(self):
        from src.config import Settings
        s = Settings()
        assert s.EMBEDDING_DIMENSION == 384
        assert s.QDRANT_COLLECTION == "knowledge_base"


# ==================== Plan Model ====================

class TestPlanModelFields:
    def test_plan_has_stripe_and_razorpay_fields(self):
        from src.infrastructure.database.models import Plan
        from sqlalchemy import inspect
        mapper = inspect(Plan)
        column_names = {c.key for c in mapper.columns}
        assert "stripe_price_id" in column_names
        assert "stripe_price_id_yearly" in column_names
        assert "razorpay_plan_id" in column_names
        assert "razorpay_plan_id_yearly" in column_names
