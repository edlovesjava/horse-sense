# ADR-0008: Sandbox Network and Authentication — Amendment to ADR-0005

**Status**: Accepted
**Date**: 2026-04-18
**Decision makers**: Ed Wentworth
**Amends**: [ADR-0005 — Containerized Subagent Execution](0005-containerized-subagent-execution.md)

## Context

Sprint 6 implementation of T-060 (`Dockerfile.claude-sandbox`) and T-061 (`bin/claude-sandbox`) surfaced two contradictions in ADR-0005 that must be resolved for the sandbox to work in practice:

1. **Network default** — ADR-0005 lists `--network none` among the container's "secure by default" flags and makes network access an opt-in override (`network=false` by default in the input contract). This is mutually exclusive with the primary use case: `claude -p` inside the container requires HTTPS egress to `api.anthropic.com`. With `--network none` the CLI cannot authenticate and returns empty. The stated default ships broken.

2. **Authentication model** — ADR-0005 assumes the API key is supplied via `--env ANTHROPIC_API_KEY` ("API key passed via `--env` — never baked into image"). This assumes the host already has `ANTHROPIC_API_KEY` set. In practice, many users (including the horse-sense development environment) authenticate via OAuth (`claude login`) with credentials stored at `~/.claude/.credentials.json`. The in-container `claude` CLI has no access to those credentials, and no environment-variable fallback exists. Without amendment, the sandbox effectively requires every user to first set `ANTHROPIC_API_KEY` — but ADR-0005 does not say this.

SPIKE-010 confirmed the Docker and CLI infrastructure is sound; the issues above are policy, not implementation.

## Decision

Amend ADR-0005 as follows. The rest of ADR-0005 stands unchanged.

### 1. Network default is `bridge`, not `none`

`bin/claude-sandbox` defaults to `--network bridge` (standard Docker networking with outbound access). This allows `claude -p` to reach the Anthropic API, which is the entire point of the wrapper. Users who want offline or test-only invocations pass `--no-network` (alias for `--network none`), which takes precedence over the default.

The **contract input** table in ADR-0005 is updated:

| Field | Type | Description |
|---|---|---|
| `network` | string | Docker network mode (default: `bridge`). Use `none` for offline runs. |

The prior `network=false` default is rescinded.

### 2. Authentication requires `ANTHROPIC_API_KEY` on the host

Running `bin/claude-sandbox` with Docker requires `ANTHROPIC_API_KEY` to be set in the host environment. The wrapper forwards it via `--env ANTHROPIC_API_KEY`. When the variable is unset, the wrapper emits a warning to stderr and proceeds (the caller gets an empty result but a stable JSON contract, aiding debugging).

Host OAuth credentials at `~/.claude/.credentials.json` are **not** mounted into the container. Reasons:

- **Isolation** — the sandbox exists to limit blast radius. Exposing long-lived OAuth credentials to subagent code defeats the purpose.
- **Simplicity** — one auth path is easier to reason about and document than two.
- **Contract clarity** — orchestrators constructing sandbox invocations should not have to detect the host auth mode.

The **local fallback** path (when Docker is unavailable) uses the host's local `claude` CLI directly, which already has OAuth credentials via the user's login session. This path is unchanged and works transparently for OAuth users.

### 3. Documentation touchpoints

- `skills/subagent-dispatch/SKILL.md` (T-062) MUST document the `ANTHROPIC_API_KEY` prerequisite and the network default.
- `bin/claude-sandbox --help` already reflects the new defaults.
- The smoke test (T-065) will run with `ANTHROPIC_API_KEY` set in the host environment, or be skipped with a documented reason if the key is unavailable.

## Alternatives Considered

**Leave ADR-0005 as written; force users to pass `--network bridge` explicitly.** Rejected — guaranteed pit of failure: the wrapper ships "secure by default" but cannot perform its primary function out of the box. Every single invocation would need the flag. Defeats the "sensible defaults" principle.

**Auto-mount `~/.claude/.credentials.json` read-only when `ANTHROPIC_API_KEY` is absent.** Rejected — trades isolation (the property we built the sandbox for) to avoid a one-line documentation requirement. Credentials inside the container are exposed to any subagent code that runs there. Users who do not want the friction of setting the env var can always use the Docker-less fallback.

**Restrict egress to `api.anthropic.com` only via custom Docker network + iptables.** Rejected for v1 — substantial build-and-test complexity for a small marginal security gain over `--network bridge`. The Anthropic API is HTTPS-only, so the actual blast radius of an unauthenticated outbound connection from a compromised subagent is narrow. Worth revisiting if the plugin is used for untrusted third-party code execution.

## Consequences

**Positive:**

- The wrapper ships working out of the box (given `ANTHROPIC_API_KEY` is set)
- The security model is simpler to explain: "no host credentials inside the container, only the API key"
- The local fallback continues to Just Work for OAuth users developing without Docker

**Negative:**

- OAuth-only users must set `ANTHROPIC_API_KEY` once before using the Docker path — new friction
- The warning on missing `ANTHROPIC_API_KEY` may surprise users who expect the wrapper to auto-detect OAuth credentials

**Risks:**

- Users may set `ANTHROPIC_API_KEY` in `.bashrc` or shell profiles, which is less secure than a short-lived session variable. Mitigated by documentation; the choice is the user's.
- If Anthropic introduces an official sandbox-friendly auth mode in future (e.g., scoped API keys, OAuth device flow for headless use), this ADR should be revisited.

## References

- ADR-0005: Containerized Subagent Execution (the ADR this amends)
- SPIKE-010: Subagent Sandbox Environment Readiness
- T-060 commit `0ec7392` (Dockerfile)
- T-061 commit (this amendment lands alongside)
