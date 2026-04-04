---
id: US-072
title: Shell script linting
status: draft
priority: Must Have
story_points: 2
section: "3.9 Plugin Toolchain & CI/CD"
---

# US-072 — Shell script linting

> As a **plugin author**, I want to **lint all shell scripts with shellcheck** so that **scripts in bin/ and scripts/ are portable and bug-free**.

## Acceptance Criteria

```gherkin
Given any .sh file in horse/scripts/ or horse/bin/
When  I run shellcheck
Then  it reports warnings and errors per SC codes
And   the CI pipeline fails on any error-level finding
And   a .shellcheckrc at the repo root configures excluded rules (if any)
```

**Tool**: shellcheck
