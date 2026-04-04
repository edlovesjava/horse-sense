---
id: US-029
title: Process execution tracking
status: draft
priority: Should Have
story_points: 3
section: "3.4 Process Definitions — Workflow Specification"
---

# US-029 — Process execution tracking

> As a **developer**, I want **the orchestrator to track and report process execution status** so that **I can see where a workflow stands, what's completed, and what's next**.

## Acceptance Criteria

```gherkin
Given a process is being executed by an orchestrator
When  I ask for status
Then  it reports:
  | Field              | Example                                     |
  | Process            | feature-delivery                             |
  | Current step       | Step 3: Implementation (iteration 2 of 5)   |
  | Steps completed    | 1. Requirements ✓  2. Architecture ✓        |
  | Steps remaining    | 4. Testing  5. Review  6. Deployment         |
  | Blocked by         | (none) or "Waiting for human approval"       |
  | Worker agent       | developer                                    |
  | Monitor            | monitor (active, no interventions)           |

Given a process completes all steps
When  the orchestrator finishes
Then  it produces a summary of the entire execution
And   includes: steps completed, human decisions made, iterations on loops, total time context
```
