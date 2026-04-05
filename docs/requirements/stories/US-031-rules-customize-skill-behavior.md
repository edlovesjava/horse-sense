---
id: US-031
title: Rules customize skill behavior
status: draft
priority: Must Have
story_points: 3
section: "3.5 Rules — Contextual Standards"
---

# US-031 — Rules customize skill behavior

> As a **developer**, I want **rules to refine how skills operate for my language and standards** so that **the same skill works correctly across Python and TypeScript projects**.

## Acceptance Criteria

```gherkin
Given the implementation skill is active and rules/code_quality.md is loaded
When  Claude writes Python code
Then  it uses snake_case, Google-style docstrings, type hints on all public functions
And   it keeps functions under 30 lines

Given the implementation skill is active and rules/typescript_quality.md is loaded
When  Claude writes TypeScript code
Then  it uses camelCase, JSDoc or inline types, strict TypeScript
And   it follows the project's ESLint configuration
```
