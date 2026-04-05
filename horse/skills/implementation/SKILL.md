---
name: implementation
description: Implement features using TDD with language-appropriate tooling
---

# Skill: Implementation

## Purpose

Write correct, readable, and maintainable code that satisfies the acceptance criteria and fits the established architecture. This skill covers the day-to-day development workflow from picking up a ticket to opening a pull request.

## Configuration

Before starting, read the project config from `.claude/config.json` (if it exists). If absent, auto-detect:

- **Python project** — `pyproject.toml` or `requirements.txt` present
- **TypeScript project** — `package.json` present

Use these config values throughout this skill:

| Variable | Python default | TypeScript default |
|---|---|---|
| `testRunner` | `pytest` | `vitest` |
| `linter` | `ruff check` | `eslint` |
| `typeChecker` | `mypy` | `tsc --noEmit` |
| `formatter` | `ruff format` | `prettier --write` |
| `srcDir` | `src` | `src` |
| `testDir` | `tests` | `tests` |
| `coverageThreshold` | `80` | `80` |

See `${CLAUDE_PLUGIN_ROOT}/schemas/config.schema.json` for the full schema.

## Development Workflow

```
Read ticket → Create branch → Write failing test → Implement → Refactor → PR
```

### Step 1: Understand Before You Code

Before touching any file:

- Read the user story and acceptance criteria in full
- Check the relevant ADRs in `docs/architecture/adr/`
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

For Python projects:

```bash
source .venv/bin/activate
```

For TypeScript projects:

```bash
npm install   # if node_modules/ is missing
```

### Step 4: Write Tests First (TDD)

Write a failing test that documents the expected behavior.

**Python** (`pytest`):

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

**TypeScript** (`vitest`):

```typescript
import { describe, it, expect } from 'vitest'
import { User } from '../src/user'

describe('password reset', () => {
  it('generates a 64-char token', () => {
    const user = new User('alice@example.com')
    const token = user.requestPasswordReset()
    expect(token).toBeDefined()
    expect(token).toHaveLength(64)
  })
})
```

Run it to confirm it fails:

```bash
# Python
python -m pytest ${testDir}/unit/test_user.py -x -v

# TypeScript
npx vitest run ${testDir}/unit/user.test.ts
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
# Python
python -m pytest ${testDir}/ -x --tb=short

# TypeScript
npx vitest run
```

Fix any failures before moving on.

### Step 7: Check Code Quality

Use the tools from `.claude/config.json` (or defaults):

```bash
# Python
ruff check . --fix && ruff format .
mypy ${srcDir}/
pip audit

# TypeScript
npx eslint ${srcDir}/ --fix
npx prettier --write ${srcDir}/
npx tsc --noEmit
npm audit
```

### Step 8: Update Sprint Plan Status

Before committing, update the active sprint plan so its status reflects the work you just completed:

1. Locate the current sprint plan. Default path: `docs/plans/sprints/sprint_<N>_plan.md`. If your project stores plans elsewhere, check `horse.config.md` or ask the user.
2. Find the task row(s) for the work you completed (match by task ID or title).
3. Change the status cell to `✅ Done`.
4. If the task was in progress and is now blocked, use `🚫 Blocked` instead and add a note under Risks & Blockers.
5. Stage the sprint plan edit alongside your code so the status update lands in the **same commit** as the work.

Status conventions (from the sprint plan template):

| Symbol | Meaning |
|---|---|
| `⬜` | To Do |
| `🔵` | In Progress |
| `🔍` | In Review |
| `✅` | Done |
| `🚫` | Blocked |

A task with green tests but a stale sprint plan is **not** done.

### Step 9: Commit

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git add .
git commit -m "feat(auth): add password reset token generation

Implements PasswordResetToken with 64-char hex value and 24-hour TTL.
Marks T-042 as Done in sprint_3_plan.md.
Closes #42"
```

### Step 10: Open a Pull Request

- Fill out the PR template completely
- Link the ticket
- Request review from the Reviewer agent or a team member
- Don't merge your own PR without review

## Project Layouts

### Python

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

### TypeScript

```
src/
├── models/
├── services/
├── routes/
└── index.ts
tests/
├── unit/
├── integration/
└── setup.ts
package.json
tsconfig.json
```

## Tooling Reference

### Python

| Tool | Purpose | Command |
|---|---|---|
| `ruff` | Linting + formatting | `ruff check . --fix && ruff format .` |
| `mypy` | Static type checking | `mypy src/` |
| `pytest` | Test runner | `python -m pytest tests/` |
| `pytest-cov` | Coverage | `pytest --cov=src --cov-report=term-missing` |
| `pip audit` | Dependency vulnerabilities | `pip audit` |

### TypeScript

| Tool | Purpose | Command |
|---|---|---|
| `eslint` | Linting | `npx eslint src/ --fix` |
| `prettier` | Formatting | `npx prettier --write src/` |
| `tsc` | Type checking | `npx tsc --noEmit` |
| `vitest` | Test runner | `npx vitest run` |
| `vitest --coverage` | Coverage | `npx vitest run --coverage` |
| `npm audit` | Dependency vulnerabilities | `npm audit` |
