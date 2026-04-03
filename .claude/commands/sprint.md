# /user:sprint

Plan and manage a sprint.

## What This Command Does

- Creates a new sprint plan using `templates/sprint_plan.md`
- Reviews and prioritizes the backlog
- Assigns stories based on team capacity
- Tracks progress during the sprint

## Instructions for Claude

### Starting a Sprint

1. Ask: *"Is this a new sprint or an update to an in-progress sprint?"*
2. If new sprint:
   - Read the current `templates/project_plan.md` to find unfinished stories.
   - Ask: *"What is the sprint goal (in one sentence)?"*
   - Ask: *"How many person-days of capacity does the team have?"*
   - Select stories from the backlog to fill ~80% of capacity (leave buffer for unplanned work).
   - Generate a new `templates/sprint_plan.md`.
3. If updating:
   - Read the existing sprint plan.
   - Ask which stories are done, in progress, or blocked.
   - Update statuses and note any blockers.

### Daily Standup Support

Ask each team member:
- *"What did you complete yesterday?"*
- *"What are you working on today?"*
- *"Do you have any blockers?"*

Update the sprint plan's standup notes table.

### Sprint Completion

At the end of the sprint:
1. Mark completed stories as ✅ Done in the sprint plan.
2. Move incomplete stories back to the backlog with a note.
3. Calculate velocity: total story points completed.
4. Prompt: *"Ready to run a retrospective? Use /user:retrospective"*
