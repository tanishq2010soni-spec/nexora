from __future__ import annotations

import os
from contextlib import asynccontextmanager
from datetime import datetime, timezone

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from nexora_ai.domain.enums.agent_enums import AgentStatus, AgentType
from nexora_ai.infrastructure.agent_client.registration_client import AgentRegistrationClient, get_metrics

from backend.config import settings as config_settings
from backend.api import (analytics, appointments, auth, calls, campaigns, contacts,
                          health, knowledge, leads, logs, monitoring, organizations,
                          permissions, plugins, recordings, scripts, settings)
from backend.infrastructure.database import close_db, init_db

start_time = datetime.now(timezone.utc)
_control_plane_url = os.environ.get("NEXORA_CONTROL_PLANE_URL", "")
_registration_client: AgentRegistrationClient | None = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global _registration_client
    config_settings.ensure_dirs()
    await init_db()

    _registration_client = AgentRegistrationClient(
        agent_id="calling-agent-001",
        agent_name="Calling Agent",
        agent_type=AgentType.CALLING,
        version=config_settings.app_version,
        control_plane_url=_control_plane_url,
        heartbeat_interval=30,
        capabilities=["calls", "campaigns", "leads", "contacts", "recordings", "voip"],
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

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(organizations.router)
app.include_router(calls.router)
app.include_router(campaigns.router)
app.include_router(leads.router)
app.include_router(contacts.router)
app.include_router(appointments.router)
app.include_router(scripts.router)
app.include_router(recordings.router)
app.include_router(knowledge.router)
app.include_router(analytics.router)
app.include_router(settings.router)
app.include_router(permissions.router)
app.include_router(logs.router)
app.include_router(plugins.router)
app.include_router(monitoring.router)


@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
    return response


@app.get("/")
async def root():
    return {"app": config_settings.app_name, "version": config_settings.app_version}


@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "agent_id": "calling-agent-001",
        "uptime_seconds": (datetime.now(timezone.utc) - start_time).total_seconds(),
    }


@app.get("/capabilities")
async def capabilities_check():
    caps = _registration_client.build_capabilities(
        supported_tools=["make_call", "receive_call", "voicemail", "recording", "sms"],
        max_concurrent_sessions=50,
        max_concurrent_conversations=25,
        features={"voip": True, "recording": True, "transcription": True, "tts": True},
    ) if _registration_client else None
    return caps.to_json() if caps else {"agent_id": "calling-agent-001", "capabilities": []}


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
        "agent_id": "calling-agent-001",
        "agent_name": "Calling Agent",
        "agent_type": "calling",
        "status": _registration_client.status.value if _registration_client else "unknown",
        "version": config_settings.app_version,
        "uptime_seconds": (datetime.now(timezone.utc) - start_time).total_seconds(),
        "health_status": "healthy",
        "metrics": m.to_json(),
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "backend.main:app",
        host=config_settings.host,
        port=config_settings.port,
        reload=config_settings.debug,
    )
