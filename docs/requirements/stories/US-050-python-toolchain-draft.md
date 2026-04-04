---
id: US-050
title: Python toolchain
status: draft
priority: Must Have
story_points: 3
section: "3.7 Dual Toolchain Support"
---

# US-050 — Python toolchain

> As a **Python developer**, I want **skills and scripts to fully support the Python ecosystem** so that **I can use venv, pytest, ruff, and mypy seamlessly**.

## Acceptance Criteria

```gherkin
Given .claude/config.json has language=python
When  I run /horse-sense:implement
Then  it activates venv, writes pytest tests, runs ruff, runs mypy
And   commit messages follow Conventional Commits
And   CI workflow uses Python-specific steps
```
