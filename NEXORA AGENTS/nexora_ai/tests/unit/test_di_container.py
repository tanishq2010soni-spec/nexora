from __future__ import annotations

from enum import Enum
from typing import Any

import pytest


class Scope(Enum):
    SINGLETON = "singleton"
    TRANSIENT = "transient"
    SCOPED = "scoped"


class DIContainer:

    def __init__(self) -> None:
        self._registrations: dict[str, dict[str, Any]] = {}
        self._singletons: dict[str, Any] = {}
        self._scoped: dict[str, dict[str, Any]] = {}

    def register(
        self,
        name: str,
        implementation: Any,
        scope: Scope = Scope.TRANSIENT,
        **kwargs: Any,
    ) -> None:
        self._registrations[name] = {
            "impl": implementation,
            "scope": scope,
            "kwargs": kwargs,
        }
        if scope == Scope.SINGLETON and name in self._singletons:
            del self._singletons[name]

    def resolve(self, name: str, scope_id: str | None = None) -> Any:
        if name not in self._registrations:
            raise KeyError(f"No registration found for '{name}'")

        reg = self._registrations[name]
        scope = reg["scope"]

        if scope == Scope.SINGLETON:
            if name not in self._singletons:
                self._singletons[name] = self._create_instance(reg)
            return self._singletons[name]

        elif scope == Scope.SCOPED:
            if scope_id is None:
                raise ValueError("scope_id is required for scoped resolution")
            if scope_id not in self._scoped:
                self._scoped[scope_id] = {}
            if name not in self._scoped[scope_id]:
                self._scoped[scope_id][name] = self._create_instance(reg)
            return self._scoped[scope_id][name]

        return self._create_instance(reg)

    def _create_instance(self, reg: dict[str, Any]) -> Any:
        impl = reg["impl"]
        kwargs = reg["kwargs"]
        if isinstance(impl, type):
            return impl(**kwargs)
        return impl

    def is_registered(self, name: str) -> bool:
        return name in self._registrations

    def clear(self) -> None:
        self._registrations.clear()
        self._singletons.clear()
        self._scoped.clear()


class DatabaseService:

    def __init__(self, url: str = "default://localhost") -> None:
        self.url = url


class LoggerService:

    def __init__(self, level: str = "INFO") -> None:
        self.level = level
        self.instance_id = id(self)


@pytest.fixture
def container() -> DIContainer:
    return DIContainer()


class TestDIContainer:

    async def test_register_and_resolve(self, container: DIContainer) -> None:
        container.register("db", DatabaseService, url="sqlite:///test.db")
        db = container.resolve("db")
        assert isinstance(db, DatabaseService)
        assert db.url == "sqlite:///test.db"

    async def test_singleton(self, container: DIContainer) -> None:
        container.register("logger", LoggerService, scope=Scope.SINGLETON, level="DEBUG")
        log1 = container.resolve("logger")
        log2 = container.resolve("logger")
        assert log1 is log2
        assert log1.level == "DEBUG"

    async def test_transient(self, container: DIContainer) -> None:
        container.register("logger", LoggerService, scope=Scope.TRANSIENT)
        log1 = container.resolve("logger")
        log2 = container.resolve("logger")
        assert log1 is not log2
        assert log1.instance_id != log2.instance_id

    async def test_scope(self, container: DIContainer) -> None:
        container.register("service", LoggerService, scope=Scope.SCOPED, level="INFO")
        s1 = container.resolve("service", scope_id="request1")
        s2 = container.resolve("service", scope_id="request1")
        assert s1 is s2

        s3 = container.resolve("service", scope_id="request2")
        assert s1 is not s3

    async def test_unregistered_raises_error(self, container: DIContainer) -> None:
        with pytest.raises(KeyError, match="No registration found"):
            container.resolve("nonexistent")
