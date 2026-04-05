---
id: US-032
title: User-customizable rules
status: draft
priority: Should Have
story_points: 2
section: "3.5 Rules — Contextual Standards"
---

# US-032 — User-customizable rules

> As a **developer**, I want to **add, modify, or override rules** so that **I can adapt the plugin to my project's specific standards**.

## Acceptance Criteria

```gherkin
Given I create a new rule file rules/my_api_standards.md with glob **/*_api.py
When  I edit a file matching that glob
Then  my custom rule is loaded alongside the built-in rules

Given I modify rules/code_quality.md to change the line length from 100 to 120
When  Claude generates Python code
Then  it respects the 120-character line length limit

Given I delete a built-in rule file
When  Claude operates on matching files
Then  that rule is no longer applied
And   other rules continue to function normally
```
