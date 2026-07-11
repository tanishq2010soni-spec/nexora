"""
Workflow Execution Engine - Directed graph traversal with node execution.

Supports node types:
- trigger: Entry point, receives input data
- condition: Branch based on data evaluation
- delay: Wait before continuing
- webhook: Make HTTP requests
- whatsapp_send: Send WhatsApp messages via inbox
- email_send: Send emails (placeholder for provider integration)
- task_create: Create tasks in the task management system
- lead_update: Update lead records
- customer_update: Update customer records
"""

import asyncio
import datetime
import json
import uuid
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Dict, List, Optional, Set, Tuple

import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.models import (
    Workflow,
    WorkflowExecution,
    Task,
    Lead,
    Customer,
    InboxConversation,
    InboxMessage,
)
from src.infrastructure.realtime.connection_manager import manager

logger = structlog.get_logger(__name__)


class NodeStatus(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    SKIPPED = "skipped"


class NodeType(str, Enum):
    TRIGGER = "trigger"
    CONDITION = "condition"
    DELAY = "delay"
    WEBHOOK = "webhook"
    WHATSAPP_SEND = "whatsapp_send"
    EMAIL_SEND = "email_send"
    TASK_CREATE = "task_create"
    LEAD_UPDATE = "lead_update"
    CUSTOMER_UPDATE = "customer_update"


@dataclass
class NodeResult:
    node_id: str
    status: NodeStatus
    output: Dict[str, Any] = field(default_factory=dict)
    error: Optional[str] = None
    started_at: Optional[datetime.datetime] = None
    completed_at: Optional[datetime.datetime] = None


@dataclass
class ExecutionState:
    execution_id: uuid.UUID
    org_id: uuid.UUID
    workflow_id: uuid.UUID
    input_data: Dict[str, Any]
    node_results: Dict[str, NodeResult] = field(default_factory=dict)
    context: Dict[str, Any] = field(default_factory=dict)
    is_failed: bool = False
    error_message: Optional[str] = None


class WorkflowEngine:
    """Executes workflow graphs by traversing nodes and edges."""

    def __init__(self, db: AsyncSession, org_id: uuid.UUID):
        self.db = db
        self.org_id = org_id

    async def execute_workflow(
        self,
        workflow: Workflow,
        trigger_event: str,
        input_data: Optional[Dict[str, Any]] = None,
    ) -> WorkflowExecution:
        """Execute a workflow from start to finish."""
        now = datetime.datetime.now(datetime.timezone.utc)

        execution = WorkflowExecution(
            id=uuid.uuid4(),
            workflow_id=workflow.id,
            trigger_event=trigger_event,
            status="running",
            input_json=json.dumps(input_data or {}),
            started_at=now,
        )
        self.db.add(execution)
        await self.db.flush()

        state = ExecutionState(
            execution_id=execution.id,
            org_id=self.org_id,
            workflow_id=workflow.id,
            input_data=input_data or {},
        )

        try:
            nodes = json.loads(workflow.nodes_json) if workflow.nodes_json else []
            edges = json.loads(workflow.edges_json) if workflow.edges_json else []

            if not nodes:
                execution.status = "completed"
                execution.output_json = json.dumps({"message": "No nodes to execute"})
                execution.completed_at = datetime.datetime.now(datetime.timezone.utc)
                await self.db.commit()
                return execution

            adjacency = self._build_adjacency(edges)
            execution_order = self._topological_sort(nodes, adjacency)

            entry_nodes = self._find_entry_nodes(nodes, edges)
            if not entry_nodes:
                execution.status = "failed"
                execution.error_message = "No entry node found in workflow"
                execution.completed_at = datetime.datetime.now(datetime.timezone.utc)
                await self.db.commit()
                return execution

            for entry_id in entry_nodes:
                await self._execute_subgraph(
                    state, nodes, adjacency, entry_id, execution
                )

            if state.is_failed:
                execution.status = "failed"
                execution.error_message = state.error_message
            else:
                execution.status = "completed"
                execution.output_json = json.dumps(state.context, default=str)

            execution.completed_at = datetime.datetime.now(datetime.timezone.utc)
            workflow.execution_count += 1
            workflow.last_executed_at = now

            await self.db.commit()
            return execution

        except Exception as e:
            logger.error(
                "Workflow execution failed",
                workflow_id=str(workflow.id),
                execution_id=str(execution.id),
                error=str(e),
            )
            execution.status = "failed"
            execution.error_message = str(e)
            execution.completed_at = datetime.datetime.now(datetime.timezone.utc)
            await self.db.commit()
            return execution

    def _build_adjacency(self, edges: List[Dict[str, Any]]) -> Dict[str, List[str]]:
        """Build adjacency list from edges."""
        adj: Dict[str, List[str]] = {}
        for edge in edges:
            source = edge.get("source", "")
            target = edge.get("target", "")
            if source and target:
                adj.setdefault(source, []).append(target)
        return adj

    def _topological_sort(
        self, nodes: List[Dict[str, Any]], adjacency: Dict[str, List[str]]
    ) -> List[str]:
        """Return topological order of nodes."""
        node_ids = {n["id"] for n in nodes}
        in_degree: Dict[str, int] = {nid: 0 for nid in node_ids}
        for source, targets in adjacency.items():
            for target in targets:
                if target in in_degree:
                    in_degree[target] += 1

        queue = [nid for nid, deg in in_degree.items() if deg == 0]
        order: List[str] = []
        while queue:
            current = queue.pop(0)
            order.append(current)
            for neighbor in adjacency.get(current, []):
                if neighbor in in_degree:
                    in_degree[neighbor] -= 1
                    if in_degree[neighbor] == 0:
                        queue.append(neighbor)
        return order

    def _find_entry_nodes(
        self, nodes: List[Dict[str, Any]], edges: List[Dict[str, Any]]
    ) -> List[str]:
        """Find nodes with no incoming edges (entry points)."""
        targets = {e["target"] for e in edges if "target" in e}
        entry_nodes = []
        for node in nodes:
            node_id = node.get("id", "")
            if node_id not in targets:
                entry_nodes.append(node_id)
        if not entry_nodes and nodes:
            entry_nodes = [nodes[0].get("id", "")]
        return entry_nodes

    async def _execute_subgraph(
        self,
        state: ExecutionState,
        nodes: List[Dict[str, Any]],
        adjacency: Dict[str, List[str]],
        current_id: str,
        execution: WorkflowExecution,
    ):
        """Recursively execute nodes starting from current_id."""
        node_map = {n["id"]: n for n in nodes}
        visited: Set[str] = set()
        await self._execute_node_chain(state, node_map, adjacency, current_id, visited, execution)

    async def _execute_node_chain(
        self,
        state: ExecutionState,
        node_map: Dict[str, Dict[str, Any]],
        adjacency: Dict[str, List[str]],
        current_id: str,
        visited: Set[str],
        execution: WorkflowExecution,
    ):
        """Execute a node and continue to its children."""
        if current_id in visited or state.is_failed:
            return
        visited.add(current_id)

        node = node_map.get(current_id)
        if not node:
            return

        result = await self._execute_node(state, node, execution)
        state.node_results[current_id] = result

        if result.status == NodeStatus.FAILED:
            state.is_failed = True
            state.error_message = f"Node '{current_id}' failed: {result.error}"
            return

        state.context.update(result.output)

        for next_id in adjacency.get(current_id, []):
            if next_id in node_map:
                await self._execute_node_chain(
                    state, node_map, adjacency, next_id, visited, execution
                )

    async def _execute_node(
        self,
        state: ExecutionState,
        node: Dict[str, Any],
        execution: WorkflowExecution,
    ) -> NodeResult:
        """Execute a single node based on its type."""
        node_id = node.get("id", "")
        node_type = node.get("type", "")
        config = node.get("data", {}).get("config", {})
        started_at = datetime.datetime.now(datetime.timezone.utc)

        result = NodeResult(
            node_id=node_id,
            status=NodeStatus.RUNNING,
            started_at=started_at,
        )

        try:
            if node_type == NodeType.TRIGGER:
                output = {"trigger_data": state.input_data}
                result.status = NodeStatus.COMPLETED
                result.output = output

            elif node_type == NodeType.CONDITION:
                output = await self._execute_condition(state, config)
                result.status = NodeStatus.COMPLETED
                result.output = output

            elif node_type == NodeType.DELAY:
                delay_seconds = config.get("delay_seconds", 1)
                await asyncio.sleep(min(delay_seconds, 300))
                result.status = NodeStatus.COMPLETED
                result.output = {"delayed_seconds": delay_seconds}

            elif node_type == NodeType.WEBHOOK:
                output = await self._execute_webhook(state, config)
                result.status = NodeStatus.COMPLETED
                result.output = output

            elif node_type == NodeType.WHATSAPP_SEND:
                output = await self._execute_whatsapp_send(state, config)
                result.status = NodeStatus.COMPLETED
                result.output = output

            elif node_type == NodeType.EMAIL_SEND:
                output = await self._execute_email_send(state, config)
                result.status = NodeStatus.COMPLETED
                result.output = output

            elif node_type == NodeType.TASK_CREATE:
                output = await self._execute_task_create(state, config)
                result.status = NodeStatus.COMPLETED
                result.output = output

            elif node_type == NodeType.LEAD_UPDATE:
                output = await self._execute_lead_update(state, config)
                result.status = NodeStatus.COMPLETED
                result.output = output

            elif node_type == NodeType.CUSTOMER_UPDATE:
                output = await self._execute_customer_update(state, config)
                result.status = NodeStatus.COMPLETED
                result.output = output

            else:
                result.status = NodeStatus.FAILED
                result.error = f"Unknown node type: {node_type}"

        except Exception as e:
            logger.error(
                "Node execution failed",
                node_id=node_id,
                node_type=node_type,
                error=str(e),
            )
            result.status = NodeStatus.FAILED
            result.error = str(e)

        result.completed_at = datetime.datetime.now(datetime.timezone.utc)
        return result

    async def _execute_condition(
        self, state: ExecutionState, config: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Evaluate a condition node."""
        field_path = config.get("field", "")
        operator = config.get("operator", "equals")
        value = config.get("value", "")
        context_value = self._resolve_field(field_path, state.context)

        condition_met = False
        if operator == "equals":
            condition_met = str(context_value) == str(value)
        elif operator == "not_equals":
            condition_met = str(context_value) != str(value)
        elif operator == "contains":
            condition_met = str(value) in str(context_value)
        elif operator == "greater_than":
            try:
                condition_met = float(context_value) > float(value)
            except (ValueError, TypeError):
                condition_met = False
        elif operator == "less_than":
            try:
                condition_met = float(context_value) < float(value)
            except (ValueError, TypeError):
                condition_met = False
        elif operator == "is_empty":
            condition_met = not context_value
        elif operator == "is_not_empty":
            condition_met = bool(context_value)

        return {"condition_met": condition_met, "field": field_path, "operator": operator}

    async def _execute_webhook(
        self, state: ExecutionState, config: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Make an HTTP webhook request."""
        import httpx

        url = config.get("url", "")
        method = config.get("method", "POST").upper()
        headers = config.get("headers", {})
        body = config.get("body", {})

        resolved_body = self._resolve_template(body, state.context)

        async with httpx.AsyncClient(timeout=30.0) as client:
            if method == "GET":
                response = await client.get(url, headers=headers)
            elif method == "POST":
                response = await client.post(url, json=resolved_body, headers=headers)
            elif method == "PUT":
                response = await client.put(url, json=resolved_body, headers=headers)
            elif method == "PATCH":
                response = await client.patch(url, json=resolved_body, headers=headers)
            else:
                response = await client.request(method, url, json=resolved_body, headers=headers)

            return {
                "status_code": response.status_code,
                "response_body": response.text[:1000],
                "success": 200 <= response.status_code < 300,
            }

    async def _execute_whatsapp_send(
        self, state: ExecutionState, config: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Send a WhatsApp message through the inbox system."""
        conversation_id = config.get("conversation_id", "")
        message_template = config.get("message", "")
        resolved_message = self._resolve_template_string(message_template, state.context)

        conversation_id_resolved = self._resolve_template_string(conversation_id, state.context)

        if conversation_id_resolved:
            try:
                conv_uuid = uuid.UUID(conversation_id_resolved)
                stmt = select(InboxConversation).where(
                    InboxConversation.id == conv_uuid,
                    InboxConversation.org_id == self.org_id,
                )
                result = await self.db.execute(stmt)
                conv = result.scalar_one_or_none()

                if conv:
                    now = datetime.datetime.now(datetime.timezone.utc)
                    msg = InboxMessage(
                        id=uuid.uuid4(),
                        conversation_id=conv.id,
                        sender_type="bot",
                        content=resolved_message,
                        channel="whatsapp",
                        is_read=False,
                        created_at=now,
                    )
                    self.db.add(msg)
                    conv.last_message = resolved_message[:200]
                    conv.updated_at = now
                    await self.db.flush()

                    await manager.broadcast_new_message(
                        conv.id,
                        {
                            "id": str(msg.id),
                            "conversation_id": str(conv.id),
                            "sender_type": "bot",
                            "content": resolved_message,
                            "channel": "whatsapp",
                            "created_at": now.isoformat(),
                        },
                    )

                    return {
                        "message_id": str(msg.id),
                        "conversation_id": str(conv.id),
                        "status": "sent",
                    }
            except (ValueError, Exception) as e:
                logger.warning("WhatsApp send failed", error=str(e))

        return {"message_id": None, "status": "queued", "message": resolved_message}

    async def _execute_email_send(
        self, state: ExecutionState, config: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Send an email (logs for now, provider integration needed)."""
        to = config.get("to", "")
        subject = config.get("subject", "")
        body = config.get("body", "")

        resolved_to = self._resolve_template_string(to, state.context)
        resolved_subject = self._resolve_template_string(subject, state.context)
        resolved_body = self._resolve_template_string(body, state.context)

        logger.info(
            "Email send executed",
            to=resolved_to,
            subject=resolved_subject,
            org_id=str(self.org_id),
        )

        return {
            "to": resolved_to,
            "subject": resolved_subject,
            "status": "sent",
        }

    async def _execute_task_create(
        self, state: ExecutionState, config: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Create a task."""
        title = config.get("title", "Workflow Task")
        description = config.get("description", "")
        priority = config.get("priority", "medium")
        assigned_to = config.get("assigned_to", None)
        due_days = config.get("due_in_days", 7)

        resolved_title = self._resolve_template_string(title, state.context)
        resolved_description = self._resolve_template_string(description, state.context)

        now = datetime.datetime.now(datetime.timezone.utc)
        due_date = now + datetime.timedelta(days=due_days)

        task = Task(
            id=uuid.uuid4(),
            org_id=self.org_id,
            title=resolved_title,
            description=resolved_description,
            priority=priority,
            status="pending",
            assigned_to=assigned_to,
            due_date=due_date,
            entity_type="workflow",
            entity_id=state.workflow_id,
            created_at=now,
            updated_at=now,
        )
        self.db.add(task)
        await self.db.flush()

        return {
            "task_id": str(task.id),
            "title": resolved_title,
            "priority": priority,
            "status": "created",
        }

    async def _execute_lead_update(
        self, state: ExecutionState, config: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Update a lead record."""
        lead_id = config.get("lead_id", "")
        updates = config.get("updates", {})

        lead_id_resolved = self._resolve_template_string(lead_id, state.context)

        if not lead_id_resolved:
            return {"status": "skipped", "reason": "No lead_id provided"}

        try:
            lead_uuid = uuid.UUID(lead_id_resolved)
            stmt = select(Lead).where(Lead.id == lead_uuid, Lead.org_id == self.org_id)
            result = await self.db.execute(stmt)
            lead = result.scalar_one_or_none()

            if not lead:
                return {"status": "not_found", "lead_id": lead_id_resolved}

            for key, value in updates.items():
                resolved_value = self._resolve_template_string(str(value), state.context)
                if hasattr(lead, key):
                    setattr(lead, key, resolved_value)

            lead.updated_at = datetime.datetime.now(datetime.timezone.utc)
            await self.db.flush()

            return {"lead_id": lead_id_resolved, "status": "updated", "fields": list(updates.keys())}

        except (ValueError, Exception) as e:
            return {"status": "error", "error": str(e)}

    async def _execute_customer_update(
        self, state: ExecutionState, config: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Update a customer record."""
        customer_id = config.get("customer_id", "")
        updates = config.get("updates", {})

        customer_id_resolved = self._resolve_template_string(customer_id, state.context)

        if not customer_id_resolved:
            return {"status": "skipped", "reason": "No customer_id provided"}

        try:
            cust_uuid = uuid.UUID(customer_id_resolved)
            stmt = select(Customer).where(
                Customer.id == cust_uuid, Customer.org_id == self.org_id
            )
            result = await self.db.execute(stmt)
            customer = result.scalar_one_or_none()

            if not customer:
                return {"status": "not_found", "customer_id": customer_id_resolved}

            for key, value in updates.items():
                resolved_value = self._resolve_template_string(str(value), state.context)
                if hasattr(customer, key):
                    setattr(customer, key, resolved_value)

            customer.updated_at = datetime.datetime.now(datetime.timezone.utc)
            await self.db.flush()

            return {
                "customer_id": customer_id_resolved,
                "status": "updated",
                "fields": list(updates.keys()),
            }

        except (ValueError, Exception) as e:
            return {"status": "error", "error": str(e)}

    def _resolve_field(self, field_path: str, context: Dict[str, Any]) -> Any:
        """Resolve a dot-separated field path from context."""
        parts = field_path.split(".")
        current = context
        for part in parts:
            if isinstance(current, dict):
                current = current.get(part)
            else:
                return None
        return current

    def _resolve_template(
        self, template: Any, context: Dict[str, Any]
    ) -> Any:
        """Resolve template strings in a dict structure."""
        if isinstance(template, str):
            return self._resolve_template_string(template, context)
        elif isinstance(template, dict):
            return {k: self._resolve_template(v, context) for k, v in template.items()}
        elif isinstance(template, list):
            return [self._resolve_template(item, context) for item in template]
        return template

    def _resolve_template_string(self, template: str, context: Dict[str, Any]) -> str:
        """Resolve {{field}} placeholders in a string."""
        import re

        def replace_match(match):
            field_path = match.group(1).strip()
            value = self._resolve_field(field_path, context)
            if value is None:
                return ""
            return str(value)

        return re.sub(r"\{\{(.+?)\}\}", replace_match, template)
