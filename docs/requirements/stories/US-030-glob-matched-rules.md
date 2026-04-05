---
id: US-030
title: Glob-matched rules
status: draft
priority: Must Have
story_points: 3
section: "3.5 Rules — Contextual Standards"
---

# US-030 — Glob-matched rules

> As a **developer**, I want **coding standards to be automatically injected based on the files I'm editing** so that **Claude follows the right conventions without me having to specify them**.

## Acceptance Criteria

```gherkin
Given rules/code_quality.md has glob frontmatter for **/*.py
When  I ask Claude to edit a Python file
Then  the Python code quality rules are loaded into context
And   Claude follows naming conventions, type hint requirements, and line length limits

Given rules/typescript_quality.md has glob frontmatter for **/*.ts
When  I ask Claude to edit a TypeScript file
Then  the TypeScript quality rules are loaded into context
And   Claude follows TypeScript naming, strict mode, and ESLint conventions

Given I'm editing a file that matches no rule globs
When  Claude generates code
Then  it uses general best practices without language-specific enforcement
```
