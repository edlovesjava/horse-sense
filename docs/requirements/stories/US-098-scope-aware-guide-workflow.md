---
id: US-098
title: Scope-aware guide workflow
status: draft
priority: Must Have
story_points: 8
section: "3.17 Project Scope Profiles"
---

# US-098 — Scope-aware guide workflow

> As a **developer**, I want **the `/horse:guide` workflow to adapt its steps, roles, and artifacts based on my project scope profile** so that **I get exactly the right amount of process for my project — no more, no less**.

## Context

Once the scope profile is set (US-096, US-097), the guide workflow needs to actually adapt. Currently `/horse:guide` runs every SDLC phase in sequence regardless of project size. With scope awareness, the guide becomes a tailored onboarding experience.

This is the most impactful story in the scope profile feature — it's where the user *feels* the difference between a spike and a product.

## Acceptance Criteria

```gherkin
Given project_scope is "spike"
When  /horse:guide runs the workflow
Then  it executes only:
  | Step | Action |
  | Environment | Set up dev environment |
  | Investigate | Run scout skill with timebox |
  | Implement | Code the investigation |
  | Report | Produce spike report |
And  it skips: requirements doc, architecture, planning, formal testing, review, deployment

Given project_scope is "poc"
When  /horse:guide runs the workflow
Then  it executes only:
  | Step | Action |
  | Requirements | Lightweight checklist (what, for whom, success criteria) |
  | Environment | Set up dev environment |
  | Implement | Code with basic tests |
  | Document | Minimal README |
And  it skips: architecture doc, sprint planning, formal review, deployment, quality plan

Given project_scope is "project"
When  /horse:guide runs the workflow
Then  it executes:
  | Step | Action |
  | Requirements | Full requirements elicitation and documentation |
  | Architecture | Architecture doc (lightweight or full based on complexity) |
  | Planning | Project plan and first sprint plan |
  | Environment | Set up dev environment with CI |
  | Implement | TDD workflow |
  | Test | Full test pyramid |
  | Review | Code review |
  | Document | README + docs/ |
  | Deploy | CI/CD setup |

Given project_scope is "product"
When  /horse:guide runs the workflow
Then  it executes all "project" steps PLUS:
  | Step | Action |
  | Vision | Product vision (product-planning skill) |
  | PRD | Product requirements document |
  | Roadmap | Release roadmap with phases |
  | Quality | Quality plan with gates |
  | Sprint | Full sprint planning with velocity tracking |

Given project_scope is "enterprise"
When  /horse:guide runs the workflow
Then  it executes all "product" steps PLUS:
  | Step | Action |
  | DDD | Domain model with bounded contexts |
  | UX | UX research and interaction design |
  | Ops | Observability requirements and infrastructure plan |
  | Compliance | Quality gates with compliance checks |

Given any scope profile
When  the guide skips a step
Then  it briefly notes what was skipped and why
And   it mentions that the user can run the skipped command manually if needed

Given a scope profile with optional roles (e.g., designer on "product")
When  the guide reaches a step where an optional role would help
Then  it asks: "Your profile includes optional UX design — want to include it?"
And   the user can opt in or skip for this run
```

## Notes

- This story modifies the existing `/horse:guide` command — not a new command
- The guide should feel like a natural conversation that adapts, not a rigid checklist that skips items
- Each profile's workflow is a subset of the full workflow, not a completely different flow
- Steps that are skipped should be mentioned briefly so users know they exist
- The guide should use the planner agent persona for planning steps, architect for design steps, etc. — scope doesn't change which agent handles which step, only which steps run
- Depends on: US-096 (scope profiles), US-097 (scope Q&A)
