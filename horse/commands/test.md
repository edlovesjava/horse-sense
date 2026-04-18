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
2. **Entry gate — what test scope is needed at this decomposition level?** Unit tests from TDD in **I** cover the task level. Evaluate what's needed at the current scope:
   - **Task level**: TDD unit tests from implementation may already be sufficient.
   - **Story level**: integration tests across components within the story.
   - **Epic level**: end-to-end tests across stories, non-functional tests (performance, security).
   - If coverage is already sufficient for this scope level and no integration boundaries exist, tell the user: *"Unit test coverage from implementation looks solid for this scope. Do you want to add integration or e2e tests at a higher level, or move on to review?"*
3. Review the existing tests for the relevant module.
4. Identify untested code paths using coverage data (if available).
5. Categorize the needed tests:
   - **Unit**: isolated functions/classes → `tests/unit/`
   - **Integration**: component interactions → `tests/integration/`
   - **E2E**: user journeys → `tests/e2e/`
6. Write the tests following naming conventions from `${CLAUDE_PLUGIN_ROOT}/rules/testing.md`.
7. Use pytest fixtures for shared setup; don't repeat setup code.
8. Run the tests: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.sh`
9. If coverage is below 80%, identify the gaps and fill them.

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
