---
id: US-081
title: PR fix skill
status: draft
priority: Must Have
story_points: 8
section: "3.10 PR Review & Fix Skills"
---

# US-081 — PR fix skill

> As a **developer**, I want **a skill that reads PR review comments, decides on an action for each, performs the work, and replies when done** so that **review feedback is resolved efficiently without manual triage**.

## Context

The PR fix skill complements the PR review skill (US-080). After a PR has been reviewed (by the horse review skill, Copilot, or a human), this skill reads all unresolved review comments, triages each one, performs the appropriate action, and replies to the comment thread with what was done.

## Acceptance Criteria

```gherkin
Given a PR with unresolved review comments
When  the PR fix skill is invoked
Then  it fetches all review comments via gh CLI
And   for each comment it decides one of: fix, defer, or accept

Given a comment with action "fix"
When  the skill processes it
Then  it modifies the relevant code to address the feedback
And   it replies to the comment with what was changed and the commit SHA

Given a comment with action "defer"
When  the skill processes it
Then  it does not modify code
And   it replies to the comment explaining why this is deferred (e.g., out of scope, needs discussion)

Given a comment with action "accept"
When  the skill processes it
Then  it does not modify code
And   it replies to the comment acknowledging the feedback (e.g., nit accepted as-is, or already addressed)

Given all comments have been processed
When  the skill completes
Then  it commits all fixes in a single commit with a descriptive message
And   it pushes the commit to the PR branch
And   it posts a summary comment on the PR listing actions taken per comment

Given a comment that the skill cannot confidently resolve
When  the skill triages it
Then  it defers the comment and flags it for human review
And   it does not make speculative changes
```

## Notes

- Must handle comments from any reviewer (human, Copilot, horse review skill)
- The fix/defer/accept decision should consider: severity, confidence in the fix, scope of change
- Should skip comments that already have a reply indicating resolution
- Uses the developer agent persona for code changes and the reviewer agent for triage decisions
- All code changes should pass existing tests before committing
