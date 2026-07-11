# Architecture Guide

## System Architecture

```
                    ┌─────────────┐
                    │   Clients    │
                    │ (Flutter/Web │
                    │  /API/Mobile)│
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   nginx     │
                    │  (Ingress)  │
                    │ TLS, Rate   │
                    │ Limiting    │
                    └──────┬──────┘
                           │
              ┌────────────▼────────────┐
              │     FastAPI (Brain)     │
              │  4+ Workers, Async      │
              │  Prometheus, OTel       │
              └────┬────┬────┬────┬─────┘
                   │    │    │    │
        ┌──────────┘    │    │    └──────────┐
        ▼               ▼    ▼               ▼
  ┌──────────┐   ┌────────┐ ┌────────┐ ┌──────────┐
  │PostgreSQL│   │ Redis  │ │ Qdrant │ │  Ollama  │
  │  15      │   │   7    │ │ 1.9.0  │ │  0.3.0   │
  │ Primary  │   │ Cache  │ │ Vector │ │  LLM     │
  │ + WAL    │   │ Queue  │ │  DB    │ │  GPU     │
  └──────────┘   └────────┘ └────────┘ └──────────┘
```

## Service Components

| Service | Language | Framework | Purpose |
|---------|----------|-----------|---------|
| brain | Python 3.11 | FastAPI | API server, business logic |
| postgres | SQL | PostgreSQL 15 | Primary database |
| redis | C | Redis 7 | Cache, rate limiting, queues |
| qdrant | Rust | Qdrant 1.9 | Vector embeddings |
| ollama | Go | Ollama 0.3 | Local LLM inference |
| nginx | C | nginx | Reverse proxy, TLS |

## Monitoring Stack

| Service | Purpose |
|---------|---------|
| Prometheus | Metrics collection |
| Grafana | Dashboards & visualization |
| Alertmanager | Alert routing |
| Loki | Log aggregation |
| Promtail | Log shipping |
| OpenTelemetry Collector | Trace, metric, log collection |
| Node Exporter | Host metrics |
| cAdvisor | Container metrics |

## Key Design Decisions

1. **Async-first**: All I/O is async (FastAPI + SQLAlchemy async + httpx)
2. **Multi-tenant**: org_id scoping on all queries, JWT contains org_id
3. **Graceful degradation**: All external services (Redis, Qdrant, Ollama) fail safe
4. **Blue/Green deployment**: Zero-downtime via color-switching deployments
5. **Prometheus metrics**: Full instrumentation with histograms, counters, gauges
6. **OpenTelemetry tracing**: End-to-end distributed tracing via OTLP
7. **Structured logging**: JSON in production, correlation IDs on all requests
