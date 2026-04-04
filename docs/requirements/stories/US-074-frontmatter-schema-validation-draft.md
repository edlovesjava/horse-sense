---
id: US-074
title: Frontmatter schema validation
status: draft
priority: Must Have
story_points: 3
section: "3.9 Plugin Toolchain & CI/CD"
---

# US-074 — Frontmatter schema validation

> As a **plugin author**, I want to **validate YAML frontmatter in all Markdown components** so that **agents, skills, commands, and rules have the required metadata for auto-discovery**.

## Acceptance Criteria

```gherkin
Given an agent file in horse/agents/
When  I run frontmatter validation
Then  it requires: name (string), description (string), and any agent-specific fields
And   it warns on unrecognized fields

Given a skill file horse/skills/*/SKILL.md
When  I run frontmatter validation
Then  it requires: name (string), description (string)
And   it validates optional fields match expected types

Given a command file in horse/commands/
When  I run frontmatter validation
Then  it requires: name (string), description (string)
And   it validates that referenced templates and scripts exist

Given a rule file in horse/rules/
When  I run frontmatter validation
Then  it requires: name (string), description (string), globs (list of strings)
```

**Tool**: Custom validation script (Python or Bash) using a YAML parser.
