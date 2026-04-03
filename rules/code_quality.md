# Rule: Code Quality

These rules apply to all code in this repository. They are enforced by automated tooling (ruff, mypy) and reinforced in code review.

## General Principles

1. **Clarity over cleverness** — write code for the next person to read, not the machine.
2. **Single responsibility** — every function, class, and module should do one thing well.
3. **Fail loudly** — prefer explicit errors over silent failures or wrong results.
4. **Avoid premature optimization** — first make it work, then make it fast (with data).

## Python-Specific Rules

### Naming
| Type | Convention | Example |
|---|---|---|
| Variables, functions | `snake_case` | `user_id`, `get_user()` |
| Classes | `PascalCase` | `UserRepository` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_RETRIES = 3` |
| Private | leading underscore | `_internal_helper()` |
| Modules | `snake_case` | `user_service.py` |

### Type Hints
All public functions and methods must have type hints:
```python
# Good
def get_user(user_id: int) -> User | None:
    ...

# Bad
def get_user(user_id):
    ...
```

### Docstrings (Google Style)
```python
def calculate_discount(price: float, rate: float) -> float:
    """Calculate the discounted price.

    Args:
        price: The original price in USD.
        rate: The discount rate as a decimal (0.0–1.0).

    Returns:
        The final price after applying the discount.

    Raises:
        ValueError: If rate is outside the range [0.0, 1.0].
    """
    if not 0.0 <= rate <= 1.0:
        raise ValueError(f"Rate must be between 0 and 1, got {rate}")
    return price * (1 - rate)
```

### Error Handling
```python
# Good — specific exception, informative message
try:
    user = db.get_user(user_id)
except DatabaseConnectionError as exc:
    logger.error("Database unavailable", extra={"user_id": user_id})
    raise ServiceUnavailableError("Cannot fetch user") from exc

# Bad — swallowing the exception
try:
    user = db.get_user(user_id)
except Exception:
    pass
```

### Imports
```python
# Order: stdlib → third-party → local (ruff handles this automatically)
import os
from pathlib import Path

import httpx
from pydantic import BaseModel

from src.models import User
```

### Magic Numbers
```python
# Bad
if len(password) < 8:
    ...

# Good
MIN_PASSWORD_LENGTH = 8
if len(password) < MIN_PASSWORD_LENGTH:
    ...
```

## File & Module Length Limits

| Unit | Soft Limit | Hard Limit |
|---|---|---|
| Function / method | 30 lines | 50 lines |
| Class | 200 lines | 300 lines |
| Module | 300 lines | 500 lines |

Exceeding these limits is a signal to refactor, not a hard block.

## Linting Configuration

Configure `ruff` in `pyproject.toml`:
```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "B", "SIM", "ANN"]
ignore = ["ANN101", "ANN102"]

[tool.mypy]
python_version = "3.11"
strict = true
ignore_missing_imports = true
```

Run the linter:
```bash
ruff check . --fix
ruff format .
mypy src/
```

## Code Review Standards

- **No new linter warnings** in submitted code
- **No TODO comments** without a linked ticket
- **No commented-out code** — delete it; git has history
- **No hardcoded secrets** — use environment variables
