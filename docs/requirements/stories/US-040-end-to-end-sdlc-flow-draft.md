---
id: US-040
title: End-to-end SDLC flow via process orchestration
status: draft
priority: Must Have
story_points: 8
section: "3.6 SDLC Workflow (Orchestrated)"
---

# US-040 — End-to-end SDLC flow via process orchestration

> As a **developer**, I want to **follow a structured workflow from requirements through deployment** so that **I produce well-documented, tested, deployable software**.

## Acceptance Criteria

```gherkin
Given I run /horse:guide on a new project
When  the SDLC Orchestrator loads the feature-delivery trail definition
Then  it guides me through these phases using worker agents:
  | Phase          | Worker Agent | Output                                    |
  | Requirements   | Planner      | Filled requirements_doc.md                |
  | Architecture   | Architect    | Filled architecture_doc.md + ADRs         |
  | Sprint Plan    | Planner      | Filled sprint_plan.md with stories        |
  | Implementation | Developer    | Working code with tests, passing CI       |
  | Review         | Reviewer     | Code review feedback addressed            |
  | Deployment     | Developer    | Deployment artifacts and runbook created  |
And  each phase has entry gates checked by the orchestrator
And  human approval is required before implementation and after review
And  I can re-enter any phase to iterate
```

## Notes

Implemented via trail definitions (US-025) and orchestrator agents (US-023). The SDLC flow is defined in `trails/feature_delivery.md`.
