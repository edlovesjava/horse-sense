---
id: US-075
title: Documentation generation
status: draft
priority: Should Have
story_points: 3
section: "3.9 Plugin Toolchain & CI/CD"
---

# US-075 — Documentation generation

> As a **plugin author**, I want to **auto-generate a command, skill, and agent reference** so that **documentation stays in sync with the plugin content**.

## Acceptance Criteria

```gherkin
Given the plugin has agents, commands, and skills with frontmatter
When  I run the doc generation tool
Then  it produces a reference document listing all components with:
  | Field       | Source                          |
  | Name        | frontmatter name                |
  | Description | frontmatter description         |
  | Type        | agent / command / skill / rule  |
  | Path        | relative file path              |
And   it writes the output to docs/reference.md (or a configured path)
And   CI fails if the generated reference differs from the committed version (staleness check)
```
