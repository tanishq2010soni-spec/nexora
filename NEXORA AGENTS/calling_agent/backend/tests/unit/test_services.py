from __future__ import annotations

from datetime import datetime, timedelta
from decimal import Decimal
from unittest.mock import AsyncMock, MagicMock, patch
from uuid import UUID, uuid4

import pytest

from backend.services.lead_scorer import LeadScorer


class TestLeadScorer:
    def setup_method(self):
        self.scorer = LeadScorer()

    @pytest.mark.asyncio
    async def test_calculate_score_high_value(self):
        score = await self.scorer.calculate_score({
            "company": "Enterprise Corp",
            "position": "CEO",
            "call_count": 3,
            "last_disposition": "interested",
            "industry": "technology",
            "email_verified": True,
            "has_website": True,
        })
        assert 0 <= score <= 100
        assert score >= 60

    @pytest.mark.asyncio
    async def test_calculate_score_minimal_data(self):
        score = await self.scorer.calculate_score({
            "company": None,
            "position": None,
            "call_count": 0,
            "last_disposition": None,
            "industry": None,
            "email_verified": False,
            "has_website": False,
        })
        assert 0 <= score <= 100

    @pytest.mark.asyncio
    async def test_calculate_score_no_company(self):
        score = await self.scorer.calculate_score({
            "company": None,
            "position": "manager",
            "call_count": 1,
            "industry": "finance",
        })
        assert 0 <= score <= 100

    @pytest.mark.asyncio
    async def test_calculate_score_startup(self):
        score = await self.scorer.calculate_score({
            "company": "My Startup",
            "position": "founder",
            "call_count": 2,
            "last_disposition": "completed",
            "industry": "saas",
            "email_verified": True,
            "has_website": True,
        })
        assert score >= 50

    @pytest.mark.asyncio
    async def test_calculate_score_ceo_tech(self):
        score = await self.scorer.calculate_score({
            "company": "TechCorp Inc",
            "position": "CEO",
            "call_count": 1,
            "last_disposition": "interested",
            "industry": "technology",
            "email_verified": True,
            "has_website": True,
        })
        assert score >= 70

    @pytest.mark.asyncio
    async def test_calculate_score_intern(self):
        score = await self.scorer.calculate_score({
            "company": "SmallBiz",
            "position": "intern",
            "call_count": 0,
            "industry": "retail",
            "email_verified": False,
            "has_website": False,
        })
        assert score < 50

    @pytest.mark.asyncio
    async def test_calculate_score_dnc_lead(self):
        score = await self.scorer.calculate_score({
            "company": "Enterprise Corp",
            "position": "VP",
            "call_count": 5,
            "last_disposition": "dnc",
            "industry": "technology",
            "email_verified": True,
            "has_website": True,
        })
        assert score >= 0

    @pytest.mark.asyncio
    async def test_calculate_score_with_custom_fields(self):
        score = await self.scorer.calculate_score({
            "company": "TechCorp",
            "position": "director",
            "call_count": 2,
            "industry": "software",
            "email_verified": True,
            "has_website": True,
        })
        assert 0 <= score <= 100

    def test_score_company_size_enterprise(self):
        assert self.scorer._score_company_size("Enterprise Corp") == 1.0

    def test_score_company_size_startup(self):
        assert self.scorer._score_company_size("My Startup") == 0.5

    def test_score_company_size_none(self):
        assert self.scorer._score_company_size(None) == 0.3

    def test_score_company_size_unknown(self):
        assert self.scorer._score_company_size("Acme") == 0.6

    def test_score_position_ceo(self):
        assert self.scorer._score_position("CEO") == 1.0

    def test_score_position_manager(self):
        assert self.scorer._score_position("manager") == 0.7

    def test_score_position_none(self):
        assert self.scorer._score_position(None) == 0.2

    def test_score_position_unknown(self):
        assert self.scorer._score_position("random") == 0.3

    def test_score_call_history_no_calls(self):
        assert self.scorer._score_call_history(0, None) == 0.5

    def test_score_call_history_interested(self):
        score = self.scorer._score_call_history(1, "interested")
        assert score >= 0.7

    def test_score_call_history_dnc(self):
        assert self.scorer._score_call_history(1, "dnc") == 0.0

    def test_score_call_history_many_attempts(self):
        score = self.scorer._score_call_history(5, "no_answer")
        assert score < 0.3

    def test_score_industry_technology(self):
        assert self.scorer._score_industry("technology") == 1.0

    def test_score_industry_none(self):
        assert self.scorer._score_industry(None) == 0.3

    def test_score_industry_unknown(self):
        assert self.scorer._score_industry("agriculture") == 0.4

    def test_score_engagement_full(self):
        assert self.scorer._score_engagement(True, True) == 1.0

    def test_score_engagement_none(self):
        assert self.scorer._score_engagement(False, False) == 0.0

    def test_score_engagement_email_only(self):
        assert self.scorer._score_engagement(True, False) == 0.6

    def test_batch_scoring(self):
        leads = [
            {"company": "Enterprise Corp", "position": "CEO", "industry": "technology"},
            {"company": None, "position": "intern", "industry": None},
        ]
        import asyncio
        scores = []
        for lead in leads:
            score = asyncio.run(self.scorer.calculate_score(lead))
            scores.append(score)
        assert len(scores) == 2
        assert scores[0] > scores[1]
