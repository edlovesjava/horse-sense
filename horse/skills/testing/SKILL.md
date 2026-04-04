---
name: testing
description: Create and run tests following the test pyramid strategy
---

# Skill: Testing

## Purpose

Validate that the software behaves correctly, reliably, and securely at every level — from individual functions to full user journeys. A good test suite is a safety net that enables confident, frequent releases.

## The Test Pyramid

```
        /‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\
       /   E2E (few)      \     ← Slow, brittle, high-value journeys
      /‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\
     /  Integration (some)  \   ← Service/DB boundaries
    /‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\
   /   Unit Tests (many)      \  ← Fast, isolated, lots of them
  /‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\
```

## Configuration

Before starting, read the project config from `.claude/config.json` (if it exists). If absent, auto-detect:

- **Python project** — `pyproject.toml` or `requirements.txt` present
- **TypeScript project** — `package.json` present

Use these config values throughout this skill:

| Variable | Python default | TypeScript default |
|---|---|---|
| `testRunner` | `pytest` | `vitest` |
| `srcDir` | `src` | `src` |
| `testDir` | `tests` | `tests` |
| `coverageThreshold` | `80` | `80` |

See `${CLAUDE_PLUGIN_ROOT}/schemas/config.schema.json` for the full schema.

## Unit Testing

### Goal

Verify individual functions, methods, or classes in complete isolation.

### Setup

**Python:**

```bash
source .venv/bin/activate
pip install pytest pytest-cov
```

**TypeScript:**

```bash
npm install --save-dev vitest @vitest/coverage-v8
```

### Writing a Unit Test

```python
# tests/unit/test_calculator.py
import pytest
from src.calculator import add, divide


def test_add_two_positive_numbers():
    assert add(2, 3) == 5


def test_add_negative_and_positive():
    assert add(-1, 1) == 0


def test_divide_by_zero_raises():
    with pytest.raises(ZeroDivisionError):
        divide(10, 0)


class TestCalculator:
    def test_add_floats(self):
        result = add(1.1, 2.2)
        assert result == pytest.approx(3.3)
```

### Running Unit Tests

**Python:**

```bash
python -m pytest tests/unit/ -v
python -m pytest tests/unit/ -v --tb=short   # shorter tracebacks
python -m pytest tests/unit/ -x              # stop on first failure
```

**TypeScript:**

```bash
npx vitest run tests/unit/
npx vitest run tests/unit/ --reporter=verbose
```

## Integration Testing

### Goal

Verify that components work together correctly — typically testing a service against a real (or containerized) database or external API.

### Using pytest-fixtures for Setup/Teardown

```python
# tests/integration/conftest.py
import pytest
from src.database import create_engine, Session

@pytest.fixture(scope="session")
def db_engine():
    engine = create_engine("sqlite:///test.db")
    yield engine
    engine.dispose()

@pytest.fixture
def db_session(db_engine):
    session = Session(db_engine)
    yield session
    session.rollback()
    session.close()
```

### Running Integration Tests

**Python:**

```bash
python -m pytest tests/integration/ -v
```

**TypeScript:**

```bash
npx vitest run tests/integration/
```

## End-to-End Testing

### Goal

Validate complete user journeys against a running application instance.

### Example (using `httpx`)

```python
# tests/e2e/test_auth_flow.py
import httpx

BASE_URL = "http://localhost:8000"

def test_user_registration_and_login():
    client = httpx.Client(base_url=BASE_URL)

    # Register
    resp = client.post("/auth/register", json={
        "email": "test@example.com",
        "password": "SecurePass123!"
    })
    assert resp.status_code == 201

    # Login
    resp = client.post("/auth/login", json={
        "email": "test@example.com",
        "password": "SecurePass123!"
    })
    assert resp.status_code == 200
    assert "access_token" in resp.json()
```

## Coverage

**Python:**

```bash
python -m pytest tests/ --cov=src --cov-report=term-missing --cov-report=html
open htmlcov/index.html
```

**TypeScript:**

```bash
npx vitest run --coverage
open coverage/index.html
```

### Coverage Targets

Use `coverageThreshold` from `.claude/config.json` (default: 80).

- New business logic: ≥ coverageThreshold% line coverage
- Critical paths (auth, payments, data integrity): ≥ 90%
- Auto-generated or trivial code: exempt

## Test Doubles (Mocks, Stubs, Fakes)

```python
from unittest.mock import patch, MagicMock

def test_send_email_called_on_registration(mock_email_service):
    with patch("src.services.email.send") as mock_send:
        register_user("alice@example.com", "pass123")
        mock_send.assert_called_once_with(
            to="alice@example.com",
            subject="Welcome!"
        )
```

## Parameterized Tests

```python
@pytest.mark.parametrize("email,valid", [
    ("user@example.com", True),
    ("user@", False),
    ("@example.com", False),
    ("notanemail", False),
])
def test_email_validation(email, valid):
    assert validate_email(email) == valid
```

## Security Testing

**Python:**

```bash
pip audit
bandit -r src/ -ll
```

**TypeScript:**

```bash
npm audit
```

## Continuous Integration

Add this to your CI workflow:

**Python:**

```yaml
- name: Run tests
  run: |
    source .venv/bin/activate
    python -m pytest tests/ --cov=src --cov-fail-under=${coverageThreshold}
    pip audit
```

**TypeScript:**

```yaml
- name: Run tests
  run: |
    npx vitest run --coverage --coverage.thresholds.lines=${coverageThreshold}
    npm audit
```
