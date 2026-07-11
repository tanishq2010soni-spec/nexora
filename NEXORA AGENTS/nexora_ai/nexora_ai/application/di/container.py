from __future__ import annotations

from typing import Any, TypeVar

T = TypeVar("T")


class DIContainer:
    def __init__(self, parent: DIContainer | None = None) -> None:
        self._factories: dict[type, Any] = {}
        self._singletons: dict[type, Any] = {}
        self._instances: dict[type, Any] = {}
        self._parent = parent

    def register(
        self,
        interface: type[T],
        implementation: type[T],
        singleton: bool = True,
    ) -> None:

        def factory(container: DIContainer) -> T:
            return container._create_instance(implementation)

        self._factories[interface] = (factory, singleton)
        self._instances.pop(interface, None)
        self._singletons.pop(interface, None)

    def register_instance(self, interface: type[T], instance: T) -> None:
        self._instances[interface] = instance
        self._factories.pop(interface, None)

    def resolve(self, interface: type[T]) -> T:
        if interface in self._instances:
            return self._instances[interface]
        if interface in self._singletons:
            return self._singletons[interface]
        if interface in self._factories:
            factory, singleton = self._factories[interface]
            instance = factory(self)
            if singleton:
                self._singletons[interface] = instance
            return instance
        if self._parent is not None:
            return self._parent.resolve(interface)
        raise KeyError(f"No registration found for {interface.__name__}")

    def create_scope(self) -> DIContainer:
        return DIContainer(parent=self)

    def dispose(self) -> None:
        self._factories.clear()
        self._singletons.clear()
        self._instances.clear()
        self._parent = None

    def _create_instance(self, implementation: type[T]) -> T:
        try:
            init = implementation.__init__
            import inspect

            sig = inspect.signature(init)
            params = list(sig.parameters.values())[1:]
            kwargs: dict[str, Any] = {}
            for param in params:
                if param.annotation is not param.empty:
                    if param.annotation in (str, int, float, bool, bytes):
                        continue
                    try:
                        kwargs[param.name] = self.resolve(param.annotation)
                    except KeyError:
                        if param.default is not param.empty:
                            continue
                        raise
                elif param.default is not param.empty:
                    continue
            return implementation(**kwargs)
        except Exception:
            return implementation()
