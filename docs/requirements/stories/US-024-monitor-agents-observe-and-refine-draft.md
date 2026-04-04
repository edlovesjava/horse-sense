---
id: US-024
title: Monitor agents observe and refine
status: draft
priority: Should Have
story_points: 5
section: "3.3 Agents — Workers and Orchestrators"
---

# US-024 — Monitor agents observe and refine

> As a **developer**, I want **monitor agents to watch long-running loops and provide feedback** so that **iterative processes converge on quality rather than spinning**.

## Acceptance Criteria

```gherkin
Given a develop-test-fix loop is running for a story
When  the monitor agent observes the third iteration without test convergence
Then  it analyzes the pattern of failures
And   it suggests a different approach or escalates to the human

Given the monitor agent detects code quality degrading across iterations
When  it evaluates the current state against rules
Then  it intervenes with specific guidance to the worker agent
And   logs the intervention for the orchestrator's status report

Given the monitor agent detects all quality criteria are met
When  it evaluates the current iteration
Then  it signals the orchestrator that the loop can exit
```

## Notes

Monitor agents are optional — orchestrators can run without them, but monitors improve quality on complex or long-running tasks.
