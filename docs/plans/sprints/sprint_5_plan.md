# Sprint 5 Plan: Phase 2 Core — Epic 5 Orchestrator & Monitor Agents

> **Sprint**: 5
> **Duration**: 2026-04-09 → 2026-04-16 (1 week)
> **Team capacity**: 30 SP core + ~10 SP stretch (at sustained velocity of 41 SP)
> **Sprint goal**: Complete Phase 2: Process Orchestration by delivering Epic 5 — the SDLC orchestrator, sprint orchestrator, and loop monitor agents that transform the plugin from a collection of independent skills into a coordinated SDLC workflow.

---

## Sprint Goal

One primary objective and one stretch stream, in priority order:

1. **Epic 5: Orchestrator & Monitor Agents (M6)** — create the three orchestrator-tier agents (`sdlc`, `sprint-orchestrator`, `monitor`), wire them into the `/horse:guide` and `/horse:sprint` commands, and validate end-to-end by running the feature-delivery trail on a test project. This is the Phase 2 core milestone: after this sprint the plugin can autonomously drive a feature from requirements through deployment.

2. **Missing trail documents (stretch)** — the three trails deferred from Epic 4 (`sprint_execution.md`, `bug_fix.md`, `code_review.md`) directly feed the orchestrators. Pull them in if core work completes ahead of schedule. Only if trails are complete does the US-084 project-init command become eligible for capacity.

---

## Sprint Backlog

### Part 1: Epic 5 — Orchestrator & Monitor Agents (Core)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-040 | Create `agents/sdlc.md` — SDLC orchestrator agent that reads `trails/feature_delivery.md` and directs worker agents through the RAITCrD lifecycle | US-023, US-026, US-027, US-028, US-029 | 8 | ✅ Done |
| T-041 | Create `agents/sprint-orchestrator.md` — Sprint orchestrator agent that manages story-level iteration (implement → test → review loop) | US-023 | 5 | ✅ Done |
| T-042 | Create `agents/monitor.md` — Loop quality monitor agent that watches iteration loops, flags non-convergence, and suggests pivots | US-024 | 5 | ✅ Done |
| T-043 | Update `/horse:guide` command to invoke the SDLC orchestrator | US-040, US-041 | 3 | ✅ Done |
| T-044 | Update `/horse:sprint` command to invoke the Sprint orchestrator | US-040 | 2 | ✅ Done |
| T-045 | End-to-end validation: run the feature-delivery trail on a test project | US-029, US-040, US-041 | 5 | ✅ Done |
| | **Part 1 subtotal (core)** | | **28** | |

### Part 2: Missing Trail Documents (Stretch Goal — Epic 4 leftover)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-032 | Create `trails/sprint_execution.md` (story-level iteration: plan → implement → test → review) | US-025 | 3 | ✅ Done |
| T-033 | Create `trails/bug_fix.md` (triage → fix → verify) | US-025 | 3 | ✅ Done |
| T-034 | Create `trails/code_review.md` (review → feedback → resolve) | US-025 | 2 | ✅ Done |
| | **Part 2 subtotal (stretch A)** | | **8** | |

### Part 3: Project Init Command (Stretch Goal — US-084, if capacity remains)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-050 | Create `/horse:init` command (interview-driven project scaffolding per SPIKE-003) | US-084 | 8 | ✅ Done |
| | **Part 3 subtotal (stretch B)** | | **8** | |

| | **Sprint 5 Total (core + stretch A + stretch B)** | | **44** | |

### Status Key

- ⬜ To Do
- 🔵 In Progress
- 🔍 In Review
- ✅ Done
- 🚫 Blocked

---

## Stories In Sprint

| Story | Title | Status before sprint |
|---|---|---|
| US-023 | Orchestrator agent drives the SDLC lifecycle | Draft |
| US-024 | Loop quality monitor flags non-convergence | Draft |
| US-026 | Orchestrator reads trail definitions | Draft |
| US-027 | Orchestrator composes worker agents at each step | Draft |
| US-028 | Human-in-the-loop decision checkpoints pause execution | Draft |
| US-029 | Process execution status reported after each step | Draft |
| US-040 | `/horse:guide` and `/horse:sprint` invoke orchestrators | Draft |
| US-041 | Feature-delivery trail drives end-to-end validation | Draft |
| US-025 | Trail definition documents (T-032/T-033/T-034 remainder, stretch) | In Progress |

T-043 and T-044 update existing commands; no new stories are opened for those tasks. US-084 (project-init command) remains in backlog unless stretch B capacity materialises.

---

## Task Details

### T-040: `agents/sdlc.md` — SDLC orchestrator agent

YAML frontmatter agent file in `horse/agents/`. This is the top-level orchestrator. It must:

1. Read the trail definition at `horse/trails/feature_delivery.md` on activation.
2. Evaluate the current step's readiness gate (ADR-0007) before advancing.
3. Dispatch the appropriate worker agent(s) for the current step using the Agent tool or sub-agent composition.
4. Record step completion status and output artifacts in `docs/process/execution_log.md` (or equivalent tracking file).
5. Pause at human checkpoints (marked `human_checkpoint: true` in the trail) and await explicit approval before advancing.
6. Enforce loop limits from the trail (`max_iterations` per step); escalate to the monitor agent when a loop limit is approached.
7. Surface a step-level status summary after each step completes.

Worker agents used: planner, architect, developer, tester, reviewer, trainer, scout.

**Acceptance**: Agent file exists with correct plugin frontmatter; a dry-run invocation on a minimal feature request advances through at least two trail steps, pauses at the first human checkpoint, and logs status correctly.

---

### T-041: `agents/sprint-orchestrator.md` — Sprint orchestrator agent

YAML frontmatter agent file in `horse/agents/`. Manages story-level iteration within a single sprint:

1. Read the active sprint plan and enumerate `⬜ To Do` tasks.
2. For each story, invoke the implement → test → review loop using the developer, tester, and reviewer worker agents.
3. Detect when a loop is not converging (repeated test/review failures on the same story) and escalate to the monitor agent.
4. Update task status in the sprint plan (🔵 In Progress → 🔍 In Review → ✅ Done) as work progresses.
5. Enforce the doc-sync check (readiness gate 4) before marking a story done.

**Acceptance**: Agent file exists; a dry-run on a minimal sprint plan with one story advances the story through all three loop phases and updates its status.

---

### T-042: `agents/monitor.md` — Loop quality monitor agent

YAML frontmatter agent file in `horse/agents/`. Activated by the orchestrators when:

- A loop's iteration count approaches the trail's `max_iterations` limit, or
- The same test or review failure repeats across two or more iterations.

Responsibilities:

1. Analyse the iteration history and failure pattern.
2. Classify the failure: scope ambiguity, implementation bug, test flakiness, requirements gap.
3. Recommend a concrete pivot: refine requirements, split the story, skip the step with a documented caveat, or escalate to a human.
4. Emit a structured monitor report and pause for human review if no safe pivot exists.

**Acceptance**: Agent file exists; given a simulated non-converging loop log, the monitor correctly classifies the failure and produces a pivot recommendation.

---

### T-043: Update `/horse:guide` — invoke SDLC orchestrator

Modify `horse/commands/guide.md` so that after the kickoff interview and project scaffolding it hands control to `agents/sdlc.md`. The command must:

- Reference `${CLAUDE_PLUGIN_ROOT}/agents/sdlc.md` and `${CLAUDE_PLUGIN_ROOT}/trails/feature_delivery.md`.
- Pass the feature name and scope from the kickoff interview as context to the orchestrator.
- Document how to resume an interrupted run (re-invoke `/horse:guide` with `--resume`).

**Acceptance**: Updated command file references the orchestrator correctly; no broken internal links; `make check` passes.

---

### T-044: Update `/horse:sprint` — invoke Sprint orchestrator

Modify `horse/commands/sprint.md` so that the "execute sprint" phase delegates to `agents/sprint-orchestrator.md` instead of describing manual steps. The command must:

- Reference `${CLAUDE_PLUGIN_ROOT}/agents/sprint-orchestrator.md`.
- Pass the current sprint plan path as context.
- Preserve the existing pre-flight check and post-merge close-out gate sequence added in Sprint 4.

**Acceptance**: Updated command file references the sprint orchestrator correctly; `make check` passes.

---

### T-045: End-to-end validation — feature-delivery trail on a test project

Run the full feature-delivery trail via the SDLC orchestrator on a minimal test feature (e.g., "add a `hello` function to the horse-sense repo"). Document the run in `docs/validation/e2e_orchestrator_validation.md`.

Validation checklist:

- [ ] Orchestrator reads `trails/feature_delivery.md` without error
- [ ] Steps 1–7 each activate the correct worker agent
- [ ] Readiness gates are evaluated at each step boundary
- [ ] Human checkpoints pause execution and resume correctly
- [ ] Monitor agent activates if a loop limit is reached during the test
- [ ] Step status log is written after each step
- [ ] Sprint orchestrator manages the implementation loop (steps 4–6)
- [ ] Final output matches the feature delivery trail's exit criteria

Any integration issues found must be filed as follow-up tasks; they do not block sprint close-out unless they prevent the trail from reaching step 7.

**Acceptance**: Validation doc exists with the checklist completed. At least steps 1–3 complete end-to-end without manual intervention.

---

### T-032 (stretch): `trails/sprint_execution.md`

Trail covering story-level iteration within a sprint. Steps:

1. Requirements review (planner confirms story is ready-for-sprint)
2. Implementation (developer)
3. Testing (tester)
4. Code review (reviewer)
5. Doc-sync check (trainer)
6. Human sign-off checkpoint

Include: `max_iterations: 3` for the implement → test → review loop; a branch-back from step 4 to step 2 on review failure; a loop-limit escalation to the monitor agent.

**Acceptance**: Trail file exists; consistent with the format in `docs/process/trail_format.md`; referenced from the sprint orchestrator (T-041).

---

### T-033 (stretch): `trails/bug_fix.md`

Trail covering a bug-fix lifecycle: triage → fix → verify. Steps:

1. Triage (scout or developer identifies root cause and affected components)
2. Fix (developer implements the minimal change)
3. Regression test (tester verifies fix and adds a regression test)
4. Review (reviewer confirms fix scope is minimal and no new issues introduced)
5. Human checkpoint before merge

Include: `max_iterations: 2` for the fix → verify loop; escalation path if root cause is unclear after triage.

**Acceptance**: Trail file exists; consistent with trail format; loop limits and escalation path defined.

---

### T-034 (stretch): `trails/code_review.md`

Trail covering a standalone code review cycle: review → feedback → resolve. Steps:

1. Review (reviewer reads the diff and produces structured comments with severity labels)
2. Feedback triage (developer accepts, defers, or disputes each comment)
3. Resolution (developer addresses accepted comments)
4. Re-review (reviewer confirms resolution)
5. Human approval checkpoint

Include: `max_iterations: 2` for the review → resolve loop; escalation if disputes remain unresolved after two passes.

**Acceptance**: Trail file exists; consistent with trail format; used by the SDLC orchestrator at the code-review step of `feature_delivery.md`.

---

## Capacity Planning

| Team Member | Available Days | Capacity (pts) | Assigned (pts) |
|---|---|---|---|
| Ed Wentworth | 5 | 30 + stretch | 28 core + 8 stretch A + 8 stretch B |
| **Total** | **5** | **30 + stretch** | **44** |

Stretch B (T-050, `/horse:init`) is only attempted if core and stretch A both complete with time remaining. Given T-040's complexity (8 SP), treat the first three days as core-only. Reassess stretch eligibility at Day 3 standup.

---

## Risks & Blockers

| Risk | Impact | Mitigation |
|---|---|---|
| Orchestrator complexity (loop state, gate evaluation, branch-back) — T-040 is the highest-risk task | High | Time-box design to Day 1; start with a linear walk-through of steps 1–3 before adding branch-back and loop logic |
| Agent tool behavior for sub-agent dispatch is uncharted in the plugin | High | Spike within T-040: test a minimal two-agent handoff before writing the full orchestrator prompt |
| End-to-end validation (T-045) may surface integration gaps between the three orchestrator agents | Med | File integration issues as follow-up tasks; do not let them block sprint close-out |
| T-040 and T-041 are tightly coupled — changes to one may invalidate the other | Med | Write T-042 (monitor) after T-040 and T-041 are stable; keep monitor interface narrow |
| Stretch A trails (T-032/T-033/T-034) block if core runs long | Low | Trails are independent of core tasks and can be written in parallel with T-042 on Day 3+ |

---

## Definition of Done

A task is **Done** when:

- [ ] Implementation matches task description and acceptance criteria
- [ ] `make check` passes (structure, frontmatter, markdown, shellcheck, JSON schema)
- [ ] Doc-sync check passes (story status frontmatter, index table, sprint plan, project plan all consistent)
- [ ] No broken internal references in plugin
- [ ] Agent files have correct YAML frontmatter and are auto-discoverable in `horse/agents/`
- [ ] Changes committed with Conventional Commits format
- [ ] Story status (frontmatter + index table) updated if story completes

---

## Daily Standup Notes

### Day 1 — 2026-04-09

| Person | Yesterday | Today | Blockers |
|---|---|---|---|
| Ed | Sprint 4 close-out (all 41 SP delivered) | Sprint 5 kickoff; spike on Agent tool sub-agent dispatch; begin T-040 design | None |

---

## Sprint Review Notes

_[fill in via `/horse:sprint` at sprint end]_

---

## Retrospective Notes

_[fill in via `/horse:retrospective` at sprint end]_
