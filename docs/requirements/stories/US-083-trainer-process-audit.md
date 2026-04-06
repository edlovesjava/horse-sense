---
id: US-083
title: Trainer agent with process audit skill and command
status: done
priority: Must Have
story_points: 8
section: "3.12 Trainer — Process Quality Auditing"
---

# US-083 — Trainer agent with process audit skill and command

> As a **developer**, I want **a trainer agent that audits SDLC artifacts and process trails** so that **I can verify my requirements, designs, plans, and code are complete, consistent, and traceable**.

## Context

The trainer agent (added in Sprint 3) acts as a QA engineer for the *process* rather than the *code*. It audits requirements, designs, plans, and decision trails for completeness and consistency. This story covers the supporting skill and slash command to make the trainer fully operational.

The trainer agent (`agents/trainer.md`) already exists. This story adds:

- A process audit skill (`skills/process-audit/SKILL.md`) with step-by-step guidance
- A slash command (`/horse:audit`) to invoke the trainer

## Acceptance Criteria

```gherkin
Given a project with SDLC artifacts (requirements, architecture, plans)
When  the /horse:audit command is invoked
Then  the trainer audits all artifacts using the process-audit skill
And   it produces a structured report with severity labels (gap/weak/drift/good)
And   findings are grouped by category (requirements, design, plan, trail)

Given a specific artifact type (e.g., "requirements" or "design")
When  the /horse:audit command is invoked with that scope
Then  only the specified artifact category is audited

Given a project with traceable artifacts
When  the trail audit runs
Then  it verifies requirement → design → code → test traceability
And   it reports orphan features and orphan requirements
```

## Notes

- The trainer agent persona already exists in `agents/trainer.md`
- The skill should reference the audit checklists already in the agent prompt
- Consider adding a `templates/audit_report.md` template for structured output
