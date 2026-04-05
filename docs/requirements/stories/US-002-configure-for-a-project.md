---
id: US-002
title: Configure for a project
status: draft
priority: Must Have
story_points: 5
section: "3.1 Plugin Installation & Configuration"
---

# US-002 — Configure for a project

> As a **developer**, I want to **create a `.claude/config.json` with my project's language, framework, and tooling** so that **skills adapt their guidance to my specific project**.

## Acceptance Criteria

```gherkin
Given horse-sense is installed
When  I create .claude/config.json with {"language": "python", "testRunner": "pytest", ...}
Then  skills reference pytest commands instead of generic test commands
And   implementation skills use Python conventions (venv, ruff, mypy)
And   rules for **/*.py are active

Given horse-sense is installed
When  I create .claude/config.json with {"language": "typescript", "testRunner": "vitest", ...}
Then  skills reference vitest commands instead of generic test commands
And   implementation skills use TypeScript conventions (npm, eslint, tsc)
And   rules for **/*.ts are active

Given horse-sense is installed and no .claude/config.json exists
When  I invoke a skill
Then  it auto-detects language from pyproject.toml or package.json presence
And   uses sensible defaults for all config values
```

## Config schema

| Variable | Type | Default | Description |
|---|---|---|---|
| `language` | string | auto-detect | `"python"` or `"typescript"` |
| `framework` | string | none | Framework name (e.g., `"fastapi"`, `"express"`) |
| `testRunner` | string | per-language default | Test runner command (e.g., `"pytest"`, `"vitest"`) |
| `linter` | string | per-language default | Linter (e.g., `"ruff"`, `"eslint"`) |
| `typeChecker` | string | per-language default | Type checker (e.g., `"mypy"`, `"tsc"`) |
| `formatter` | string | per-language default | Formatter (e.g., `"ruff format"`, `"prettier"`) |
| `srcDir` | string | `"src"` | Source code directory |
| `testDir` | string | `"tests"` | Test directory |
| `packageManager` | string | per-language default | Package manager (e.g., `"pip"`, `"npm"`) |
| `coverageThreshold` | number | `80` | Minimum test coverage percentage |
| `branchingStrategy` | string | `"github-flow"` | Git branching model |
| `pythonVersion` | string | `"3.11"` | Python version (if language=python) |
| `nodeVersion` | string | `"20"` | Node.js version (if language=typescript) |
