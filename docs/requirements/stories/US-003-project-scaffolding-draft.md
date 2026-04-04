---
id: US-003
title: Project scaffolding
status: draft
priority: Must Have
story_points: 5
section: "3.1 Plugin Installation & Configuration"
---

# US-003 — Project scaffolding

> As a **developer starting a new project**, I want to **run a scaffolding command** so that **the project structure, config, CI, and templates are set up correctly from the start**.

## Acceptance Criteria

```gherkin
Given horse-sense is installed
When  I run /horse-sense:sdlc-start with a project name
Then  project directories are created (src/, tests/, docs/adr/)
And   .claude/config.json is generated with prompted values
And   CI workflow template is placed in .github/workflows/
And   CLAUDE.md is initialized with project-specific instructions
And   requirements and architecture templates are copied to docs/
```
