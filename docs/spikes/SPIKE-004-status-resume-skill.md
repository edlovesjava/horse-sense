# SPIKE-004: Status & Resume Capability for the horse Plugin

> **Status**: Complete (revised)
> **Author**: Scout agent
> **Date**: 2026-04-06 (revised 2026-04-06)
> **Timebox**: 3 hours

---

## Question

What state sources already exist in the horse plugin ecosystem, what status information can
be derived from them without new infrastructure, and what is the best design for session
bookending — a `/horse:sitrep` command (end of session) and `/horse:standup` command
(start of session) — that lets a user capture context when stopping and resume work from
a cold start?

### Scope

In bounds:

- All artifact types: project plan, sprint plans, user stories, `horse.config.md`,
  `.claude/config.json`, git branch state
- Session bookending: sitrep (end-of-session capture) and standup (start-of-session briefing)
- Sitrep persistence format and storage conventions
- Command vs. skill vs. hybrid architecture trade-offs
- Script-backed vs. prompt-only implementation trade-offs
- T-shirt-size effort estimate

Out of bounds:

- External state storage (databases, APIs) — everything stays in the repo
- Changes to existing artifact schemas
- Implementation (this is a design spike, not a build spike)

---

## Approach

- [x] Read all templates: `sprint_plan.md`, `project_plan.md`, `user_story.md`, `horse_config.md`
- [x] Read existing commands: `sprint.md`, `implement.md`, `guide.md`
- [x] Read skills: `implementation/SKILL.md`, `process-audit/SKILL.md`, `scout/SKILL.md`
- [x] Survey live artifacts: `docs/plans/project_plan.md`, all four sprint plans,
      `docs/requirements/requirements_doc.md`, `docs/requirements/stories/`
- [x] Inspect `horse/scripts/doc_sync_check.sh` to understand existing parsing capability
- [x] Check `.claude/config.json`, `horse.config.md`, git branch state

---

## Findings

### Finding 1: State Is Fully Distributed Across Five Artifact Types

The plugin carries all meaningful project state in static Markdown and YAML files. No database,
no external service, no session store — everything is in the repo. The five canonical state
sources are:

| Artifact | Location | State Carried |
|---|---|---|
| Project plan | `docs/plans/project_plan.md` | Milestones + status, epic/story assignment to sprints, overall phase |
| Sprint plans | `docs/plans/sprints/sprint_N_plan.md` | Current sprint goal, task statuses (emoji), capacity, review notes |
| User story files | `docs/requirements/stories/US-NNN-*.md` | YAML frontmatter: `status`, `priority`, `story_points` |
| Requirements index | `docs/requirements/requirements_doc.md` | Status column in every epic table (denormalized mirror of frontmatter) |
| Config files | `horse.config.md`, `.claude/config.json` | `requirements_format`, `requirements_stories_dir`, `git_strategy`, language, toolchain |

Git branch state (`git branch -a`, `git log`) provides auxiliary context: which sprint branches
exist, whether sprint PRs are merged, current working branch.

### Finding 2: Status Symbols Are Consistent and Machine-Readable

The sprint plan template defines a closed set of five task-status emoji:

| Symbol | Meaning |
|---|---|
| `⬜` | To Do |
| `🔵` | In Progress |
| `🔍` | In Review |
| `✅` | Done |
| `🚫` | Blocked |

These appear in sprint plan tables (both the Sprint Backlog and Technical Tasks sections).
The user story YAML frontmatter uses text values: `draft`, `ready`, `in-progress`, `done`,
`blocked`. The project plan milestone table uses `✅ Done` and `⬜`.

The `doc_sync_check.sh` script already parses story frontmatter (via `awk` on `---` blocks)
and the requirements index table (via `awk -F'|'`). The same parsing techniques are directly
reusable for a status script.

### Finding 3: Current Sprint Is Determinable Without New Infrastructure

The active sprint can be identified via multiple convergent signals:

1. **Highest-numbered sprint plan where Sprint Review Notes section is empty** (not filled in).
   Sprint 4 plan shows `☑ Yes` in the review, meaning it is closed. The next plan with no
   review section = active sprint.
2. **Live sprint branches**: `git branch -a | grep sprint-` lists open sprint branches. A
   merged-and-deleted branch means the sprint is closed.
3. **Story status in frontmatter**: stories with `status: in-progress` belong to the running
   sprint.

The current repo (2026-04-06) has sprints 1–4 closed (all ✅ Done in Sprint Review Notes).
Sprint 5 has not started yet. This is detectable without a separate "current sprint" marker.

### Finding 4: SDLC Phase Is Inferrable from Milestone Status in the Project Plan

The project plan's milestone table maps milestones to phases and carries `✅ Done` / `⬜`
status. A simple algorithm:

1. Find the first milestone with status `⬜` (not done).
2. Map it to its phase using the milestone description.
3. The SDLC phase is the phase containing the first incomplete milestone.

Current state (from `project_plan.md`): M0 through M2 are done, M3 and M4 are `⬜`, placing
the project in **Phase 1 / Sprint 3 territory** (though actually Sprint 4 is done and Sprint 5
is next — a nuance a smart prompt could resolve by cross-referencing sprint plans).

### Finding 5: "Next Action" Can Be Derived with a Decision Tree

Given the state signals above, the next recommended action follows a deterministic tree:

```
Is there an active sprint branch with open tasks?
  YES → Resume with /horse:implement [next ⬜ task in sprint]
  NO  →
    Is the last sprint closed (review notes filled, PR merged)?
      YES →
        Are there unplanned stories in the backlog?
          YES → Run /horse:sprint to plan the next sprint
          NO  → Project is complete — run /horse:retrospective
      NO  → Close out the sprint via /horse:sprint (update + close-out gate)
```

### Finding 6: Existing Commands Detect State Implicitly and Inconsistently

| Command / Skill | How It Finds State | Consistency |
|---|---|---|
| `/horse:sprint` | Asks "new or update?" — relies on user memory | Prompt-only, no auto-detection |
| `/horse:implement` | Asks which story/task — relies on user memory | Prompt-only, no auto-detection |
| `/horse:guide` | Checks for `horse.config.md` + `.claude/config.json` presence | Partial auto-detection |
| `implementation` skill | Reads sprint plan at `docs/plans/sprints/sprint_N_plan.md` | Requires user to know N |
| `process-audit` skill | Scans all artifact dirs systematically | Best existing model for systematic reading |

The `process-audit` skill's Step 2 ("Load Artifacts") is the closest existing pattern to what
a status command needs: it reads all artifact directories and synthesizes a structured view. A
status command would follow the same artifact-loading pattern but with a different output goal
(current state snapshot vs. compliance findings).

### Finding 7: No `horse.config.md` Exists in This Repo

The horse-sense repo itself has no `horse.config.md` in the project root. The file is a
template for consumer projects. This is expected: horse-sense uses per-story format and the
config model is described in CLAUDE.md and the template. However, a `/horse:status` command
must handle the case where `horse.config.md` is absent gracefully.

### Finding 8: Sprint Plans Have Enough Data for Burndown Estimation

Each sprint plan includes:

- Sprint duration (start and end dates in the header)
- Total story points (from the "Total" row in Sprint Backlog)
- Per-task status (emoji in Status column)
- Velocity from the Sprint Review Notes of the prior sprint

From these, a status command can compute:

- Points completed (`✅` tasks' points)
- Points remaining (`⬜` + `🔵` + `🔍` tasks' points)
- Days elapsed and remaining (from start/end dates vs. today's date)
- Implied velocity and whether the team is on track

---

## Trade-off Matrix (Original — Single Status Command)

| Option | Pros | Cons | Effort | Risk |
|---|---|---|---|---|
| **A: Prompt-only command** (`/horse:status` reads artifacts, narrates status) | Zero new infrastructure; consistent with other commands; Claude can handle edge cases intelligently; immediately implementable | Slower than a script (reads many files); output format varies by session; can hallucinate if artifacts are inconsistent | XS (1–2 hours) | Low |
| **B: Shell script backed command** (`horse/scripts/status_check.sh` + thin command wrapper) | Fast, deterministic, diff-stable output; parseable by CI; can be called from Makefile | Requires maintaining a bash script; edge cases (missing files, emoji parsing) need explicit handling; less flexible for narrative output | M (1–2 days) | Medium (bash emoji/unicode parsing is fiddly) |
| **C: Command + companion skill** (`/horse:status` for interactive use; `status` skill for model-invoked use from other commands/agents) | Maximum reuse; other commands can invoke the skill to orient themselves; skill can be referenced from `sprint.md` and `implement.md` | Two artifacts to maintain; skill invocation from commands is a new pattern not yet established in this plugin | S (4–8 hours) | Low-Medium |
| **D: Hybrid — script for data + command for narrative** (script outputs JSON; command reads JSON and generates human summary) | Clean separation of concerns; script output is testable; narrative remains flexible | Most complex to build; JSON output format needs a schema; over-engineering risk for the current team size | L (3–5 days) | Medium |

---

## Revised Recommendation: Sitrep + Standup (Two-Command Design)

> **Revision note (2026-04-06):** The original recommendation was Option C (single
> `/horse:status` command + skill). After discussion, the design evolved into a
> **two-command model** — `/horse:sitrep` (end of session) and `/horse:standup`
> (start of session) — which better captures the session-bookending workflow and
> preserves context that static artifacts cannot.

### Why Two Commands Instead of One

A single `/horse:status` can read artifact state, but it **cannot capture intent**.

| Capability | Single `/horse:status` | Sitrep + Standup |
|---|---|---|
| Project/sprint/task status | Yes (reads artifacts) | Yes (standup reads artifacts) |
| What was the user working on? | Inferred from git state | Explicitly captured in sitrep |
| Why was the user doing it? | Lost between sessions | Recorded in sitrep |
| What's half-done but uncommitted? | Partially (git diff) | Explicitly noted in sitrep |
| Decisions pending / blockers | Only if recorded in sprint plan | Captured in sitrep with context |
| "What should I do next?" | Decision tree from artifacts | Decision tree + user's own stated intent |
| Session-to-session continuity | None — each session starts cold | Sitrep bridges the gap |

The sitrep captures what artifacts structurally cannot: **partial progress, intent, pending
decisions, and next-action context** — the things a developer would tell a colleague during
a handoff.

### Design: `/horse:sitrep` (End of Session)

**Purpose:** "Save your game." Capture session context before stopping work.

**Trigger:** User runs `/horse:sitrep` when wrapping up a work session.

**What it captures:**

| Section | Content | Source |
|---|---|---|
| Session summary | What was accomplished this session | User narrative + git log since session start |
| Work in flight | Partially completed tasks, uncommitted changes | git status, git diff --stat, user input |
| Decisions made | Architecture, design, or implementation choices | User narrative |
| Blockers & open questions | Things that need answers before continuing | User narrative |
| Next actions | What to do first when resuming | User narrative + decision tree |

**Storage:** `docs/sitreps/YYYY-MM-DD.md` (one per day, appended if multiple sessions).

**Sitrep template structure:**

```markdown
---
date: 2026-04-06
sprint: 5
branch: sprint-5
author: (user)
---

# Sitrep — 2026-04-06

## What Got Done
- (bulleted list of accomplishments, with commit refs where applicable)

## Work in Flight
- (partially completed tasks, open branches, uncommitted changes)

## Decisions Made
- (any architecture, design, or process decisions — with rationale)

## Blockers & Open Questions
- (things that need answers before continuing)

## Next Actions
- (ordered list: what to do first when resuming)
```

**How it works:**

1. Read the active sprint plan to identify the current sprint and branch.
2. Run `git log --oneline` since the session start (or last sitrep) to enumerate commits.
3. Run `git status` and `git diff --stat` to detect uncommitted work.
4. Ask the user: *"What did you accomplish this session?"* (pre-fill from git log)
5. Ask: *"Is anything half-done or in-flight that you'll need to pick up?"*
6. Ask: *"Any decisions you made that should be recorded?"*
7. Ask: *"Any blockers or open questions?"*
8. Ask: *"What should you (or the next person) do first when resuming?"*
9. Write the sitrep to `docs/sitreps/YYYY-MM-DD.md`.
10. Commit the sitrep file.

### Design: `/horse:standup` (Start of Session)

**Purpose:** "Load your game." Brief the user (or a fresh Claude session) on where things
stand and what to do next.

**Trigger:** User runs `/horse:standup` at the beginning of a work session.

**What it reads (in order):**

| Source | What it extracts |
|---|---|
| Latest sitrep (`docs/sitreps/`) | Session context, in-flight work, blockers, next actions |
| Project plan (`docs/plans/project_plan.md`) | Current SDLC phase, milestone progress |
| Active sprint plan (`docs/plans/sprints/sprint_N_plan.md`) | Sprint goal, task burndown, days remaining |
| Story files (`docs/requirements/stories/`) | Stories with `status: in-progress` or `status: blocked` |
| Git state | Current branch, uncommitted changes, open PRs |
| Doc-sync health | `make doc-sync` or manual check |

**Output format:**

```
## Standup Briefing — 2026-04-07

### Last Session (from sitrep 2026-04-06)
- Completed: US-082 auth middleware, fixed token validation bug
- In flight: US-083 API rate limiting — tests written, implementation 60% done
- Blocker: Waiting on architect decision re: rate limit storage (Redis vs in-memory)
- Next actions: Finish rate limiter implementation, then update ADR-005

### Project Status
Phase 1: Plugin Packaging — in progress (M3, M4 remaining)

### Sprint 5 — Day 3 of 10
Goal: Complete auth + rate limiting stories
Progress: 18/34 SP done (53%) | 2 in-progress | 1 blocked | 3 to-do
On track: Yes (expected 50% at day 3)

### Backlog Health
84 stories | 5 in sprint | 0 blocked outside sprint | 79 in backlog

### Recommended Next Action
/horse:implement US-083 — resume rate limiter implementation (60% done per sitrep)
```

**How it works:**

1. Find the most recent sitrep in `docs/sitreps/` (sort by filename date).
2. Read it and extract the key sections.
3. Read `docs/plans/project_plan.md` — find current phase and milestone status.
4. Scan `docs/plans/sprints/` — find the active sprint plan (highest-N with empty review).
5. Parse the sprint backlog table for task status counts and story point totals.
6. Compute days elapsed vs. sprint end date; compare progress to expected pace.
7. Scan story files for `status: in-progress` or `status: blocked`.
8. Check git state: current branch, uncommitted changes, open PRs.
9. Apply the decision tree (Finding 5), enhanced with sitrep context:
   - If sitrep says "next action: finish X" → recommend resuming X
   - If sitrep says "blocker: Y" → flag it and suggest unblocked alternatives
   - Otherwise fall back to the artifact-based decision tree
10. Print the structured standup briefing.

### Companion Skill: `status/SKILL.md`

The standup's artifact-reading logic (steps 2–9 above) is extracted into a skill so other
commands can invoke it for cold-start orientation. The skill returns the structured status
block as text. Used by:

- `/horse:standup` — full briefing with sitrep context
- `/horse:sprint` — pre-flight orientation before planning/updating
- `/horse:implement` — orientation before resuming implementation

### Integration Hooks

| Command | Integration |
|---|---|
| `/horse:sprint` | Invoke status skill as first step; skip "new or update?" question if state is unambiguous |
| `/horse:implement` | Invoke status skill; auto-suggest the next task if sitrep has next-actions |
| Sprint close-out (Step 3) | Prompt: *"Run /horse:sitrep before closing out?"* |
| `/horse:guide` | For new projects, skip sitrep/standup (no prior state exists) |

---

## Revised Trade-off Matrix

| Option | Pros | Cons | Effort | Risk |
|---|---|---|---|---|
| **Original C: Single `/horse:status`** | Simple, one command | Cannot capture intent; cold-start only; no session bridging | S (4–8 hrs) | Low |
| **Revised: Sitrep + Standup + Skill** | Captures intent and context; bridges sessions; standup subsumes status; skill enables reuse | Two commands + one skill + one template; sitrep requires user input (not fully automated) | S–M (2 days) | Low |

### Why the revised design wins

1. **Sitrep captures what artifacts cannot.** Sprint plans track tasks; sitreps track intent,
   partial progress, and pending decisions. This is the information that's actually lost between
   sessions.

2. **Standup is a better UX than status.** "Here's your briefing, here's what to do next" is
   more actionable than "here's the current state." The standup reads the sitrep for session
   context *and* the artifacts for ground truth — best of both worlds.

3. **Effort is comparable.** The sitrep command is simple (ask questions, write a file). The
   standup command is essentially the original `/horse:status` design plus sitrep reading.
   The companion skill is unchanged. Total effort increases from ~1 day to ~2 days.

4. **The sitrep trail has secondary value.** Over time, `docs/sitreps/` becomes a lightweight
   work journal — useful for retrospectives, onboarding new team members, and understanding
   the "why" behind decisions that the git log doesn't capture.

---

## Open Questions

- [ ] Should sitreps be committed automatically, or should the user review before committing?
      (Recommend: auto-commit with a clear message; user can amend if needed.)
- [ ] Should `/horse:standup` replace the pre-flight check in `/horse:sprint`, or complement it?
      (The sprint command's pre-flight checks sprint close-out status specifically; standup is
      broader. Recommend: standup complements, does not replace.)
- [ ] Should sitreps be one-per-day (appended) or one-per-session (timestamped)?
      (Recommend: one-per-day, appended with `## Session 2` headers if multiple sessions.)
- [ ] Should the standup warn if the most recent sitrep is stale (e.g., > 3 days old)?
      (Recommend: yes, with a note like "Last sitrep is from 3 days ago — context may be outdated.")
- [ ] Should the status skill emit machine-readable output (YAML/JSON block) alongside the
      human narrative, to make it easier for other commands to parse?

---

## Next Steps

- [ ] Create user story `US-085-sitrep-command.md` (Must Have, ~5 SP, Sprint 5 candidate)
- [ ] Create user story `US-086-standup-command.md` (Must Have, ~8 SP, Sprint 5 candidate)
- [ ] Create `horse/templates/sitrep.md` — sitrep file template
- [ ] Create `horse/commands/sitrep.md` — end-of-session command
- [ ] Create `horse/commands/standup.md` — start-of-session command
- [ ] Create `horse/skills/status/SKILL.md` — companion skill for artifact reading
- [ ] Update `/horse:sprint` to invoke the status skill as first step
- [ ] Update `/horse:implement` to invoke the status skill as first step
- [ ] Add sitrep prompt to sprint close-out sequence (Step 3)
- [ ] Create `docs/sitreps/` directory convention
