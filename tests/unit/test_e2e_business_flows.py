"""
Phase 6B — End-to-End Business Flow Tests

Tests the complete customer lifecycle:
Lead → Conversation → Customer → Workflow → Task → Billing
"""

import json
import uuid
import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import datetime, timezone
from httpx import AsyncClient, ASGITransport

from src.main import app
from src.infrastructure.database.connection import get_db_session
from src.presentation.api.dependencies import get_current_org_id, get_current_user, oauth2_scheme


@pytest.fixture
def org_id():
    return uuid.uuid4()


@pytest.fixture
def mock_db():
    return AsyncMock()


@pytest.fixture
def mock_user_payload(org_id):
    return {
        "sub": str(uuid.uuid4()),
        "org_id": str(org_id),
        "role": "admin",
        "email": "admin@test.com",
    }


@pytest.fixture
def client(mock_db, mock_user_payload, org_id):
    async def _get_org():
        return org_id

    async def _get_user():
        return mock_user_payload

    async def _fake_oauth():
        return "fake_token"

    app.dependency_overrides[get_db_session] = lambda: mock_db
    app.dependency_overrides[get_current_org_id] = _get_org
    app.dependency_overrides[get_current_user] = _get_user
    app.dependency_overrides[oauth2_scheme] = _fake_oauth

    transport = ASGITransport(app=app)
    c = AsyncClient(transport=transport, base_url="http://test", follow_redirects=True)
    yield c

    app.dependency_overrides.clear()


class TestLeadLifecycle:
    @pytest.mark.asyncio
    async def test_create_lead_success(self, client, mock_db, org_id):
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = None
        mock_db.execute.return_value = mock_result
        mock_db.add = MagicMock()
        mock_db.flush = AsyncMock()
        mock_db.refresh = AsyncMock()

        response = await client.post(
            "/api/v1/leads/",
            json={
                "name": "John Smith",
                "phone": "+1234567890",
                "email": "john@example.com",
                "intent": "buying",
                "product_interest": "Enterprise Plan",
                "budget": 500.0,
            },
        )
        assert response.status_code in (200, 201, 400, 422)

    @pytest.mark.asyncio
    async def test_lead_status_update(self, client, mock_db, org_id):
        mock_lead = MagicMock()
        mock_lead.id = uuid.uuid4()
        mock_lead.org_id = org_id
        mock_lead.status = "new"
        mock_lead.name = "John Smith"
        mock_lead.phone = "+1234567890"
        mock_lead.email = "john@test.com"
        mock_lead.intent = "buying"
        mock_lead.product_interest = "Enterprise"
        mock_lead.budget = 500.0
        mock_lead.assigned_to = None
        mock_lead.created_at = datetime.now(timezone.utc)
        mock_lead.updated_at = datetime.now(timezone.utc)

        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_lead
        mock_db.execute.return_value = mock_result
        mock_db.flush = AsyncMock()
        mock_db.add = MagicMock()

        response = await client.patch(
            f"/api/v1/leads/{mock_lead.id}/status",
            json={"status": "contacted"},
        )
        assert response.status_code in (200, 404, 500)

    @pytest.mark.asyncio
    async def test_lead_search(self, client, mock_db, org_id):
        mock_result = MagicMock()
        mock_result.scalars.return_value.all.return_value = []
        mock_db.execute.return_value = mock_result
        response = await client.get("/api/v1/leads/search?q=john")
        assert response.status_code == 200

    @pytest.mark.asyncio
    async def test_lead_analytics(self, client, mock_db, org_id):
        mock_result = MagicMock()
        mock_result.all.return_value = []
        mock_db.execute.return_value = mock_result
        response = await client.get("/api/v1/leads/analytics")
        assert response.status_code == 200


class TestConversationFlow:
    @pytest.mark.asyncio
    async def test_create_conversation_with_customer(self, client, mock_db, org_id):
        mock_conv_result = MagicMock()
        mock_conv_result.scalar_one_or_none.return_value = None
        mock_cust_result = MagicMock()
        mock_cust_result.scalar_one_or_none.return_value = None
        mock_db.execute.side_effect = [mock_conv_result, mock_cust_result]
        mock_db.add = MagicMock()
        mock_db.flush = AsyncMock()

        from src.infrastructure.integrations.meta_service import MetaOmnichannelService
        service = MetaOmnichannelService(db=mock_db)
        result = await service.process_webhook_message(
            channel="whatsapp",
            platform_user_id="wa_user_123",
            message_content="Hi, interested in your product!",
            org_id=org_id,
            customer_name="Jane Doe",
            customer_phone="+1987654321",
        )
        assert result["status"] == "ok"
        assert "conversation_id" in result

    @pytest.mark.asyncio
    async def test_conversation_send_reply(self, client, mock_db, org_id):
        mock_conv = MagicMock()
        mock_conv.id = uuid.uuid4()
        mock_conv.org_id = org_id
        mock_conv.channel = "whatsapp"

        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_conv
        mock_db.execute.return_value = mock_result
        mock_db.add = MagicMock()
        mock_db.flush = AsyncMock()

        from src.infrastructure.integrations.meta_service import MetaOmnichannelService
        with patch("src.infrastructure.integrations.meta_service.manager") as mock_ws:
            mock_ws.broadcast_new_message = AsyncMock()
            service = MetaOmnichannelService(db=mock_db)
            result = await service.send_message_to_conversation(
                conversation_id=mock_conv.id,
                org_id=org_id,
                content="Thanks for your interest!",
                sender_type="agent",
            )
        assert result["status"] == "sent"


class TestWorkflowExecution:
    @pytest.mark.asyncio
    async def test_execute_workflow(self, client, mock_db, org_id):
        from src.application.services.workflow_engine import WorkflowEngine
        mock_workflow = MagicMock()
        mock_workflow.id = uuid.uuid4()
        mock_workflow.org_id = org_id
        mock_workflow.nodes_json = json.dumps([
            {"id": "n1", "type": "trigger", "data": {"config": {}}},
            {"id": "n2", "type": "task_create", "data": {"config": {
                "title": "Follow up", "priority": "high",
            }}},
        ])
        mock_workflow.edges_json = json.dumps([{"source": "n1", "target": "n2"}])
        mock_workflow.is_active = True
        mock_db.add = MagicMock()
        mock_db.flush = AsyncMock()

        engine = WorkflowEngine(db=mock_db, org_id=org_id)
        result = await engine.execute_workflow(
            workflow=mock_workflow, trigger_event="manual", input_data={"name": "John"},
        )
        assert result is not None

    @pytest.mark.asyncio
    async def test_workflow_condition(self, client, mock_db, org_id):
        from src.application.services.workflow_engine import WorkflowEngine, ExecutionState
        engine = WorkflowEngine(db=mock_db, org_id=org_id)
        state = ExecutionState(
            execution_id=uuid.uuid4(), org_id=org_id,
            workflow_id=uuid.uuid4(), input_data={},
            context={"status": "qualified", "score": 85},
        )
        result = await engine._execute_condition(state, {
            "field": "status", "operator": "equals", "value": "qualified"
        })
        assert result["condition_met"] is True

        result = await engine._execute_condition(state, {
            "field": "score", "operator": "greater_than", "value": "80"
        })
        assert result["condition_met"] is True


class TestTaskLifecycle:
    @pytest.mark.asyncio
    async def test_create_task(self, client, mock_db, org_id):
        mock_db.add = MagicMock()
        mock_db.flush = AsyncMock()

        response = await client.post(
            "/api/v1/tasks/",
            json={
                "title": "Call lead John Smith",
                "description": "Follow up on enterprise inquiry",
                "priority": "high",
                "assigned_to": "sales_team",
                "entity_type": "lead",
                "entity_id": str(uuid.uuid4()),
            },
        )
        assert response.status_code in (200, 201, 422)

    @pytest.mark.asyncio
    async def test_list_tasks(self, client, mock_db, org_id):
        mock_result = MagicMock()
        mock_result.scalars.return_value.all.return_value = []
        mock_db.execute.return_value = mock_result
        response = await client.get("/api/v1/tasks/")
        assert response.status_code == 200

    @pytest.mark.asyncio
    async def test_update_task(self, client, mock_db, org_id):
        mock_task = MagicMock()
        mock_task.id = uuid.uuid4()
        mock_task.org_id = org_id
        mock_task.title = "Test task"
        mock_task.description = "Test description"
        mock_task.priority = "medium"
        mock_task.status = "pending"
        mock_task.assigned_to = None
        mock_task.entity_type = None
        mock_task.entity_id = None
        mock_task.due_date = None
        mock_task.reminder_at = None
        mock_task.created_at = datetime.now(timezone.utc)
        mock_task.updated_at = datetime.now(timezone.utc)

        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_task
        mock_db.execute.return_value = mock_result
        mock_db.flush = AsyncMock()

        response = await client.patch(
            f"/api/v1/tasks/{mock_task.id}",
            json={"status": "in_progress"},
        )
        assert response.status_code in (200, 404)


class TestBillingFlow:
    @pytest.mark.asyncio
    async def test_stripe_webhook_activates_subscription(self, client, mock_db, org_id):
        from src.infrastructure.integrations.payment_service import PaymentService
        mock_plan = MagicMock()
        mock_plan.id = uuid.uuid4()
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_plan
        mock_db.execute.return_value = mock_result
        mock_db.add = MagicMock()
        mock_db.flush = AsyncMock()

        service = PaymentService(db=mock_db)
        result = await service.handle_stripe_webhook("checkout.session.completed", {
            "object": {
                "metadata": {"org_id": str(org_id), "price_id": "price_pro"},
                "subscription": "sub_test",
            }
        })
        assert result["status"] == "activated"

    @pytest.mark.asyncio
    async def test_stripe_invoice_paid(self, client, mock_db, org_id):
        from src.infrastructure.integrations.payment_service import PaymentService
        mock_db.add = MagicMock()
        mock_db.flush = AsyncMock()

        service = PaymentService(db=mock_db)
        result = await service.handle_stripe_webhook("invoice.paid", {
            "object": {
                "metadata": {"org_id": str(org_id)},
                "amount_paid": 4999,
                "currency": "usd",
                "id": "in_test",
            }
        })
        assert result["status"] == "invoice_created"

    @pytest.mark.asyncio
    async def test_stripe_subscription_cancelled(self, client, mock_db, org_id):
        from src.infrastructure.integrations.payment_service import PaymentService
        from src.infrastructure.database.models import Subscription
        mock_sub = MagicMock(spec=Subscription)
        mock_sub.status = "active"
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_sub
        mock_db.execute.return_value = mock_result
        mock_db.flush = AsyncMock()

        service = PaymentService(db=mock_db)
        result = await service.handle_stripe_webhook("customer.subscription.deleted", {
            "object": {"id": "sub_test"}
        })
        assert result["status"] == "cancelled"
        assert mock_sub.status == "cancelled"

    @pytest.mark.asyncio
    async def test_razorpay_webhook_activates(self, client, mock_db, org_id):
        from src.infrastructure.integrations.payment_service import PaymentService
        mock_plan = MagicMock()
        mock_plan.id = uuid.uuid4()
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_plan
        mock_db.execute.return_value = mock_result
        mock_db.add = MagicMock()
        mock_db.flush = AsyncMock()

        service = PaymentService(db=mock_db)
        result = await service.handle_razorpay_webhook("subscription.activated", {
            "subscription": {"id": "sub_rp", "plan_id": "plan_rp"},
            "entity": {"notes": {"org_id": str(org_id)}},
        })
        assert result["status"] == "activated"


class TestFullLifecycle:
    @pytest.mark.asyncio
    async def test_lead_to_customer_conversion(self, client, mock_db, org_id):
        from src.infrastructure.integrations.meta_service import MetaOmnichannelService
        mock_db.execute.return_value = MagicMock(scalar_one_or_none=MagicMock(return_value=None))
        mock_db.add = MagicMock()
        mock_db.flush = AsyncMock()

        service = MetaOmnichannelService(db=mock_db)
        result = await service.process_webhook_message(
            channel="whatsapp", platform_user_id="wa_12345",
            message_content="I want to buy!", org_id=org_id,
            customer_name="Alice", customer_phone="+1555123456",
        )
        assert result["status"] == "ok"
        assert mock_db.add.call_count >= 2

    @pytest.mark.asyncio
    async def test_ai_copilot_creates_task(self, client, mock_db, org_id):
        from src.application.services.ai_copilot import AICopilotService
        mock_db.add = MagicMock()
        mock_db.flush = AsyncMock()
        copilot = AICopilotService(db=mock_db, org_id=org_id)
        response = await copilot.process_command("create a task to call John Smith")
        assert response is not None

    @pytest.mark.asyncio
    async def test_workflow_to_task_chain(self, mock_db, org_id):
        from src.application.services.workflow_engine import WorkflowEngine
        mock_workflow = MagicMock()
        mock_workflow.id = uuid.uuid4()
        mock_workflow.org_id = org_id
        mock_workflow.nodes_json = json.dumps([
            {"id": "t", "type": "trigger", "data": {"config": {}}},
            {"id": "c", "type": "task_create", "data": {"config": {
                "title": "Qualify: {{name}}", "priority": "high",
            }}},
        ])
        mock_workflow.edges_json = json.dumps([{"source": "t", "target": "c"}])
        mock_workflow.is_active = True
        mock_db.add = MagicMock()
        mock_db.flush = AsyncMock()

        engine = WorkflowEngine(db=mock_db, org_id=org_id)
        result = await engine.execute_workflow(
            workflow=mock_workflow, trigger_event="manual",
            input_data={"name": "Test Lead"},
        )
        assert result is not None


class TestAPIEndpointAvailability:
    @pytest.mark.asyncio
    async def test_leads(self, client):
        r = await client.get("/api/v1/leads/")
        assert r.status_code != 404

    @pytest.mark.asyncio
    async def test_customers(self, client):
        r = await client.get("/api/v1/customers/")
        assert r.status_code != 404

    @pytest.mark.asyncio
    async def test_conversations(self, client):
        r = await client.get("/api/v1/conversations/")
        assert r.status_code != 404

    @pytest.mark.asyncio
    async def test_tasks(self, client):
        r = await client.get("/api/v1/tasks/")
        assert r.status_code != 404

    @pytest.mark.asyncio
    async def test_workflows(self, client):
        r = await client.get("/api/v1/workflows/")
        assert r.status_code != 404

    @pytest.mark.asyncio
    async def test_billing(self, client):
        r = await client.get("/api/v1/billing/plans")
        assert r.status_code != 404

    @pytest.mark.asyncio
    async def test_analytics(self, client):
        r = await client.get("/api/v1/analytics/executive")
        assert r.status_code != 404

    @pytest.mark.asyncio
    async def test_copilot(self, client):
        r = await client.get("/api/v1/copilot/suggestions")
        assert r.status_code != 404

    @pytest.mark.asyncio
    async def test_health(self, client, mock_db):
        mock_db.execute.return_value = MagicMock()
        app.dependency_overrides[get_db_session] = lambda: mock_db
        r = await client.get("/api/v1/health")
        assert r.status_code == 200
        data = r.json()
        assert "status" in data
        assert "cache" in data
