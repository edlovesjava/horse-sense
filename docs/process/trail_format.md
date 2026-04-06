# Trail Document Format

> **Status**: Draft
> **Date**: 2026-04-06
> **Stories**: US-025, US-026, US-027

---

## Overview

A **trail** is a structured Markdown document that defines a repeatable workflow for an orchestrator agent to follow. Trails specify the sequence of steps, which agents execute each step, what artifacts they consume and produce, and the gates that govern transitions.

Trail files live in `horse/trails/` and are auto-discovered by the plugin manager.

---

## File Structure

```
horse/trails/
├── feature_delivery.md       ← Full SDLC lifecycle
├── bug_fix.md                ← Abbreviated fix-verify cycle
└── spike.md                  ← Research spike workflow
```

---

## Format Specification

### YAML Frontmatter

Every trail begins with YAML frontmatter:

```yaml
---
name: feature-delivery                    # Unique identifier (kebab-case)
description: End-to-end feature delivery  # One-line summary
trigger: /horse:deliver                   # Slash command that starts this trail (optional)
version: 1                                # Format version
---
```

| Field | Required | Description |
|---|---|---|
| `name` | Yes | Unique trail identifier (kebab-case) |
| `description` | Yes | One-line summary of the trail's purpose |
| `trigger` | No | Slash command that invokes this trail |
| `version` | No | Format version (default: 1) |

### Document Body

The body uses Markdown with conventions that an orchestrator can parse.

#### Entry Gate

A checklist at the top of the trail defining preconditions:

```markdown
## Entry Gate

- [ ] Feature request or user story exists
- [ ] .claude/config.json is configured
- [ ] CI pipeline is green on main branch
```

The orchestrator checks each item before starting. If any item fails, the trail is blocked and the orchestrator reports what is missing.

#### Steps

Each step is a level-3 heading (`###`) with a structured body:

```markdown
### Step N: Step Name

- **Agent**: <agent-name>
- **Skills**: <skill-name>[, <skill-name>...]
- **Input**: <artifact or condition>
- **Output**: <artifact produced>
- **Completion**: <exit criteria — when this step is done>
- **Fail**: <fail condition> → <fail action>
```

| Field | Required | Description |
|---|---|---|
| **Agent** | Yes | Which worker agent executes this step |
| **Skills** | No | Skills the agent should use |
| **Input** | No | Artifacts or conditions required (beyond the entry gate) |
| **Output** | No | Artifacts this step produces |
| **Completion** | Yes | Criteria that must be true for the step to succeed |
| **Fail** | No | Condition that triggers failure and the resulting action |

#### Flow Control

Steps execute sequentially by default. Flow control is expressed inline:

##### Loops

```markdown
- **Loop**: <loop body description>
- **Loop exit**: <condition to stop looping>
- **Loop limit**: <max iterations> (default: 5)
- **Fail**: Loop exceeds <N> iterations → HUMAN DECISION
```

##### Branches

```markdown
- **Branch**: If <condition> → GOTO Step N (<step name>)
```

The orchestrator tracks branch-back counts and aborts if a configurable limit is exceeded (default: 3).

##### Sub-trails

```markdown
- **Sub-trail**: <trail-name>
```

The orchestrator loads and executes the referenced trail, then returns control to the parent.

#### Human Checkpoints

Explicit points requiring human approval:

```markdown
- **Gate**: HUMAN APPROVAL — <what the human reviews>
```

The orchestrator pauses and presents the current state to the human. Execution resumes only after explicit approval.

#### Monitor Agents

Optional observer agents that run alongside a step:

```markdown
- **Monitor**: <agent-name> (optional, on <what they observe>)
```

Monitors observe but do not control the step. They can flag issues for the orchestrator to handle.

---

## Minimal Example

```markdown
---
name: bug-fix
description: Fix a reported bug with verification
trigger: /horse:fix
version: 1
---

# Bug Fix Trail

## Entry Gate

- [ ] Bug report or issue exists
- [ ] Steps to reproduce are documented

### Step 1: Diagnose

- **Agent**: developer
- **Skills**: implementation
- **Input**: Bug report with reproduction steps
- **Output**: Root cause identified in code
- **Completion**: Root cause documented in a comment or commit message

### Step 2: Fix and Test

- **Agent**: developer
- **Skills**: implementation, testing
- **Input**: Root cause from Step 1
- **Output**: Code fix with regression test
- **Loop**: write fix → write test → run tests → fix failures
- **Loop exit**: All tests pass, including new regression test
- **Loop limit**: 5
- **Fail**: Loop exceeds 5 iterations → HUMAN DECISION
- **Completion**: Fix committed, all tests green

### Step 3: Review

- **Agent**: reviewer
- **Skills**: pr-review
- **Input**: PR with fix and test
- **Output**: Approved PR
- **Branch**: If blocking issues found → GOTO Step 2 (Fix and Test)
- **Completion**: No blocking issues, PR approved
- **Gate**: HUMAN APPROVAL — final review sign-off
```

---

## Orchestrator Behavior

When executing a trail, the orchestrator:

1. Loads the trail document and parses frontmatter and steps.
2. Evaluates the **entry gate**. If any item fails, reports what is missing and halts.
3. Executes steps in order. For each step:
   a. Dispatches to the named **agent** with the specified **skills**.
   b. Evaluates **completion** criteria when the agent reports done.
   c. If completion is met, advances to the next step.
   d. If a **fail** condition is reached, executes the fail action.
   e. If a **gate** (HUMAN APPROVAL) is present, pauses for human input.
   f. If a **branch** condition is true, jumps to the target step.
4. Tracks **loop** iterations and **branch-back** counts to prevent infinite execution.
5. Reports progress after each step transition.

---

## Design Decisions

- **Markdown over YAML/DSL**: Trails are readable by humans and parseable by Claude. No custom parser needed — the orchestrator reads the document as context.
- **Convention over schema**: The format uses Markdown conventions (headings, bullet lists, bold labels) rather than a strict schema. This makes trails easy to write and modify.
- **Minimum viable format**: This version covers sequence, loops, branches, and human checkpoints. Parameterization, parallel steps, and sub-trail composition are deferred to future iterations.
