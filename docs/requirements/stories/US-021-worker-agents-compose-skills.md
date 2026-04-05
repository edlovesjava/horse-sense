---
id: US-021
title: Worker agents compose skills
status: draft
priority: Must Have
story_points: 3
section: "3.3 Agents — Workers and Orchestrators"
---

# US-021 — Worker agents compose skills

> As a **developer**, I want **worker agents to automatically use relevant skills** so that **I don't have to manually invoke each skill during a focused work session**.

## Acceptance Criteria

```gherkin
Given the developer worker agent is active
When  I ask it to implement a feature
Then  it follows the implementation skill (branch, write test, implement, lint, commit)
And   it references the testing skill for test structure
And   it reads project config for language-specific commands
And   it applies code quality rules to the files it creates

Given the architect worker agent is active
When  I ask it to design a new component
Then  it follows the architecture-design skill
And   it creates an ADR using the ADR template
And   it generates Mermaid diagrams per the documentation rules
```
