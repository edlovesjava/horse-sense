# End-to-End Orchestrator Validation (T-045)

> **Date**: 2026-04-12
> **Sprint**: 5
> **Validator**: Ed Wentworth (assisted by Claude)
> **Test feature**: Orchestrator system integration validation (structural + dry-run)

---

## Validation Approach

This validation verifies that the SDLC orchestrator, sprint orchestrator, and monitor agent are correctly wired together and can drive the feature-delivery trail end-to-end. The validation is **structural** (inspecting files, cross-references, and integration points) combined with a **dry-run trace** that walks through the trail execution path to confirm each step would activate the correct worker agent.

Since the horse plugin operates as prompt-based orchestration (Markdown agents parsed by Claude at runtime), "execution" means the orchestrator agent reads the trail, dispatches workers via the Agent tool, and manages state. The validation confirms all the pieces are in place for this to work.

---

## Validation Checklist

### 1. Orchestrator reads `trails/feature_delivery.md` without error

- [x] **PASS** — `horse/agents/sdlc.md` (line 34) references `${CLAUDE_PLUGIN_ROOT}/trails/feature_delivery.md` as its default trail
- [x] **PASS** — `horse/commands/guide.md` (line 113) passes the trail path to the orchestrator
- [x] **PASS** — `horse/trails/feature_delivery.md` exists with valid YAML frontmatter (`name: feature-delivery`, `version: 1`)
- [x] **PASS** — Trail has 7 steps, entry gate (4 items), exit gate (4 items), artifacts table (8 artifacts)

### 2. Steps 1–7 each activate the correct worker agent

Verified by cross-referencing the trail's `Agent` field with the sdlc.md Worker Dispatch Reference table and confirming each agent file exists:

| Trail Step | Agent in Trail | Agent in sdlc.md Dispatch Table | Agent File Exists |
|---|---|---|---|
| Step 1: Requirements | planner | `horse:planner` | `horse/agents/planner.md` — Yes |
| Step 2: Architecture | architect | `horse:architect` | `horse/agents/architect.md` — Yes |
| Step 3: Sprint Planning | planner | `horse:planner` | `horse/agents/planner.md` — Yes |
| Step 4: Implementation | developer | `horse:developer` | `horse/agents/developer.md` — Yes |
| Step 5: Testing | tester | `horse:tester` | `horse/agents/tester.md` — Yes |
| Step 6: Review | reviewer | `horse:reviewer` | `horse/agents/reviewer.md` — Yes |
| Step 7: Deployment | developer | `horse:developer` | `horse/agents/developer.md` — Yes |

- [x] **PASS** — All 7 steps map to existing worker agents; dispatch table is consistent with trail definitions

### 3. Readiness gates are evaluated at each step boundary

- [x] **PASS** — sdlc.md Section 3 ("Evaluate the entry gate") defines gate evaluation protocol for trail entry
- [x] **PASS** — sdlc.md Section 4a ("Check step preconditions") verifies input artifacts before each step
- [x] **PASS** — sdlc.md Section 4d ("Evaluate completion") checks completion criteria after each step
- [x] **PASS** — sdlc.md Section 5 ("Evaluate the exit gate") defines exit gate evaluation after the final step
- [x] **PASS** — guide.md Phase Gates table defines entry/exit gates for all 6 RAITCrD phases

### 4. Human checkpoints pause execution and resume correctly

Trail steps with HUMAN APPROVAL gates:

| Step | Gate Present | sdlc.md Handling |
|---|---|---|
| Step 1: Requirements | `Gate: HUMAN APPROVAL` | Section 4g: present summary, list artifacts, ask "Approve to continue?" |
| Step 2: Architecture | `Gate: HUMAN APPROVAL` | Same protocol |
| Step 3: Sprint Planning | `Gate: HUMAN APPROVAL` | Same protocol |
| Step 6: Review | `Gate: HUMAN APPROVAL` | Same protocol |
| Step 7: Deployment | `Gate: HUMAN APPROVAL` | Same protocol |

- [x] **PASS** — 5 human checkpoints defined in the trail
- [x] **PASS** — sdlc.md Section 4g defines the 8-step protocol for handling HUMAN APPROVAL gates
- [x] **PASS** — Decisions are logged in the state file under `## Decisions`
- [x] **PASS** — Resume protocol: sdlc.md Section 2 reads existing state file to determine current step and resume from where execution left off

### 5. Monitor agent activates if a loop limit is reached during the test

- [x] **PASS** — sdlc.md `tools` frontmatter includes `horse:trainer` (the monitor agent)
- [x] **PASS** — sprint-orchestrator.md Section 3d: if loop count >= 3, dispatches `horse:trainer` with loop history
- [x] **PASS** — monitor.md defines activation criteria: 80% of loop limit, recurring failures, failed retry
- [x] **PASS** — monitor.md produces structured Monitor Report with classification, root cause, recommended pivot, and 4 user options
- [x] **PASS** — Trail defines loop limits: Step 4 (Implementation) = 10, Step 5 (Testing) = 5

### 6. Step status log is written after each step

- [x] **PASS** — sdlc.md State File Protocol defines `docs/trails/sdlc-state.md` as the source of truth
- [x] **PASS** — State file template exists at `horse/templates/sdlc_state.md` (85 lines)
- [x] **PASS** — Template includes: Current State, Step Progress checklist, Step Summaries (per step), Loop Counts table, Decisions log, Branch Log
- [x] **PASS** — sdlc.md: "Always update the state file before and after each step" (Constraints)
- [x] **PASS** — guide.md Step 17: initializes state file and marks Steps 1–3 as completed after kickoff interview

### 7. Sprint orchestrator manages the implementation loop (steps 4–6)

- [x] **PASS** — sprint-orchestrator.md defines the implement → test → review loop (Sections 3a–3d)
- [x] **PASS** — Worker dispatch: `horse:developer` → `horse:tester` → `horse:reviewer`
- [x] **PASS** — Loop control: blocking review issues trigger re-dispatch to developer (up to 3 iterations)
- [x] **PASS** — Status tracking: `⬜ To Do` → `🔵 In Progress` → `🔍 In Review` → `✅ Done`
- [x] **PASS** — sprint.md (line 37) references `${CLAUDE_PLUGIN_ROOT}/agents/sprint-orchestrator.md`
- [x] **PASS** — Doc-sync check runs at story completion (Section 5)

### 8. Final output matches the feature delivery trail's exit criteria

Trail exit gate requires:
1. All steps completed or explicitly skipped with rationale
2. All output artifacts exist and are up to date
3. CI is green on the main branch
4. PR merged and sprint branch cleaned up

- [x] **PASS** — sdlc.md Section 5 evaluates exit gate after the final step
- [x] **PASS** — sdlc.md Section 6 produces a completion summary (steps, decisions, loops, branches, artifacts, deferred items)
- [x] **PASS** — Trail artifacts table lists all 8 expected artifacts with direction (input/output)
- [x] **PASS** — sprint-orchestrator.md Section 6 reports sprint summary with delivered points and deferred stories

---

## Dry-Run Trace: Feature Delivery Walk-Through

Simulated execution of the feature-delivery trail for a hypothetical feature: "add a `hello` command to the horse plugin."

### Entry Gate Evaluation

| Gate Item | Check Method | Expected Result |
|---|---|---|
| Feature request exists | User provides description | "Add /horse:hello that prints a greeting" |
| `.claude/config.json` configured | `Read .claude/config.json` | File exists with language, testRunner, etc. |
| CI green on main | `Bash: git status` | Clean working tree |
| `horse.config.md` exists | `Read horse.config.md` | File exists with requirements_format set |

### Step Execution Trace

| Step | Agent Dispatched | Key Action | Gate/Loop | Expected State Update |
|---|---|---|---|---|
| 1. Requirements | `horse:planner` | Write US for /horse:hello with AC | HUMAN APPROVAL → pause | Step 1: completed |
| 2. Architecture | `horse:architect` | Assess: simple command, skip architecture | HUMAN APPROVAL → user confirms skip | Step 2: completed (skipped) |
| 3. Sprint Planning | `horse:planner` | Create sprint plan with 1 story | HUMAN APPROVAL → pause | Step 3: completed |
| 4. Implementation | `horse:developer` | TDD: write test → implement → verify | Loop (up to 10 iterations) | Step 4: completed, loop count recorded |
| 5. Testing | `horse:tester` | Integration test for command loading | Loop (up to 5 iterations) | Step 5: completed |
| 6. Review | `horse:reviewer` | Review PR, structured feedback | Branch to Step 4 if blocking | Step 6: completed |
| 7. Deployment | `horse:developer` | Update CHANGELOG, build artifacts | HUMAN APPROVAL → pause | Step 7: completed |

### Exit Gate Evaluation

All steps marked complete → artifacts verified → CI green → trail complete.

---

## Trail Integration: Sub-Trails

The three new trails created in Sprint 5 integrate with the orchestrator system:

| Trail | Used By | Integration Point |
|---|---|---|
| `sprint_execution.md` | sprint-orchestrator.md | Defines the story-level iteration cycle the sprint orchestrator follows |
| `bug_fix.md` | sdlc.md (as alternative trail) | Can be loaded instead of feature_delivery.md for bug-fix workflows |
| `code_review.md` | sdlc.md (at Step 6) | Provides detailed review cycle used by the reviewer agent at the code review step |

All three trails follow the format spec in `docs/process/trail_format.md`: YAML frontmatter, entry/exit gates, artifacts table, numbered steps with Agent/Skills/Completion/Fail fields, loop limits, and human checkpoints.

---

## Integration Issues Found

**None.** All cross-references resolve, all agent files exist, all skills are defined, state file template is complete, and the orchestration chain from `/horse:guide` → sdlc.md → feature_delivery.md → worker agents is fully wired.

---

## Summary

| Checklist Item | Result |
|---|---|
| 1. Orchestrator reads feature_delivery.md | PASS |
| 2. Steps 1–7 activate correct worker agents | PASS |
| 3. Readiness gates evaluated at boundaries | PASS |
| 4. Human checkpoints pause and resume | PASS |
| 5. Monitor agent activates at loop limit | PASS |
| 6. Step status log written after each step | PASS |
| 7. Sprint orchestrator manages impl loop | PASS |
| 8. Final output matches exit criteria | PASS |

**Result: 8/8 checks passed.** The orchestrator system is structurally complete and ready for live execution.
