---
id: US-025
title: Process definition documents
status: draft
priority: Must Have
story_points: 8
section: "3.4 Process Definitions — Workflow Specification"
---

# US-025 — Process definition documents

> As a **plugin author**, I want to **define workflows as structured process documents** so that **orchestrator agents have a clear, repeatable specification to follow**.

## Acceptance Criteria

```gherkin
Given a process document exists at processes/feature_delivery.md
When  an orchestrator reads it
Then  it can identify:
  | Element              | Description                                      |
  | Name                 | Process identifier                                |
  | Entry gate           | Preconditions to start (artifacts, state, config) |
  | Steps                | Ordered sequence of work                          |
  | Agent assignment     | Which worker agent executes each step             |
  | Skills & tools       | Which skills and tools each step uses              |
  | Completion criteria  | How to know a step succeeded                      |
  | Fail conditions      | When to abort or escalate                         |
  | Human checkpoints    | Explicit points requiring human decision          |
And  it executes the process by following the steps in order
```

## Process document structure

```markdown
---
name: feature-delivery
description: End-to-end feature delivery from requirements to deployment
trigger: /horse-sense:deliver
---

# Feature Delivery Process

## Entry Gate
- [ ] Feature request or user story exists
- [ ] .claude/config.json is configured
- [ ] CI pipeline is green on main branch

## Steps

### Step 1: Requirements
- **Agent**: planner
- **Skills**: requirements-analysis
- **Action**: Gather and document requirements
- **Completion**: requirements_doc.md exists and has all sections filled
- **Fail**: Unable to clarify requirements after 2 rounds → HUMAN DECISION

### Step 2: Architecture
- **Agent**: architect
- **Skills**: architecture-design
- **Action**: Design system architecture, create ADRs
- **Completion**: architecture_doc.md updated, ADRs created
- **Gate**: HUMAN APPROVAL — review architecture before implementation

### Step 3: Implementation
- **Agent**: developer
- **Skills**: implementation
- **Monitor**: monitor (optional, on develop-test loop)
- **Action**: Implement feature with TDD
- **Loop**: write test → implement → run tests → fix failures
- **Loop exit**: All tests pass, lint clean, type check clean
- **Fail**: Loop exceeds 5 iterations without convergence → HUMAN DECISION

### Step 4: Testing
- **Agent**: tester
- **Skills**: testing
- **Action**: Expand test coverage, integration and e2e tests
- **Completion**: Coverage ≥ threshold, all test categories pass
- **Fail**: Coverage cannot reach threshold → HUMAN DECISION

### Step 5: Review
- **Agent**: reviewer
- **Skills**: review
- **Action**: Code review against quality standards
- **Branch**: If blocking issues found → GOTO Step 3 (implementation fixes)
- **Completion**: No blocking issues, PR approved
- **Gate**: HUMAN APPROVAL — final review sign-off

### Step 6: Deployment
- **Agent**: developer
- **Skills**: deployment
- **Action**: Prepare deployment artifacts and runbook
- **Completion**: CI green, artifacts built, runbook documented
```
