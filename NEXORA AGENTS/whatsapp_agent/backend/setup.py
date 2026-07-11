from setuptools import find_packages, setup

setup(
    name="whatsapp_agent",
    version="1.0.0",
    description="Enterprise WhatsApp AI Agent",
    packages=find_packages(),
    python_requires=">=3.12",
    install_requires=[
        "fastapi>=0.110.0",
        "uvicorn[standard]>=0.29.0",
        "pydantic>=2.7.0",
        "pydantic-settings>=2.2.0",
        "sqlalchemy[asyncio]>=2.0.30",
        "aiosqlite>=0.20.0",
        "httpx>=0.27.0",
    ],
)
