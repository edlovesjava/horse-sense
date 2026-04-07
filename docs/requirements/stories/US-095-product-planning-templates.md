---
id: US-095
title: Product and quality planning templates
status: draft
priority: Must Have
story_points: 5
section: "3.14 Leadership Views — Product Manager"
---

# US-095 — Product and quality planning templates

> As a **developer**, I want **templates for product vision, PRD, release roadmap, and quality plan** so that **leadership artifacts have consistent structure and are easy to scaffold for new projects**.

## Context

The new leadership view skills (US-090, US-091, US-092) need templates to scaffold their output artifacts, just as the existing planner uses `project_plan.md` and `sprint_plan.md` templates. Without templates, each skill would invent its own structure, leading to inconsistency.

This story adds four new templates to `horse/templates/`:

| Template | Used By | Purpose |
|---|---|---|
| `product_vision.md` | Product planning skill (US-090) | North-star statement, target users, value proposition, differentiation |
| `prd.md` | Product planning skill (US-090) | Problem, personas, jobs-to-be-done, success measures (OKRs/KPIs) |
| `release_roadmap.md` | Release planning skill (US-091) | Phases → milestones → epics with dates, scope, dependencies |
| `quality_plan.md` | Quality planning skill (US-092) | Quality gates, coverage targets, V&V checklists, defect register |

## Acceptance Criteria

```gherkin
Given a new project using the horse plugin
When  the product-planning skill scaffolds a product vision
Then  it uses templates/product_vision.md as the starting structure
And   the template includes sections for: vision statement, target users, problem, value proposition, differentiation, success metrics

Given a new project using the horse plugin
When  the product-planning skill scaffolds a PRD
Then  it uses templates/prd.md as the starting structure
And   the template includes sections for: problem statement, user personas, jobs-to-be-done, key use cases, constraints, success measures (OKRs/KPIs), out of scope

Given a project with a PRD and prioritized epics
When  the release-planning skill scaffolds a release roadmap
Then  it uses templates/release_roadmap.md as the starting structure
And   the template includes: phase table (phase → goal → epics → target date → status), dependency summary, velocity assumptions, risk assessment

Given a new project using the horse plugin
When  the quality-planning skill scaffolds a quality plan
Then  it uses templates/quality_plan.md as the starting structure
And   the template includes: quality gates table (phase → entry criteria → exit criteria → responsible), coverage targets, verification checklist, validation checklist, defect register table

Given any template
When  it is used to scaffold a document
Then  placeholder text is clearly marked with [brackets] or _italics_
And   each section has a one-line description of what belongs there
And   the template follows Markdown standards from rules/documentation.md
```

## Notes

- Templates are static markdown — no logic, no compilation
- Follow the pattern of existing templates (project_plan.md, sprint_plan.md, architecture_doc.md)
- Templates should be self-documenting: a developer reading the template should understand what goes in each section
- The product_vision.md template should be concise (1-2 pages when filled) — vision documents lose power when too long
- The PRD template should distinguish between "must know before building" and "nice to know" sections
