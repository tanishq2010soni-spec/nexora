# NEXORA AGENTS - Dependency Report

**Date**: July 1, 2026  
**Phase**: D.5 - Production Stabilization

---

## Dependency Summary

| Project | Python Deps | Flutter Deps | Lock File | Status |
|---------|------------|--------------|-----------|--------|
| nexora_ai | 4 core + 13 optional | N/A | pyproject.toml | OK |
| personal_ai | 15 | 7 | pubspec.lock | OK |
| whatsapp_agent | 25 | 9 | pubspec.lock | OK |
| calling_agent | 16 | 9 | pubspec.lock | OK |

---

## Python Dependencies

### nexora_ai (pyproject.toml)
```
Core:
  httpx>=0.27
  aiosqlite>=0.20
  pyyaml>=6.0
  cryptography>=42.0

Optional:
  openai, anthropic, google-generativeai, groq, mistralai
  qdrant-client, chromadb
  playwright
  pyperclip, aiosmtplib, pillow, pytesseract, pyautogui
```

### personal_ai/backend/requirements.txt
```
fastapi>=0.115.0
uvicorn[standard]>=0.32.0
websockets>=13.0
httpx>=0.27.0
aiosqlite>=0.20.0
pyyaml>=6.0
cryptography>=42.0
pywin32>=306
pytesseract>=0.3.10
playwright>=1.45.0
PyMuPDF>=1.24.0
python-docx>=1.1.0
openpyxl>=3.1.0
psutil>=5.9.0
Pillow>=10.0.0
```

### whatsapp_agent/backend/requirements.txt
```
fastapi>=0.110.0
uvicorn[standard]>=0.29.0
pydantic>=2.7.0
pydantic-settings>=2.2.0
sqlalchemy[asyncio]>=2.0.30
aiosqlite>=0.20.0
alembic>=1.13.0
redis>=5.0.0
httpx>=0.27.0
python-multipart>=0.0.9
python-jose[cryptography]>=3.3.0
passlib[bcrypt]>=1.7.4
python-magic>=0.4.27
Pillow>=10.3.0
python-docx>=1.1.2
openpyxl>=3.1.2
markdown>=3.6.0
beautifulsoup4>=4.12.0
langdetect>=1.0.9
textblob>=0.18.0
fitz>=0.0.1.dev2
PyMuPDF>=1.24.0
websockets>=12.0
apscheduler>=3.10.4
tenacity>=8.3.0
```

### calling_agent/backend/requirements.txt
```
fastapi>=0.110.0
uvicorn[standard]>=0.29.0
pydantic>=2.7.0
pydantic-settings>=2.2.0
sqlalchemy[asyncio]>=2.0.30
aiosqlite>=0.20.0
alembic>=1.13.0
httpx>=0.27.0
python-multipart>=0.0.9
python-jose[cryptography]>=3.3.0
passlib[bcrypt]>=1.7.4
websockets>=12.0
apscheduler>=3.10.4
tenacity>=8.3.0
webrtcvad>=2.0.10
pyttsx3>=2.90
```

---

## Flutter Dependencies

### personal_ai/pubspec.yaml
```
provider: ^6.1.1
web_socket_channel: ^2.4.0
http: ^1.1.0
google_fonts: ^6.1.0
window_manager: ^0.3.7
go_router: ^12.1.1
```

### whatsapp_agent/pubspec.yaml
```
provider: ^6.1.1
http: ^1.1.0
web_socket_channel: ^2.4.0
google_fonts: ^6.1.0
window_manager: ^0.3.7
go_router: ^12.1.1
fl_chart: ^0.66.0
intl: ^0.19.0
```

### calling_agent/pubspec.yaml
```
provider: ^6.1.1
http: ^1.1.0
web_socket_channel: ^2.4.0
google_fonts: ^6.1.0
window_manager: ^0.3.7
go_router: ^12.1.1
fl_chart: ^0.66.0
intl: ^0.19.0
```

---

## Issues Found & Fixed

| Issue | Project | Fix |
|-------|---------|-----|
| `setuptools.backends._legacy` invalid | nexora_ai | Changed to `setuptools.build_meta` |
| `bcrypt>=4.1` breaks passlib | whatsapp_agent, calling_agent | Pinned `bcrypt<4.1` |
| `webrtcvad` missing | calling_agent | Installed `webrtcvad>=2.0.10` |
| `nexora_ai` not installed | personal_ai | Installed as editable package |

---

## Version Pinning Status

| Project | Pinning Strategy | Recommendation |
|---------|-----------------|----------------|
| nexora_ai | `>=` minimum | Pin exact versions |
| personal_ai | `>=` minimum | Pin exact versions |
| whatsapp_agent | `>=` minimum | Pin exact versions |
| calling_agent | `>=` minimum | Pin exact versions |

**Recommendation**: All projects should use `~=` compatible release operator or pin exact versions for reproducible builds.
