---
name: bug-fix
description: Bug-fix lifecycle from triage through fix, verification, and review
trigger: /horse:fix
version: 1
---

# Bug Fix Trail

Abbreviated lifecycle for fixing a reported bug: triage to identify root cause, fix with minimal change, verify with regression test, review, and human sign-off before merge.

## Entry Gate

- [ ] Bug report or issue exists with description of the problem
- [ ] Steps to reproduce are documented (or reproducible from description)
- [ ] `.claude/config.json` is configured for the project
- [ ] CI pipeline is green on the main branch

## Exit Gate

- [ ] Bug is fixed and regression test exists
- [ ] All tests pass, including the new regression test
- [ ] PR merged and branch cleaned up
- [ ] Bug report or issue updated with resolution

## Artifacts

| Artifact | Direction | Description |
|---|---|---|
| Bug report / issue | Input | Description of the problem with reproduction steps |
| Root cause analysis | Output | Documented root cause (in commit message or issue comment) |
| Code fix + regression test | Output | Minimal fix with a test that would have caught the bug |
| PR with review | Output | Reviewed and approved pull request |

### Step 1: Triage

- **Agent**: scout
- **Skills**: (codebase exploration, root cause analysis)
- **Input**: Bug report with reproduction steps
- **Output**: Root cause identified — affected file(s), function(s), and failure mechanism documented
- **Completion**: Root cause documented with specific code references; affected components identified
- **Fail**: Root cause unclear after investigation → HUMAN DECISION (provide findings so far and request guidance)

### Step 2: Fix

- **Agent**: developer
- **Skills**: implementation
- **Input**: Root cause from Step 1
- **Output**: Minimal code fix addressing the root cause
- **Completion**: Fix implemented with smallest possible change scope
- **Fail**: Fix requires architectural changes beyond bug scope → HUMAN DECISION

### Step 3: Regression Test

- **Agent**: tester
- **Skills**: testing
- **Input**: Code fix from Step 2
- **Output**: Regression test that reproduces the original bug and verifies the fix
- **Loop**: write regression test → run tests → fix failures
- **Loop exit**: All tests pass, including the new regression test
- **Loop limit**: 2
- **Fail**: Tests cannot pass after 2 iterations → escalate to monitor agent
- **Completion**: Regression test exists and passes; full test suite green

### Step 4: Review

- **Agent**: reviewer
- **Skills**: pr-review
- **Input**: PR with fix and regression test
- **Output**: Review feedback confirming fix scope is minimal and no new issues introduced
- **Branch**: If blocking issues found → GOTO Step 2 (Fix)
- **Completion**: No blocking review comments, fix scope confirmed minimal, PR approved
- **Fail**: Branch-back to Step 2 exceeds 2 cycles → escalate to monitor agent

### Step 5: Human Approval

- **Gate**: HUMAN APPROVAL — review fix, regression test, and review feedback before merge
- **Completion**: Human confirms fix is ready to merge; bug report updated with resolution
