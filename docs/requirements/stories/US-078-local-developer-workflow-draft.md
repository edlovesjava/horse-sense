---
id: US-078
title: Local developer workflow
status: draft
priority: Must Have
story_points: 3
section: "3.9 Plugin Toolchain & CI/CD"
---

# US-078 — Local developer workflow

> As a **plugin author**, I want to **run all CI checks locally before pushing** so that **I get fast feedback without waiting for CI**.

## Acceptance Criteria

```gherkin
Given I am developing the plugin locally
When  I run `make check` (or equivalent)
Then  it runs the same checks as CI: structure, markdown lint, shellcheck, JSON schema, frontmatter
And   it completes in under 30 seconds
And   it reports all failures, not just the first one

Given I want to fix auto-fixable issues
When  I run `make fix` (or equivalent)
Then  it auto-fixes Markdown formatting issues
And   it reports issues that require manual intervention
```
