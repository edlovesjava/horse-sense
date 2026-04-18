# /horse:plan

Create or update the project plan and sprint backlog.

## What This Command Does

- Reviews existing requirements in `${CLAUDE_PLUGIN_ROOT}/templates/requirements_doc.md` (if present)
- Creates or updates `${CLAUDE_PLUGIN_ROOT}/templates/project_plan.md`
- Creates or updates `${CLAUDE_PLUGIN_ROOT}/templates/sprint_plan.md` for the next sprint
- Applies MoSCoW prioritization to the backlog

## Instructions for Claude

When this command is invoked:

1. **Entry gate — are requirements sufficient to plan against?** Check whether there are enough documented requirements to build a meaningful plan. If the prompt or existing docs are too vague (no clear stories, no acceptance criteria, no scope boundaries), tell the user: *"I need more detail before I can build a useful plan — [specific gap]. Want to flesh out requirements first?"* Do not proceed until there is enough to plan against.
2. Check `horse.config.md` for `requirements_format`.
   - **monolith**: read the project's `requirements_doc.md` for all stories.
   - **per-story**: read the project's `requirements_doc.md` index and scan the `requirements_stories_dir` (default: `docs/requirements/stories/`) for individual story files.
3. Check if `${CLAUDE_PLUGIN_ROOT}/templates/project_plan.md` exists.
   - If yes: ask "Do you want to update the existing plan or create a new sprint plan?"
   - If no: start the project plan from scratch using `${CLAUDE_PLUGIN_ROOT}/templates/project_plan.md`.
4. Gather any new requirements or changes since the last plan update.
5. Apply MoSCoW prioritization:
   - Must Have: list non-negotiable items
   - Should Have: list important but deferrable items
   - Could Have: list nice-to-haves
   - Won't Have: explicitly call out what's out of scope
6. Break Must Have items into user stories with acceptance criteria.
7. Estimate story points (Fibonacci: 1, 2, 3, 5, 8, 13).
8. Assign stories to a sprint based on team capacity.
9. Write the sprint plan to `${CLAUDE_PLUGIN_ROOT}/templates/sprint_plan.md`.

## Output

- Updated `${CLAUDE_PLUGIN_ROOT}/templates/project_plan.md`
- New `${CLAUDE_PLUGIN_ROOT}/templates/sprint_plan.md` for the upcoming sprint
