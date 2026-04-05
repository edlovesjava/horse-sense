---
id: US-026
title: Process flow control (sequence, loop, branch, conditional)
status: draft
priority: Must Have
story_points: 8
section: "3.4 Process Definitions — Workflow Specification"
---

# US-026 — Process flow control (sequence, loop, branch, conditional)

> As a **plugin author**, I want **process steps to support sequential execution, loops, conditional branching, and recursion** so that **real-world workflows with iterative and conditional logic can be modeled**.

## Acceptance Criteria

```gherkin
Given a process with sequential steps 1 → 2 → 3
When  the orchestrator executes it
Then  it completes each step before starting the next
And   it checks completion criteria between steps

Given a process step with a loop (e.g., develop-test-fix)
When  the orchestrator enters the loop
Then  it repeats the loop body until exit criteria are met
And   a monitor agent (if assigned) observes each iteration
And   the loop aborts if the fail condition is reached

Given a process step with a conditional branch (e.g., "if review has blocking issues → goto implementation")
When  the branch condition is true
Then  the orchestrator jumps to the target step
And   re-executes from that point forward
And   tracks the number of branch-backs to prevent infinite loops

Given a process step with a recursive sub-process reference
When  the orchestrator encounters it
Then  it loads and executes the referenced process document
And   returns control to the parent process when the sub-process completes
```
