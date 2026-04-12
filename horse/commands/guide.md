# /horse:guide

Kick off the full SDLC workflow for a new project or feature.

## What This Command Does

Guides you through the horse-sense SDLC using the **RAITCrD** lifecycle:

> **R**equirements → **A**rchitecture → **I**mplementation → **T**esting → **C**ode **r**eview → **D**eployment

### The Iterative Model

RAITCrD is **not a waterfall**. It is a naturally iterative cycle with quality gates between phases. Work flows forward through the phases, but any phase can send work back to an earlier phase when the need arises:

- **Insufficiently specified?** → flow back to **R**equirements to clarify scope, acceptance criteria, or edge cases before continuing.
- **Design gap discovered during implementation?** → flow back to **A**rchitecture to update the design or record a new ADR before proceeding.
- **Implementation** proceeds via TDD — write tests, make them pass, refactor — until the code is reviewable.
- **Testing** reveals a defect? → flow back to **I**mplementation to fix, then re-test.
- **Code review** raises design concerns? → flow back to **A**rchitecture or **I**mplementation as appropriate.
- **Deployment** blocked by a quality gate? → flow back to the phase that owns the gap.

Each forward transition has a **gate** — a check that the current phase's output is sufficient before the next phase begins. But gates are not one-way doors; they are checkpoints that you pass through as many times as needed.

```
  ┌──────────────────────────────────────────────────┐
  │         ◄── flow back when needed ──◄            │
  │                                                  │
  R ──► A ──► I ◄──► T ──► Cr ──► D                 │
  ▲     ▲     ▲             │      │                 │
  │     │     └─────────────┘      │                 │
  │     └──────────────────────────┘                 │
  └──────────────────────────────────────────────────┘
```

### Scope and Decomposition

Work naturally decomposes along two axes, and RAITCrD applies at every level — but **not every level needs every phase**. Higher-scope work often satisfies a phase for everything beneath it.

**Functional decomposition** — *what* to build:

```
Product / Milestone
  └── Epic
        └── User Story
              └── Task
```

**Structural decomposition** — *how* it's built:

```
System
  └── Service
        └── Component
              └── Class / Module
```

Different phases naturally align with different scope levels:

| Phase | Typical scope level | Example |
|---|---|---|
| **R** Requirements | Product / Milestone | Product-level requirements cover all epics within the milestone |
| **A** Architecture | Epic / Service | System architecture for an epic; component design for a story |
| **I** Implementation | Story / Task | One story or task per TDD cycle |
| **T** Testing | Story (unit) → Epic (integration) → Milestone (e2e) | Test scope widens as you zoom out |
| **Cr** Code Review | Story / Epic | Review at the PR boundary — usually one story or a small epic |
| **D** Deployment | Epic / Milestone | Ship a coherent slice of functionality |

**The key insight for entry gates:** When evaluating "do I need this phase?", check whether a parent scope already provides sufficient coverage. For example:

- Requirements authored at the milestone level may already specify enough for each story within it — the story-level **R** entry gate passes because the parent scope covered it.
- Architecture designed at the epic level may define the component structure — individual stories inherit that design and skip **A**.
- A task that decomposes from a well-specified story may need only **I → T → Cr** — the story already handled **R** and **A**.

This also enables **parallelization**: once an epic's architecture is defined, multiple stories within it can proceed through **I → T → Cr** concurrently.

### First-Time Walkthrough

On first use, the guide walks you through each phase in order to establish the project baseline:

1. **Requirements (R)** — populate requirements (monolith or per-story, based on `horse.config.md`)
2. **Architecture (A)** — populate `${CLAUDE_PLUGIN_ROOT}/templates/architecture_doc.md` and create ADRs
3. **Planning** — populate `${CLAUDE_PLUGIN_ROOT}/templates/project_plan.md` and `${CLAUDE_PLUGIN_ROOT}/templates/sprint_plan.md`
4. **Environment Setup** — run `${CLAUDE_PLUGIN_ROOT}/scripts/setup_env.sh`
5. **Implementation (I)** — follow `${CLAUDE_PLUGIN_ROOT}/skills/implementation/SKILL.md`
6. **Testing (T)** — follow `${CLAUDE_PLUGIN_ROOT}/skills/testing/SKILL.md`
7. **Code Review (Cr)** — follow `${CLAUDE_PLUGIN_ROOT}/agents/reviewer.md`
8. **Deployment (D)** — follow `${CLAUDE_PLUGIN_ROOT}/skills/deployment/SKILL.md`

## Instructions for Claude

When this command is invoked:

0. **Init check** — Before starting the SDLC workflow, check whether the project has been initialized:
   - If **both** `horse.config.md` and `.claude/config.json` exist: the project is initialized. Skip questions 5–8 below (toolchain and config are already set). Tell the user: *"Project is already initialized — I found horse.config.md and .claude/config.json. Jumping straight to requirements."* Proceed to step 2.
   - If **neither** exists: suggest running `/horse:init` first: *"This project hasn't been initialized yet. Would you like to run `/horse:init` to set up the toolchain and project scaffold first, or proceed with just the SDLC planning?"* If they choose init, invoke `/horse:init` and resume here when it completes.
   - If **one** exists but not the other: note the gap and proceed, filling in the missing config as part of steps 5–8 below.
1. Briefly explain the RAITCrD iterative model: *"horse-sense follows an iterative lifecycle — Requirements, Architecture, Implementation, Testing, Code Review, Deployment. We'll walk through each phase in order to set up your project, but this isn't a one-way path. Any time we discover a gap — unclear requirements, a design issue, a failing test — we flow back to the right phase to address it before moving forward again."*
2. Ask the user: *"What are you building? Give me a one-sentence description."*
3. Ask: *"Who are the primary users and what problem does it solve for them?"*
4. Ask: *"What are the must-have features for the first release?"*
5. Ask: *"Do you have any technology preferences or constraints?"* (Skip if init already ran — read from `.claude/config.json`)
6. Ask: *"How would you like to organize requirements — a single document or one file per story?"* (Skip if init already ran — read from `horse.config.md`)
7. Ask: *"Do you prefer rebase or merge for integrating feature branches?"* (Skip if init already ran — read from `horse.config.md`)
8. Generate `horse.config.md` in the project root using `${CLAUDE_PLUGIN_ROOT}/templates/horse_config.md`, setting `requirements_format` and `git_strategy` based on the user's answers. (Skip if `horse.config.md` already exists from init.)
9. Based on the config:
   - **monolith**: generate a draft `requirements_doc.md` using `${CLAUDE_PLUGIN_ROOT}/templates/requirements_doc.md`.
   - **per-story**: generate a draft `requirements_doc.md` using `${CLAUDE_PLUGIN_ROOT}/templates/requirements_index.md` (index only), then create individual story files using `${CLAUDE_PLUGIN_ROOT}/templates/user_story.md` in the configured `requirements_stories_dir`.
10. **Requirements exit gate**: Confirm with the user that the requirements are sufficiently specified — clear AC, testable, small enough scope. If not, iterate on requirements until they are.
11. **Architecture entry gate**: Evaluate whether this work needs explicit design. If the requirements already specify the approach or the change fits an existing pattern, tell the user: *"This looks straightforward enough to skip architecture — the requirements already cover the approach. OK to move to implementation?"* If the user agrees, skip to step 14.
12. Propose a high-level architecture with two or three options and trade-offs.
13. Once the user selects an architecture, generate a draft `architecture_doc.md`. **Architecture exit gate**: Confirm the design addresses the requirements. If gaps are found, flow back to requirements or iterate on the design.
14. Break the requirements into a sprint backlog and generate a `sprint_plan.md`.
15. Run `${CLAUDE_PLUGIN_ROOT}/scripts/setup_env.sh` or guide the user to do so.
16. Confirm the user is ready to begin implementation.
17. **Hand off to the SDLC orchestrator.** At this point the kickoff interview is complete and the project has requirements, architecture (if needed), and a sprint plan. Transition to orchestrated execution:
    - Initialize the trail state file from `${CLAUDE_PLUGIN_ROOT}/templates/sdlc_state.md` at `docs/trails/sdlc-state.md`.
    - Follow the orchestrator protocol defined in `${CLAUDE_PLUGIN_ROOT}/agents/sdlc.md`: read the trail at `${CLAUDE_PLUGIN_ROOT}/trails/feature_delivery.md`, evaluate gates, dispatch worker agents for each step, and pause at human checkpoints.
    - Mark steps 1–3 (Requirements, Architecture, Sprint Planning) as already completed in the state file, since the kickoff interview handled them.
    - Begin orchestrated execution from Step 4 (Implementation).
18. Remind: *"Remember — if you hit unclear requirements during implementation, come back to R. If the design needs to change, revisit A. The phases are a loop, not a line."*

## Phase Gates

Every phase has two lightweight checks — an **entry gate** ("do I need this phase?") and an **exit gate** ("am I ready for the next?"). The entry gate lets you skip work that's already done or not needed; the exit gate catches gaps before you move on.

| Phase | Entry gate — *"Do I need this step?"* | Exit gate — *"Am I done?"* |
|---|---|---|
| **R** Requirements | Is the prompt or ticket sufficient? Are AC clear, scope small enough, edge cases covered? Or did a parent scope (milestone, epic) already specify enough? If yes → skip to **A**. | Stories have clear AC, are testable, and are small enough to implement in one pass. |
| **A** Architecture | Is this complex enough to need design? Does the parent epic/service already define the architecture? Do the requirements already specify the approach, or does this fit an existing pattern? If yes → skip to **I**. | Design addresses all in-scope stories. Key decisions recorded as ADRs. |
| **I** Implementation | *(always needed — this is where the code gets written)* | Code compiles, TDD cycle complete (tests written and passing), ready for review. |
| **T** Testing | *(always needed — but scope varies by decomposition level)* Unit tests from TDD cover the task; are integration or e2e tests needed at the story/epic level? | All tests pass. Coverage meets threshold for this scope level. |
| **Cr** Code Review | *(always needed for shared code)* Is this a solo exploratory spike with no merge target? If yes → skip to **D**. | All review findings resolved or explicitly deferred with rationale. Quality checks green (`make can-review`). |
| **D** Deployment | Is there an artifact to ship or merge? Deployment typically aligns with epic/milestone scope — individual stories merge to a branch; the epic ships. | Branch merged, environment updated, rollback plan confirmed. |

**How to use the entry gate:** At the start of each phase, Claude evaluates the entry criteria against the current state *and* checks whether a parent scope already provides coverage. If the phase can be skipped, Claude states why (e.g., *"The epic-level architecture already covers this story's design"*) and advances to the next phase. The user can always override and say "let's do this phase anyway."

If an exit gate answer is **no**, flow back to the appropriate phase — not necessarily the current one.

## Guiding Principles

- Ask one clarifying question at a time.
- **Gates, not walls** — check readiness before advancing, but flow back freely when gaps appear.
- Document decisions immediately — don't defer to "we'll figure it out later".
- Keep the scope tight for the first sprint — better to ship less and iterate.
- The lifecycle is a loop: shipping is not the end — feedback from deployment feeds back into requirements for the next iteration.
