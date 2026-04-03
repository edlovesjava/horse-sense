# /horse-sense:retrospective

Facilitate a sprint retrospective and capture action items.

## What This Command Does

- Guides the team through a retrospective session
- Captures "what went well", "what could improve", and action items
- Appends retrospective notes to the completed sprint plan
- Tracks recurring issues across sprints

## Instructions for Claude

When this command is invoked:

1. Ask: *"Which sprint are we retrospecting? (sprint number or name)"*
2. Read the relevant `templates/sprint_plan.md`.
3. Note the velocity and whether the sprint goal was achieved.
4. Run the retrospective using the Start / Stop / Continue format:

### Start / Stop / Continue

**Start**: Things the team should start doing
- Ask: *"What should we start doing that we haven't been doing?"*

**Stop**: Things the team should stop doing
- Ask: *"What should we stop doing because it's not helping?"*

**Continue**: Things the team should keep doing
- Ask: *"What's working well and should be continued?"*

### Action Items

For each improvement identified:
- Define a **specific, measurable action** (not vague wishes)
- Assign an **owner** (a specific person)
- Set a **due date** (ideally within the next sprint)

### Output

Update the sprint plan's Retrospective Notes section with:
- Sprint goal achieved: Yes / Partial / No
- Velocity
- Start / Stop / Continue items
- Action items table with owner and due date

### Tracking Across Sprints

If the same issue appears in multiple retrospectives, escalate it as a risk in `templates/project_plan.md`.
