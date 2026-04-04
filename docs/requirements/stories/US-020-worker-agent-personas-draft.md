---
id: US-020
title: Worker agent personas
status: draft
priority: Must Have
story_points: 5
section: "3.3 Agents — Workers and Orchestrators"
---

# US-020 — Worker agent personas

> As a **developer**, I want to **switch to a specialized worker agent persona** so that **Claude approaches work from a specific role's perspective with the right skills loaded**.

## Context

Agents are divided into two categories:

- **Worker agents** perform focused tasks from a specific role perspective, using skills and rules
- **Orchestrator agents** direct worker agents through process definitions, managing workflow execution, gating, and human-in-the-loop decision points

## Acceptance Criteria

```gherkin
Given I select the "developer" worker agent
When  Claude enters that agent context
Then  it prioritizes implementation, debugging, and refactoring skills
And   it follows code quality and testing rules
And   it maintains the developer persona across the session

Given I select the "tester" worker agent
When  Claude enters that agent context
Then  it prioritizes test strategy, test writing, and coverage skills
And   it enforces testing rules and coverage thresholds
And   it reviews code from a quality-assurance perspective
```

## Required agents

| Agent | Type | Role | Primary Skills | Perspective |
|---|---|---|---|---|
| **Planner** | Worker | Project Manager | requirements-analysis, sprint planning | Scope, priorities, timelines |
| **Architect** | Worker | System Designer | architecture-design, tech selection | Components, interfaces, trade-offs |
| **Developer** | Worker | Implementer | implementation, python-venv/ts-setup | Code quality, TDD, shipping |
| **Tester** | Worker | QA Engineer | testing, security audit | Coverage, edge cases, reliability |
| **Reviewer** | Worker | Code Reviewer | review checklist, security, perf | Correctness, standards, maintainability |
| **SDLC Orchestrator** | Orchestrator | Process Director | all workflow processes | End-to-end delivery lifecycle |
| **Sprint Orchestrator** | Orchestrator | Sprint Director | sprint process | Story-level iteration within a sprint |
| **Monitor** | Orchestrator | Quality Watcher | testing, review skills | Observes loops, checks quality, guides refinement |
