---
id: US-076
title: Distribution via Git releases
status: draft
priority: Should Have
story_points: 3
section: "3.9 Plugin Toolchain & CI/CD"
---

# US-076 — Distribution via Git releases

> As a **plugin author**, I want to **distribute the plugin via Git tags and GitHub Releases** so that **users can install a specific version and track changes**.

## Acceptance Criteria

```gherkin
Given I tag a commit with a semver tag (e.g., v1.0.0)
When  CI detects the new tag
Then  it runs the full validation suite
And   it creates a GitHub Release with auto-generated release notes
And   the release description includes a changelog since the last tag
And   the release assets include a .tar.gz of the horse/ directory

Given a user wants to install a specific version
When  they clone the repo and check out a tag
Then  they can use `claude --plugin-dir ./horse` and get that version's plugin
```
