---
id: US-096
title: Project scope profiles
status: draft
priority: Must Have
story_points: 5
section: "3.17 Project Scope Profiles"
---

# US-096 — Project scope profiles

> As a **developer**, I want **a `project_scope` setting in `horse.config.md` that defines the process weight for my project** so that **the plugin adapts its roles, artifacts, and workflow steps to match the actual scope of work instead of applying heavyweight process to everything**.

## Context

The plugin currently applies the same full SDLC process to every project — a weekend PoC gets prompted for ADRs, sprint plans, and quality gates just like a production SaaS product. This friction drives users to skip the plugin on small projects where it should be most helpful.

SPIKE-008 identified five natural scope profiles that cover the spectrum from throwaway investigations to enterprise systems. A single config field lets every command and skill adapt its behavior.

The five profiles:

| Profile | Description | Team Size |
|---|---|---|
| **spike** | Timeboxed investigation, throwaway code | 1 |
| **poc** | Proof of concept, validate an idea | 1 |
| **project** | Real project with users and maintenance | 1–3 |
| **product** | Product with roadmap, releases, business outcomes | 2–5 |
| **enterprise** | Large-scale system, compliance, multiple teams | 5+ |

## Acceptance Criteria

```gherkin
Given a project using the horse plugin
When  horse.config.md contains project_scope: spike
Then  only the scout and developer roles are active
And   the guide workflow skips planning, architecture, and formal testing steps
And   the expected output is a spike report and working code

Given a project using the horse plugin
When  horse.config.md contains project_scope: poc
Then  the developer and basic tester roles are active
And   the guide workflow includes lightweight requirements and basic tests
And   architecture, sprint planning, and formal review are skipped

Given a project using the horse plugin
When  horse.config.md contains project_scope: project
Then  developer, planner, architect, tester, reviewer, and doc-writer roles are active
And   the guide workflow includes requirements, architecture, sprint planning, TDD, and review
And   product-level artifacts (PRD, roadmap) are optional

Given a project using the horse plugin
When  horse.config.md contains project_scope: product
Then  all project roles plus the product manager lens are active
And   the guide workflow includes product vision, PRD, roadmap, quality plan, and sprint planning
And   designer and ops roles are optional (activated via override)

Given a project using the horse plugin
When  horse.config.md contains project_scope: enterprise
Then  all roles are active including designer and ops
And   the guide workflow includes all artifacts plus DDD, compliance gates, and infrastructure planning

Given horse.config.md does not contain project_scope
When  any command or skill checks the scope
Then  it defaults to "project" (the most common case)
And   the user is prompted to set the scope on first run of /horse:guide

Given any scope profile
When  a user manually invokes a command outside their profile (e.g., /horse:arch on a poc)
Then  the command runs normally — scope is advisory, not blocking
And   the command may note that this artifact is not required for the current profile
```

## Notes

- The `project_scope` field goes in `horse.config.md` (workflow config), not `.claude/config.json` (toolchain config)
- Default is "project" if omitted — this matches the current behavior
- Scope is advisory: it controls what the guide workflow *prompts for* and what agents *suggest*, but never blocks a manual command invocation
- See SPIKE-008 for the full role/artifact/step mapping per profile
