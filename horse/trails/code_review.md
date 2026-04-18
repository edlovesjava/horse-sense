---
name: code-review
description: Standalone code review cycle — review, feedback triage, resolution, re-review
version: 1
---

# Code Review Trail

Standalone review workflow for a pull request or changeset. The reviewer produces structured feedback, the developer triages and resolves accepted comments, and a re-review confirms resolution. Used by the SDLC orchestrator at the code-review step of the feature delivery trail.

## Entry Gate

- [ ] PR or changeset exists with a clear description of changes
- [ ] All tests pass on the PR branch
- [ ] Linter and type checker are clean

## Exit Gate

- [ ] All blocking review comments resolved
- [ ] Re-review confirms resolution — no new blocking issues
- [ ] Human has approved the final state

## Artifacts

| Artifact | Direction | Description |
|---|---|---|
| PR / changeset | Input | Code changes to review |
| Review comments | Output | Structured feedback with severity labels |
| Resolution summary | Output | How each comment was addressed (accepted, deferred, disputed) |

### Step 1: Review

- **Agent**: reviewer
- **Skills**: pr-review
- **Input**: PR diff and description
- **Output**: Structured review comments with severity labels (blocking, suggestion, nit)
- **Completion**: All changed files reviewed; each comment has a severity label and actionable description
- **Fail**: PR is too large to review meaningfully → recommend splitting; HUMAN DECISION

### Step 2: Feedback Triage

- **Agent**: developer
- **Input**: Review comments from Step 1
- **Output**: Triage decision for each comment — accepted, deferred (with rationale), or disputed (with counter-argument)
- **Completion**: Every review comment has a triage decision; disputed items include a clear rationale

### Step 3: Resolution

- **Agent**: developer
- **Skills**: implementation
- **Input**: Accepted comments from Step 2
- **Output**: Code changes addressing accepted comments; deferred items tracked as follow-up tasks
- **Completion**: All accepted comments addressed in code; deferred items documented
- **Fail**: Resolution introduces new test failures → fix before proceeding

### Step 4: Re-Review

- **Agent**: reviewer
- **Skills**: pr-review
- **Input**: Updated PR with resolutions from Step 3
- **Output**: Confirmation that accepted comments are resolved; assessment of disputed items
- **Loop**: If new blocking issues found → GOTO Step 3 (Resolution)
- **Loop exit**: No blocking issues remain
- **Loop limit**: 2
- **Fail**: Disputes remain unresolved after 2 review cycles → escalate to monitor agent; HUMAN DECISION
- **Completion**: No blocking comments remain; reviewer confirms resolution is satisfactory

### Step 5: Human Approval

- **Gate**: HUMAN APPROVAL — final sign-off on the reviewed and resolved PR
- **Completion**: Human approves; PR is ready to merge
