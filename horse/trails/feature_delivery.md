---
name: feature-delivery
description: End-to-end feature delivery from requirements to deployment
trigger: /horse:deliver
version: 1
---

# Feature Delivery Trail

Full SDLC lifecycle for delivering a feature: requirements gathering, architecture design, sprint planning, implementation with TDD, testing, code review, and deployment preparation.

## Entry Gate

- [ ] Feature request, user story, or problem statement exists
- [ ] `.claude/config.json` is configured for the project
- [ ] CI pipeline is green on the main branch
- [ ] `horse.config.md` exists with `requirements_format` and `git_strategy` set

## Exit Gate

- [ ] All steps completed or explicitly skipped with rationale
- [ ] All output artifacts exist and are up to date
- [ ] CI is green on the main branch
- [ ] PR merged and sprint branch cleaned up

## Artifacts

| Artifact | Direction | Description |
|---|---|---|
| Feature request / user story | Input | Problem statement or requirements to implement |
| `.claude/config.json` | Input | Project toolchain configuration |
| `requirements_doc.md` | Output | Updated requirements with user stories |
| `architecture_doc.md` | Output | System design and ADRs |
| `sprint_plan.md` | Output | Sprint backlog with tasks and capacity |
| Source code + tests | Output | Working implementation with passing tests |
| PR with review | Output | Reviewed and approved pull request |
| Deployment artifacts | Output | Build artifacts, runbook, updated CHANGELOG |

### Step 1: Requirements

- **Agent**: planner
- **Skills**: requirements-analysis
- **Input**: Feature request or problem statement from the user
- **Output**: Updated `requirements_doc.md` with user stories and acceptance criteria
- **Completion**: All stories have title, description, acceptance criteria, priority, and estimate
- **Fail**: Unable to clarify requirements after 2 rounds → HUMAN DECISION
- **Gate**: HUMAN APPROVAL — review requirements before design

### Step 2: Architecture

- **Agent**: architect
- **Skills**: architecture-design
- **Input**: Approved requirements from Step 1
- **Output**: Updated `architecture_doc.md`, new ADRs for key decisions
- **Completion**: Architecture document updated, ADRs created for technology choices and trade-offs
- **Fail**: Conflicting non-functional requirements that cannot be resolved → HUMAN DECISION
- **Gate**: HUMAN APPROVAL — review architecture before implementation

### Step 3: Sprint Planning

- **Agent**: planner
- **Skills**: (sprint planning via `/horse:sprint`)
- **Input**: Approved requirements and architecture
- **Output**: Sprint plan at `docs/plans/sprints/sprint_<N>_plan.md`
- **Completion**: Sprint plan exists with goal, backlog, capacity, and Definition of Done; stories transitioned to `in-progress`
- **Gate**: HUMAN APPROVAL — confirm sprint scope and capacity

### Step 4: Implementation

- **Agent**: developer
- **Skills**: implementation
- **Monitor**: trainer (optional, on code quality and process adherence)
- **Input**: Sprint plan with assigned tasks
- **Output**: Working code with passing unit tests
- **Loop**: write test → implement → run tests → fix failures
- **Loop exit**: All unit tests pass, linter clean, type checker clean
- **Loop limit**: 10
- **Fail**: Loop exceeds 10 iterations without convergence → HUMAN DECISION
- **Completion**: All sprint tasks implemented, unit tests passing, `make can-commit` green

### Step 5: Testing

- **Agent**: tester
- **Skills**: testing
- **Input**: Implemented code from Step 4
- **Output**: Integration and e2e tests, coverage report
- **Loop**: write tests → run suite → fix gaps
- **Loop exit**: Coverage meets threshold, all test categories pass
- **Loop limit**: 5
- **Fail**: Coverage cannot reach threshold after 5 iterations → HUMAN DECISION
- **Completion**: Integration and e2e tests pass, coverage ≥ configured threshold

### Step 6: Review

- **Agent**: reviewer
- **Skills**: pr-review
- **Input**: PR with implementation and tests
- **Output**: Review feedback, approved PR
- **Branch**: If blocking issues found → GOTO Step 4 (Implementation)
- **Completion**: No blocking review comments, `make can-review` green, PR approved
- **Gate**: HUMAN APPROVAL — final review sign-off before merge

### Step 7: Deployment

- **Agent**: developer
- **Skills**: deployment
- **Input**: Approved, merged code
- **Output**: Deployment artifacts, runbook, updated CHANGELOG
- **Completion**: CI green on main, deployment artifacts built, runbook documented
- **Gate**: HUMAN APPROVAL — confirm deployment readiness
