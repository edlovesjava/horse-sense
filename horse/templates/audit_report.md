# Audit Report: {{title}}

> **Date**: {{date}}
> **Auditor**: Trainer agent
> **Scope**: {{scope — full / requirements / design / plan / trail}}
> **Project phase**: {{phase — e.g., Sprint 3, pre-release, early exploration}}

---

## Scope & Objectives

- **What was audited**: {{list of artifact categories and directories examined}}
- **What was excluded**: {{anything explicitly out of scope}}
- **Audit criteria**: completeness, internal consistency, cross-artifact traceability

---

## Artifacts Audited

| Category | Artifact | Path | Reviewed |
|---|---|---|---|
| Requirements | Requirements index | `docs/requirements/requirements_doc.md` | ☐ |
| Requirements | User stories | `docs/requirements/stories/` | ☐ |
| Design | Architecture document | `docs/architecture/architecture_doc.md` | ☐ |
| Design | ADRs | `docs/architecture/adr/` | ☐ |
| Plan | Project plan | `docs/plans/project_plan.md` | ☐ |
| Plan | Sprint plans | `docs/plans/sprints/` | ☐ |
| Trail | Process trails | `trails/` | ☐ |

---

## Findings

### Requirements

| # | Finding | Severity | Details |
|---|---|---|---|
| 1 | {{finding}} | `[gap]` / `[weak]` / `[drift]` / `[good]` | {{details}} |

### Design

| # | Finding | Severity | Details |
|---|---|---|---|
| 1 | {{finding}} | `[gap]` / `[weak]` / `[drift]` / `[good]` | {{details}} |

### Plan

| # | Finding | Severity | Details |
|---|---|---|---|
| 1 | {{finding}} | `[gap]` / `[weak]` / `[drift]` / `[good]` | {{details}} |

### Trail

| # | Finding | Severity | Details |
|---|---|---|---|
| 1 | {{finding}} | `[gap]` / `[weak]` / `[drift]` / `[good]` | {{details}} |

---

## Summary

| Severity | Count |
|---|---|
| `[gap]` — missing artifact or broken trail | {{n}} |
| `[weak]` — incomplete or vague | {{n}} |
| `[drift]` — inconsistent process adherence | {{n}} |
| `[good]` — practice worth highlighting | {{n}} |

---

## Traceability Matrix

| Requirement | Design | Code | Test | Status |
|---|---|---|---|---|
| US-NNN | ADR-NNNN / section | `src/...` | `tests/...` | ✅ Traced / ⚠️ Partial / ❌ Missing |

---

## Open Questions

| # | Question | Owner | Priority |
|---|---|---|---|
| 1 | {{question}} | {{owner}} | High / Medium / Low |

---

## Recommended Follow-ups

- [ ] {{action item with owner and target date}}
- [ ] {{action item with owner and target date}}
- [ ] {{action item with owner and target date}}
