---
id: US-023
title: Orchestrator agents direct worker agents
status: draft
priority: Must Have
story_points: 8
section: "3.3 Agents — Workers and Orchestrators"
---

# US-023 — Orchestrator agents direct worker agents

> As a **developer**, I want **orchestrator agents to coordinate worker agents through a defined process** so that **complex multi-step workflows are executed consistently without me manually sequencing each step**.

## Acceptance Criteria

```gherkin
Given the SDLC Orchestrator is active and a process definition exists for "feature delivery"
When  I ask it to deliver a feature
Then  it reads the trail definition from trails/feature_delivery.md
And   it dispatches the planner worker to gather requirements
And   it waits for the entry gate to pass before advancing to the next step
And   it dispatches the architect worker for design
And   it continues through implementation, testing, review, and deployment steps
And   it tracks overall progress and reports status at each transition

Given the Sprint Orchestrator is active
When  I ask it to execute the current sprint
Then  it reads the sprint plan and iterates over each story
And   for each story it dispatches developer → tester → reviewer workers in sequence
And   it aggregates results and reports sprint completion status
```
