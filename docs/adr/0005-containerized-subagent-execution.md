# ADR-0005: Containerized Subagent Execution

**Status**: Accepted  
**Date**: 2026-04-04  
**Decision makers**: Ed Wentworth

## Context

ADR-0004 introduced the orchestrator/worker/monitor agent model, where orchestrators dispatch worker agents to perform focused tasks within a process. However, that design assumed all agents run inside the same Claude Code session — sharing the same context window, filesystem access, and permissions.

This creates several limitations:

1. **Blast radius** — a misbehaving subagent (infinite loop, runaway file writes, destructive commands) affects the entire session and the user's workspace directly
2. **Context pollution** — each worker dispatch consumes tokens in the shared context window, limiting the depth of multi-step processes
3. **No parallelism** — the in-session Agent tool runs subagents sequentially within one process (Claude Code does support parallel Agent calls, but they share the same environment)
4. **No isolation** — workers can read/write any file the host session can, which matters for untrusted or generated code execution

Meanwhile, the `claude` CLI already supports non-interactive, one-shot invocation:

```bash
claude -p "your prompt here" --output-format json
claude -p "$(cat task.md)" --output-format json --input-file context.txt
```

This is not a hack — it is an explicitly supported interface. Anthropic's own documentation describes multi-agent patterns where Claude spawns subagents. The orchestrator/subagent model is part of Claude Code's design.

By running these one-shot invocations inside Docker containers, we get sandboxing for free: filesystem isolation, network restriction, resource limits, and timeout enforcement — all via standard Docker flags.

## Decision

Add a **containerized subagent execution** capability to the horse plugin:

### 1. `bin/claude-sandbox` — Container Runner

A shell script (auto-discovered, added to PATH) that wraps `docker run` to execute `claude -p` inside a sandboxed container.

**Interface:**
```bash
claude-sandbox --prompt "Generate unit tests for auth.py" \
               --mount ./src:/workspace/src:ro \
               --timeout 120 \
               --output result.json
```

**Container defaults (secure by default):**
- `--network none` — no internet access
- `--read-only` — read-only root filesystem
- `--tmpfs /tmp:size=256m` — writable temp only
- `--user 1000:1000` — non-root
- `--memory 2g --cpus 2` — resource caps
- `--rm` — auto-cleanup
- API key passed via `--env ANTHROPIC_API_KEY` (never baked into image)

### 2. `Dockerfile.claude-sandbox` — Sandbox Image

Minimal image containing:
- `claude` CLI (installed via npm)
- Python 3.11+ and Node.js 20+ (for subagent tool use)
- `git` (for repo-aware subagents)
- No secrets, no credentials, no project-specific config

### 3. `skills/subagent-dispatch/SKILL.md` — Dispatch Skill

A model-invoked skill that teaches Claude **when** and **how** to dispatch containerized subagents. It encodes:
- When to dispatch (task is self-contained, doesn't need conversational context)
- How to construct prompts (task description + constraints + output schema)
- How to parse results (JSON with `result`, `exit_code`, `stderr`)
- When NOT to dispatch (task needs user interaction, requires shared state, needs network)

### 4. Invocation Contract

**Input:**
| Field | Type | Description |
|---|---|---|
| `prompt` | string | The task prompt (or path to a prompt file) |
| `mounts` | list | Workspace paths to mount (read-only by default) |
| `timeout` | int | Max execution time in seconds (default: 120) |
| `output_format` | string | `json` (default) or `text` |
| `network` | bool | Enable network access (default: false) |

**Output (JSON):**
```json
{
  "result": "... the subagent's response ...",
  "exit_code": 0,
  "stderr": "",
  "duration_seconds": 14.2,
  "tokens_used": { "input": 1200, "output": 850 }
}
```

### 5. Graceful Degradation

When Docker is not available (CI without Docker, restricted hosts):
- `bin/claude-sandbox` falls back to local `claude -p` execution
- Logs a warning that sandboxing is not active
- All other behavior (prompt construction, JSON parsing, timeouts) remains identical

## Alternatives Considered

**In-session Agent tool only** — Use Claude Code's built-in Agent tool for all subagent work. This is the current approach. Rejected as the sole mechanism because: no filesystem isolation, shared context window, no resource limits, no network restriction. The Agent tool remains valuable for tasks that need conversational context or access to the full session state — containerized subagents complement it for isolated, one-shot work.

**Direct `docker exec` without wrapper** — Have orchestrator agents construct `docker run` commands directly. Rejected because: error-prone, security flags easily forgotten, no consistent interface, harder to override defaults per project.

**Kubernetes Jobs / remote execution** — Run subagents on a Kubernetes cluster or remote CI. Rejected for v1 because: massive complexity increase, requires infrastructure beyond a developer's laptop, and the `claude` CLI is designed for local use. Could revisit for team-scale deployments.

**Nsjail / Firecracker / gVisor** — More granular sandboxing than Docker. Rejected for v1 because: Docker is ubiquitous and sufficient for our threat model (protecting the user's workspace from subagent mistakes, not running hostile code). Worth revisiting if the plugin is used for executing untrusted third-party code.

**No sandboxing (local `claude -p` only)** — Skip containerization entirely. Rejected because: the whole point of one-shot subagents is that they're disposable and isolated. Without sandboxing, a subagent that writes to the wrong directory or runs a destructive command has full access. Local fallback is kept as a degradation path, not the primary mode.

## Consequences

**Positive:**
- Subagents are sandboxed — filesystem, network, and resource isolation by default
- Orchestrators can dispatch parallel work without polluting the session context
- One-shot invocations have clear input/output contracts (JSON in, JSON out)
- The `bin/claude-sandbox` wrapper is reusable outside the plugin (any script can call it)
- Graceful degradation means the plugin works without Docker, just without sandboxing
- SKILL.md encoding makes the dispatch pattern learnable and reproducible

**Negative:**
- Docker is a new dependency (optional but strongly recommended)
- Container cold-start adds latency (~5-15s for first invocation, faster with cached images)
- Each subagent invocation consumes its own API tokens (no context reuse across dispatches)
- Debugging subagent failures is harder — must inspect JSON output, no interactive session
- Image maintenance burden (keeping `claude` CLI version in sync)

**Risks:**
- Docker unavailability in some environments (Codespaces, restricted CI) — mitigated by local fallback
- API key leakage via container environment — mitigated by `--env` (not `--build-arg`), never baked into image layers
- Subagent prompt injection via mounted files — mitigated by read-only mounts, constrained prompts, and result validation by the orchestrator
- Claude CLI non-interactive mode may have undocumented limitations — must test `-p` and `--output-format json` thoroughly in Sprint 6 (T-055)

## References

- ADR-0004: Process Orchestration Model (the orchestrator/worker pattern this extends)
- Claude Code CLI documentation: non-interactive mode (`-p`, `--output-format json`)
- Docker security best practices: rootless, read-only, network isolation
