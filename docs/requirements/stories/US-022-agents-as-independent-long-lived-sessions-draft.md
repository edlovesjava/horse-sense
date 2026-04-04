---
id: US-022
title: Agents as independent long-lived sessions
status: draft
priority: Should Have
story_points: 3
section: "3.3 Agents — Workers and Orchestrators"
---

# US-022 — Agents as independent long-lived sessions

> As a **developer**, I want **agents to maintain context across a long session** so that **I can work on complex, multi-step tasks without re-explaining the project**.

## Acceptance Criteria

```gherkin
Given the developer agent has been working on a feature for 30+ minutes
When  I ask a follow-up question about the same feature
Then  it remembers the feature context, decisions made, and files modified
And   it does not re-read files it has already analyzed

Given I switch from the developer agent to the reviewer agent
When  the reviewer starts a code review
Then  it has access to the same project context (config, rules)
But   it approaches the code from a review perspective, not an implementation one
```
