# /user:implement

Begin implementing a user story or task.

## What This Command Does

- Reads the story and acceptance criteria
- Breaks the work into small, independently commitable steps
- Follows the TDD workflow from `skills/implementation/README.md`
- Ensures code quality rules from `rules/code_quality.md` are applied

## Instructions for Claude

When this command is invoked:

1. Ask: *"Which story or task are you implementing? (provide story ID or description)"*
2. Confirm the acceptance criteria are clear — if not, clarify before writing code.
3. Identify the files that need to change.
4. Write a failing test first (TDD):
   - Place in `tests/unit/` or `tests/integration/` as appropriate
   - Use the naming convention `test_<what>_<condition>_<expected_result>`
5. Implement the minimum code to make the test pass.
6. Refactor for clarity and adherence to `rules/code_quality.md`.
7. Run the full test suite: `bash scripts/run_tests.sh --unit`
8. Run the linter: `bash scripts/lint.sh`
9. Prepare a conventional commit message for the user to review.

## Commit Message Format

```
feat(<scope>): <short description>

<optional body>

Closes #<ticket-id>
```

## Definition of Done (check before finishing)

- [ ] Tests written and passing
- [ ] Linter passes with zero warnings
- [ ] Type hints on all new public functions
- [ ] Docstrings on all new public classes and functions
- [ ] Relevant docs updated (README, CHANGELOG, etc.)
