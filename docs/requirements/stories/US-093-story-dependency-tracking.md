---
id: US-093
title: Story dependency tracking
status: draft
priority: Must Have
story_points: 3
section: "3.15 Leadership Views — Project Manager"
---

# US-093 — Story dependency tracking

> As a **developer**, I want **a `depends_on` field in user story frontmatter** so that **story dependencies are explicit, trackable, and can inform sprint planning and release sequencing**.

## Context

Stories currently have no way to express dependencies. The user_story.md template frontmatter includes `id`, `title`, `status`, `priority`, `story_points`, and `section` — but no `depends_on`. This means:

- The sprint command can assign a story whose prerequisite isn't done
- Release planning can't identify the critical path
- Dependency chains are invisible until someone hits a blocker

Adding `depends_on` as an optional frontmatter field enables the release-planning skill (US-091) to perform dependency analysis and the sprint command to warn about unmet dependencies.

## Acceptance Criteria

```gherkin
Given a user story with dependencies
When  the story is authored
Then  the depends_on field accepts a list of story IDs (e.g., [US-025, US-026])
And   the field is optional (stories with no dependencies omit it)

Given a story with depends_on: [US-025]
When  US-025 status is not "done"
Then  the release-planning skill flags this dependency as unmet
And   the sprint command warns if assigning this story to a sprint

Given a set of stories with depends_on fields
When  the release-planning skill analyzes dependencies
Then  it can construct a dependency graph
And   it identifies the critical path (longest chain)
And   it detects and reports circular dependencies as errors

Given the user_story.md template
When  a new story is scaffolded
Then  the template includes depends_on as an optional commented-out field
And   the field documentation explains the expected format
```

## Notes

- Format: `depends_on: [US-NNN, US-NNN]` (YAML list of story IDs)
- Dependency enforcement should be advisory (warn) not blocking (error) — the user may have good reasons to override
- Update `templates/user_story.md` to include the field
- Update `schemas/` if frontmatter schema validation exists (US-074)
- This is a prerequisite for the release-planning skill (US-091)
