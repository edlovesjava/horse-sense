---
name: sprint-execution
description: Story-level iteration within a sprint — plan, implement, test, review, doc-sync
trigger: /horse:sprint
version: 1
---

# Sprint Execution Trail

Story-level iteration cycle used by the sprint orchestrator to drive each story from ready-for-sprint through to done. The core loop is implement, test, review with branch-back on review failure and escalation to the monitor agent when the loop does not converge.

## Entry Gate

- [ ] Sprint plan exists with at least one story in `To Do` status
- [ ] `.claude/config.json` is configured for the project
- [ ] CI pipeline is green on the sprint branch
- [ ] All stories in the sprint have acceptance criteria defined

## Exit Gate

- [ ] All sprint stories are `Done` or explicitly deferred with rationale
- [ ] All output artifacts exist and are up to date
- [ ] CI is green on the sprint branch
- [ ] Doc-sync check passes (story status, index table, sprint plan all consistent)

## Artifacts

| Artifact | Direction | Description |
|---|---|---|
| Sprint plan | Input | Sprint backlog with stories, tasks, and capacity |
| `requirements_doc.md` | Input | User stories with acceptance criteria |
| Source code + tests | Output | Working implementation with passing tests |
| Updated sprint plan | Output | Task statuses updated to reflect completion |
| PR with review | Output | Reviewed and approved pull request per story |

### Step 1: Requirements Review

- **Agent**: planner
- **Skills**: requirements-analysis
- **Input**: Sprint plan and story acceptance criteria
- **Output**: Confirmed story is ready-for-sprint — requirements are clear, testable, and scoped
- **Completion**: Story has clear acceptance criteria, no ambiguous terms, estimate confirmed
- **Fail**: Requirements unclear after 1 clarification round → HUMAN DECISION

### Step 2: Implementation

- **Agent**: developer
- **Skills**: implementation
- **Input**: Story requirements and architecture context
- **Output**: Working code with passing unit tests
- **Loop**: write test → implement → run tests → fix failures
- **Loop exit**: All unit tests pass, linter clean, type checker clean
- **Loop limit**: 3
- **Fail**: Loop exceeds 3 iterations without convergence → escalate to monitor agent
- **Completion**: Story tasks implemented, unit tests passing, `make can-commit` green

### Step 3: Testing

- **Agent**: tester
- **Skills**: testing
- **Input**: Implemented code from Step 2
- **Output**: Integration tests, coverage report
- **Loop**: write tests → run suite → fix gaps
- **Loop exit**: Coverage meets threshold, all test categories pass
- **Loop limit**: 3
- **Fail**: Coverage cannot reach threshold after 3 iterations → escalate to monitor agent
- **Completion**: Tests pass, coverage meets configured threshold

### Step 4: Code Review

- **Agent**: reviewer
- **Skills**: pr-review
- **Input**: PR with implementation and tests
- **Output**: Review feedback, approved PR
- **Branch**: If blocking issues found → GOTO Step 2 (Implementation)
- **Completion**: No blocking review comments, PR approved
- **Fail**: Branch-back to Step 2 exceeds 3 cycles → escalate to monitor agent

### Step 5: Doc-Sync Check

- **Agent**: trainer
- **Skills**: (doc-sync validation)
- **Input**: Completed story implementation and PR
- **Output**: Verified documentation consistency
- **Completion**: Story status frontmatter, index table, sprint plan, and project plan are all consistent; no broken internal references
- **Fail**: Documentation inconsistencies found → developer fixes before proceeding

### Step 6: Human Sign-Off

- **Gate**: HUMAN APPROVAL — review completed story, tests, and documentation before marking Done
- **Completion**: Human confirms story is done; task status updated to `Done` in sprint plan
