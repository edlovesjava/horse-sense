# SPIKE-010: Containerized Subagent Dispatch — Environment Readiness

> **Status**: Complete
> **Author**: Claude (Day 3 kickoff spike, Sprint 6)
> **Date**: 2026-04-18
> **Timebox**: 30 minutes
> **Stories**: Epic 6 (M7) — T-060 through T-065

---

## Question

Two High-risk items from the Sprint 6 risk table block T-060 (Dockerfile):

1. **Is Docker available** in the Codespaces environment we develop in?
2. **What is the correct npm package name** for the `claude` CLI, and does it install cleanly in a container base image?

This spike answers both before the Dockerfile work starts.

### Scope

In bounds:

- Docker CLI availability and daemon reachability in this dev environment
- `claude` CLI packaging on the npm registry and local install path
- Node.js base-image version selection for the sandbox image

Out of bounds:

- API key passthrough semantics (covered by T-065 smoke test)
- Full Dockerfile implementation (T-060 itself)
- Rootless Docker / Podman alternatives

## Approach

- [x] Check `docker --version` and `docker ps` to confirm daemon is reachable
- [x] Check local `claude` CLI version
- [x] Query npm registry for `@anthropic-ai/claude-code`, `claude-code`, `claude`
- [x] Check Node.js version vs. ADR-0005's `node:20-slim` base image

## Findings

### Finding 1: Docker is available in Codespaces

```
$ docker --version
Docker version 28.5.1-1, build e180ab8ab82d22b7895a3e6e110cf6dd5c45f1d7

$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
(empty — daemon reachable, no running containers)
```

Docker-in-Docker (or equivalent) works in this Codespace. The risk table item "Docker not available in Codespaces environment (High)" is **de-risked**. The graceful-degradation fallback in T-061 (`bin/claude-sandbox` falls back to local `claude -p` when Docker is absent) remains necessary for portability but is not needed for our development loop.

### Finding 2: Official claude CLI package is `@anthropic-ai/claude-code`

```
$ npm view @anthropic-ai/claude-code version description
version = '2.1.113'
description = "Use Claude, Anthropic's AI assistant, right from your terminal..."
```

There are two squatter/pointer packages on npm:

| Package | Version | Notes |
|---|---|---|
| `@anthropic-ai/claude-code` | 2.1.113 | **Official** — install this |
| `claude-code` | 1.0.0 | Pointer (description: "Pointer to the official Claude Code package at @anthropic-ai/claude-code") |
| `claude` | 0.1.2 | Third-party squatter (description: "This is not the official Claude Code package") |

The Dockerfile must install `@anthropic-ai/claude-code`, not `claude` or `claude-code`. The risk table item "`claude` CLI npm package may not exist or may require auth (High)" is **de-risked** — the package is public and installable without auth (the API key is supplied at runtime via `ANTHROPIC_API_KEY`).

### Finding 3: Local claude CLI is already at the target version

```
$ which claude && claude --version
/home/codespace/.local/bin/claude
2.1.113 (Claude Code)
```

Local and latest-on-npm match (2.1.113). This means:

- The fallback path in T-061 (`claude -p` outside the container) will behave identically to the in-container version for smoke-test purposes
- We can validate T-064 prompt templates locally before wiring them into the containerized path

### Finding 4: Node.js base-image choice

Codespaces currently ships Node v24.11.1. The ADR-0005 design called for `node:20-slim`. Node 20 is LTS through April 2026 (effectively now — LTS formally ends 2026-04-30 per the Node release schedule). Recommendation:

- **Use `node:22-slim`** (current LTS, active maintenance through 2027-04)
- Avoid `node:24-slim` (current release line, not yet LTS)

This is a deviation from ADR-0005 worth noting in the T-060 implementation commit (does not require a new ADR — same architecture, newer LTS line).

## Trade-off Matrix

| Option | Base image | Pros | Cons |
|---|---|---|---|
| A: `node:20-slim` (per ADR-0005) | Node 20 LTS | Matches ADR exactly | LTS ends within days of sprint end |
| B: `node:22-slim` (recommended) | Node 22 LTS | Active LTS until 2027-04; minor deviation from ADR | Requires a note in T-060 commit |
| C: `node:24-slim` | Node 24 current | Matches host environment | Not yet LTS; upstream churn risk |

## Recommendation

Proceed with T-060 immediately. No blockers remain. Use `node:22-slim` as the base image and document the deviation from ADR-0005's `node:20-slim` in the T-060 commit message.

## Open Questions

- [ ] Should `bin/claude-sandbox` detect and reject Node-24-host / Node-22-container mismatches, or is this irrelevant at runtime?
- [ ] Is there a lighter base than `node:22-slim` (e.g., `node:22-alpine`) that still supports the `@anthropic-ai/claude-code` native deps? Defer decision to T-060 if image size exceeds the 500 MB target.

## Next Steps

- [x] Document findings (this file)
- [ ] Begin T-060 (`horse/Dockerfile.claude-sandbox`) using `node:22-slim`
- [ ] Begin T-061 (`horse/bin/claude-sandbox`) once T-060 builds successfully
