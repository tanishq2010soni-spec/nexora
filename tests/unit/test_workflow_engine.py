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


@pytest.fixture
def sample_workflow_data():
    return {
        "id": uuid.uuid4(),
        "org_id": uuid.uuid4(),
        "name": "Test Workflow",
        "description": "A test workflow",
        "trigger_type": "manual",
        "is_active": True,
        "nodes_json": json.dumps([
            {"id": "node1", "type": "trigger", "data": {"config": {}}},
            {"id": "node2", "type": "task_create", "data": {"config": {"title": "Test Task", "priority": "high"}}},
        ]),
        "edges_json": json.dumps([
            {"source": "node1", "target": "node2"},
        ]),
        "execution_count": 0,
        "last_executed_at": None,
        "created_at": datetime.now(timezone.utc),
        "updated_at": datetime.now(timezone.utc),
    }


class TestWorkflowEngine:
    def test_build_adjacency(self, sample_workflow_data):
        from src.application.services.workflow_engine import WorkflowEngine
        engine = WorkflowEngine(db=AsyncMock(), org_id=uuid.uuid4())

        edges = json.loads(sample_workflow_data["edges_json"])
        adj = engine._build_adjacency(edges)
        assert "node1" in adj
        assert "node2" in adj["node1"]

    def test_topological_sort(self, sample_workflow_data):
        from src.application.services.workflow_engine import WorkflowEngine
        engine = WorkflowEngine(db=AsyncMock(), org_id=uuid.uuid4())

        nodes = json.loads(sample_workflow_data["nodes_json"])
        edges = json.loads(sample_workflow_data["edges_json"])
        adj = engine._build_adjacency(edges)
        order = engine._topological_sort(nodes, adj)
        assert order.index("node1") < order.index("node2")

    def test_find_entry_nodes(self, sample_workflow_data):
        from src.application.services.workflow_engine import WorkflowEngine
        engine = WorkflowEngine(db=AsyncMock(), org_id=uuid.uuid4())

        nodes = json.loads(sample_workflow_data["nodes_json"])
        edges = json.loads(sample_workflow_data["edges_json"])
        entries = engine._find_entry_nodes(nodes, edges)
        assert "node1" in entries

    def test_resolve_template_string(self, org_id):
        from src.application.services.workflow_engine import WorkflowEngine
        engine = WorkflowEngine(db=AsyncMock(), org_id=org_id)

        context = {"name": "John", "email": "john@test.com"}
        result = engine._resolve_template_string("Hello {{name}}, email: {{email}}", context)
        assert result == "Hello John, email: john@test.com"

    def test_resolve_template_string_missing_field(self, org_id):
        from src.application.services.workflow_engine import WorkflowEngine
        engine = WorkflowEngine(db=AsyncMock(), org_id=org_id)

        result = engine._resolve_template_string("Hello {{missing}}", {})
        assert result == "Hello "

    def test_resolve_field_nested(self, org_id):
        from src.application.services.workflow_engine import WorkflowEngine
        engine = WorkflowEngine(db=AsyncMock(), org_id=org_id)

        context = {"outer": {"inner": "value"}}
        result = engine._resolve_field("outer.inner", context)
        assert result == "value"

    def test_resolve_field_missing(self, org_id):
        from src.application.services.workflow_engine import WorkflowEngine
        engine = WorkflowEngine(db=AsyncMock(), org_id=org_id)

        result = engine._resolve_field("missing.path", {})
        assert result is None


class TestConditionNode:
    @pytest.mark.asyncio
    async def test_condition_equals(self, org_id):
        from src.application.services.workflow_engine import WorkflowEngine, ExecutionState
        engine = WorkflowEngine(db=AsyncMock(), org_id=org_id)

        state = ExecutionState(
            execution_id=uuid.uuid4(),
            org_id=org_id,
            workflow_id=uuid.uuid4(),
            input_data={},
            context={"status": "active"},
        )
        config = {"field": "status", "operator": "equals", "value": "active"}
        result = await engine._execute_condition(state, config)
        assert result["condition_met"] is True

    @pytest.mark.asyncio
    async def test_condition_not_equals(self, org_id):
        from src.application.services.workflow_engine import WorkflowEngine, ExecutionState
        engine = WorkflowEngine(db=AsyncMock(), org_id=org_id)

        state = ExecutionState(
            execution_id=uuid.uuid4(),
            org_id=org_id,
            workflow_id=uuid.uuid4(),
            input_data={},
            context={"status": "active"},
        )
        config = {"field": "status", "operator": "not_equals", "value": "inactive"}
        result = await engine._execute_condition(state, config)
        assert result["condition_met"] is True

    @pytest.mark.asyncio
    async def test_condition_contains(self, org_id):
        from src.application.services.workflow_engine import WorkflowEngine, ExecutionState
        engine = WorkflowEngine(db=AsyncMock(), org_id=org_id)

        state = ExecutionState(
            execution_id=uuid.uuid4(),
            org_id=org_id,
            workflow_id=uuid.uuid4(),
            input_data={},
            context={"name": "John Smith"},
        )
        config = {"field": "name", "operator": "contains", "value": "John"}
        result = await engine._execute_condition(state, config)
        assert result["condition_met"] is True


class TestAICopilot:
    @pytest.mark.asyncio
    async def test_parse_show_leads(self, org_id):
        from src.application.services.ai_copilot import AICopilotService
        copilot = AICopilotService(db=AsyncMock(), org_id=org_id)

        command = copilot._parse_command("show me all leads")
        assert command.intent == "show_leads"
        assert command.command_type.value == "query"

    @pytest.mark.asyncio
    async def test_parse_create_task(self, org_id):
        from src.application.services.ai_copilot import AICopilotService
        copilot = AICopilotService(db=AsyncMock(), org_id=org_id)

        command = copilot._parse_command("create a task called Follow up with client")
        assert command.intent == "create_task"
        assert command.command_type.value == "action"

    @pytest.mark.asyncio
    async def test_parse_show_customers(self, org_id):
        from src.application.services.ai_copilot import AICopilotService
        copilot = AICopilotService(db=AsyncMock(), org_id=org_id)

        command = copilot._parse_command("show vip customers")
        assert command.intent == "show_customers"
        assert "segment" in command.entities
        assert command.entities["segment"] == "vip"

    @pytest.mark.asyncio
    async def test_parse_navigate(self, org_id):
        from src.application.services.ai_copilot import AICopilotService
        copilot = AICopilotService(db=AsyncMock(), org_id=org_id)

        command = copilot._parse_command("go to inbox")
        assert command.command_type.value == "navigate"

    @pytest.mark.asyncio
    async def test_parse_unknown(self, org_id):
        from src.application.services.ai_copilot import AICopilotService
        copilot = AICopilotService(db=AsyncMock(), org_id=org_id)

        command = copilot._parse_command("asdfghjkl")
        assert command.intent == "unknown"

    def test_extract_entities_status(self, org_id):
        from src.application.services.ai_copilot import AICopilotService
        copilot = AICopilotService(db=AsyncMock(), org_id=org_id)

        entities = copilot._extract_entities("show open leads")
        assert entities.get("status") == "open"

    def test_extract_entities_limit(self, org_id):
        from src.application.services.ai_copilot import AICopilotService
        copilot = AICopilotService(db=AsyncMock(), org_id=org_id)

        entities = copilot._extract_entities("show 10 leads")
        assert entities.get("limit") == 10

    @pytest.mark.asyncio
    async def test_handle_navigate(self, org_id):
        from src.application.services.ai_copilot import AICopilotService
        copilot = AICopilotService(db=AsyncMock(), org_id=org_id)

        from src.application.services.ai_copilot import CopilotCommand, CommandType
        cmd = CopilotCommand(
            raw_input="go to inbox",
            command_type=CommandType.NAVIGATE,
            intent="navigate",
            entities={"target": "go to inbox"},
        )
        response = copilot._handle_navigate(cmd)
        assert response.actions[0]["target"] == "/inbox"

    @pytest.mark.asyncio
    async def test_handle_unknown(self, org_id):
        from src.application.services.ai_copilot import AICopilotService
        copilot = AICopilotService(db=AsyncMock(), org_id=org_id)

        from src.application.services.ai_copilot import CopilotCommand, CommandType
        cmd = CopilotCommand(
            raw_input="asdfghjkl",
            command_type=CommandType.UNKNOWN,
            intent="unknown",
        )
        response = await copilot._handle_unknown(cmd)
        assert len(response.suggestions) > 0
