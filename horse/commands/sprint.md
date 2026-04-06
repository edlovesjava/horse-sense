# /horse:sprint

Plan and manage a sprint.

## What This Command Does

- Creates a new sprint plan using `${CLAUDE_PLUGIN_ROOT}/templates/sprint_plan.md`
- Reviews and prioritizes the backlog
- Assigns stories based on team capacity
- Tracks progress during the sprint

## Instructions for Claude

### Starting a Sprint

1. Ask: *"Is this a new sprint or an update to an in-progress sprint?"*
2. If new sprint:
   - **Pre-flight check**: Verify the previous sprint is fully closed out before starting a new one. Check:
     - The previous sprint plan's Sprint Review section is filled in (not placeholder text)
     - The previous sprint's PR has been merged (check `gh pr list --state merged`)
     - The previous sprint's branch has been deleted (check `git branch -r`)
     - If any of these are incomplete, prompt: *"Sprint N is not fully closed out yet. Please complete the close-out sequence first."*
   - Read the current `${CLAUDE_PLUGIN_ROOT}/templates/project_plan.md` to find unfinished stories.
   - Check `horse.config.md` for `requirements_format`. If **per-story**, also scan `requirements_stories_dir` for story files to cross-reference status and details.
   - Ask: *"What is the sprint goal (in one sentence)?"*
   - Ask: *"How many person-days of capacity does the team have?"*
   - Select stories from the backlog to fill ~80% of capacity (leave buffer for unplanned work).
   - Generate a new sprint plan at `docs/plans/sprints/sprint_<N>_plan.md` using `${CLAUDE_PLUGIN_ROOT}/templates/sprint_plan.md`.
   - **Transition each selected story to `in-progress`** (see "Story Status Transitions" below).
3. If updating:
   - Read the existing sprint plan.
   - Ask which stories are done, in progress, or blocked.
   - Update statuses and note any blockers.
   - **Transition any newly blocked story to `blocked`** (see "Story Status Transitions" below).

### Story Status Transitions

Story status is the canonical responsibility of `/horse:sprint`. Task status inside a sprint is owned by the developer (see `implementation` skill); story status across sprints is owned here.

Each story has status in **two places** that must stay in sync:

1. **YAML frontmatter** in the story file: `status: <value>`
2. **Index table** in `requirements_doc.md` (or `requirements_index.md` for per-story mode): the Status column

Valid values: `draft`, `ready`, `in-progress`, `done`, `blocked`.

**When starting a sprint** — for each story entering the sprint:

- Open the story file (default: `docs/requirements/stories/US-<NNN>-<title>.md`)
- Update the frontmatter: `status: in-progress`
- Update the Status cell in the requirements index table
- Both edits go in the same commit that creates the sprint plan

**When ending a sprint** — for each completed sprint task, check if its parent story has any remaining open tasks:

- If **all** tasks for the story are done: transition story to `done` (frontmatter + index)
- If tasks remain: leave story as `in-progress` (it rolls into the next sprint)
- If the story became blocked mid-sprint: set to `blocked` and note the blocker under Risks & Blockers in the sprint plan

**Never** edit story status silently — always record the transition in the commit message (e.g., `chore(stories): mark US-080, US-081 as done`).

### Daily Standup Support

Ask each team member:

- *"What did you complete yesterday?"*
- *"What are you working on today?"*
- *"Do you have any blockers?"*

Update the sprint plan's standup notes table.

### Sprint Completion

At the end of the sprint, execute the close-out sequence in order. Each step must pass before proceeding to the next.

#### Step 1: Task & Story Wrap-up

1. Mark completed sprint tasks as `✅ Done` in the sprint plan (if the developer hasn't already — they should have, per the `implementation` skill).
2. **Transition each fully-completed story to `done`** per the "Story Status Transitions" rules above. Stories with remaining open tasks stay `in-progress` and roll into the next sprint's backlog.
3. Move incomplete sprint tasks back to the backlog with a note.

#### Step 2: Close-out Gate

Run the close-out checklist before committing. All items must pass:

- [ ] All sprint tasks are `✅ Done` or explicitly deferred with rationale
- [ ] `make doc-sync` passes (story frontmatter ↔ index table parity)
- [ ] `make can-review` passes (structure, frontmatter, markdown, shellcheck, doc-sync)
- [ ] Story statuses transitioned in both frontmatter and index
- [ ] Sprint review section filled in (velocity, what was delivered, what was not)

If any item fails, fix it before proceeding.

#### Step 3: Commit & Push

1. Commit all close-out changes (sprint plan updates, story transitions) with a clear message (e.g., `chore(sprint-4): close out sprint — 41 SP delivered`).
2. Push the sprint branch to remote.

#### Step 4: Review & Merge

1. Create a PR for the sprint branch (or update the existing one).
2. Request Copilot review: `gh pr edit <number> --add-reviewer @me` (triggers GitHub Copilot code review automatically).
3. Address any Copilot findings before requesting human review.
4. Request human review — the reviewer should verify the close-out gate items.
5. Merge after both Copilot and human approval.

#### Step 5: Clean Up

After the PR is merged:

1. Delete the remote sprint branch: `git push origin --delete sprint-<N>`
2. Delete the local sprint branch: `git checkout main && git pull && git branch -d sprint-<N>`
3. Verify clean state: no stale sprint branches remain (`git branch -a | grep sprint`)

#### Step 6: Velocity & Retrospective

1. Calculate velocity: total story points completed.
2. Prompt: *"Ready to run a retrospective? Use /horse:retrospective"*
