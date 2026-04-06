# Sprint 4 Plan: Phase 1 Close-out, Trainer Audit & Readiness Gates

> **Sprint**: 4
> **Duration**: 2026-04-06 → 2026-04-13 (1 week)
> **Team capacity**: 30 SP core + ~10 SP stretch (at Sprint 3 velocity of 41 SP)
> **Sprint goal**: Close out Phase 1 by landing deferred TypeScript/E2E validation and the trainer audit skill, plus ship the readiness-gate policy and enforcement hooks from the Sprint 3 retro.

---

## Sprint Goal

Three objectives, in priority order:

1. **Phase 1 close-out** — land the Sprint 3 carryover (TypeScript scaffolding, end-to-end validation for Python and TypeScript) and complete the trainer agent's tooling (process-audit skill, `/horse:audit` command, audit report template). After this sprint, Phase 1 is fully shipped.

2. **Readiness-gate policy & enforcement** — deliver the five-gate readiness ladder from the Sprint 3 retrospective: policy doc (ADR-0007), CI hooks enforcing commit/push/merge gates, doc-sync check, and a workflow rules doc covering the "fresh branch + single branch + single PR" discipline. Trainer owns this stream.

3. **Phase 2 kickoff (stretch)** — if core work lands early, begin Epic 4 with the trail definition format and the first trail (`trails/feature_delivery.md`). This unblocks Sprint 5 orchestrator work.

---

## Sprint Backlog

### Part 1: Phase 1 Close-out (deferred from Sprint 3)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-025 | Update `scripts/new_project.sh` to support TypeScript scaffolding | US-051 | 3 | ⬜ To Do |
| T-026 | End-to-end validation: install plugin into a fresh Python project | US-001, US-002 | 3 | ⬜ To Do |
| T-027 | End-to-end validation: install plugin into a fresh TypeScript project | US-001, US-051 | 3 | ⬜ To Do |
| | **Part 1 subtotal** | | **9** | |

### Part 2: Trainer Audit Skill & Command (US-083)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-037 | Create `skills/process-audit/SKILL.md` — step-by-step audit skill for the trainer agent | US-083 | 5 | ✅ Done |
| T-038 | Create `commands/audit.md` — `/horse:audit` slash command | US-083 | 2 | ✅ Done |
| T-039 | Create `templates/audit_report.md` — structured audit report template | US-083 | 1 | ✅ Done |
| | **Part 2 subtotal** | | **8** | |

### Part 3: Readiness-Gate Policy & Enforcement (Sprint 3 retro action items)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-130 | ADR-0007: five-gate readiness policy (ready-for-sprint → ready-for-commit → ready-for-push → ready-for-review → ready-for-merge) | — | 3 | ⬜ To Do |
| T-131 | CI hooks enforcing commit/push/merge gates (unit → integration/e2e → review/doc-sync) in `horse/templates/ci.yml` | US-077 | 5 | ⬜ To Do |
| T-132 | Doc-sync check for "ready-for-review" gate (story status ↔ index table ↔ code references) | — | 3 | ⬜ To Do |
| T-133 | Branch/PR workflow doc: "fresh branch + single branch + single PR" rules; propose supporting skills/commands/hooks | — | 2 | ⬜ To Do |
| T-134 | Housekeeping: back-transition any Sprint 3 story drift (frontmatter ↔ index parity audit) | — | 1 | ⬜ To Do |
| | **Part 3 subtotal** | | **14** | |

| | **Parts 1–3 subtotal (core)** | | **31** | |

### Part 4: Phase 2 Trail Definitions (Stretch Goal — Epic 4)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-030 | Define trail document format (frontmatter, steps, gates, flow control) | US-025, US-026, US-027 | 5 | ⬜ To Do |
| T-031 | Create `trails/feature_delivery.md` (full SDLC lifecycle) | US-025, US-040 | 5 | ⬜ To Do |
| | **Part 4 subtotal (stretch)** | | **10** | |

| | **Sprint 4 Total (with stretch)** | | **41** | |

### Status Key

- ⬜ To Do
- 🔵 In Progress
- 🔍 In Review
- ✅ Done
- 🚫 Blocked

---

## Stories In Sprint

| Story | Title | Status before | Status after sprint start |
|---|---|---|---|
| US-083 | Trainer agent with process audit skill and command | Draft | 🔵 In Progress |
| US-025 | Trail definition documents (stretch) | Draft | 🔵 In Progress |

Phase 1 close-out tasks (T-025/T-026/T-027) are verification/follow-up work against stories already marked `done` (US-051, US-001, US-002) and are tracked as non-story technical tasks rather than reopening those stories. Part 3 retro items are process work and do not correspond to user stories.

---

## Task Details

### T-025: TypeScript scaffolding in `scripts/new_project.sh`

Add a `--language typescript` branch (or auto-detect) to `horse/scripts/new_project.sh` that scaffolds a Node.js/TypeScript project: `package.json`, `tsconfig.json`, vitest + eslint + prettier dev dependencies, `src/` and `tests/` directories, starter `.claude/config.json` derived from `templates/config.example.typescript.json`.

**Acceptance**: Running the script with `--language typescript` produces a working TS project that passes `make check` and runs the typescript-setup skill cleanly.

---

### T-026: End-to-end validation — Python project

Install the plugin into a fresh Python project via `claude --plugin-dir ./horse`. Verify: all `/horse:*` commands load, agents appear in `/agents`, python-venv skill bootstraps the environment, python-setup/pytest/ruff toolchain runs, config auto-detection populates `.claude/config.json` from `pyproject.toml`. Record findings in a short validation log under `docs/validation/`.

**Acceptance**: Validation log exists with a pass/fail checklist. Any gaps filed as follow-up tasks.

---

### T-027: End-to-end validation — TypeScript project

Same as T-026 but for a fresh TypeScript project scaffolded by T-025. Exercises the TS branch end-to-end (typescript-setup skill, vitest, eslint, tsc, prettier).

**Acceptance**: Validation log exists; TS toolchain works end-to-end from a clean directory.

---

### T-037: `skills/process-audit/SKILL.md`

Step-by-step audit skill for the trainer agent. Should:

1. Identify the audit scope (full / requirements / design / plan / trail)
2. Load artifacts from `docs/requirements/`, `docs/architecture/`, `docs/plans/`, sprint plans
3. Check completeness, internal consistency, and cross-artifact traceability (req → design → story → task → code)
4. Label findings with severity: `gap`, `weak`, `drift`, `good`
5. Emit a structured report using `templates/audit_report.md`
6. Reference the audit checklists already embedded in `agents/trainer.md`

**Acceptance**: Skill drives a real audit on this repo and produces a report with categorized findings.

---

### T-038: `commands/audit.md` — `/horse:audit`

Slash command that invokes the trainer agent with the process-audit skill. Supports optional scope argument (`/horse:audit requirements`, `/horse:audit design`, etc.). References `${CLAUDE_PLUGIN_ROOT}/skills/process-audit/SKILL.md` and `${CLAUDE_PLUGIN_ROOT}/templates/audit_report.md`.

**Acceptance**: `/horse:audit` runs the trainer end-to-end with correct frontmatter and path refs.

---

### T-039: `templates/audit_report.md`

Report scaffold with sections: scope, artifacts audited, findings by category (requirements/design/plan/trail) with severity labels, traceability matrix, open questions, recommended follow-ups.

**Acceptance**: Template exists and is referenced by both the skill and the command.

---

### T-130: ADR-0007 — Readiness-gate policy

ADR at `docs/architecture/adr/0007-readiness-gate-policy.md` documenting the five-gate ladder from the Sprint 3 retro:

1. **Ready for sprint** — meets Definition of Ready
2. **Ready for commit** — unit tests pass locally
3. **Ready for push** — integration & e2e tests pass
4. **Ready for review** — doc-sync verified (story status ↔ index ↔ code)
5. **Ready for merge** — human review & approval

Each gate specifies: automated check(s), owner (trainer for automation; human for review gate), failure behaviour, bypass rules. Supersedes any ad-hoc process in the retro notes.

**Acceptance**: ADR merged; referenced from `CLAUDE.md` and trainer agent prompt.

---

### T-131: CI hooks enforcing gates

Extend `horse/templates/ci.yml` with jobs matching the three automatable gates:

- **commit gate** — unit tests (`pytest -m unit` / `vitest run tests/unit`)
- **push gate** — integration + e2e tests
- **review gate** — doc-sync check (T-132) + markdown lint + frontmatter validation + structure validation

Jobs run in sequence; downstream gates skip if an upstream gate fails. Document how to run each gate locally via `make check`, `make gate-commit`, `make gate-push`, `make gate-review`.

**Acceptance**: CI template runs the three gates on both Python and TypeScript matrix jobs; the horse-sense repo's own CI adopts the template.

---

### T-132: Doc-sync check

Validation script (bash or python under `horse/scripts/`) that enforces parity between:

- Story frontmatter `status` field
- Requirements index table status column
- Sprint plan task status for tasks referencing the story
- Project plan Epic table status

Exits non-zero with a diff-style report on mismatch. Integrated into the review gate (T-131).

**Acceptance**: Script runs via `make check` and catches deliberate drift seeded in a test fixture.

---

### T-133: Branch/PR workflow rules doc

Document at `docs/process/workflow_rules.md` covering:

- **Fresh branch** — always `git fetch && git pull` before committing; never start work on a stale branch
- **Single branch** — one active branch per developer at a time; no parallel feature branches
- **Single PR** — one PR in flight unless explicitly authorized; avoid review context-switching

Propose hooks/skills/commands to support the rules (e.g. pre-commit freshness check; `/horse:branch` helper; warning when opening a second PR).

**Acceptance**: Doc merged, referenced from trainer agent prompt and `CLAUDE.md`.

---

### T-134: Sprint 3 drift audit

Run the doc-sync check (T-132) against the current repo state and fix any residual drift from the Sprint 3 back-transition. The retro noted this was addressed by the sprint-status refactor; this task verifies closure.

**Acceptance**: Doc-sync check runs clean; any remaining drift resolved in a single housekeeping commit.

---

### T-030 (stretch): Trail document format

Define the trail format in `docs/process/trail_format.md` (or extend architecture docs). Trails are Markdown with YAML frontmatter containing: id, name, owner, steps, gates, loop limits, human checkpoints. Each step names the agent(s), input artifacts, output artifacts, and exit criteria. Include a minimal example.

**Acceptance**: Format documented; one example trail validates against it (T-031).

---

### T-031 (stretch): `trails/feature_delivery.md`

First concrete trail covering the full SDLC lifecycle: requirements → design → plan → implement → test → review → deploy. Uses the format from T-030. References worker agents (planner, architect, developer, tester, reviewer), readiness gates (ADR-0007), and human checkpoints.

**Acceptance**: Trail file merged; orchestrator in Sprint 5 can read and follow it.

---

## Capacity Planning

| Team Member | Available Days | Capacity (pts) | Assigned (pts) |
|---|---|---|---|
| Ed Wentworth | 5 | 30 + stretch | 31 core + 10 stretch |
| **Total** | **5** | **30 + stretch** | **41** |

---

## Risks & Blockers

| Risk | Impact | Mitigation |
|---|---|---|
| CI gate implementation (T-131) larger than scoped | Med | Keep gates as thin wrappers around existing `make` targets; don't redesign the test pyramid in this sprint |
| Doc-sync script (T-132) could grow unbounded | Med | Start with exact-string comparison on status field only; expand later if needed |
| E2E validation (T-026/T-027) may surface latent plugin bugs | Med | Capture bugs as follow-ups, don't block sprint on unrelated fixes |
| Trail format (T-030) is Phase 2 foundational — easy to over-design | Med | Stretch only; minimum viable format with one example, iterate in Sprint 5 |
| Trainer audit skill scope creep (audit is open-ended) | Low | Restrict to severity-labelled findings using existing checklists in `agents/trainer.md` |

---

## Definition of Done

A task is **Done** when:

- [ ] Implementation matches task description and acceptance criteria
- [ ] `make check` passes (structure, frontmatter, markdown, shellcheck, JSON schema)
- [ ] Doc-sync check (once T-132 lands) passes
- [ ] No broken internal references in plugin
- [ ] New skills/commands/templates are config-aware where applicable
- [ ] Changes committed with Conventional Commits format
- [ ] Story status (frontmatter + index table) updated if story completes

---

## Daily Standup Notes

### Day 1 — 2026-04-06

| Person | Yesterday | Today | Blockers |
|---|---|---|---|
| Ed | Sprint 3 close-out | Sprint 4 kickoff; start T-025 or T-130 | None |

---

## Sprint Review Notes

**Demo completed**: ☐ Yes / ☐ No
**Sprint goal achieved**: ☐ Yes / ☐ Partial / ☐ No
**Velocity**: [N story points completed]

### What was delivered

- _[fill in at close]_

### What was not completed (and why)

- _[fill in at close]_

---

## Retrospective Notes

_[fill in via `/horse:retrospective` at sprint end]_
