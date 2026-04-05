---
id: US-073
title: JSON schema validation
status: draft
priority: Should Have
story_points: 2
section: "3.9 Plugin Toolchain & CI/CD"
---

# US-073 — JSON schema validation

> As a **plugin author**, I want to **validate JSON files against their schemas** so that **plugin.json and config templates are always well-formed**.

## Acceptance Criteria

```gherkin
Given horse/.claude-plugin/plugin.json exists
When  I run schema validation
Then  it validates against the Claude Code plugin.json schema
And   it reports missing required fields and type mismatches

Given templates or docs reference a config.json structure
When  I run schema validation
Then  it validates example config.json files against the project config schema
```

**Tool**: ajv-cli or check-jsonschema (Python)
