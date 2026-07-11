# Deployment Guide

## Prerequisites

- Python 3.12 or higher
- pip (Python package manager)
- Access to a database (SQLite for development, PostgreSQL for production)
- Redis (optional, for task queuing and caching)

## Voice Dependencies

### STT Providers

**Whisper (local):**
```bash
pip install openai-whisper
# Requires ffmpeg on the system
# Ubuntu/Debian: sudo apt install ffmpeg
# macOS: brew install ffmpeg
# Windows: Download from https://ffmpeg.org/download.html
```

**Deepgram (cloud):**
```bash
pip install httpx
# Requires a Deepgram API key
```

### TTS Providers

**pyttsx3 (local):**
```bash
pip install pyttsx3
# Linux: sudo apt install espeak espeak-data libespeak1
```

**ElevenLabs (cloud):**
```bash
pip install httpx
# Requires an ElevenLabs API key
```

### VAD Providers

**WebRTC VAD:**
```bash
pip install webrtcvad
```

**Silero VAD:**
```bash
pip install torch numpy
```

## Phone Provider Setup

### Twilio

1. Create a Twilio account at https://www.twilio.com
2. Get Account SID and Auth Token from the console
3. Purchase a phone number
4. Configure webhook URLs:
   - Voice URL: `https://your-domain.com/api/v1/webhooks/twilio/voice`
   - Status Callback: `https://your-domain.com/api/v1/webhooks/twilio/status`

### Exotel

1. Create an Exotel account
2. Get API Key, API Token, and Exotel SID
3. Configure your Exotel number's call URL to point to your webhook

### Plivo

1. Create a Plivo account
2. Get Auth ID and Auth Token
3. Purchase a phone number
4. Set the voice URL to your webhook endpoint

### SIP/PBX

1. Configure your SIP server or PBX
2. Set the SIP URI and credentials
3. Configure the trunk to route calls to your application

## Configuration

Create a `.env` file in the project root:

```env
# Application
CA_APP_NAME=Calling Agent
CA_APP_VERSION=1.0.0
CA_DEBUG=false
CA_HOST=0.0.0.0
CA_PORT=8200

# Database (SQLite for development)
CA_DATABASE_URL=sqlite+aiosqlite:///./calling_agent.db

# Database (PostgreSQL for production)
# CA_DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/calling_agent

# Redis
CA_REDIS_URL=redis://localhost:6379/0

# Security
CA_SECRET_KEY=your-secure-random-secret-key-here
CA_ACCESS_TOKEN_EXPIRE_MINUTES=60
CA_REFRESH_TOKEN_EXPIRE_DAYS=7

# STT
CA_STT_PROVIDER=whisper
CA_STT_MODEL=base
CA_STT_LANGUAGE=en

# TTS
CA_TTS_PROVIDER=pyttsx3
CA_TTS_VOICE=default
CA_TTS_SPEED=1.0

# VAD
CA_VAD_MODE=1
CA_VAD_FRAME_MS=30
CA_VAD_SILENCE_MS=500

# Twilio
CA_TWILIO_ACCOUNT_SID=your_account_sid
CA_TWILIO_AUTH_TOKEN=your_auth_token
CA_TWILIO_PHONE_NUMBER=+15551234567

# Exotel
CA_EXOTEL_API_KEY=your_api_key
CA_EXOTEL_API_TOKEN=your_api_token
CA_EXOTEL_SID=your_exotel_sid

# Plivo
CA_PLIVO_AUTH_ID=your_auth_id
CA_PLIVO_AUTH_TOKEN=your_auth_token
CA_PLIVO_PHONE_NUMBER=+15551234567

# Webhook
CA_WEBHOOK_BASE_URL=https://your-domain.com
```

## Running the Server

### Development

```bash
# Install all dependencies
pip install -r requirements.txt

# Start the server
python -m backend.main
```

The server will start at `http://localhost:8200`.

### Using uvicorn directly

```bash
uvicorn backend.main:app --host 0.0.0.0 --port 8200 --reload
```

### Using Docker

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8200

CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8200"]
```

```bash
docker build -t calling-agent .
docker run -p 8200:8200 --env-file .env calling-agent
```

## Production Deployment

### System Requirements

- Python 3.12+
- 2GB RAM minimum (4GB+ recommended)
- 20GB disk space (for recordings, logs)
- PostgreSQL 14+ (recommended over SQLite)
- Redis 6+ (for caching and task queues)
- Nginx or similar reverse proxy

### Production Checklist

1. **Security**
   - Generate a strong random SECRET_KEY
   - Enable HTTPS with valid SSL certificate
   - Set appropriate CORS origins
   - Use strong passwords for database
   - Enable firewall rules

2. **Database**
   - Use PostgreSQL in production
   - Set up database backups
   - Configure connection pooling
   - Run database migrations

3. **Performance**
   - Deploy behind Nginx reverse proxy
   - Enable Gunicorn + Uvicorn workers
   - Configure Redis caching
   - Set up CDN for recordings

4. **Monitoring**
   - Set up health check monitoring
   - Configure logging aggregation
   - Set up alerting for critical errors

### Production Deployment with Nginx

```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://127.0.0.1:8200;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400s;
    }

    location /ws {
        proxy_pass http://127.0.0.1:8200;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 86400s;
    }
}
```

### Using systemd

```ini
[Unit]
Description=AI Calling Agent
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/calling-agent
EnvironmentFile=/opt/calling-agent/.env
ExecStart=/usr/local/bin/uvicorn backend.main:app --host 127.0.0.1 --port 8200 --workers 4
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Scaling

For high-volume deployments:

1. **Horizontal Scaling**: Run multiple instances behind a load balancer
2. **Database Scaling**: Use PostgreSQL read replicas for analytics queries
3. **Caching**: Use Redis for session data and rate limiting
4. **CDN**: Serve recordings and static assets via CDN
5. **Task Queue**: Use Celery with Redis for async task processing
