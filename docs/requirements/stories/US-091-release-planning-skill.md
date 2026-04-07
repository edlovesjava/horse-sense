---
id: US-091
title: Release planning skill
status: draft
priority: Must Have
story_points: 8
section: "3.15 Leadership Views — Project Manager"
---

# US-091 — Release planning skill

> As a **developer**, I want **a release planning skill that manages story maps, dependency analysis, resource allocation, and incremental release plans** so that **I can coordinate multi-sprint delivery with confidence in scope, sequence, and dates**.

## Context

The `/horse:sprint` command handles single-sprint planning well (SPIKE-005 finding), but there is no guidance for the tactical project-level horizon: how do stories relate to each other, which stories must ship together in a release, how are team resources allocated across sprints, and what is the critical path?

The release-planning skill (`skills/release-planning/SKILL.md`) provides guided workflows for:

- **Story Mapping** — organize stories by user activities and release slices
- **Dependency Analysis** — identify and track inter-story dependencies, flag critical path
- **Release Planning** — group stories into incremental releases with scope, dates, and risk
- **Resource Allocation** — allocate team capacity across sprints, balance skill-based assignment
- **Velocity Forecasting** — use historical velocity to predict release dates

## Acceptance Criteria

```gherkin
Given a backlog of prioritized stories
When  the release-planning skill is invoked for story mapping
Then  it organizes stories by user activity (horizontal) and release slice (vertical)
And   it identifies stories that can be deferred without breaking a release slice
And   it produces a story map section in the project plan

Given stories with depends_on frontmatter fields
When  the release-planning skill analyzes dependencies
Then  it identifies dependency chains and the critical path
And   it flags circular dependencies as errors
And   it warns when a sprint backlog contains a story whose dependency is not yet done

Given a product roadmap with phases
When  the release-planning skill is invoked for release planning
Then  it assigns stories to releases based on phase goals and dependencies
And   each release has a defined scope, target date, and risk assessment
And   it identifies stories that are "at risk" of slipping based on velocity

Given team capacity data and historical velocity
When  the release-planning skill forecasts completion
Then  it estimates the number of sprints needed to complete each release
And   it highlights when forecasted completion exceeds target dates
And   it suggests scope adjustments if dates are at risk

Given an in-progress release plan
When  the release-planning skill is invoked for update
Then  it recalculates forecasts based on actual velocity from completed sprints
And   it flags stories that have been deferred more than once
And   it recommends re-prioritization or scope cuts when behind schedule
```

## Notes

- The planner agent composes this skill for project-level work
- Depends on `depends_on` frontmatter field in user stories (US-093)
- Velocity forecasting should use a simple weighted average of recent sprints (last 3)
- Story mapping concept based on Jeff Patton's User Story Mapping
- The release plan should link to the product roadmap (US-090) for phase alignment
- Consider a risk register as a section in the project plan or a standalone artifact
