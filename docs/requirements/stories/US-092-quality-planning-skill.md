---
id: US-092
title: Quality planning skill
status: draft
priority: Must Have
story_points: 8
section: "3.16 Leadership Views — QA Lead"
---

# US-092 — Quality planning skill

> As a **developer**, I want **a quality planning skill that manages quality gates, verification & validation checklists, and a quality plan** so that **quality is proactively planned and tracked rather than reactively discovered**.

## Context

The tester agent handles test strategy and coverage, and the trainer audits process compliance. But neither provides proactive quality governance: defining quality gates per SDLC phase, distinguishing verification ("did we build it right?") from validation ("did we build the right thing?"), or maintaining a quality plan that evolves with the project.

Quality is currently assessed at two points: the tester writes tests (verification) and the trainer audits artifacts (process compliance). Missing: acceptance testing guidance (validation), phase-level quality gates as a managed artifact, formal defect tracking, and a quality plan that ties these together.

The quality-planning skill (`skills/quality-planning/SKILL.md`) provides guided workflows for:

- **Quality Plan** — test strategy, coverage targets, quality gates per SDLC phase
- **Verification Checklist** — technical quality checks (unit, integration, e2e, performance, security)
- **Validation Checklist** — business quality checks (acceptance criteria met, UAT, user feedback)
- **Quality Gates** — entry/exit criteria per phase (requirements → design → code → test → deploy)
- **Defect Register** — known issues tracked by severity, status, and linked story

## Acceptance Criteria

```gherkin
Given a new project
When  the quality-planning skill is invoked for quality plan creation
Then  it produces a quality_plan.md artifact in docs/
And   the plan defines quality gates for each SDLC phase
And   each gate has entry criteria, exit criteria, and responsible role
And   the plan specifies coverage targets for unit, integration, and e2e tests

Given an SDLC phase transition (e.g., design → implementation)
When  the quality-planning skill evaluates the quality gate
Then  it checks all exit criteria for the current phase
And   it checks all entry criteria for the next phase
And   it reports pass/fail with specific items that are not met
And   it blocks transition if any Must Have criteria are not met

Given a feature approaching acceptance testing
When  the quality-planning skill generates a validation checklist
Then  the checklist includes all acceptance criteria from the user story
And   it includes usability criteria if a designer view exists
And   it includes non-functional requirements (performance, accessibility)
And   each checklist item has a pass/fail status and evidence field

Given a bug or issue discovered during development or testing
When  the quality-planning skill logs a defect
Then  it records severity (critical, major, minor, cosmetic), description, steps to reproduce
And   it links the defect to the originating story or test
And   it tracks status (open, in-progress, fixed, verified, closed)
And   critical and major defects block the quality gate for deployment

Given a sprint or release review
When  the quality-planning skill generates a quality report
Then  it summarizes: tests passed/failed, coverage achieved, quality gates passed, open defects
And   it compares actual quality metrics against the targets in the quality plan
```

## Notes

- The tester agent composes this skill for quality-focused work — extends the tester's role into QA lead territory
- The trainer's process audit remains separate (audits process compliance, not product quality)
- Quality gates should be configurable per project in quality_plan.md, not hardcoded
- New template needed: `templates/quality_plan.md`
- Verification = "built it right" (developer/tester concern); Validation = "built the right thing" (product/user concern)
- Defect tracking is lightweight (markdown-based) — not a replacement for Jira/Linear, but sufficient for small teams
