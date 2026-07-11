"""Seed default subscription plans for NEXORA SaaS.

Run:
    python scripts/seed_plans.py
"""

import asyncio
import uuid
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy import select
from src.infrastructure.database.models import Plan


DEFAULT_PLANS = [
    {
        "id": uuid.UUID("00000000-0000-0000-0000-000000000001"),
        "name": "Starter",
        "slug": "starter",
        "description": "For small businesses getting started with AI CRM",
        "price_monthly": 29.99,
        "price_yearly": 299.90,
        "currency": "usd",
        "trial_days": 14,
        "max_users": 3,
        "max_agents": 5,
        "max_leads": 500,
        "max_conversations": 1000,
        "max_calls": 100,
        "max_storage_mb": 1024,
        "features_json": '["ai_copilot","basic_automation","email_integration","basic_analytics"]',
        "is_active": True,
    },
    {
        "id": uuid.UUID("00000000-0000-0000-0000-000000000002"),
        "name": "Professional",
        "slug": "professional",
        "description": "For growing teams that need full AI automation",
        "price_monthly": 79.99,
        "price_yearly": 799.90,
        "currency": "usd",
        "trial_days": 14,
        "max_users": 10,
        "max_agents": 25,
        "max_leads": 5000,
        "max_conversations": 10000,
        "max_calls": 1000,
        "max_storage_mb": 10240,
        "features_json": '["ai_copilot","advanced_automation","omnichannel","voice_ai","advanced_analytics","workflow_engine","memory_engine","api_access"]',
        "is_active": True,
    },
    {
        "id": uuid.UUID("00000000-0000-0000-0000-000000000003"),
        "name": "Enterprise",
        "slug": "enterprise",
        "description": "For organizations requiring custom solutions",
        "price_monthly": 249.99,
        "price_yearly": 2499.90,
        "currency": "usd",
        "trial_days": 30,
        "max_users": 50,
        "max_agents": 100,
        "max_leads": 100000,
        "max_conversations": 100000,
        "max_calls": 10000,
        "max_storage_mb": 102400,
        "features_json": '["ai_copilot","advanced_automation","omnichannel","voice_ai","advanced_analytics","workflow_engine","memory_engine","api_access","custom_integrations","priority_support","dedicated_account_manager"]',
        "is_active": True,
    },
]


async def seed_plans():
    from src.config import settings
    db_url = settings.DATABASE_URL
    engine = create_async_engine(db_url)
    async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        for plan_data in DEFAULT_PLANS:
            existing = await session.get(Plan, plan_data["id"])
            if existing:
                print(f"  Plan '{plan_data['name']}' already exists, skipping")
                continue

            plan = Plan(**plan_data)
            session.add(plan)
            print(f"  Created plan: {plan_data['name']} (${plan_data['price_monthly']}/mo)")

        await session.commit()
        print("\n[OK] Subscription plans seeded successfully")


if __name__ == "__main__":
    asyncio.run(seed_plans())
