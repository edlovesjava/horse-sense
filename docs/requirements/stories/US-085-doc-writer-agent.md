---
id: US-085
title: Doc writer agent persona
status: in-progress
priority: Must Have
story_points: 5
section: "3.13 Doc Writer — Documentation Authoring & Maintenance"
---

# US-085 — Doc writer agent persona

> As a **developer**, I want **a dedicated doc writer agent that owns documentation authoring and maintenance** so that **project documentation stays complete, accurate, and consistent without relying on ad-hoc effort spread across other agents**.

## Context

Documentation authoring is currently fragmented across five agents: the architect writes ADRs, the planner writes project docs, the developer writes docstrings, the scout writes spike reports, and the reviewer checks doc existence. No single agent owns "Is our documentation complete, accurate, and up to date?"

The plugin's `rules/documentation.md` mandates READMEs, CHANGELOGs, Mermaid diagrams, and Markdown standards — but no agent or skill guides their creation. The trainer can flag "docs are stale" but cannot fix them. This gap causes documentation debt to accumulate.

The doc writer agent (`agents/doc-writer.md`) fills this gap as a dedicated technical writer persona that:

- Authors and maintains project-facing documentation (READMEs, guides, API docs, CHANGELOGs)
- Creates and reviews Mermaid diagrams across all diagram types
- Reviews and improves inline code documentation (docstrings, comments)
- Composes the documentation, diagrams, code-docs, and doc-review skills

## Acceptance Criteria

```gherkin
Given the horse plugin is installed
When  a user needs documentation authored or maintained
Then  the doc-writer agent is available as a worker agent persona

Given the doc-writer agent is active
When  it authors documentation
Then  it follows all standards in rules/documentation.md
And   it reads .claude/config.json for project context (language, framework, paths)

Given the doc-writer agent is active
When  it creates or updates documentation
Then  it verifies accuracy against the current state of the codebase
And   it does not introduce claims that contradict the code

Given the doc-writer agent is active
When  the trainer audits documentation artifacts
Then  the doc-writer can remediate any gaps or issues the trainer identifies
```

## Notes

- The doc writer is a worker agent, not an orchestrator — it composes skills to do its work
- The doc writer complements the reviewer (who checks doc *existence*) by owning doc *quality and content*
- The doc writer complements the trainer (who audits doc *completeness*) by owning doc *authoring and remediation*
- The agent should have expertise in: technical writing, Markdown, Mermaid, and code documentation conventions
