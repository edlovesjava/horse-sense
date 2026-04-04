---
id: US-071
title: Markdown linting
status: draft
priority: Must Have
story_points: 3
section: "3.9 Plugin Toolchain & CI/CD"
---

# US-071 — Markdown linting

> As a **plugin author**, I want to **lint all Markdown files for consistency** so that **skills, agents, commands, and rules follow a uniform style**.

## Acceptance Criteria

```gherkin
Given any Markdown file in horse/
When  I run the Markdown linter
Then  it enforces consistent heading structure, list formatting, and line length
And   it validates that fenced code blocks have a language tag
And   it flags broken internal links (e.g., [template](../templates/missing.md))
And   configuration is defined in a .markdownlint.json at the repo root
```

**Tool**: markdownlint-cli2 (Node.js) or mdl (Ruby) — prefer markdownlint-cli2 for Node.js availability.
