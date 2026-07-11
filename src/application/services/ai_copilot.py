"""
AI Copilot Service - Natural language command processing and cross-module actions.

Handles:
- Global command palette
- Natural language commands
- Cross-module actions
- Command history
"""

import datetime
import json
import re
import uuid
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Dict, List, Optional, Tuple

import structlog
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.models import (
    Lead, Customer, Task, InboxConversation, Call, Agent, Workflow,
)

logger = structlog.get_logger(__name__)


class CommandType(str, Enum):
    QUERY = "query"
    ACTION = "action"
    NAVIGATE = "navigate"
    UNKNOWN = "unknown"


class ActionStatus(str, Enum):
    SUCCESS = "success"
    ERROR = "error"
    PARTIAL = "partial"


@dataclass
class CopilotCommand:
    raw_input: str
    command_type: CommandType
    intent: str
    entities: Dict[str, Any] = field(default_factory=dict)
    parameters: Dict[str, Any] = field(default_factory=dict)


@dataclass
class CopilotResponse:
    text: str
    data: Optional[Any] = None
    actions: List[Dict[str, Any]] = field(default_factory=list)
    suggestions: List[str] = field(default_factory=list)


class AICopilotService:
    """AI Copilot for natural language commands and cross-module actions."""

    INTENT_PATTERNS = {
        "show_leads": [
            r"show\s+(?:me\s+)?(?:all\s+)?leads?",
            r"list\s+leads?",
            r"leads?\s+(?:list|view|show)",
            r"how\s+many\s+leads?",
            r"leads?\s+(?:dashboard|overview|status)",
        ],
        "show_customers": [
            r"show\s+(?:me\s+)?(?:all\s+)?customers?",
            r"list\s+customers?",
            r"customers?\s+(?:list|view|show)",
            r"how\s+many\s+customers?",
            r"vip\s+customers?",
        ],
        "show_conversations": [
            r"show\s+(?:me\s+)?(?:all\s+)?conversations?",
            r"open\s+conversations?",
            r"unread\s+messages?",
            r"inbox",
        ],
        "create_task": [
            r"create\s+(?:a\s+)?task",
            r"add\s+(?:a\s+)?task",
            r"new\s+task",
            r"assign\s+task",
        ],
        "show_analytics": [
            r"show\s+(?:me\s+)?analytics",
            r"dashboard",
            r"metrics",
            r"kpi",
            r"performance",
        ],
        "send_whatsapp": [
            r"send\s+whatsapp",
            r"message\s+(?:on\s+)?whatsapp",
            r"whatsapp\s+to",
        ],
        "show_calls": [
            r"show\s+(?:me\s+)?calls?",
            r"call\s+history",
            r"recent\s+calls?",
        ],
        "generate_report": [
            r"generate\s+(?:a\s+)?report",
            r"create\s+(?:a\s+)?report",
            r"sales\s+report",
            r"business\s+report",
        ],
        "search": [
            r"search\s+for",
            r"find",
            r"look\s+up",
        ],
    }

    def __init__(self, db: AsyncSession, org_id: uuid.UUID):
        self.db = db
        self.org_id = org_id

    async def process_command(self, raw_input: str) -> CopilotResponse:
        """Process a natural language command and return a response."""
        command = self._parse_command(raw_input)

        if command.command_type == CommandType.QUERY:
            return await self._handle_query(command)
        elif command.command_type == CommandType.ACTION:
            return await self._handle_action(command)
        elif command.command_type == CommandType.NAVIGATE:
            return self._handle_navigate(command)
        else:
            return await self._handle_unknown(command)

    def _parse_command(self, raw_input: str) -> CopilotCommand:
        """Parse natural language input into a structured command."""
        text = raw_input.lower().strip()

        if any(word in text for word in ["go to", "open", "navigate", "switch to"]):
            return CopilotCommand(
                raw_input=raw_input,
                command_type=CommandType.NAVIGATE,
                intent="navigate",
                entities={"target": text},
            )

        for intent, patterns in self.INTENT_PATTERNS.items():
            for pattern in patterns:
                if re.search(pattern, text, re.IGNORECASE):
                    cmd_type = CommandType.ACTION if intent.startswith("create") or intent.startswith("send") else CommandType.QUERY
                    if intent.startswith("show") or intent == "inbox":
                        cmd_type = CommandType.QUERY
                    if intent.startswith("generate"):
                        cmd_type = CommandType.ACTION

                    entities = self._extract_entities(text)
                    return CopilotCommand(
                        raw_input=raw_input,
                        command_type=cmd_type,
                        intent=intent,
                        entities=entities,
                    )

        return CopilotCommand(
            raw_input=raw_input,
            command_type=CommandType.UNKNOWN,
            intent="unknown",
        )

    def _extract_entities(self, text: str) -> Dict[str, Any]:
        entities = {}

        vip_match = re.search(r"vip\s+customers?", text)
        if vip_match:
            entities["segment"] = "vip"

        status_match = re.search(r"(open|closed|pending|new|converted|lost)", text)
        if status_match:
            entities["status"] = status_match.group(1)

        count_match = re.search(r"(\d+)\s+(?:tasks?|leads?|customers?|calls?)", text)
        if count_match:
            entities["limit"] = int(count_match.group(1))

        date_match = re.search(r"(today|yesterday|this\s+week|this\s+month|last\s+month)", text)
        if date_match:
            entities["date_range"] = date_match.group(1)

        name_match = re.search(r'(?:task|lead|customer)\s+"?([^"]+)"?', text)
        if name_match:
            entities["name"] = name_match.group(1).strip()

        return entities

    async def _handle_query(self, command: CopilotCommand) -> CopilotResponse:
        intent = command.intent

        if intent == "show_leads":
            return await self._query_leads(command.entities)
        elif intent == "show_customers":
            return await self._query_customers(command.entities)
        elif intent == "show_conversations":
            return await self._query_conversations(command.entities)
        elif intent == "show_analytics":
            return await self._query_analytics()
        elif intent == "show_calls":
            return await self._query_calls(command.entities)
        elif intent == "search":
            return await self._handle_search(command.entities)

        return CopilotResponse(
            text="I understand you want to query data, but I need more specifics.",
            suggestions=["Show leads", "Show customers", "Show conversations", "Show analytics"],
        )

    async def _query_leads(self, entities: Dict[str, Any]) -> CopilotResponse:
        stmt = select(Lead).where(Lead.org_id == self.org_id)
        if "status" in entities:
            stmt = stmt.where(Lead.status == entities["status"])
        stmt = stmt.order_by(Lead.created_at.desc()).limit(entities.get("limit", 10))

        result = await self.db.execute(stmt)
        leads = result.scalars().all()

        if not leads:
            return CopilotResponse(
                text="No leads found matching your criteria.",
                data=[],
                suggestions=["Create a new lead", "Check lead sources"],
            )

        lead_list = [
            {"id": str(l.id), "name": l.name, "status": l.status, "email": l.email}
            for l in leads
        ]

        status_counts = {}
        for l in leads:
            status_counts[l.status] = status_counts.get(l.status, 0) + 1

        return CopilotResponse(
            text=f"Found {len(leads)} leads. Status breakdown: {json.dumps(status_counts)}",
            data=lead_list,
            suggestions=["Show converted leads", "Show new leads", "Create follow-up task"],
        )

    async def _query_customers(self, entities: Dict[str, Any]) -> CopilotResponse:
        stmt = select(Customer).where(Customer.org_id == self.org_id)
        if "segment" in entities:
            stmt = stmt.where(Customer.segment == entities["segment"])
        stmt = stmt.order_by(Customer.created_at.desc()).limit(entities.get("limit", 10))

        result = await self.db.execute(stmt)
        customers = result.scalars().all()

        if not customers:
            return CopilotResponse(
                text="No customers found matching your criteria.",
                data=[],
                suggestions=["Import customers", "Check customer segments"],
            )

        customer_list = [
            {"id": str(c.id), "name": c.name, "phone": c.phone, "segment": c.segment}
            for c in customers
        ]

        segment_counts = {}
        for c in customers:
            seg = c.segment or "unassigned"
            segment_counts[seg] = segment_counts.get(seg, 0) + 1

        return CopilotResponse(
            text=f"Found {len(customers)} customers. Segments: {json.dumps(segment_counts)}",
            data=customer_list,
            suggestions=["Show VIP customers", "Show churned customers"],
        )

    async def _query_conversations(self, entities: Dict[str, Any]) -> CopilotResponse:
        stmt = select(InboxConversation).where(InboxConversation.org_id == self.org_id)
        if "status" in entities:
            stmt = stmt.where(InboxConversation.status == entities["status"])
        else:
            stmt = stmt.where(InboxConversation.status == "open")
        stmt = stmt.order_by(InboxConversation.updated_at.desc()).limit(entities.get("limit", 10))

        result = await self.db.execute(stmt)
        convs = result.scalars().all()

        conv_list = [
            {
                "id": str(c.id),
                "channel": c.channel,
                "customer_name": c.customer_name,
                "last_message": c.last_message,
                "unread_count": c.unread_count,
            }
            for c in convs
        ]

        return CopilotResponse(
            text=f"Found {len(convs)} conversations.",
            data=conv_list,
            suggestions=["Show unread messages", "Show by channel"],
        )

    async def _query_analytics(self) -> CopilotResponse:
        now = datetime.datetime.now(datetime.timezone.utc)
        month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

        async def _count(stmt):
            return (await self.db.execute(stmt)).scalar() or 0

        total_leads = await _count(select(func.count()).select_from(Lead).where(Lead.org_id == self.org_id))
        total_customers = await _count(select(func.count()).select_from(Customer).where(Customer.org_id == self.org_id))
        total_conversations = await _count(select(func.count()).select_from(InboxConversation).where(InboxConversation.org_id == self.org_id))
        open_convs = await _count(select(func.count()).select_from(InboxConversation).where(InboxConversation.org_id == self.org_id, InboxConversation.status == "open"))
        total_calls = await _count(select(func.count()).select_from(Call).where(Call.org_id == self.org_id))
        total_tasks = await _count(select(func.count()).select_from(Task).where(Task.org_id == self.org_id))

        return CopilotResponse(
            text=(
                f"Business Overview:\n"
                f"- Leads: {total_leads}\n"
                f"- Customers: {total_customers}\n"
                f"- Open Conversations: {open_convs}/{total_conversations}\n"
                f"- Total Calls: {total_calls}\n"
                f"- Total Tasks: {total_tasks}"
            ),
            data={
                "leads": total_leads,
                "customers": total_customers,
                "conversations": total_conversations,
                "open_conversations": open_convs,
                "calls": total_calls,
                "tasks": total_tasks,
            },
            suggestions=["Show lead analytics", "Show call analytics", "Generate sales report"],
        )

    async def _query_calls(self, entities: Dict[str, Any]) -> CopilotResponse:
        stmt = select(Call).where(Call.org_id == self.org_id)
        stmt = stmt.order_by(Call.created_at.desc()).limit(entities.get("limit", 10))

        result = await self.db.execute(stmt)
        calls = result.scalars().all()

        call_list = [
            {
                "id": str(c.id),
                "direction": c.direction,
                "caller_number": c.caller_number,
                "callee_number": c.callee_number,
                "status": c.status,
                "duration_seconds": c.duration_seconds,
            }
            for c in calls
        ]

        return CopilotResponse(
            text=f"Found {len(calls)} recent calls.",
            data=call_list,
            suggestions=["Show missed calls", "Show call analytics"],
        )

    async def _handle_search(self, entities: Dict[str, Any]) -> CopilotResponse:
        query = entities.get("name", "")
        if not query:
            return CopilotResponse(text="What would you like to search for?")

        results = {"leads": [], "customers": [], "tasks": []}

        lead_stmt = select(Lead).where(
            Lead.org_id == self.org_id,
            Lead.name.ilike(f"%{query}%"),
        ).limit(5)
        lead_result = await self.db.execute(lead_stmt)
        results["leads"] = [
            {"id": str(l.id), "name": l.name, "status": l.status}
            for l in lead_result.scalars().all()
        ]

        cust_stmt = select(Customer).where(
            Customer.org_id == self.org_id,
            Customer.name.ilike(f"%{query}%"),
        ).limit(5)
        cust_result = await self.db.execute(cust_stmt)
        results["customers"] = [
            {"id": str(c.id), "name": c.name, "phone": c.phone}
            for c in cust_result.scalars().all()
        ]

        task_stmt = select(Task).where(
            Task.org_id == self.org_id,
            Task.title.ilike(f"%{query}%"),
        ).limit(5)
        task_result = await self.db.execute(task_stmt)
        results["tasks"] = [
            {"id": str(t.id), "title": t.title, "status": t.status}
            for t in task_result.scalars().all()
        ]

        total = sum(len(v) for v in results.values())

        return CopilotResponse(
            text=f"Found {total} results for '{query}'.",
            data=results,
            suggestions=["Search for something else", "Show all leads"],
        )

    async def _handle_action(self, command: CopilotCommand) -> CopilotResponse:
        intent = command.intent

        if intent == "create_task":
            return await self._create_task_from_command(command.entities)
        elif intent == "send_whatsapp":
            return CopilotResponse(
                text="To send a WhatsApp message, open the Inbox and select a conversation.",
                actions=[{"type": "navigate", "target": "/inbox"}],
            )
        elif intent == "generate_report":
            return await self._generate_report()

        return CopilotResponse(text="Action acknowledged. Processing your request.")

    async def _create_task_from_command(self, entities: Dict[str, Any]) -> CopilotResponse:
        now = datetime.datetime.now(datetime.timezone.utc)
        title = entities.get("name", "Task from Copilot")
        task = Task(
            id=uuid.uuid4(),
            org_id=self.org_id,
            title=title,
            description=f"Created via AI Copilot",
            priority="medium",
            status="pending",
            created_at=now,
            updated_at=now,
        )
        self.db.add(task)
        await self.db.flush()

        return CopilotResponse(
            text=f"Task created: '{title}'",
            data={"task_id": str(task.id), "title": title},
            suggestions=["View task", "Create another task"],
        )

    async def _generate_report(self) -> CopilotResponse:
        analytics = await self._query_analytics()
        return CopilotResponse(
            text=f"Sales Report:\n\n{analytics.text}\n\nThis report was generated from live data.",
            data=analytics.data,
            suggestions=["Export report", "Show trends", "Compare with last month"],
        )

    def _handle_navigate(self, command: CopilotCommand) -> CopilotResponse:
        target = command.entities.get("target", "")
        routes = {
            "leads": "/leads",
            "customers": "/customers",
            "inbox": "/inbox",
            "conversations": "/conversations",
            "analytics": "/analytics-center",
            "tasks": "/tasks",
            "team": "/team",
            "billing": "/billing",
            "settings": "/settings",
            "workflows": "/workflows",
            "calls": "/calls",
        }

        for key, route in routes.items():
            if key in target:
                return CopilotResponse(
                    text=f"Navigating to {key.title()}.",
                    actions=[{"type": "navigate", "target": route}],
                )

        return CopilotResponse(
            text="I can navigate to: leads, customers, inbox, conversations, analytics, tasks, team, billing, settings, workflows, calls.",
            suggestions=["Go to leads", "Go to inbox", "Go to analytics"],
        )

    async def _handle_unknown(self, command: CopilotCommand) -> CopilotResponse:
        return CopilotResponse(
            text="I'm not sure what you mean. Here are some things I can help with:",
            suggestions=[
                "Show leads",
                "Show customers",
                "Show conversations",
                "Create a task",
                "Show analytics",
                "Generate report",
                "Search for [query]",
                "Go to [module]",
            ],
        )
