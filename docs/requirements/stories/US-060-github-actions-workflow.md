---
id: US-060
title: GitHub Actions workflow
status: done
priority: Should Have
story_points: 5
section: "3.8 CI/CD Integration"
---

# US-060 — GitHub Actions workflow

> As a **developer**, I want **a CI workflow template that enforces the plugin's quality standards** so that **PRs are automatically validated before review**.

## Acceptance Criteria

```gherkin
Given a project configured with horse-sense
When  a PR is opened
Then  CI runs: lint, type check, test suite with coverage, security audit
And   the PR is blocked if any check fails
And   coverage report is posted as a PR comment

Given the project uses Python
Then  CI runs: ruff check, mypy, pytest --cov, pip audit

Given the project uses TypeScript
Then  CI runs: eslint, tsc --noEmit, vitest --coverage, npm audit
```
