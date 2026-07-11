# Deployment Guide

## Prerequisites

- **Python 3.12+** (3.12 or higher required)
- **pip** (Python package installer)
- **Redis** (optional, for caching and job queues)
- **SQLite** (included with Python, for development) or **PostgreSQL** (for production)

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd whatsapp_agent
```

### 2. Create Virtual Environment

```bash
python -m venv venv
# On Windows:
venv\Scripts\activate
# On Linux/Mac:
source venv/bin/activate
```

### 3. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

## Configuration

All configuration is managed through environment variables prefixed with `WA_`, or via a `.env` file in the `backend/` directory.

### Environment Variables

| Variable                       | Default                        | Description                           |
|--------------------------------|--------------------------------|---------------------------------------|
| `WA_APP_NAME`                  | `WhatsApp Agent`               | Application name                      |
| `WA_APP_VERSION`               | `1.0.0`                        | Application version                   |
| `WA_DEBUG`                     | `false`                        | Enable debug mode                     |
| `WA_HOST`                      | `0.0.0.0`                      | Server bind address                   |
| `WA_PORT`                      | `8100`                         | Server port                           |
| `WA_DATABASE_URL`              | `sqlite+aiosqlite:///./whatsapp_agent.db` | Database connection string |
| `WA_DATABASE_ECHO`             | `false`                        | Log SQL queries                       |
| `WA_REDIS_URL`                 | `redis://localhost:6379/0`     | Redis connection URL                  |
| `WA_SECRET_KEY`                | `change-me-in-production`      | JWT signing secret                    |
| `WA_ACCESS_TOKEN_EXPIRE_MINUTES` | `60`                        | Access token TTL                      |
| `WA_REFRESH_TOKEN_EXPIRE_DAYS` | `7`                            | Refresh token TTL                     |
| `WA_ALGORITHM`                 | `HS256`                        | JWT algorithm                         |
| `WA_NEXORA_AI_PATH`            | `""`                           | Path to Nexora AI installation        |
| `WA_WHATSAPP_SESSION_DIR`      | `data/sessions`                | WhatsApp session storage              |
| `WA_STORAGE_DIR`               | `data/storage`                 | File storage directory                |
| `WA_KNOWLEDGE_DIR`             | `data/knowledge`               | Knowledge base file directory         |
| `WA_MAX_UPLOAD_SIZE_MB`        | `50`                           | Max upload file size                  |
| `WA_RATE_LIMIT_PER_MINUTE`     | `60`                           | API rate limit per minute             |
| `WA_RATE_LIMIT_PER_HOUR`       | `1000`                         | API rate limit per hour               |
| `WA_CORS_ORIGINS`              | `["*"]`                        | Allowed CORS origins                  |
| `WA_ANALYTICS_RETENTION_DAYS`  | `90`                           | Analytics data retention              |
| `WA_LOG_RETENTION_DAYS`        | `30`                           | Log retention period                  |

### .env File Example

```env
WA_APP_NAME=My WhatsApp Agent
WA_DEBUG=true
WA_DATABASE_URL=sqlite+aiosqlite:///./whatsapp_agent.db
WA_SECRET_KEY=your-strong-secret-key-here
WA_CORS_ORIGINS=["https://app.example.com"]
```

## Database Setup

### Development (SQLite)

No additional setup is required. The database is created automatically on first run.

### Production (PostgreSQL)

1. Install PostgreSQL and create a database:

```bash
createdb whatsapp_agent
```

2. Set the database URL:

```env
WA_DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/whatsapp_agent
```

3. Install the PostgreSQL driver:

```bash
pip install asyncpg
```

4. Database tables are created automatically via SQLAlchemy's `create_all` on startup.

### Running Migrations

The application uses SQLAlchemy's `create_all` for schema creation. For production, consider using Alembic for migration management:

```bash
pip install alembic
alembic init alembic
# Configure alembic.ini with your database URL
alembic revision --autogenerate -m "initial"
alembic upgrade head
```

## Running the Server

### Development

```bash
cd backend
python main.py
```

The server starts at `http://localhost:8100` with auto-reload enabled.

### Production

```bash
cd backend
uvicorn backend.main:app --host 0.0.0.0 --port 8100 --workers 4 --log-level info
```

### Using Gunicorn + Uvicorn Workers (Linux)

```bash
pip install gunicorn
gunicorn backend.main:app --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8100 --workers 4
```

## Production Considerations

### Security

1. **Change the secret key** — Set `WA_SECRET_KEY` to a strong, unique value.
2. **Enable HTTPS** — Use a reverse proxy (Nginx, Caddy) with TLS termination.
3. **Rate limiting** — Configure `WA_RATE_LIMIT_PER_MINUTE` and `WA_RATE_LIMIT_PER_HOUR`.
4. **CORS** — Restrict `WA_CORS_ORIGINS` to your specific domain(s).
5. **Database credentials** — Use strong passwords and restrict network access.

### Reverse Proxy (Nginx Example)

```nginx
server {
    listen 443 ssl;
    server_name api.example.com;

    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;

    location / {
        proxy_pass http://127.0.0.1:8100;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 60s;
    }
}
```

### Process Management with systemd

```ini
[Unit]
Description=WhatsApp Agent
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/whatsapp_agent/backend
Environment=WA_DATABASE_URL=sqlite+aiosqlite:///./whatsapp_agent.db
Environment=WA_SECRET_KEY=your-secret-key
ExecStart=/opt/whatsapp_agent/venv/bin/uvicorn backend.main:app --host 127.0.0.1 --port 8100
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### Monitoring

- **Health endpoint** — `GET /api/v1/health` for uptime monitoring
- **Logs** — Configure `WA_LOG_RETENTION_DAYS` for audit log retention
- **Metrics** — Use the analytics API for business metrics

### Scaling

- **Horizontal scaling** — Run multiple workers behind a load balancer
- **Database** — Migrate to PostgreSQL for better concurrent access
- **Caching** — Enable Redis for session caching and rate limiting
- **File storage** — Replace local storage with S3-compatible object storage

### Backup

- **Database** — Schedule regular database backups
- **WhatsApp sessions** — Backup `data/sessions/` directory
- **Knowledge documents** — Backup `data/knowledge/` directory
