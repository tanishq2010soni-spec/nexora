# Contributing to Nexora AI

## Getting Started

1. **Fork** the repository
2. **Clone** your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/nexora-ai.git
   cd nexora-ai
   ```
3. **Install** in development mode:
   ```bash
   pip install -e ".[dev,all]"
   ```
4. **Run tests** to verify:
   ```bash
   pytest
   ```

## Development Workflow

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make your changes
3. Run the test suite: `pytest`
4. Run linting: `ruff check .`
5. Run type checking: `mypy nexora_ai`
6. Commit with descriptive messages
7. Push and open a pull request

## Code Style

- **Python**: 3.12+
- **Formatter**: `ruff format`
- **Linter**: `ruff check`
- **Type checker**: `mypy --strict`
- **Line length**: 100 characters
- **Quotes**: Double quotes for strings
- **Naming**: `snake_case` for functions/variables, `PascalCase` for classes, `UPPER_CASE` for constants

## Pre-commit Hooks

```bash
pip install pre-commit
pre-commit install
```

The pre-commit config runs `ruff`, `mypy`, and `pytest` on staged changes.

## Testing

- **Unit tests**: `pytest -m unit`
- **Integration tests**: `pytest -m integration`
- **Contract tests**: `pytest -m contract`
- **All tests**: `pytest`
- **Coverage**: `pytest --cov=nexora_ai --cov-report=term-missing`

Write tests for all new code. Use the mocking framework in `tests/mocks/`.

## Pull Request Guidelines

1. Keep PRs focused — one feature/fix per PR
2. Update documentation if you change public API
3. Add tests for new functionality
4. Ensure CI passes
5. Reference related issues

## Project Structure

```
nexora_ai/
├── application/
│   ├── services/          # Tool registry, automation, plugin, retry
│   └── use_cases/         # Conversation, planning, memory
├── domain/
│   ├── entities/          # Domain models
│   ├── enums/             # Type definitions
│   ├── events/            # Domain events
│   ├── exceptions/        # Domain exceptions
│   └── interfaces/        # Contracts (ProviderInterface)
└── infrastructure/
    ├── providers/         # LLM adapters
    ├── memory/            # Memory backends
    ├── event_bus/         # Async pub/sub
    ├── config/            # Config management
    ├── logging/           # JSON logging
    ├── tools/             # Tool registry
    ├── security/          # Permission manager
    ├── automation/        # Workflow engine
    ├── runtime/           # AI runtime
    ├── plugin_sdk/        # Plugin system
    └── screen/            # Desktop automation
```

## Issue Reporting

- **Bug reports**: Include Python version, OS, error traceback, and steps to reproduce
- **Feature requests**: Describe the use case and desired behavior
- **Questions**: Use GitHub Discussions

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
