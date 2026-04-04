---
id: US-012
title: Model-invoked skills (automatic)
status: draft
priority: Should Have
story_points: 3
section: "3.2 Skills — Primary Behavior Definition"
---

# US-012 — Model-invoked skills (automatic)

> As a **developer**, I want **Claude to automatically invoke relevant skills based on context** so that **I don't have to remember which command to use for every activity**.

## Acceptance Criteria

```gherkin
Given I ask Claude to "set up the Python environment"
When  Claude recognizes this matches the python-venv skill description
Then  it follows the python-venv SKILL.md guide automatically

Given I ask Claude to "write tests for the user service"
When  Claude recognizes this matches the testing skill description
Then  it follows the testing SKILL.md guide automatically
And   adapts to the project's configured test runner
```

## Notes

Requires SKILL.md files with descriptive `name` and `description` frontmatter fields.
