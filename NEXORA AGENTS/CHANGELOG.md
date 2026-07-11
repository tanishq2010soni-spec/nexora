# NEXORA AGENTS - Changelog

## [0.2.0] - 2026-07-01 - Production Stabilization

### Fixed
- **calling_agent**: UUID serialization in JWT token generation (`auth.py`)
- **calling_agent**: Unit tests now test real `LeadScorer` implementation instead of mocks
- **calling_agent**: Filled 7 empty stub tests in campaign engine tests
- **calling_agent**: Integration test assertions (401 vs 403 status codes)
- **calling_agent**: Python 3.14 asyncio compatibility in tests
- **whatsapp_agent**: Async test marking (class-level `pytestmark`)
- **whatsapp_agent**: E2E test fallback that masked failures
- **whatsapp_agent**: E2E test that accepted 404 for existing conversation
- **personal_ai**: Syntax error in `desktop_controller.py` (`type()` dict)
- **nexora_ai**: Build backend path in `pyproject.toml`

### Added
- **personal_ai**: Backend test suite (46 tests)
  - `test_permissions_manager.py` - 15 tests
  - `test_settings_manager.py` - 14 tests
  - `test_app_settings.py` - 17 tests
- **All projects**: Coverage HTML reports
- **All projects**: Security audit report
- **All projects**: Performance report
- **All projects**: Dependency report
- **All projects**: Release checklist
- **All projects**: Project health dashboard

### Changed
- **nexora_ai**: Build backend from `setuptools.backends._legacy` to `setuptools.build_meta`
- **calling_agent**: Pinned `bcrypt<4.1` for passlib compatibility
- **All projects**: Installed `webrtcvad` for voice pipeline

### Security
- Identified 3 CRITICAL, 6 HIGH, 8 MEDIUM, 4 LOW security issues
- See `SECURITY_REPORT.md` for details

### Testing
- Total tests: 619 (all passing)
- Coverage: 51% average (target: 90%)
- See `TEST_REPORT.md` for details

---

## [0.1.0] - 2026-06-15 - Initial Release

### Added
- nexora_ai: AI framework with 118 tests
- calling_agent: Voice calling agent with 225 tests
- whatsapp_agent: WhatsApp agent with 230 tests
- personal_ai: Personal assistant (backend only)
