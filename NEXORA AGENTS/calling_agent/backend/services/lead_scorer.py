from __future__ import annotations

from typing import Any, Optional


class LeadScorer:
    WEIGHTS = {
        "company_size": 0.25,
        "position": 0.25,
        "call_history": 0.20,
        "industry_fit": 0.15,
        "engagement": 0.15,
    }

    POSITION_SCORES: dict[str, float] = {
        "ceo": 1.0,
        "founder": 1.0,
        "owner": 1.0,
        "president": 1.0,
        "vp": 0.9,
        "vice president": 0.9,
        "director": 0.8,
        "head": 0.8,
        "manager": 0.7,
        "lead": 0.6,
        "senior": 0.5,
        "engineer": 0.4,
        "specialist": 0.3,
        "associate": 0.2,
        "intern": 0.1,
    }

    INDUSTRY_SCORES: dict[str, float] = {
        "technology": 1.0,
        "software": 1.0,
        "saas": 1.0,
        "finance": 0.9,
        "healthcare": 0.8,
        "insurance": 0.8,
        "real estate": 0.7,
        "education": 0.6,
        "manufacturing": 0.6,
        "retail": 0.5,
        "nonprofit": 0.4,
        "government": 0.3,
    }

    async def calculate_score(self, lead_data: dict) -> float:
        company = lead_data.get("company")
        position = lead_data.get("position")
        call_count = lead_data.get("call_count", 0)
        last_disposition = lead_data.get("last_disposition")
        industry = lead_data.get("industry", "")
        email_verified = lead_data.get("email_verified", False)
        has_website = lead_data.get("has_website", False)

        company_score = self._score_company_size(company)
        position_score = self._score_position(position)
        call_history_score = self._score_call_history(call_count, last_disposition)
        industry_score = self._score_industry(industry)
        engagement_score = self._score_engagement(email_verified, has_website)

        total = (
            company_score * self.WEIGHTS["company_size"]
            + position_score * self.WEIGHTS["position"]
            + call_history_score * self.WEIGHTS["call_history"]
            + industry_score * self.WEIGHTS["industry_fit"]
            + engagement_score * self.WEIGHTS["engagement"]
        )

        return round(total * 100, 2)

    def _score_company_size(self, company: Optional[str]) -> float:
        if not company:
            return 0.3
        company_lower = company.lower()
        size_indicators = {
            "enterprise": 1.0,
            "inc": 0.9,
            "corp": 0.9,
            "ltd": 0.8,
            "llc": 0.7,
            "gmbh": 0.7,
            "startup": 0.5,
        }
        for keyword, score in size_indicators.items():
            if keyword in company_lower:
                return score
        return 0.6

    def _score_position(self, position: Optional[str]) -> float:
        if not position:
            return 0.2
        position_lower = position.lower()
        for keyword, score in self.POSITION_SCORES.items():
            if keyword in position_lower:
                return score
        return 0.3

    def _score_call_history(self, call_count: int, last_disposition: Optional[str]) -> float:
        if call_count == 0:
            return 0.5

        disposition_scores: dict[str, float] = {
            "interested": 0.9,
            "qualified": 0.9,
            "appointment_set": 0.85,
            "sale_made": 1.0,
            "follow_up_required": 0.7,
            "call_back": 0.7,
            "completed": 0.5,
            "voicemail": 0.4,
            "no_answer": 0.3,
            "busy": 0.3,
            "not_interested": 0.1,
            "wrong_number": 0.05,
            "dnc": 0.0,
        }

        last_score = disposition_scores.get(last_disposition or "", 0.5)
        attempt_penalty = max(0, 1.0 - (call_count - 1) * 0.15)
        return last_score * attempt_penalty

    def _score_industry(self, industry: Optional[str]) -> float:
        if not industry:
            return 0.3
        industry_lower = industry.lower()
        for keyword, score in self.INDUSTRY_SCORES.items():
            if keyword in industry_lower:
                return score
        return 0.4

    def _score_engagement(self, email_verified: bool, has_website: bool) -> float:
        score = 0.0
        if email_verified:
            score += 0.6
        if has_website:
            score += 0.4
        return score
