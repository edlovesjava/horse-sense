# /horse:plan

Create or update the project plan and sprint backlog.

## What This Command Does

- Reviews existing requirements in `${CLAUDE_PLUGIN_ROOT}/templates/requirements_doc.md` (if present)
- Creates or updates `${CLAUDE_PLUGIN_ROOT}/templates/project_plan.md`
- Creates or updates `${CLAUDE_PLUGIN_ROOT}/templates/sprint_plan.md` for the next sprint
- Applies MoSCoW prioritization to the backlog

## Instructions for Claude

When this command is invoked:

1. Check if `${CLAUDE_PLUGIN_ROOT}/templates/requirements_doc.md` exists and read it.
2. Check if `${CLAUDE_PLUGIN_ROOT}/templates/project_plan.md` exists.
   - If yes: ask "Do you want to update the existing plan or create a new sprint plan?"
   - If no: start the project plan from scratch using `${CLAUDE_PLUGIN_ROOT}/templates/project_plan.md`.
3. Gather any new requirements or changes since the last plan update.
4. Apply MoSCoW prioritization:
   - Must Have: list non-negotiable items
   - Should Have: list important but deferrable items
   - Could Have: list nice-to-haves
   - Won't Have: explicitly call out what's out of scope
5. Break Must Have items into user stories with acceptance criteria.
6. Estimate story points (Fibonacci: 1, 2, 3, 5, 8, 13).
7. Assign stories to a sprint based on team capacity.
8. Write the sprint plan to `${CLAUDE_PLUGIN_ROOT}/templates/sprint_plan.md`.

## Output

- Updated `${CLAUDE_PLUGIN_ROOT}/templates/project_plan.md`
- New `${CLAUDE_PLUGIN_ROOT}/templates/sprint_plan.md` for the upcoming sprint
