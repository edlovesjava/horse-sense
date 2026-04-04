---
id: US-070
title: Plugin structure validation
status: draft
priority: Must Have
story_points: 5
section: "3.9 Plugin Toolchain & CI/CD"
---

# US-070 — Plugin structure validation

> As a **plugin author**, I want to **validate the plugin's structure and content** so that **broken plugins are caught before they reach users**.

## Acceptance Criteria

```gherkin
Given the plugin directory horse/
When  I run the validation tool
Then  it checks that .claude-plugin/plugin.json exists and conforms to its schema
And   every file in agents/ has valid YAML frontmatter with required fields (name, description)
And   every file in commands/ has valid YAML frontmatter with required fields
And   every skills/*/SKILL.md has valid YAML frontmatter with required fields
And   every file in rules/ has valid YAML frontmatter with glob patterns
And   every script in scripts/ is executable and passes shellcheck
And   cross-references between components resolve (e.g., a command referencing a template that exists)
And   it exits non-zero with clear error messages if any check fails
```
