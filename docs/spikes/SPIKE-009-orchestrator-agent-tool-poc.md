# SPIKE-009: SDLC Orchestrator Design & Agent Tool POC

> **Status**: Complete
> **Author**: Scout agent
> **Date**: 2026-04-09
> **Timebox**: 3 hours
> **Stories**: US-023, US-024, US-026, US-027, US-028, US-029

---

## Question

How should the SDLC orchestrator agent (`agents/sdlc.md`) be designed to execute
process trails by dispatching worker agents via Claude Code's Agent tool? Two
sub-questions:

1. **Mechanics** — How does the Agent tool dispatch to plugin agents? Can a
   plugin agent invoke other plugin agents as sub-agents? What are the
   constraints?
2. **Design** — Given the trail format, existing worker agents, and plugin
   constraints, what is the right architecture for the orchestrator?

### Scope

In bounds:

- Agent tool dispatch mechanics (subagent_type, tools allowlist, context flow)
- Plugin agent constraints (frontmatter, hooks, permissionMode)
- State tracking across long-running orchestrator sessions
- Human checkpoint and loop management patterns
- Draft `agents/sdlc.md` design

Out of bounds:

- Containerized subagent dispatch (Phase 3)
- Agent teams / experimental features
- Cross-session persistence beyond file state

## Approach

- [x] Read all worker agent files to understand frontmatter patterns
- [x] Read trail format spec and feature_delivery trail
- [x] Read ADR-0004 (process orchestration model)
- [x] Read orchestration requirement stories (US-023 through US-029, US-040, US-041)
- [x] Research Claude Code Agent tool documentation and constraints
- [x] Design orchestrator frontmatter and system prompt
- [x] Identify risks and constraints

## Findings

### Finding 1: Subagents cannot spawn other subagents — hard constraint

Claude Code enforces a single-level dispatch rule: subagents cannot use the
Agent tool to spawn further subagents. If the orchestrator runs *as a subagent*
(e.g., dispatched by a command), it **cannot** dispatch worker agents.

**Implication**: The orchestrator must run as the **main conversation agent**
(via `--agent horse:sdlc` or equivalent), not as a subagent dispatched by
another agent.

### Finding 2: Plugin agent naming convention

Plugin agents appear in the Agent tool as `horse:<agent-name>`. The `name`
field in YAML frontmatter is the identifier; the plugin namespace prefixes it.

Dispatch syntax: `Agent(subagent_type: "horse:developer", prompt: "...")`

### Finding 3: Context flows through files and prompts, not inheritance

Subagents receive **only** their own system prompt plus basic environment
details. They do not inherit the orchestrator's conversation history.

Context passes between steps via:

1. **Files on disk** — primary mechanism. Worker reads artifacts written by
   prior workers.
2. **The task prompt** — orchestrator summarizes prior step output when
   constructing the worker's prompt.
3. **Subagent result** — when a worker finishes, its result (text summary)
   returns to the orchestrator for forwarding.

### Finding 4: Agent tool parameters

The Agent tool accepts:

- **prompt** — what the subagent should do
- **subagent_type** — which agent definition (e.g., `horse:developer`)
- **description** — short task description
- **model** (optional) — per-invocation model override
- **run_in_background** (optional) — concurrent execution
- **isolation** (optional) — `"worktree"` for git isolation

### Finding 5: Tools allowlist controls dispatch scope

The `tools` frontmatter field controls what the orchestrator can dispatch:

```yaml
tools: Agent(horse:planner, horse:architect, horse:developer, horse:tester, horse:reviewer, horse:trainer), Read, Write, Bash, Glob, Grep
```

This is an explicit allowlist — only named agents can be spawned.

### Finding 6: State persistence — files only

Claude Code has no persistent state beyond files. The orchestrator must
maintain a **session state file** (e.g., `docs/trails/.sdlc-state.md`) that
tracks:

- Current step and status
- Loop iteration counts
- Human decisions made
- Step output summaries

This survives context window compaction and allows trail inspection/resumption.

### Finding 7: Human checkpoints use natural conversation turns

The orchestrator, running as the main agent, simply asks the user a question
and waits. No special API needed. The trail's `HUMAN APPROVAL` gates map to:
present summary → ask approve/reject/modify → wait for response → log decision
→ continue.

### Finding 8: The `--agent` invocation path

The orchestrator runs as the main session agent:

```bash
claude --plugin-dir ./horse --agent horse:sdlc
```

Or triggered via a command that instructs Claude to follow the orchestrator
pattern inline. The `/horse:guide` command can reference the orchestrator's
approach without requiring `--agent`.

### Finding 9: Plugin constraints

Plugin agents **cannot** use `hooks`, `mcpServers`, or `permissionMode`
frontmatter fields. These must be set at project level in `.claude/settings.json`.

### Finding 10: Worker skill activation

Subagents do not inherit skills from the parent. Worker agents reference
skills via path in their body text (the `SKILL.md` approach). The orchestrator
does not need implementation skills — it constructs prompts that activate
worker agents which carry their own skill references.

## Trade-off Matrix

| Option | Description | Pros | Cons | Effort | Risk |
|---|---|---|---|---|---|
| A: `sdlc.md` as `--agent` orchestrator | Agent runs as main session; dispatches workers via Agent tool | Matches platform design; clean worker isolation; state file persistence | Requires `--agent` flag or equivalent invocation | Medium | Medium |
| B: Command-only orchestration | Keep orchestration in `guide.md`; inline all steps | Already works; no new mechanism | Grows unwieldy; no worker isolation; all in one context | Low | Low |
| C: Hybrid — command triggers orchestrator pattern | `/horse:guide` instructs Claude to follow orchestrator protocol inline | No `--agent` flag needed; works from any command | Orchestrator behavior in command body, not reusable across trails | Medium | Low |

## Recommendation

**Option A (primary) with Option C (fallback entry point).**

Create `agents/sdlc.md` as a main-session orchestrator agent. The canonical
invocation is `--agent horse:sdlc`. Additionally, update `/horse:guide` to
reference the orchestrator pattern so users can activate it from a running
session without restarting.

### Proposed Design

#### Frontmatter

```yaml
---
name: sdlc
description: >
  SDLC orchestrator — reads and executes process trails by dispatching worker
  agents through each step. Invoke to run the feature-delivery trail end-to-end.
model: sonnet
maxTurns: 50
tools: Agent(horse:planner, horse:architect, horse:developer, horse:tester, horse:reviewer, horse:trainer), Read, Write, Bash, Glob, Grep
---
```

Key decisions:

- `maxTurns: 50` — full 7-step trail with loops and human checkpoints requires
  many orchestrator turns
- `model: sonnet` — orchestration is reasoning-heavy but produces no code;
  Sonnet is cost-effective
- Tools allowlist explicit: six named worker agents + file I/O + Bash (gate checks)

#### Body structure

1. **Role statement** — orchestrator only; never writes code/docs directly
2. **Trail loading protocol** — read trail file, parse entry gate/steps/exit gate
3. **State tracking** — maintain `docs/trails/.sdlc-state.md` with step
   progress, loop counts, decisions
4. **Worker dispatch pattern** — construct prompts from trail step definitions;
   pass input artifacts and completion criteria
5. **Gate evaluation** — file existence (Glob/Read), test results (Bash),
   human gates (conversation)
6. **Loop management** — count in state file; check against `max_iterations`;
   escalate to human when exceeded
7. **Branch handling** — update state to target step; restart from there
8. **Human checkpoint protocol** — present summary, state decision needed,
   wait, log decision
9. **Context hand-off** — summarize worker output in state file; pass forward
   as next worker's prompt context

## Open Questions

- [ ] Should the orchestrator use `run_in_background` for any parallel worker
  dispatches (e.g., lint + test simultaneously)?
- [ ] How should `/horse:guide` activate the orchestrator pattern without
  `--agent`? Inline instructions or delegation?
- [ ] Should the state file template live at `horse/templates/sdlc_state.md`?
- [ ] What is the right `maxTurns` value? 50 may be too many or too few — needs
  tuning against real trail executions.

## Next Steps

- [ ] Implement `horse/agents/sdlc.md` from this design (T-040)
- [ ] Create state file template at `horse/templates/sdlc_state.md`
- [ ] Update `/horse:guide` to reference the orchestrator (T-043)
- [ ] Dry-run trace through Step 1 (Requirements) only to validate dispatch cycle
- [ ] Implement `horse/agents/monitor.md` for loop escalation (T-042)
