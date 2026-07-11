from __future__ import annotations

from pathlib import Path

from cryptography.fernet import Fernet


class ConfigEncryptor:
    @staticmethod
    def generate_key() -> bytes:
        return Fernet.generate_key()

    @staticmethod
    def encrypt(plaintext: str, key: bytes) -> str:
        f = Fernet(key)
        return f.encrypt(plaintext.encode("utf-8")).decode("utf-8")

    @staticmethod
    def decrypt(ciphertext: str, key: bytes) -> str:
        f = Fernet(key)
        return f.decrypt(ciphertext.encode("utf-8")).decode("utf-8")

    @staticmethod
    def load_key(path: str | Path) -> bytes:
        return Path(path).read_bytes()

    @staticmethod
    def save_key(key: bytes, path: str | Path) -> None:
        Path(path).write_bytes(key)
