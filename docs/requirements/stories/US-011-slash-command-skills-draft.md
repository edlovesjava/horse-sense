---
id: US-011
title: Slash-command skills (user-invoked)
status: draft
priority: Must Have
story_points: 3
section: "3.2 Skills — Primary Behavior Definition"
---

# US-011 — Slash-command skills (user-invoked)

> As a **developer**, I want to **invoke skills via slash commands** so that **I can explicitly trigger a specific SDLC activity**.

## Acceptance Criteria

```gherkin
Given horse-sense is installed
When  I type /horse-sense:plan
Then  Claude enters planning mode following the plan skill guide
And   $ARGUMENTS are passed through to the skill

Given horse-sense is installed
When  I type /horse-sense:implement add user authentication
Then  Claude follows the implementation skill guide
And   "add user authentication" is available as $ARGUMENTS context
```

## Required slash commands

- `/horse:sdlc-start` — full SDLC kickoff workflow
- `/horse:plan` — create or update a project plan
- `/horse:arch` — design system architecture
- `/horse:implement` — begin a feature implementation
- `/horse:review` — perform a code review
- `/horse:test` — create and run tests
- `/horse:deploy` — prepare deployment artifacts
- `/horse:sprint` — plan and manage a sprint
- `/horse:retrospective` — facilitate a sprint retrospective
