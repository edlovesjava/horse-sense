---
name: process-audit
description: Audit SDLC artifacts for completeness, consistency, and cross-artifact traceability, producing a structured report with severity-labelled findings
---

# Skill: Process Audit

## Purpose

Systematically audit project artifacts — requirements, designs, plans, and process trails — for completeness, internal consistency, and cross-artifact traceability. Produce a structured report with severity-labelled findings that the team can act on.

## Configuration

Read `horse.config.md` for `requirements_format`, `requirements_stories_dir`, and `git_strategy`. Read `.claude/config.json` for project-level settings (language, framework, test runner).

See `${CLAUDE_PLUGIN_ROOT}/schemas/config.schema.json` for the full config schema.

## Workflow

```
Identify scope → Load artifacts → Audit each category → Check traceability → Generate report
```

### Step 1: Identify Audit Scope

Determine what to audit. The scope is one of:

| Scope | What is audited |
|---|---|
| `full` | All categories below |
| `requirements` | Requirements index, user stories |
| `design` | Architecture document, ADRs |
| `plan` | Project plan, sprint plans |
| `trail` | Cross-artifact traceability (req → design → code → test) |

If no scope is specified, default to `full`.

Ask the user what phase the project is in — expectations differ between early exploration and pre-release hardening. Adjust severity accordingly (e.g., missing tests are `[weak]` during design but `[gap]` before release).

### Step 2: Load Artifacts

Gather the artifacts for the selected scope:

#### Requirements

- Read `docs/requirements/requirements_doc.md` (or the index file for per-story mode)
- If per-story: scan `requirements_stories_dir` for individual story files
- Check YAML frontmatter in each story file for status, priority, story points

#### Design

- Read `docs/architecture/architecture_doc.md` (if it exists)
- Scan `docs/architecture/adr/` for ADR files
- Check ADR structure: context, decision, consequences, status

#### Plan

- Read `docs/plans/project_plan.md` (if it exists)
- Scan `docs/plans/sprints/` for sprint plan files
- Cross-reference sprint tasks against user stories

#### Trail

- Map requirement → design → code → test chains
- Identify orphan code (implemented but undocumented)
- Identify orphan requirements (documented but unimplemented and marked done)

### Step 3: Audit Each Category

Apply the checklists from `${CLAUDE_PLUGIN_ROOT}/agents/trainer.md`. For each finding, assign a severity label:

| Severity | Meaning | Action |
|---|---|---|
| `[gap]` | Missing artifact or broken trail | Must be addressed to maintain process integrity |
| `[weak]` | Artifact exists but is incomplete or vague | Should be strengthened |
| `[drift]` | Process is being followed inconsistently | Course correction needed |
| `[good]` | Practice worth highlighting | Reinforce — team is doing this well |

#### Requirements Checklist

- [ ] Every user story has title, description, acceptance criteria, and priority
- [ ] Acceptance criteria are specific, measurable, and testable
- [ ] Non-functional requirements are documented
- [ ] Stories follow INVEST principles
- [ ] Dependencies between stories are identified
- [ ] Stories are estimated with story points
- [ ] Story status in frontmatter matches status in the requirements index table

#### Design Checklist

- [ ] Architecture decisions are recorded as ADRs with context, decision, consequences
- [ ] Technology choices include rationale and alternatives considered
- [ ] Security considerations are documented
- [ ] API contracts are defined (if applicable)

#### Plan Checklist

- [ ] Sprint goals are specific and achievable
- [ ] Tasks are linked to user stories
- [ ] Definition of Done is written and enforced
- [ ] Capacity is accounted for
- [ ] Risks and blockers are identified with mitigation plans
- [ ] Velocity is tracked across sprints

#### Trail Checklist

- [ ] Every feature has a traceable path: requirement → design → code → test
- [ ] No orphan code (implemented but undocumented features)
- [ ] No orphan requirements (documented but unimplemented stories marked as done)
- [ ] Review feedback is resolved, not just acknowledged
- [ ] Scope changes are documented with rationale

### Step 4: Check Cross-Artifact Consistency

Regardless of scope, verify internal consistency:

- **Status parity**: Story frontmatter status matches requirements index status
- **Sprint linkage**: Sprint plan tasks reference valid story IDs
- **Estimate consistency**: Story points in stories match those in the index table
- **Naming consistency**: Story file names follow the `US-NNN-kebab-title.md` convention

### Step 5: Generate Report

Create an audit report using the template at `${CLAUDE_PLUGIN_ROOT}/templates/audit_report.md`.

Save the report to `docs/audits/audit-<date>-<scope>.md` (create the directory if needed).

The report must include:

1. **Scope & objectives** — what was audited and why
2. **Artifacts audited** — checklist of what was examined
3. **Findings by category** — requirements, design, plan, trail (as applicable)
4. **Summary** — count of findings by severity
5. **Traceability matrix** — requirement → design → code → test mapping (for full or trail scope)
6. **Open questions** — things that need human decision
7. **Recommended follow-ups** — actionable next steps with owners

### Step 6: Present Findings

Present the report to the user with:

- A one-paragraph executive summary
- The total finding count by severity
- Top 3 most important findings to address first
- Concrete next steps

## Tips

- **Calibrate to the phase** — a project in early requirements gathering won't have code trails; don't report those as gaps
- **Be constructive** — explain *why* the standard exists, not just what was violated
- **Highlight good practices** — `[good]` findings reinforce what the team should keep doing
- **Don't boil the ocean** — focus on findings that materially affect project quality
- **Check git history** — recent commits may have addressed issues; verify before reporting
