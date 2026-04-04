---
id: US-027
title: Entry gates and completion criteria
status: draft
priority: Must Have
story_points: 5
section: "3.4 Process Definitions — Workflow Specification"
---

# US-027 — Entry gates and completion criteria

> As a **developer**, I want **each process step to have explicit entry gates and completion criteria** so that **work doesn't start prematurely and doesn't end before quality is met**.

## Acceptance Criteria

```gherkin
Given a process step has an entry gate requiring "requirements_doc.md exists"
When  the orchestrator attempts to start that step
And   requirements_doc.md does not exist
Then  the step is blocked
And   the orchestrator reports what is missing
And   it suggests which prior step or action would satisfy the gate

Given a process step has completion criteria "all tests pass, coverage ≥ 80%"
When  the worker agent finishes its work
Then  the orchestrator evaluates the completion criteria
And   if met, advances to the next step
And   if not met, the worker continues or the step enters its fail path

Given a process step has a fail condition "loop exceeds 5 iterations"
When  the iteration count exceeds 5
Then  the orchestrator halts the step
And   reports the failure reason and iteration history
And   invokes the fail action (typically HUMAN DECISION)
```
