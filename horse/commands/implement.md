# /horse:implement

Begin implementing a user story or task.

## What This Command Does

- Reads the story and acceptance criteria
- Breaks the work into small, independently commitable steps
- Follows the TDD workflow from `${CLAUDE_PLUGIN_ROOT}/skills/implementation/SKILL.md`
- Ensures code quality rules from `${CLAUDE_PLUGIN_ROOT}/rules/code_quality.md` are applied

## Instructions for Claude

When this command is invoked:

1. Ask: *"Which story or task are you implementing? (provide story ID or description)"*
2. Look up the story:
   - Check `horse.config.md` for `requirements_format`.
   - **monolith**: find the story in `requirements_doc.md`.
   - **per-story**: find the story file in the configured `requirements_stories_dir` (default: `docs/requirements/stories/`) matching the given ID.
3. Confirm the acceptance criteria are clear — if not, clarify before writing code.
4. Identify the files that need to change.
5. Write a failing test first (TDD):
   - Place in `tests/unit/` or `tests/integration/` as appropriate
   - Use the naming convention `test_<what>_<condition>_<expected_result>`
6. Implement the minimum code to make the test pass.
7. Refactor for clarity and adherence to `${CLAUDE_PLUGIN_ROOT}/rules/code_quality.md`.
8. Run the full test suite: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.sh --unit`
9. Run the linter: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/lint.sh`
10. Prepare a conventional commit message for the user to review.

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
