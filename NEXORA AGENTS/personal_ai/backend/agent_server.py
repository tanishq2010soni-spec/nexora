from __future__ import annotations

import asyncio
import json
import os
import secrets
import time
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from typing import Any
from uuid import uuid4

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Query, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from nexora_ai.application.di.container import DIContainer
from nexora_ai.application.services.conversation_service import ConversationService
from nexora_ai.application.services.context_service import ContextService
from nexora_ai.application.services.memory_service import MemoryService
from nexora_ai.application.services.planning_service import PlanningService
from nexora_ai.application.services.retry_service import RetryService
from nexora_ai.domain.entities.memory import MemoryEntry
from nexora_ai.domain.enums.agent_enums import AgentStatus, AgentType
from nexora_ai.domain.enums.event_enums import EventType
from nexora_ai.domain.enums.memory_enums import MemoryImportance, MemoryType
from nexora_ai.domain.enums.provider_enums import ModelCapability, ProviderType
from nexora_ai.domain.enums.tool_enums import ToolCategory
from nexora_ai.domain.interfaces.event_bus_interface import EventBusInterface
from nexora_ai.domain.interfaces.logging_interface import LoggingInterface
from nexora_ai.infrastructure.agent_client.registration_client import AgentRegistrationClient, get_metrics
from nexora_ai.infrastructure.agent_manager.agent_manager import AgentManager
from nexora_ai.infrastructure.config.config_manager import ConfigManager
from nexora_ai.infrastructure.event_bus.event_bus import AsyncEventBus
from nexora_ai.infrastructure.logging.json_logger import JsonLogger
from nexora_ai.infrastructure.memory.memory_manager import MemoryManager
from nexora_ai.infrastructure.provider_router import ProviderRouter
from nexora_ai.infrastructure.tools.tool_registry import ToolRegistry

from backend.personal_agent import PersonalAgent

API_KEY = os.environ.get("PERSONAL_AI_API_KEY", "")
CONTROL_PLANE_URL = os.environ.get("NEXORA_CONTROL_PLANE_URL", "http://localhost:8000")
AUTH_MODE = os.environ.get("NEXORA_AUTH_MODE", "legacy")

agent: PersonalAgent | None = None
registration_client: AgentRegistrationClient | None = None
agent_manager: AgentManager | None = AgentManager()
_start_time = time.time()


async def _verify_api_key(
    x_api_key: str = Header(default=""),
    authorization: str = Header(default=""),
) -> None:
    if AUTH_MODE == "unified" and authorization:
        token = authorization.replace("Bearer ", "")
        from nexora_ai.infrastructure.auth import AuthClient
        from nexora_ai.domain.entities.auth import AuthConfig
        client = AuthClient()
        jwt_secret = os.environ.get("NEXORA_JWT_SECRET", API_KEY)
        client.configure(AuthConfig(jwt_secret=jwt_secret, issuer="nexora"))
        await client.validate_token(token)
        return
    if not API_KEY:
        return
    if not secrets.compare_digest(x_api_key, API_KEY):
        raise HTTPException(status_code=401, detail="Invalid API key")


def _build_container() -> DIContainer:
    container = DIContainer()

    config = ConfigManager()
    event_bus = AsyncEventBus()
    logger = JsonLogger()
    memory_backend = MemoryManager.__new__(MemoryManager)
    tool_registry = ToolRegistry()
    provider_router = ProviderRouter()
    conversation_service = ConversationService()
    planning_service = PlanningService()
    context_service = ContextService()
    retry_service = RetryService()
    memory_service = MemoryService()

    container.register_instance(ConfigManager, config)
    container.register_instance(EventBusInterface, event_bus)
    container.register_instance(LoggingInterface, logger)
    container.register_instance(MemoryManager, memory_backend)
    container.register_instance(ToolRegistry, tool_registry)
    container.register_instance(ProviderRouter, provider_router)
    container.register_instance(ConversationService, conversation_service)
    container.register_instance(PlanningService, planning_service)
    container.register_instance(ContextService, context_service)
    container.register_instance(RetryService, retry_service)
    container.register_instance(MemoryService, memory_service)

    return container


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    global agent, registration_client
    container = _build_container()
    agent = PersonalAgent(container=container)
    await agent.start()

    registration_client = AgentRegistrationClient(
        agent_id="personal-ai-001",
        agent_name="Personal AI Assistant",
        agent_type=AgentType.PERSONAL_AI,
        version="1.0.0",
        control_plane_url=CONTROL_PLANE_URL,
        heartbeat_interval=30,
        organization_id="",
        capabilities=["chat", "memory", "tasks", "tools", "planning"],
        supported_models=["gpt-4", "gpt-3.5-turbo", "claude-3", "llama-3"],
        api_endpoint="http://localhost:8000",
    )
    registration_client.set_status(AgentStatus.ONLINE)
    await registration_client.register()
    registration_client.start_heartbeat_background()

    yield

    if registration_client:
        await registration_client.stop()
    if agent is not None:
        await agent.shutdown()


app = FastAPI(
    title="Personal AI Assistant",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8000", "127.0.0.1:8000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def add_security_headers(request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    return response


@app.post("/api/chat")
async def api_chat(body: dict[str, Any]) -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    message = body.get("message", "")
    conversation_id = body.get("conversation_id")
    if not message:
        raise HTTPException(status_code=400, detail="message is required")

    chunks: list[str] = []
    async for chunk in agent.chat(message=message, conversation_id=conversation_id, stream=False):
        chunks.append(chunk.content)
    return JSONResponse({"response": "".join(chunks), "conversation_id": conversation_id})


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket) -> None:
    if agent is None:
        await websocket.close(code=1011, reason="Agent not available")
        return
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_text()
            try:
                payload = json.loads(data)
            except json.JSONDecodeError:
                await websocket.send_json({"error": "Invalid JSON"})
                continue

            msg_type = payload.get("type", "chat")
            if msg_type == "chat":
                message = payload.get("message", "")
                conversation_id = payload.get("conversation_id")
                async for chunk in agent.chat(message=message, conversation_id=conversation_id, stream=True):
                    await websocket.send_json({
                        "type": "chunk",
                        "content": chunk.content,
                        "finish_reason": chunk.finish_reason,
                        "conversation_id": conversation_id,
                    })
                    if chunk.finish_reason is not None:
                        break
            elif msg_type == "ping":
                await websocket.send_json({"type": "pong"})
    except WebSocketDisconnect:
        pass


@app.get("/api/conversations")
async def api_list_conversations() -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    convs = await agent.conversation_manager.list_conversations()
    return JSONResponse(convs)


@app.get("/api/conversations/{conversation_id}")
async def api_get_conversation(conversation_id: str) -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    conv = await agent.conversation_manager.get_conversation(conversation_id)
    if conv is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return JSONResponse(conv.to_json())


@app.delete("/api/conversations/{conversation_id}")
async def api_delete_conversation(conversation_id: str) -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    success = await agent.conversation_manager.delete_conversation(conversation_id)
    if not success:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return JSONResponse({"status": "deleted"})


@app.get("/api/memory/search")
async def api_search_memory(q: str = Query("")) -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    if not q:
        return JSONResponse([])
    results = await agent.search_memory(q)
    return JSONResponse(results)


@app.post("/api/memory")
async def api_store_memory(body: dict[str, Any]) -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    content = body.get("content", "")
    if not content:
        raise HTTPException(status_code=400, detail="content is required")
    mem_id = await agent.conversation_manager.store_memory(
        content=content,
        memory_type=body.get("type", "conversation"),
        importance=body.get("importance", "medium"),
        tags=body.get("tags"),
    )
    return JSONResponse({"id": mem_id})


@app.delete("/api/memory/{memory_id}")
async def api_delete_memory(memory_id: str) -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    success = await agent.conversation_manager.delete_memory(memory_id)
    if not success:
        raise HTTPException(status_code=404, detail="Memory not found")
    return JSONResponse({"status": "deleted"})


@app.get("/api/tasks")
async def api_list_tasks() -> JSONResponse:
    return JSONResponse([])


@app.post("/api/tasks")
async def api_create_task(body: dict[str, Any]) -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    goal = body.get("goal", "")
    if not goal:
        raise HTTPException(status_code=400, detail="goal is required")
    result = await agent.execute_plan(goal)
    return JSONResponse(result)


@app.post("/api/tasks/{task_id}/cancel")
async def api_cancel_task(task_id: str) -> JSONResponse:
    return JSONResponse({"status": "cancelled", "task_id": task_id})


@app.get("/api/system/health")
async def api_system_health() -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    health = await agent.get_system_health()
    return JSONResponse(health)


@app.post("/api/system/shutdown")
async def api_system_shutdown(
    _auth: None = Depends(_verify_api_key),
) -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    asyncio.create_task(_delayed_shutdown())
    return JSONResponse({"status": "shutting_down"})


async def _delayed_shutdown() -> None:
    await asyncio.sleep(0.5)
    if agent is not None:
        await agent.shutdown()


@app.get("/api/settings")
async def api_get_settings() -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    settings = await agent.settings_manager.get_all()
    return JSONResponse(settings)


@app.put("/api/settings")
async def api_update_settings(
    body: dict[str, Any],
    _auth: None = Depends(_verify_api_key),
) -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    results = await agent.settings_manager.update(body)
    return JSONResponse(results)


@app.get("/api/permissions")
async def api_get_permissions() -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    pending = agent.permissions_manager.get_pending()
    history = agent.permissions_manager.get_history()
    return JSONResponse({"pending": pending, "history": history})


@app.post("/api/permissions/approve")
async def api_approve_permission(
    body: dict[str, Any],
    _auth: None = Depends(_verify_api_key),
) -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    permission_id = body.get("permission_id", "")
    if not permission_id:
        raise HTTPException(status_code=400, detail="permission_id is required")
    success = agent.permissions_manager.approve(permission_id)
    return JSONResponse({"success": success})


@app.get("/api/tools")
async def api_list_tools() -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    tools = await agent.tool_registry.list_tools()
    return JSONResponse(tools)


@app.get("/health")
async def health_check() -> JSONResponse:
    status = "healthy"
    if agent is None:
        status = "unavailable"
    return JSONResponse({
        "status": status,
        "agent_id": "personal-ai-001",
        "uptime_seconds": round(time.time() - _start_time, 1),
    })


@app.get("/capabilities")
async def capabilities_check() -> JSONResponse:
    caps = registration_client.build_capabilities(
        supported_tools=["open_app", "close_app", "type_text", "take_screenshot", "run_terminal", "run_powershell", "run_python"],
        max_concurrent_sessions=10,
        max_concurrent_conversations=50,
        features={"streaming": True, "websocket": True, "memory": True, "planning": True},
    ) if registration_client else None
    return JSONResponse(caps.to_json() if caps else {"agent_id": "personal-ai-001", "capabilities": []})


@app.get("/metrics")
async def metrics_check() -> JSONResponse:
    m = get_metrics(
        active_conversations=1 if agent else 0,
        running_tasks=0,
        uptime_seconds=round(time.time() - _start_time, 1),
        total_requests=registration_client._total_requests if registration_client else 0,
        total_errors=registration_client._total_errors if registration_client else 0,
    )
    return JSONResponse(m.to_json())


@app.get("/version")
async def version_check() -> JSONResponse:
    v = registration_client.build_version() if registration_client else None
    return JSONResponse(v.to_json() if v else {"version": "1.0.0"})


@app.get("/status")
async def status_check() -> JSONResponse:
    m = get_metrics(
        active_conversations=1 if agent else 0,
        uptime_seconds=round(time.time() - _start_time, 1),
    )
    return JSONResponse({
        "agent_id": "personal-ai-001",
        "agent_name": "Personal AI Assistant",
        "agent_type": "personal_ai",
        "status": registration_client.status.value if registration_client else "unknown",
        "version": "1.0.0",
        "uptime_seconds": round(time.time() - _start_time, 1),
        "health_status": "healthy" if agent else "unavailable",
        "metrics": m.to_json(),
    })


@app.post("/api/v1/agents/register")
async def agent_register(body: dict[str, Any]) -> JSONResponse:
    from nexora_ai.domain.entities.agent import AgentRegistration
    reg = AgentRegistration.from_json(body)
    if agent_manager:
        ok = await agent_manager.register(reg)
        return JSONResponse({"success": ok, "agent_id": reg.agent_id})
    return JSONResponse({"success": False, "error": "Agent manager not available"}, status_code=503)


@app.post("/api/v1/agents/heartbeat")
async def agent_heartbeat(body: dict[str, Any]) -> JSONResponse:
    from nexora_ai.domain.entities.agent import AgentHeartbeat
    hb = AgentHeartbeat.from_json(body)
    if agent_manager:
        ok = await agent_manager.heartbeat(hb)
        return JSONResponse({"success": ok})
    return JSONResponse({"success": False}, status_code=503)


@app.delete("/api/v1/agents/{agent_id}")
async def agent_unregister(agent_id: str) -> JSONResponse:
    if agent_manager:
        ok = await agent_manager.unregister(agent_id)
        return JSONResponse({"success": ok})
    return JSONResponse({"success": False}, status_code=503)


@app.get("/api/v1/agents")
async def list_agents() -> JSONResponse:
    if agent_manager:
        agents = await agent_manager.list_agents()
        return JSONResponse([a.to_json() for a in agents])
    return JSONResponse([])


@app.get("/api/v1/agents/online")
async def list_online_agents() -> JSONResponse:
    if agent_manager:
        agents = await agent_manager.list_online_agents()
        return JSONResponse([a.to_json() for a in agents])
    return JSONResponse([])


@app.get("/api/v1/agents/{agent_id}")
async def get_agent(agent_id: str) -> JSONResponse:
    if agent_manager:
        agent_reg = await agent_manager.get_agent(agent_id)
        if agent_reg:
            return JSONResponse(agent_reg.to_json())
        raise HTTPException(status_code=404, detail="Agent not found")
    raise HTTPException(status_code=503, detail="Agent manager not available")


@app.get("/api/v1/agents/{agent_id}/status")
async def get_agent_status(agent_id: str) -> JSONResponse:
    if agent_manager:
        status = await agent_manager.get_agent_status(agent_id)
        if status:
            return JSONResponse(status.to_json())
        raise HTTPException(status_code=404, detail="Agent not found")
    raise HTTPException(status_code=503, detail="Agent manager not available")


@app.get("/api/v1/agents/{agent_id}/metrics")
async def get_agent_metrics(agent_id: str) -> JSONResponse:
    if agent_manager:
        m = await agent_manager.get_agent_metrics(agent_id)
        if m:
            return JSONResponse(m.to_json())
        raise HTTPException(status_code=404, detail="Agent not found")
    raise HTTPException(status_code=503, detail="Agent manager not available")


@app.get("/api/v1/agents/{agent_id}/capabilities")
async def get_agent_capabilities(agent_id: str) -> JSONResponse:
    if agent_manager:
        caps = await agent_manager.get_agent_capabilities(agent_id)
        if caps:
            return JSONResponse(caps.to_json())
        raise HTTPException(status_code=404, detail="Agent not found")
    raise HTTPException(status_code=503, detail="Agent manager not available")


@app.get("/api/v1/agents/{agent_id}/version")
async def get_agent_version(agent_id: str) -> JSONResponse:
    if agent_manager:
        v = await agent_manager.get_agent_version(agent_id)
        if v:
            return JSONResponse(v.to_json())
        raise HTTPException(status_code=404, detail="Agent not found")
    raise HTTPException(status_code=503, detail="Agent manager not available")


@app.put("/api/v1/agents/{agent_id}/status")
async def set_agent_status(agent_id: str, body: dict[str, Any]) -> JSONResponse:
    if agent_manager:
        status = body.get("status", "")
        ok = await agent_manager.set_agent_status(agent_id, status)
        if ok:
            return JSONResponse({"success": True})
        raise HTTPException(status_code=404, detail="Agent not found or invalid status")
    raise HTTPException(status_code=503, detail="Agent manager not available")


@app.get("/api/v1/dashboard")
async def dashboard_summary() -> JSONResponse:
    if agent_manager:
        summary = await agent_manager.get_dashboard_summary()
        return JSONResponse(summary)
    return JSONResponse({"total_agents": 0, "online": 0, "offline": 0})


@app.get("/api/v1/dashboard/agents")
async def dashboard_agents() -> JSONResponse:
    if agent_manager:
        statuses = await agent_manager.get_all_status()
        return JSONResponse([s.to_json() for s in statuses])
    return JSONResponse([])


@app.post("/api/v1/agents/check-stale")
async def check_stale_agents() -> JSONResponse:
    if agent_manager:
        stale = await agent_manager.check_stale_agents()
        return JSONResponse({"stale_agents": stale})
    return JSONResponse({"stale_agents": []})


@app.post("/api/tools/{tool_name}/execute")
async def api_execute_tool(
    tool_name: str,
    body: dict[str, Any],
    _auth: None = Depends(_verify_api_key),
) -> JSONResponse:
    if agent is None:
        raise HTTPException(status_code=503, detail="Agent not available")
    parameters = body.get("parameters", {})
    result = await agent.tool_registry.execute(tool_name, parameters)
    return JSONResponse(result)


@app.get("/api/v1/auth/status")
async def auth_status() -> JSONResponse:
    return JSONResponse({
        "auth_mode": AUTH_MODE,
        "has_api_key": bool(API_KEY),
        "control_plane_url": CONTROL_PLANE_URL,
        "jwt_issuer": "nexora",
        "supported_roles": ["owner", "admin", "manager", "employee", "viewer"],
    })


@app.get("/api/v1/auth/config")
async def auth_config() -> JSONResponse:
    return JSONResponse({
        "mode": AUTH_MODE,
        "issuer": "nexora",
        "algorithm": "HS256",
        "access_token_expire_minutes": 60,
        "refresh_token_expire_days": 7,
    })


@app.get("/api/v1/auth/permissions")
async def auth_permissions() -> JSONResponse:
    from nexora_ai.domain.enums.auth_enums import ROLE_PERMISSIONS, SystemRole
    return JSONResponse({
        role.value: [p.value for p in perms]
        for role, perms in ROLE_PERMISSIONS.items()
    })


@app.get("/api/v1/providers")
async def list_providers() -> JSONResponse:
    from nexora_ai.infrastructure.provider_router import ProviderRouter
    router = ProviderRouter()
    available = router.get_available_providers()
    health = router.get_health()
    return JSONResponse({
        "providers": [
            {
                "type": p.value,
                "status": health.get("providers", {}).get(p.value, {}).get("status", "unknown"),
                "available": p in available,
                "latency": health.get("latencies", {}).get(p.value, 0),
                "cost": health.get("costs", {}).get(p.value, 0),
            }
            for p in available
        ],
        "routing_strategy": health.get("routing_strategy", "priority"),
        "total": len(available),
    })


@app.get("/api/v1/providers/health")
async def provider_health() -> JSONResponse:
    from nexora_ai.infrastructure.provider_router import ProviderRouter
    router = ProviderRouter()
    return JSONResponse(router.get_health())


@app.get("/api/v1/providers/costs")
async def provider_costs() -> JSONResponse:
    from nexora_ai.infrastructure.provider_router import ProviderRouter
    router = ProviderRouter()
    health = router.get_health()
    return JSONResponse({
        "costs": health.get("costs", {}),
        "latencies": health.get("latencies", {}),
    })


@app.get("/api/v1/providers/registered")
async def registered_providers() -> JSONResponse:
    from nexora_ai.infrastructure.providers.factory import ProviderFactory
    registered = ProviderFactory.list_registered()
    return JSONResponse({
        "registered": [p.value for p in registered],
        "total": len(registered),
    })


@app.post("/api/v1/providers/sync")
async def sync_providers() -> JSONResponse:
    from nexora_ai.infrastructure.provider_config_service import ProviderConfigService
    from nexora_ai.infrastructure.provider_router import ProviderRouter
    router = ProviderRouter()
    service = ProviderConfigService(
        provider_router=router,
        control_plane_url=CONTROL_PLANE_URL,
    )
    count = await service.sync_providers()
    return JSONResponse({
        "synced": count,
        "status": "success",
    })


@app.post("/api/v1/providers/{provider_type}/register")
async def register_provider(provider_type: str, body: dict[str, Any]) -> JSONResponse:
    from nexora_ai.infrastructure.provider_router import ProviderRouter
    from nexora_ai.domain.enums.provider_enums import ProviderType
    router = ProviderRouter()
    try:
        ptype = ProviderType(provider_type)
    except ValueError:
        raise HTTPException(status_code=400, detail=f"Unknown provider type: {provider_type}")
    await router.register_provider(
        provider_type=ptype,
        config=body.get("config", {}),
        priority=body.get("priority", 0),
    )
    return JSONResponse({"status": "registered", "provider": provider_type})


def main() -> None:
    import uvicorn
    uvicorn.run(
        "backend.agent_server:app",
        host="127.0.0.1",
        port=8000,
        reload=False,
        log_level="info",
    )


if __name__ == "__main__":
    main()
