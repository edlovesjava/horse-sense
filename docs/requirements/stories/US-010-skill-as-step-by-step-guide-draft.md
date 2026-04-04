---
id: US-010
title: Skill as step-by-step guide
status: draft
priority: Must Have
story_points: 3
section: "3.2 Skills — Primary Behavior Definition"
---

# US-010 — Skill as step-by-step guide

> As a **developer**, I want **each skill to be a complete, self-contained guide** so that **Claude follows a consistent, high-quality process for each activity**.

## Acceptance Criteria

```gherkin
Given I invoke a skill (e.g., /horse-sense:implement)
When  Claude executes the skill
Then  it follows the steps defined in the skill's Markdown guide
And   it reads .claude/config.json to adapt commands and paths
And   it references relevant rules for the files being modified
And   it produces output consistent with the skill's defined structure
```

## Notes

Skills are the workhorse of the system. They can be: (a) a Markdown guide only, (b) a guide with reference documents, or (c) a guide with executable scripts.
