---
id: US-077
title: CI/CD pipeline via GitHub Actions
status: draft
priority: Must Have
story_points: 5
section: "3.9 Plugin Toolchain & CI/CD"
---

# US-077 — CI/CD pipeline via GitHub Actions

> As a **plugin author**, I want to **a GitHub Actions workflow that validates every PR and release** so that **the plugin is always in a known-good state**.

## Acceptance Criteria

```gherkin
Given a PR is opened or updated against main
When  the CI workflow runs
Then  it executes these checks in order:
  | Step                    | Tool                  | Fails build on |
  | Plugin structure check  | custom validate script| any error       |
  | Markdown lint           | markdownlint-cli2     | any error       |
  | Shell lint              | shellcheck            | any error       |
  | JSON schema validation  | ajv-cli / check-jsonschema | any error  |
  | Frontmatter validation  | custom validate script| any error       |
  | Doc staleness check     | diff against generated| any diff        |
And   the workflow posts a summary comment on the PR
And   the PR is blocked from merging if any check fails

Given a semver tag is pushed
When  the release workflow runs
Then  it runs the full validation suite
And   creates a GitHub Release with changelog and plugin archive
```

**Workflow file**: `.github/workflows/ci.yml`
