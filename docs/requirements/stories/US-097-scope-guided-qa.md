---
id: US-097
title: Scope-guided Q&A in project setup
status: draft
priority: Must Have
story_points: 5
section: "3.17 Project Scope Profiles"
---

# US-097 — Scope-guided Q&A in project setup

> As a **developer**, I want **a short Q&A flow during `/horse:guide` that determines my project scope** so that **the right profile is set automatically without me needing to know the profile names or artifact mappings**.

## Context

Rather than asking users to pick a profile name from a list, a natural 3-question Q&A can determine the right scope profile. This makes onboarding intuitive — the user describes their situation, and the plugin figures out the process weight.

The Q&A runs as the first step of `/horse:guide` (or `/horse:init` if US-084 is implemented) and writes the result to `horse.config.md`.

## Acceptance Criteria

```gherkin
Given a new project without horse.config.md
When  /horse:guide is invoked
Then  it runs the scope Q&A before any other workflow steps
And   the Q&A asks 3 or fewer primary questions

Given the scope Q&A is running
When  the user indicates they are investigating or learning
Then  the profile is set to "spike"
And   the guide confirms: "Setting up as a spike — lightweight process, spike report output"

Given the scope Q&A is running
When  the user indicates they are testing an idea or building a quick demo
Then  the profile is set to "poc"
And   the guide confirms: "Setting up as a PoC — basic requirements, code with tests"

Given the scope Q&A is running
When  the user indicates they are building a tool or service for real use
Then  the Q&A asks a follow-up about business outcomes and team size
And   it resolves to "project", "product", or "enterprise" accordingly

Given the scope Q&A determines a profile
When  the result is confirmed
Then  it writes project_scope to horse.config.md
And   it summarizes the active roles and expected artifacts for the profile
And   it asks the user if they want to adjust (add/remove roles or artifacts)

Given the user wants to adjust after Q&A
When  they request changes (e.g., "I also need UX design")
Then  the adjustment is recorded as a role or artifact override in horse.config.md
And   the guide proceeds with the adjusted profile

Given horse.config.md already contains a project_scope
When  /horse:guide is re-invoked
Then  it skips the scope Q&A and uses the existing profile
And   it offers the option to re-run the Q&A if the user wants to change scope
```

## Notes

- The Q&A should feel conversational, not like a form — the planner agent persona handles this naturally
- Primary questions (from SPIKE-008): (1) What are you building? (2) Will this have paying users/KPIs? (3) How large is the team?
- Optional refinement questions: UX design needed? Infrastructure to manage? Compliance requirements?
- The Q&A can also ask about deployment target (local only, cloud, on-prem) to inform ops activation
- If US-084 (project init command) ships, the Q&A should run there instead of in `/horse:guide`
