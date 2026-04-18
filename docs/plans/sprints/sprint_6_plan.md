# Sprint 6 Plan: Phase 3 Kickoff — Subagent Dispatch Infrastructure + Doc Writer

> **Sprint**: 6
> **Duration**: 2026-04-16 → 2026-04-23 (1 week)
> **Team capacity**: 30 SP core + ~12 SP stretch (at sustained velocity of 41 SP)
> **Sprint goal**: Build the containerized subagent execution infrastructure (Epic 6, M7) — Dockerfile, sandbox runner, dispatch skill, invocation contract — and validate with a smoke test. Stretch: deliver the doc writer agent and first documentation skill.

---

## Sprint Goal

Two streams, in priority order:

1. **Epic 6: Subagent Dispatch Infrastructure (M7)** — create the Docker sandbox image, `bin/claude-sandbox` runner, subagent dispatch skill, invocation contract, prompt template, and validate with a smoke test. This is the Phase 3 core milestone: after this sprint the plugin can dispatch one-shot Claude tasks in isolated containers.

2. **Doc-sync cleanup + Doc Writer (stretch)** — fix stale statuses across the project plan and requirements doc, then begin Epic 8 (Doc Writer) with the agent persona (US-085) and documentation authoring skill (US-086).

---

## Sprint Backlog

### Part 1: Epic 6 — Subagent Dispatch Infrastructure (Core)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-060 | Create `Dockerfile.claude-sandbox` — minimal image with `claude` CLI, Node.js, Python, git | — | 5 | ✅ Done |
| T-061 | Create `bin/claude-sandbox` — shell wrapper for `docker run` with volume mounts, env passthrough, timeout, secure defaults | — | 5 | ✅ Done |
| T-062 | Create `skills/subagent-dispatch/SKILL.md` — when and how to spawn a containerized subagent (prompt construction, JSON parsing, error handling) | — | 3 | ⬜ To Do |
| T-063 | Define subagent invocation contract: input (prompt + context files), output (JSON with `result`, `exit_code`, `stderr`), timeout, resource limits | — | 3 | ⬜ To Do |
| T-064 | Create `templates/subagent_prompt.md` — template for constructing well-formed one-shot prompts | — | 2 | ⬜ To Do |
| T-065 | Smoke test: orchestrator dispatches a trivial task to containerized subagent, parses JSON result | — | 3 | ⬜ To Do |
| | **Part 1 subtotal (core)** | | **21** | |

### Part 2: Doc-Sync Cleanup (Housekeeping)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-066 | Update project plan milestones M3–M6 to ✅ Done; update Sprint 3–5 task statuses | — | 2 | ✅ Done |
| T-067 | Update requirements_doc.md story statuses to match delivered work (sections 3.1–3.12) | — | 2 | ✅ Done |
| T-068 | Renumber Phase 3 tasks in project plan (T-050→T-060 series) to resolve Sprint 5 collision | — | 1 | ⬜ To Do |
| | **Part 2 subtotal (housekeeping)** | | **5** | |

> **Note**: T-066 and T-067 were completed as part of the Sprint 6 kickoff commit, folding in Sprint 5's close-out doc-sync work. They appear here for traceability.

### Part 3: Epic 8 — Doc Writer Agent & Skills (Stretch)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-069 | Create `agents/doc-writer.md` — doc writer agent persona with YAML frontmatter | US-085 | 5 | ⬜ To Do |
| T-070 | Create `skills/documentation/SKILL.md` — README authoring, Markdown docs, CHANGELOG maintenance | US-086 | 8 | ⬜ To Do |
| | **Part 3 subtotal (stretch)** | | **13** | |

| | **Sprint 6 Total (core + housekeeping + stretch)** | | **39** | |

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
| (no user story) | Subagent dispatch infrastructure (Epic 6 tasks) | New — mapped from project plan Phase 3 |
| US-085 | Doc writer agent persona (stretch) | Draft |
| US-086 | Documentation authoring skill (stretch) | Draft |

Note: Epic 6 tasks are infrastructure work not directly mapped to requirements user stories. The invocation contract (T-063) and dispatch skill (T-062) address the "how" of subagent execution described in ADR-0005.

---

## Task Details

### T-060: `Dockerfile.claude-sandbox`

Create a minimal Docker image for sandboxed Claude CLI execution. Based on ADR-0005 design.

Contents:

- Base: `node:20-slim` (Claude CLI requires Node.js)
- Install: `claude` CLI via npm, Python 3.11+, git
- No secrets, no credentials, no project-specific config
- Non-root user (`claude:claude`, UID 1000)
- Working directory: `/workspace`

**Acceptance**: Image builds successfully. `docker run claude-sandbox claude --version` returns a valid version. Image size < 500MB.

**Delivered (Day 3)**: `horse/Dockerfile.claude-sandbox` built using `node:22-slim` (LTS deviation from ADR-0005's `node:20-slim` — see SPIKE-010). `claude --version` returns `2.1.113 (Claude Code)`. Image size is **576 MB** — over target by 15%; size optimization filed as a follow-up (spike alpine base or multi-stage build before Sprint 7).

---

### T-061: `bin/claude-sandbox`

Shell wrapper script that invokes `docker run` with secure defaults per ADR-0005:

- `--network none` — no internet access
- `--read-only` — read-only root filesystem
- `--tmpfs /tmp:size=256m` — writable temp only
- `--user 1000:1000` — non-root
- `--memory 2g --cpus 2` — resource caps
- `--rm` — auto-cleanup
- `ANTHROPIC_API_KEY` passed via `--env` (never baked into image)

Interface:

```bash
claude-sandbox --prompt "task description" \
               --mount ./src:/workspace/src:ro \
               --timeout 120 \
               --output result.json
```

Graceful degradation: if Docker is not available, fall back to local `claude -p` with a warning.

**Acceptance**: Script passes shellcheck. `claude-sandbox --help` prints usage. Runs successfully with Docker. Falls back gracefully without Docker.

**Delivered (Day 3)**: `horse/bin/claude-sandbox` v0.1.0. Shellcheck clean. `--help`/`--version` work. Fallback path verified end-to-end with a real API call (returned `OK`, 6/6 tokens extracted from claude's JSON envelope). Docker path plumbing verified (emits warning on missing `ANTHROPIC_API_KEY` and produces the contract JSON shape). Network default changed from `--network none` to `--network bridge` per [ADR-0008](../../architecture/adr/0008-sandbox-network-and-auth-amendment.md) — host OAuth creds are not mounted; `ANTHROPIC_API_KEY` must be set on the host for the Docker path.

---

### T-062: `skills/subagent-dispatch/SKILL.md`

Model-invoked skill that teaches Claude when and how to dispatch containerized subagents. Covers:

- **When to dispatch**: task is self-contained, doesn't need conversational context, benefits from isolation
- **When NOT to dispatch**: task needs user interaction, requires shared state, needs network
- **How to construct prompts**: task description + constraints + output schema (reference T-064 template)
- **How to parse results**: JSON with `result`, `exit_code`, `stderr`
- **Error handling**: timeout, non-zero exit, malformed JSON

**Acceptance**: Skill has correct YAML frontmatter. Skill references `bin/claude-sandbox` and `templates/subagent_prompt.md`. `make check` passes.

---

### T-063: Subagent invocation contract

Document the contract in a `docs/architecture/subagent_contract.md` file:

**Input:**

| Field | Type | Required | Description |
|---|---|---|---|
| `prompt` | string | yes | The task prompt (or path to prompt file) |
| `mounts` | list | no | Volume mounts (`host:container:mode`) |
| `timeout` | int | no | Seconds before kill (default: 120) |
| `env` | map | no | Additional environment variables |

**Output (JSON):**

| Field | Type | Description |
|---|---|---|
| `result` | string | The subagent's text output |
| `exit_code` | int | 0 = success, non-zero = failure |
| `stderr` | string | Error output (if any) |
| `duration_ms` | int | Wall-clock execution time |

**Acceptance**: Contract document exists. `bin/claude-sandbox` output matches the contract schema. Dispatch skill references the contract.

---

### T-064: `templates/subagent_prompt.md`

Template for constructing well-formed one-shot prompts:

```markdown
# Task: {{task_name}}

## Context
{{context_description}}

## Instructions
{{step_by_step_instructions}}

## Constraints
- Output format: JSON
- Do not ask clarifying questions
- Complete the task in a single pass
{{additional_constraints}}

## Output Schema
{{json_schema}}
```

**Acceptance**: Template exists. Referenced by the dispatch skill (T-062).

---

### T-065: Smoke test

Validate end-to-end subagent dispatch:

1. Build the Docker image (T-060)
2. Use `claude-sandbox` (T-061) to dispatch a trivial task (e.g., "list the files in /workspace/src and return them as JSON")
3. Parse the JSON result
4. Verify exit code, result content, and duration

Document results in `docs/validation/e2e_subagent_smoke_test.md`.

**Acceptance**: Validation doc exists with pass/fail for each step. At minimum: image builds, container runs, JSON output is parseable.

---

### T-066: Update project plan milestones

Update `docs/plans/project_plan.md`:

- Mark M3 (Dual toolchain + CI) as ✅ Done
- Mark M4 (Phase 1 complete) as ✅ Done
- Mark M5 (Trail definitions & orchestrators) as ✅ Done
- Mark M6 (Phase 2 complete) as ✅ Done
- Update all Sprint 3, 4, and 5 task statuses from ⬜ to ✅ Done

**Acceptance**: All milestone and task statuses reflect actual delivered state.

---

### T-067: Update requirements_doc.md story statuses

Sync story statuses in the requirements index table with actual delivery:

- Sections 3.1–3.6: many stories delivered in Sprints 1–5 but still show "Draft"
- Cross-reference with sprint plans and git history
- Update frontmatter in each story file AND the index table

**Acceptance**: `make doc-sync` passes. Every delivered story shows correct status in both locations.

---

### T-068: Renumber Phase 3 tasks in project plan

Sprint 5 used T-050 for `/horse:init`, creating a collision with the Phase 3 task numbering. Renumber:

- T-050 → T-060, T-051 → T-061, ..., T-055 → T-065 (Sprint 6 / Epic 6)
- T-060 → T-070, T-061 → T-071, ..., T-065 → T-075 (Sprint 7 / Epic 7)
- Update requirement traceability table (section 9)

**Acceptance**: No duplicate task IDs in the project plan. All cross-references updated.

---

### T-069: `agents/doc-writer.md` (stretch)

Create the doc writer agent persona per US-085. YAML frontmatter with name, description, model. Agent composes documentation, diagrams, code-docs, and doc-review skills.

**Acceptance**: Agent file exists with correct frontmatter. Auto-discoverable in `horse/agents/`. `make check` passes.

---

### T-070: `skills/documentation/SKILL.md` (stretch)

Create the documentation authoring skill per US-086. Guided workflows for:

- README authoring (7 mandatory sections from `rules/documentation.md`)
- Markdown doc creation/update in `docs/`
- CHANGELOG maintenance (Keep a Changelog format)

Reads `.claude/config.json` for project context.

**Acceptance**: Skill file exists with correct YAML frontmatter. Referenced by doc-writer agent. `make check` passes.

---

## Capacity Planning

| Team Member | Available Days | Capacity (pts) | Assigned (pts) |
|---|---|---|---|
| Ed Wentworth | 5 | 30 + stretch | 21 core + 5 housekeeping + 13 stretch |
| **Total** | **5** | **30 + stretch** | **39** |

Core (21 SP) is conservative — leaves room for Docker troubleshooting and integration issues. Housekeeping (5 SP) is low-risk mechanical work. Stretch (13 SP) is only attempted if core completes by Day 3.

---

## Risks & Blockers

| Risk | Impact | Mitigation |
|---|---|---|
| Docker not available in Codespaces environment | High | T-061 includes graceful degradation to local `claude -p`. Test Docker availability on Day 1. |
| `claude` CLI npm package may not exist or may require auth | High | Spike on Day 1: verify `claude` CLI installation path. May need to use `@anthropic-ai/claude-code` or alternative. |
| API key passthrough into container may fail or be blocked | Med | Test `--env ANTHROPIC_API_KEY` passthrough in smoke test (T-065). Document workarounds. |
| Image size may exceed expectations if Python + Node.js + git | Low | Start with `node:20-slim`, add Python via apt. Monitor image size. |
| Doc-sync cleanup (T-066/T-067) may surface inconsistencies requiring more work | Low | Time-box to 2 SP each. File follow-ups for anything beyond status updates. |

---

## Definition of Done

A task is **Done** when:

- [ ] Implementation matches task description and acceptance criteria
- [ ] `make check` passes (structure, frontmatter, markdown, shellcheck, JSON schema)
- [ ] Doc-sync check passes (story status frontmatter, index table, sprint plan, project plan all consistent)
- [ ] No broken internal references in plugin
- [ ] Agent/skill files have correct YAML frontmatter and are auto-discoverable
- [ ] Shell scripts pass shellcheck
- [ ] Docker artifacts build successfully (for container tasks)
- [ ] Changes committed with Conventional Commits format
- [ ] Story status (frontmatter + index table) updated if story completes

---

## Daily Standup Notes

### Day 1 — 2026-04-16

| Person | Yesterday | Today | Blockers |
|---|---|---|---|
| Ed | Sprint 5 close-out (retroactive) | Sprint 6 kickoff; spike on Docker + Claude CLI in containers; begin T-060 design | None |

### Day 3 — 2026-04-18

| Person | Yesterday | Today | Blockers |
|---|---|---|---|
| Ed | Drafted Sprint 6 plan; ran Sprint 5 close-out doc-sync (T-066, T-067) | Finalize Sprint 6 kickoff (branch + commit); begin T-060 (Dockerfile) spike | None |

---

## Sprint Review Notes

_[fill in via `/horse:sprint` at sprint end]_

---

## Retrospective Notes

_[fill in via `/horse:retrospective` at sprint end]_
