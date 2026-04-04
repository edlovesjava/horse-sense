---
id: US-080
title: PR review skill
status: draft
priority: Must Have
story_points: 8
section: "3.10 PR Review & Fix Skills"
---

# US-080 — PR review skill

> As a **developer**, I want **a skill that reviews a pull request and posts comments** so that **I get actionable feedback on code quality, correctness, and style without leaving my workflow**.

## Context

The PR review skill uses the GitHub CLI (`gh`) to fetch PR details (diff, changed files, existing comments) and posts review comments directly on the PR. It leverages the reviewer agent persona and applies project rules (code quality, testing, documentation, git workflow) when evaluating changes.

## Acceptance Criteria

```gherkin
Given an open pull request number or URL
When  the PR review skill is invoked
Then  it fetches the PR diff and changed files via gh CLI
And   it analyzes each changed file against project rules and conventions
And   it posts inline review comments on specific lines where issues are found
And   it posts a summary review comment with an overall assessment

Given a PR with no issues
When  the PR review skill completes
Then  it posts an approving review with a brief summary

Given a PR with issues found
When  the PR review skill completes
Then  each comment includes: the issue, why it matters, and a suggested fix
And   it categorizes issues as: must-fix, should-fix, or nit

Given no PR number is provided
When  the PR review skill is invoked
Then  it checks for an open PR on the current branch and uses that
And   if no PR exists, it reports an error
```

## Notes

- Should work as both a slash command (`/horse:review`) and a model-invoked skill
- Uses `gh api` for posting review comments to specific diff lines
- Respects `horse.config.md` for project-specific review standards
- Should not duplicate comments already posted on the same PR
