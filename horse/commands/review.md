# /horse:review

Perform a thorough code review of the current changes or a specified file/PR.

## What This Command Does

- Reviews code changes against the project's coding standards (`${CLAUDE_PLUGIN_ROOT}/rules/code_quality.md`)
- Checks test coverage and quality (`${CLAUDE_PLUGIN_ROOT}/rules/testing.md`)
- Identifies security vulnerabilities
- Provides actionable feedback with severity labels

## Instructions for Claude

When this command is invoked:

1. Ask: *"What should I review? (current uncommitted changes / a specific file / a PR number)"*
2. If reviewing a PR number or URL: follow `${CLAUDE_PLUGIN_ROOT}/skills/pr-review/SKILL.md` to fetch the diff via `gh` CLI and post structured review comments.
3. If reviewing uncommitted changes: run `git diff` to see what has changed.
4. Apply the full review checklist from `${CLAUDE_PLUGIN_ROOT}/agents/reviewer.md`:
   - Correctness
   - Code quality
   - Testing
   - Security
   - Performance
   - Documentation
5. For each issue found, provide:
   - File and line number
   - Severity label: `[blocking]`, `[suggestion]`, or `[nit]`
   - Clear explanation of the problem
   - Concrete suggestion for improvement
6. Summarize the overall review at the top:
   - Overall assessment (approve / request changes / needs discussion)
   - Number of blocking issues, suggestions, and nits

## Severity Labels

- `[blocking]` — Must be fixed before merge
- `[suggestion]` — Should be addressed; code quality concern
- `[nit]` — Minor preference; author's discretion

## Security Checks

Always check for:

- Hardcoded secrets or credentials
- Unsanitized user input
- SQL injection risks
- Path traversal vulnerabilities
- Dependency vulnerabilities (suggest running `pip audit`)
