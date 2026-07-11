from __future__ import annotations

import logging

from langdetect import DetectorFactory, detect, lang_detect_exception

from backend.domain.enums import LanguageCode

DetectorFactory.seed = 42

logger = logging.getLogger(__name__)


class LanguageDetector:
    _LANG_MAP: dict[str, LanguageCode] = {
        "en": LanguageCode.en,
        "es": LanguageCode.es,
        "fr": LanguageCode.fr,
        "de": LanguageCode.de,
        "it": LanguageCode.it,
        "pt": LanguageCode.pt,
        "hi": LanguageCode.hi,
        "ar": LanguageCode.ar,
        "zh": LanguageCode.zh,
        "zh-cn": LanguageCode.zh,
        "zh-tw": LanguageCode.zh,
        "ja": LanguageCode.ja,
        "ko": LanguageCode.ko,
        "ru": LanguageCode.ru,
        "nl": LanguageCode.nl,
        "tr": LanguageCode.tr,
        "vi": LanguageCode.vi,
        "th": LanguageCode.th,
    }

    async def detect(self, text: str) -> LanguageCode:
        if not text or not text.strip():
            return LanguageCode.unknown

        try:
            detected_lang = detect(text)
            code = self._LANG_MAP.get(detected_lang, LanguageCode.unknown)
            logger.debug("Detected language '%s' for text (len=%d)", code.value, len(text))
            return code
        except lang_detect_exception.LangDetectException as exc:
            logger.warning("Language detection failed: %s", exc)
            return LanguageCode.unknown
        except Exception as exc:
            logger.error("Unexpected error in language detection: %s", exc)
            return LanguageCode.unknown

    async def detect_batch(self, texts: list[str]) -> list[LanguageCode]:
        results: list[LanguageCode] = []
        for text in texts:
            code = await self.detect(text)
            results.append(code)
        return results
