from __future__ import annotations

from backend.infrastructure.phone.base import PhoneProvider


class PhoneProviderFactory:
    @staticmethod
    def create(provider: str, config: dict) -> PhoneProvider:
        if provider == "twilio":
            from backend.infrastructure.phone.twilio.provider import TwilioProvider

            return TwilioProvider(**config)
        if provider == "exotel":
            from backend.infrastructure.phone.exotel.provider import ExotelProvider

            return ExotelProvider(**config)
        if provider == "plivo":
            from backend.infrastructure.phone.plivo.provider import PlivoProvider

            return PlivoProvider(**config)
        if provider == "sip":
            from backend.infrastructure.phone.sip.provider import SIPProvider

            return SIPProvider(**config)
        raise ValueError(f"Unknown phone provider: {provider}")
