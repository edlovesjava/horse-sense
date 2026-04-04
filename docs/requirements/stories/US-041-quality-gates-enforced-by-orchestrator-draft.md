---
id: US-041
title: Quality gates enforced by orchestrator
status: draft
priority: Must Have
story_points: 3
section: "3.6 SDLC Workflow (Orchestrated)"
---

# US-041 — Quality gates enforced by orchestrator

> As a **developer**, I want **the orchestrator to enforce quality gates between phases** so that **I don't skip essential steps**.

## Acceptance Criteria

```gherkin
Given the orchestrator reaches the implementation phase
And   requirements_doc.md is missing or empty
When  the entry gate is evaluated
Then  the orchestrator blocks the step
And   reports that requirements are missing
And   dispatches the planner worker or asks the human to provide requirements

Given the orchestrator reaches the deployment phase
And   tests are failing or coverage is below threshold
When  the entry gate is evaluated
Then  the orchestrator blocks the step
And   routes back to the testing phase
And   the tester worker addresses the gaps

Given all entry gates for a phase are satisfied
When  the orchestrator evaluates the gate
Then  it advances to the phase and dispatches the appropriate worker
```

## Notes

Gates are defined in the process document, not hardcoded in skills. This makes them customizable per workflow.
