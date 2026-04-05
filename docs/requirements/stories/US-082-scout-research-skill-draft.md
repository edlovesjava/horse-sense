---
id: US-082
title: Scout research and investigation skill
status: draft
priority: Must Have
story_points: 8
section: "3.11 Scout — Research & Spikes"
---

# US-082 — Scout research and investigation skill

> As a **developer**, I want **a scout agent and skill that conducts timeboxed research spikes** so that **I get structured findings and recommendations before committing to requirements or designs**.

## Context

Many development decisions require upfront research — evaluating libraries, understanding APIs, assessing feasibility, or exploring unfamiliar codebases. Currently this research is ad-hoc and its findings are lost between sessions. The scout formalizes this into a repeatable process with a durable artifact (spike report) and optional draft stories/ADRs.

The scout operates as both:

- **An agent** (`agents/scout.md`) — a persistent research persona for dedicated investigation sessions
- **A skill** (`skills/scout/SKILL.md`) — guidance that the planner or architect can compose for quick spikes

## Acceptance Criteria

```gherkin
Given a research question or investigation topic
When  the scout skill is invoked
Then  it produces a spike report in docs/spikes/SPIKE-NNN-title.md
And   the report includes: question, approach, findings, trade-off matrix, recommendation

Given a spike report with findings
When  the user requests draft requirements
Then  the scout produces draft user story files in the configured stories directory
And   each story follows the US-NNN template with acceptance criteria

Given a spike report with findings
When  the user requests draft architecture decisions
Then  the scout produces draft ADR files in docs/architecture/adr/
And   each ADR includes context, options considered, decision, and consequences

Given a research topic with a timebox
When  the scout begins work
Then  it states the timebox and questions to answer upfront
And   it produces findings within the timebox even if incomplete
And   it clearly marks areas that need further investigation

Given no spike number is provided
When  the scout creates a new spike report
Then  it auto-increments the spike number based on existing files in docs/spikes/
```

## Notes

- Spike reports are the primary artifact (always produced)
- Draft stories/ADRs are secondary (generated on request from findings)
- The scout should read `.claude/config.json` for project context (language, framework)
- The scout should read existing requirements and architecture docs to avoid duplicating known information
- Timeboxing is advisory — the scout should prioritize breadth over depth when time is limited
