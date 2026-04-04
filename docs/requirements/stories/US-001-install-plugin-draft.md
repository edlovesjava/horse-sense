---
id: US-001
title: Install plugin
status: draft
priority: Must Have
story_points: 3
section: "3.1 Plugin Installation & Configuration"
---

# US-001 — Install plugin

> As a **developer**, I want to **install horse-sense as a Claude Code plugin** so that **its skills, agents, and rules are available in my Claude Code sessions**.

## Acceptance Criteria

```gherkin
Given I have Claude Code installed
When  I install horse-sense via `claude --plugin-dir ./horse-sense` or plugin marketplace
Then  all slash commands are available as /horse-sense:<command>
And   agents are listed in the agent selector
And   rules are active based on glob patterns
And   CLAUDE.md instructions are loaded into context
```
