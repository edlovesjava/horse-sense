---
name: implementation
description: Implement features using TDD with language-appropriate tooling
---

# Skill: Implementation

## Purpose
Write correct, readable, and maintainable code that satisfies the acceptance criteria and fits the established architecture. This skill covers the day-to-day development workflow from picking up a ticket to opening a pull request.

## Development Workflow

```
Read ticket → Create branch → Write failing test → Implement → Refactor → PR
```

### Step 1: Understand Before You Code

Before touching any file:
- Read the user story and acceptance criteria in full
- Check the relevant ADRs in `docs/adr/`
- Identify which files/modules will change
- Ask questions if anything is unclear — assumptions are expensive

### Step 2: Branch Naming

```bash
# Feature
git checkout -b feature/<ticket-id>-short-description

# Bug fix
git checkout -b fix/<ticket-id>-short-description

# Refactor
git checkout -b refactor/<ticket-id>-short-description

# Chore (deps, config, tooling)
git checkout -b chore/<ticket-id>-short-description
```

### Step 3: Activate the Environment

```bash
source .venv/bin/activate
```

### Step 4: Write Tests First (TDD)

Write a failing test that documents the expected behavior:
```python
def test_user_can_reset_password():
    # Given
    user = User(email="alice@example.com")
    # When
    token = user.request_password_reset()
    # Then
    assert token is not None
    assert len(token) == 64
```

Run it to confirm it fails:
```bash
python -m pytest tests/unit/test_user.py -x -v
```

### Step 5: Implement the Feature

Write the minimum code needed to make the test pass. Then iterate.

**Python code standards:**
- Use type hints on all function signatures
- Write docstrings for public functions and classes (Google style)
- Keep functions short (< 30 lines) and single-purpose
- Raise specific exceptions, not bare `Exception`

```python
import secrets
from dataclasses import dataclass
from datetime import datetime, timedelta


@dataclass
class PasswordResetToken:
    """Represents a time-limited password reset token."""

    value: str
    expires_at: datetime

    @classmethod
    def generate(cls, ttl_hours: int = 24) -> "PasswordResetToken":
        """Generate a cryptographically secure reset token."""
        return cls(
            value=secrets.token_hex(32),
            expires_at=datetime.utcnow() + timedelta(hours=ttl_hours),
        )

    def is_expired(self) -> bool:
        """Return True if this token has passed its expiry time."""
        return datetime.utcnow() > self.expires_at
```

### Step 6: Run All Tests

```bash
python -m pytest tests/ -x --tb=short
```

Fix any failures before moving on.

### Step 7: Check Code Quality

```bash
# Lint and auto-fix
ruff check . --fix
ruff format .

# Type checking
mypy src/

# Security scan
pip audit
```

### Step 8: Commit

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git add .
git commit -m "feat(auth): add password reset token generation

Implements PasswordResetToken with 64-char hex value and 24-hour TTL.
Closes #42"
```

### Step 9: Open a Pull Request

- Fill out the PR template completely
- Link the ticket
- Request review from the Reviewer agent or a team member
- Don't merge your own PR without review

## Python Project Layout

```
src/
├── <package>/
│   ├── __init__.py
│   ├── models/
│   ├── services/
│   ├── api/
│   └── utils/
tests/
├── unit/
├── integration/
└── conftest.py
requirements.txt
requirements-dev.txt
pyproject.toml
```

## Tooling Reference

| Tool | Purpose | Command |
|---|---|---|
| `ruff` | Linting + formatting | `ruff check . --fix && ruff format .` |
| `mypy` | Static type checking | `mypy src/` |
| `pytest` | Test runner | `python -m pytest tests/` |
| `pytest-cov` | Coverage | `pytest --cov=src --cov-report=term-missing` |
| `pip audit` | Dependency vulnerabilities | `pip audit` |
