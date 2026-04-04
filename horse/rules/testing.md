# Rule: Testing Standards

These rules define the minimum testing requirements for all code in this repository.

## Mandatory Testing Requirements

1. **No feature is complete without tests** — acceptance criteria must include testable assertions.
2. **No bug is fixed without a regression test** — the fix must be accompanied by a test that would have caught the bug.
3. **Tests must pass before merge** — CI enforces this; no exceptions.
4. **Coverage threshold** — new code must meet the project's coverage floor (default: 80%).

## Test Naming Convention

Tests must be named to describe the scenario being tested:

```python
# Pattern: test_<what>_<condition>_<expected_result>
def test_login_with_invalid_password_returns_401():
    ...

def test_create_user_with_duplicate_email_raises_error():
    ...

def test_get_order_when_order_not_found_returns_none():
    ...
```

## Test Structure (Arrange / Act / Assert)

```python
def test_discount_applied_correctly():
    # Arrange
    price = 100.0
    discount_rate = 0.2

    # Act
    final_price = calculate_discount(price, discount_rate)

    # Assert
    assert final_price == 80.0
```

## Test Independence

- Each test must be independent — no shared mutable state between tests
- Use `pytest` fixtures for setup and teardown
- Never rely on test execution order
- Clean up all side effects (database rows, files, env vars) after each test

## Mocking Policy

Mock external dependencies (network, filesystem, databases) in unit tests:

```python
# Mock the external email service, not the business logic
@patch("src.services.email_service.send_email")
def test_registration_sends_welcome_email(mock_send):
    register_user("alice@example.com", "pass123")
    mock_send.assert_called_once()
```

Do **not** mock in integration tests — those tests exist to verify real interactions.

## Test Categories and Markers

Use `pytest` markers to categorize tests:

```python
import pytest

@pytest.mark.unit
def test_validate_email_rejects_missing_at():
    ...

@pytest.mark.integration
def test_user_saved_to_database():
    ...

@pytest.mark.e2e
def test_full_registration_flow():
    ...

@pytest.mark.slow
def test_bulk_import_1000_records():
    ...
```

Configure in `pyproject.toml`:

```toml
[tool.pytest.ini_options]
markers = [
    "unit: fast, isolated unit tests",
    "integration: tests requiring external services",
    "e2e: end-to-end user journey tests",
    "slow: tests taking more than 1 second",
]
```

Run specific categories:

```bash
python -m pytest -m unit          # only unit tests
python -m pytest -m "not slow"    # skip slow tests
```

## Test Data

- Use factories or fixtures, not hardcoded strings scattered across tests
- Use realistic but fake data (e.g., `faker` library)
- Never use production data in tests

```python
import pytest
from faker import Faker

fake = Faker()

@pytest.fixture
def sample_user():
    return {
        "email": fake.email(),
        "name": fake.name(),
        "password": fake.password(length=12),
    }
```

## What NOT to Test

- Third-party library internals (trust the library's own tests)
- Trivial getters/setters with no logic
- Generated code (migrations, serializers auto-generated from schemas)

## CI Enforcement

The CI pipeline must:

1. Run the full test suite
2. Fail if coverage drops below the threshold
3. Report coverage metrics on every PR
4. Run `pip audit` for security vulnerabilities
