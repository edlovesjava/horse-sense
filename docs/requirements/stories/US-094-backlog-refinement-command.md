---
id: US-094
title: Backlog refinement command
status: draft
priority: Must Have
story_points: 5
section: "3.15 Leadership Views — Project Manager"
---

# US-094 — Backlog refinement command

> As a **developer**, I want **a `/horse:refine` command that guides backlog grooming sessions** so that **the backlog stays healthy with right-sized stories, accurate estimates, current priorities, and no stale items**.

## Context

Backlog grooming is currently implicit in the planner's responsibilities — it happens ad-hoc during `/horse:plan` or `/horse:sprint`. There is no dedicated workflow for the ongoing maintenance a backlog needs: re-estimating stories as scope clarifies, splitting oversized stories, re-prioritizing after spikes or market changes, and archiving stories that are no longer relevant.

SPIKE-005 identified this as a key gap. Without regular refinement, backlogs grow stale: 13-point stories never get split, priorities drift, and completed spikes don't feed back into story updates.

The `/horse:refine` command invokes the planner agent with the release-planning skill to run a structured refinement session.

## Acceptance Criteria

```gherkin
Given a project backlog with user stories
When  /horse:refine is invoked
Then  it reads all story files and presents a backlog health summary
And   the summary includes: total stories, stories by status, stories by priority, average SP, stories > 8 SP

Given stories with story_points > 8
When  /horse:refine identifies oversized stories
Then  it recommends splitting them into smaller deliverable stories
And   it provides splitting guidance (by workflow step, by data type, by user role, by happy/sad path)
And   the user can accept, modify, or skip each split suggestion

Given stories in "draft" status for more than 2 sprints
When  /horse:refine checks for stale stories
Then  it flags them as candidates for re-prioritization or archival
And   it asks the user to confirm: keep, re-prioritize, or archive

Given completed spikes with draft stories in their "Next Steps"
When  /horse:refine checks for spike follow-ups
Then  it identifies spike-generated stories that haven't been refined or estimated
And   it guides the user through estimating and prioritizing them

Given a story whose scope has changed since initial estimation
When  the user re-estimates during refinement
Then  the story's story_points frontmatter is updated
And   a note is added explaining the re-estimation rationale

Given a refinement session is complete
When  the user finishes
Then  it reports: stories split, stories re-estimated, stories archived, stories added
And   it updates the requirements index if stories were added or removed
```

## Notes

- The planner agent runs this command, composing the release-planning skill
- Refinement should be runnable at any time, not just at sprint boundaries
- Story splitting patterns: by workflow step, by data variation, by user role, by happy/error path, by CRUD operation, by platform
- Stale story detection uses sprint history — if stories have been in "draft" across multiple sprint plans without selection, they're candidates
- Consider reading spike reports from `docs/spikes/` to find unactioned next steps
