---
id: US-028
title: Human-in-the-loop decision points
status: draft
priority: Must Have
story_points: 5
section: "3.4 Process Definitions — Workflow Specification"
---

# US-028 — Human-in-the-loop decision points

> As a **developer**, I want **explicit human decision points in workflows** so that **I maintain control over critical decisions while letting automation handle routine work**.

## Acceptance Criteria

```gherkin
Given a process step is marked "Gate: HUMAN APPROVAL"
When  the orchestrator reaches that point
Then  it pauses execution
And   presents a summary of work completed so far
And   presents the specific decision needed (approve / reject / modify)
And   waits for the human to respond before continuing

Given a process step fails and the fail action is "HUMAN DECISION"
When  the orchestrator reaches the fail condition
Then  it pauses execution
And   presents what went wrong, what was tried, and iteration history
And   offers options: retry with guidance, skip step, abort process, or take manual action
And   waits for the human to decide before continuing

Given a human approves at a decision point
When  the orchestrator resumes
Then  it continues from the next step in the process
And   logs the approval in the process execution record

Given a human rejects at a decision point
When  the orchestrator receives the rejection with feedback
Then  it routes back to the appropriate earlier step
And   passes the human's feedback as additional context to the worker agent
```
