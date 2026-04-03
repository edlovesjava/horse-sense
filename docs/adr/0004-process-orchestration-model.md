# ADR-0004: Process Orchestration Model — Workers, Orchestrators, and Monitors

**Status**: Accepted  
**Date**: 2026-04-03  
**Decision makers**: Ed Wentworth

## Context

The original horse-sense design treated all agents as peers — each had a role but none coordinated the others. Workflows were implicit (the SDLC skill listed phases, but nothing enforced sequencing, gates, or iteration). This led to several problems:

1. Users had to manually sequence skills (`/plan` → `/arch` → `/implement` → ...) with no enforcement
2. Quality gates existed only as suggestions, not as enforced checkpoints
3. Iterative loops (develop → test → fix) had no convergence monitoring
4. There were no explicit human decision points — the AI either asked or didn't, inconsistently

We need a model where complex workflows are defined declaratively and executed reliably.

## Decision

Introduce a three-tier agent model with explicit process definitions:

### Agent Types

1. **Worker agents** — perform focused work from a role perspective (planner, architect, developer, tester, reviewer). Unchanged from the original design except organized under `agents/workers/`.

2. **Orchestrator agents** — read process definitions and execute them by dispatching workers, evaluating gates, managing loops and branches, and pausing at human checkpoints. They do not write code or documents themselves.

3. **Monitor agents** — optionally assigned to loops within a process. They observe iterations, detect non-convergence or quality degradation, and can intervene with guidance to the worker or escalate to the orchestrator.

### Process Definitions

Workflows are defined as Markdown documents in `processes/` with:
- **Entry gates** — checklist preconditions
- **Steps** — ordered, each assigned to a worker agent with skills
- **Flow control** — sequence (default), loops (with exit/fail conditions), conditional branches (GOTO), and sub-process recursion
- **Completion criteria** — per-step success conditions
- **Fail conditions** — per-step abort triggers, typically escalating to a human
- **Human checkpoints** — explicit `HUMAN APPROVAL` or `HUMAN DECISION` gates

### Execution Model

Orchestrators follow a state machine: load process → check entry gate → for each step (dispatch worker → evaluate outcome → advance/loop/branch/fail) → report summary. Human checkpoints pause the state machine and present a decision to the user.

## Alternatives Considered

**Hardcoded workflows in skills** — Skills contain step-by-step guides, so workflows could be embedded. Rejected because: not composable, not customizable per project, mixing "how to do X" with "when to do X."

**YAML/DSL for process definitions** — A formal schema would be more machine-parseable. Rejected for now because: Markdown is readable by both humans and Claude, consistent with the rest of the plugin, and avoids a parsing layer. Can revisit if process complexity grows.

**Flat agent model with conventions** — Keep all agents as peers, rely on naming conventions and documentation to imply orchestration. Rejected because: no enforcement, no gates, no loop monitoring — the same problems we're solving.

## Consequences

**Positive:**
- Workflows are declarative, readable, and customizable
- Quality gates are enforced, not suggested
- Human-in-the-loop is explicit and consistent
- Monitor agents prevent infinite loops and quality degradation
- New workflows can be added by creating a process document — no code changes
- Workers remain focused on their role; orchestrators handle sequencing

**Negative:**
- More agent definitions to maintain (orchestrators + monitors in addition to workers)
- Process definition format is a convention, not a schema — could drift
- Orchestrator behavior depends on Claude Code's ability to maintain state and context across agent dispatches (open question #6)
- Monitor agents add latency to loops (observation step between iterations)

**Risks:**
- Claude Code may not natively support the "dispatch worker" pattern — orchestrators may need to use the Agent tool or context-switching, which needs testing
- Long processes may exceed context limits — need to verify orchestrators can manage state efficiently
