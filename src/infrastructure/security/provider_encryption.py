"""
Provider API key encryption utilities.
Uses Fernet symmetric encryption from the cryptography library.
"""
from typing import Optional

from src.config import settings
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)

_fernet = None


def _get_fernet():
    """Lazy-initialize Fernet cipher from PROVIDER_ENCRYPTION_KEY."""
    global _fernet
    if _fernet is not None:
        return _fernet
    key = settings.PROVIDER_ENCRYPTION_KEY
    if not key:
        logger.warning(
            "PROVIDER_ENCRYPTION_KEY not set — API keys stored in plaintext"
        )
        return None
    try:
        from cryptography.fernet import Fernet
        _fernet = Fernet(key.encode() if isinstance(key, str) else key)
        return _fernet
    except Exception as e:
        logger.error("Failed to initialize Fernet cipher", error=str(e))
        return None


def encrypt_api_key(plaintext: str) -> str:
    """
    Encrypt an API key for storage.
    Returns plaintext if no encryption key is configured.
    """
    if not plaintext:
        return plaintext
    fernet = _get_fernet()
    if fernet is None:
        return plaintext
    try:
        return fernet.encrypt(plaintext.encode()).decode()
    except Exception as e:
        logger.error("Failed to encrypt API key", error=str(e))
        return plaintext


def decrypt_api_key(ciphertext: str) -> str:
    """
    Decrypt an API key from storage.
    Returns ciphertext if no encryption key is configured (backward compat).
    """
    if not ciphertext:
        return ciphertext
    fernet = _get_fernet()
    if fernet is None:
        return ciphertext
    try:
        return fernet.decrypt(ciphertext.encode()).decode()
    except Exception:
        # Not encrypted (legacy data) — return as-is
        return ciphertext
