---
id: US-090
title: Product planning skill
status: draft
priority: Must Have
story_points: 8
section: "3.14 Leadership Views — Product Manager"
---

# US-090 — Product planning skill

> As a **developer**, I want **a product planning skill that guides creating a product vision, PRD, roadmap, and success measures** so that **development is driven by clear business outcomes rather than ad-hoc feature lists**.

## Context

The plugin's planner agent handles sprint-level planning well, but there is no guidance for the strategic product-level horizon: *why* are we building this, *for whom*, *what does success look like*, and *in what order* should value be delivered?

Currently the requirements doc captures functional requirements but not the product vision, user personas, jobs-to-be-done, competitive positioning, or measurable success criteria (OKRs/KPIs). Without these, sprint work lacks strategic alignment — stories get built because they're next on the list, not because they deliver the highest business value.

The product-planning skill (`skills/product-planning/SKILL.md`) provides guided workflows for:

- **Product Vision** — north-star statement, target users, value proposition, differentiation
- **Product Requirements Document (PRD)** — problem statement, personas, jobs-to-be-done, constraints, success measures
- **Product Roadmap** — milestones → phases → epics, sequenced by value and dependencies
- **Success Measures** — OKRs or KPIs that define what "done" means at the product level

## Acceptance Criteria

```gherkin
Given a new project or product initiative
When  the product-planning skill is invoked for vision
Then  it guides the user through articulating target users, problem, value proposition, and differentiation
And   it produces a product_vision.md artifact in docs/

Given a product vision exists
When  the product-planning skill is invoked for PRD
Then  it elicits user personas, jobs-to-be-done, key use cases, and constraints
And   it defines measurable success criteria (OKRs or KPIs) with targets
And   it produces a prd.md artifact in docs/

Given a PRD with epics and success measures
When  the product-planning skill is invoked for roadmap
Then  it groups epics into phases with clear goals and exit criteria
And   it sequences phases by business value and dependency order
And   it produces a release_roadmap.md artifact in docs/plans/
And   the roadmap links back to PRD success measures

Given an existing product roadmap
When  the product-planning skill is invoked for update
Then  it reviews progress against success measures
And   it re-prioritizes phases based on new information, completed spikes, or market changes
And   it records the rationale for any priority changes

Given the product-planning skill produces artifacts
When  the planner agent composes this skill
Then  the planner adopts the product manager perspective for strategic planning
And   switches back to project/sprint perspective for tactical work
```

## Notes

- The planner agent composes this skill — no new agent needed (per SPIKE-006 recommendation)
- New templates needed: `templates/product_vision.md`, `templates/prd.md`, `templates/release_roadmap.md`
- Success measures should be concrete and measurable (e.g., "80% test coverage" not "good quality")
- The roadmap should connect to the project plan's milestone table
- Consider a `/horse:roadmap` command to invoke the product-level view directly
