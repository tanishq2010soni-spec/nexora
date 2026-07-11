from __future__ import annotations

import os
import time
from contextlib import asynccontextmanager
from datetime import datetime, timezone

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from nexora_ai.domain.enums.agent_enums import AgentStatus, AgentType
from nexora_ai.infrastructure.agent_client.registration_client import AgentRegistrationClient, get_metrics

from backend.config import settings as config_settings
from backend.api import (analytics, auth, campaigns, conversations, crm, health,
                          knowledge, logs, organizations, permissions, plugins,
                          settings, team_inbox, whatsapp, workflows)
from backend.infrastructure.database import close_db, init_db

start_time: datetime = datetime.now(timezone.utc)
_control_plane_url = os.environ.get("NEXORA_CONTROL_PLANE_URL", "")
_registration_client: AgentRegistrationClient | None = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global _registration_client
    config_settings.ensure_dirs()
    await init_db()

    _registration_client = AgentRegistrationClient(
        agent_id="whatsapp-agent-001",
        agent_name="WhatsApp Agent",
        agent_type=AgentType.WHATSAPP,
        version=config_settings.app_version,
        control_plane_url=_control_plane_url,
        heartbeat_interval=30,
        capabilities=["messaging", "crm", "campaigns", "workflows", "analytics"],
        supported_models=["gpt-4", "gpt-3.5-turbo"],
        api_endpoint=f"http://localhost:{config_settings.port}",
    )
    _registration_client.set_status(AgentStatus.ONLINE)
    await _registration_client.register()
    _registration_client.start_heartbeat_background()

    yield

    if _registration_client:
        await _registration_client.stop()
    await close_db()


app = FastAPI(
    title=config_settings.app_name,
    version=config_settings.app_version,
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=config_settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    response = await call_next(request)
    response.headers["X-Start-Time"] = str(int(start_time.timestamp()))
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
    return response


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error", "path": str(request.url)},
    )


app.include_router(health.router)
app.include_router(auth.router)
app.include_router(organizations.router)
app.include_router(whatsapp.router)
app.include_router(conversations.router)
app.include_router(crm.router)
app.include_router(knowledge.router)
app.include_router(workflows.router)
app.include_router(campaigns.router)
app.include_router(analytics.router)
app.include_router(team_inbox.router)
app.include_router(settings.router)
app.include_router(permissions.router)
app.include_router(logs.router)
app.include_router(plugins.router)


@app.get("/")
async def root():
    return {
        "app": config_settings.app_name,
        "version": config_settings.app_version,
        "status": "running",
        "uptime_seconds": (datetime.now(timezone.utc) - start_time).total_seconds(),
    }


@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "agent_id": "whatsapp-agent-001",
        "uptime_seconds": (datetime.now(timezone.utc) - start_time).total_seconds(),
    }


@app.get("/capabilities")
async def capabilities_check():
    caps = _registration_client.build_capabilities(
        supported_tools=["send_message", "receive_message", "manage_contacts", "campaigns"],
        max_concurrent_sessions=50,
        max_concurrent_conversations=100,
        features={"webhooks": True, "media": True, "templates": True},
    ) if _registration_client else None
    return caps.to_json() if caps else {"agent_id": "whatsapp-agent-001", "capabilities": []}


@app.get("/metrics")
async def metrics_check():
    m = get_metrics(
        uptime_seconds=(datetime.now(timezone.utc) - start_time).total_seconds(),
    )
    return m.to_json()


@app.get("/version")
async def version_check():
    v = _registration_client.build_version() if _registration_client else None
    return v.to_json() if v else {"version": config_settings.app_version}


@app.get("/status")
async def status_check():
    m = get_metrics(
        uptime_seconds=(datetime.now(timezone.utc) - start_time).total_seconds(),
    )
    return {
        "agent_id": "whatsapp-agent-001",
        "agent_name": "WhatsApp Agent",
        "agent_type": "whatsapp",
        "status": _registration_client.status.value if _registration_client else "unknown",
        "version": config_settings.app_version,
        "uptime_seconds": (datetime.now(timezone.utc) - start_time).total_seconds(),
        "health_status": "healthy",
        "metrics": m.to_json(),
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.main:app", host=config_settings.host, port=config_settings.port, reload=config_settings.debug)
