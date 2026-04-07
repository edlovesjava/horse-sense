---
id: US-088
title: Code documentation skill
status: draft
priority: Should Have
story_points: 5
section: "3.13 Doc Writer — Documentation Authoring & Maintenance"
---

# US-088 — Code documentation skill

> As a **developer**, I want **a code documentation skill that guides reviewing and authoring inline documentation** so that **code is self-documenting with clear explanations of intent, not just mechanics**.

## Context

The plugin mandates Google-style docstrings for Python (`rules/code_quality.md` lines 38-57) and JSDoc for TypeScript, but no skill guides how to write good inline documentation. The reviewer checks that docstrings *exist* but not that they are *helpful*. Developers often write rote docstrings that restate the function signature rather than explaining *why* the code exists or what callers need to know.

The code-docs skill (`skills/code-docs/SKILL.md`) provides guided workflows for:

- **Reviewing** existing code documentation for quality, clarity, and coverage
- **Authoring** docstrings, module-level docs, and explanatory comments
- **Identifying** where comments add value vs. where code should be self-documenting

## Acceptance Criteria

```gherkin
Given a source file or module
When  the code-docs skill is invoked for review
Then  it identifies public functions, classes, and modules missing docstrings
And   it flags docstrings that merely restate the signature without explaining intent
And   it reports a coverage percentage (documented / total public symbols)

Given a function or class needing documentation
When  the code-docs skill is invoked for authoring
Then  it produces a docstring in the project's configured style (Google for Python, JSDoc for TypeScript)
And   the docstring explains the purpose, parameters, return value, and any side effects
And   it includes usage examples for non-trivial public APIs

Given a complex code block with no comments
When  the code-docs skill is invoked
Then  it adds explanatory comments only where the logic is non-obvious
And   it does not add comments that restate what the code already says clearly
And   comments explain "why" rather than "what"

Given a project with .claude/config.json specifying the language
When  the code-docs skill runs
Then  it uses the appropriate docstring convention for the configured language
And   it follows the coding standards in rules/code_quality.md or rules/typescript_quality.md
```

## Notes

- The skill should distinguish between public API documentation (always required) and internal implementation docs (only when non-obvious)
- For Python: Google-style docstrings per `rules/code_quality.md`
- For TypeScript: JSDoc with `@param`, `@returns`, `@throws`, `@example` tags
- The skill should read `.claude/config.json` for `language` and `srcDir`
- Consider a "documentation debt" metric: percentage of public symbols without meaningful docstrings
