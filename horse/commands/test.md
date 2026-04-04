# /horse:test

Create and run tests for a feature or module.

## What This Command Does

- Identifies untested code paths
- Creates unit, integration, or e2e tests as appropriate
- Runs the test suite with coverage reporting
- Enforces the quality gates from `${CLAUDE_PLUGIN_ROOT}/rules/testing.md`

## Instructions for Claude

When this command is invoked:

1. Ask: *"What do you want to test? (feature name, module path, or story ID)"*
2. Review the existing tests for the relevant module.
3. Identify untested code paths using coverage data (if available).
4. Categorize the needed tests:
   - **Unit**: isolated functions/classes → `tests/unit/`
   - **Integration**: component interactions → `tests/integration/`
   - **E2E**: user journeys → `tests/e2e/`
5. Write the tests following naming conventions from `${CLAUDE_PLUGIN_ROOT}/rules/testing.md`.
6. Use pytest fixtures for shared setup; don't repeat setup code.
7. Run the tests: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.sh`
8. If coverage is below 80%, identify the gaps and fill them.

## Test Template

```python
# tests/unit/test_<module>.py
import pytest
from src.<module> import <Class or function>


class Test<Feature>:
    """Tests for <feature description>."""

    def test_<action>_<condition>_<expected>(self):
        # Arrange
        ...
        # Act
        result = ...
        # Assert
        assert result == expected_value

    def test_<action>_raises_on_<invalid_condition>(self):
        with pytest.raises(<ExceptionType>):
            ...
```

## Running Tests

```bash
# All tests
bash ${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.sh --all

# Unit tests only (fast feedback)
bash ${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.sh --unit

# Integration tests
bash ${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.sh --integration
```
