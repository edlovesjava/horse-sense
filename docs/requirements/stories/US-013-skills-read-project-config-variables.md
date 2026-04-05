---
id: US-013
title: Skills read project config variables
status: draft
priority: Must Have
story_points: 5
section: "3.2 Skills — Primary Behavior Definition"
---

# US-013 — Skills read project config variables

> As a **developer**, I want **skills to read project configuration variables** so that **guidance is tailored to my project's specific language, framework, paths, and tooling**.

## Acceptance Criteria

```gherkin
Given .claude/config.json contains {"language": "python", "srcDir": "src", "testRunner": "pytest"}
When  the implementation skill runs
Then  it references src/ as the source directory
And   it uses pytest commands for running tests
And   it uses Python-specific patterns (type hints, docstrings, venv)

Given .claude/config.json contains {"coverageThreshold": 90}
When  the testing skill runs
Then  it enforces 90% coverage instead of the default 80%

Given a config variable is missing from .claude/config.json
When  a skill reads it
Then  it falls back to a documented default value
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
