# Project Plan: horse-sense v1.0

> **Document version**: 1.2  
> **Created**: 2026-04-03  
> **Last updated**: 2026-04-04  
> **Owner**: Ed Wentworth  
> **Status**: Draft

---

## 1. Project Overview

### Problem Statement

Claude Code produces inconsistent results without structured guidance. horse-sense exists as a collection of skills, agents, rules, and scripts but needs to be packaged as an official Claude Code plugin named **horse** — it must be installable into other projects via `claude --plugin-dir ./horse`, with commands namespaced as `/horse:*`, and a directory layout conforming to the official plugin spec.

**Key constraint discovered 2026-04-04**: After reviewing the [official plugin docs](https://code.claude.com/docs/en/plugins), only certain directories are auto-discovered by the plugin manager (`commands/`, `agents/`, `skills/`, `hooks/`, `bin/`, `output-styles/`). Non-standard directories (`rules/`, `templates/`, `processes/`, `scripts/`) must exist as supporting files referenced by agents and skills, not as first-class plugin components. Additionally, `agents/` must be flat (no subdirectories) with proper YAML frontmatter.

### Goals

1. **Phase 1 — Plugin Packaging**: Create the `horse/` plugin module conforming to the official Claude Code plugin spec, with all content properly structured for auto-discovery
2. **Phase 2 — Process Orchestration**: Add configurable process definitions and orchestrator agents to enable structured, gate-enforced SDLC workflows
3. **Phase 3 — Containerized Subagent Execution**: Enable the orchestrator to spawn sandboxed `claude` CLI subagents (via `-p`, `--output-format json`) inside Docker containers for one-shot task execution

### Non-Goals (Out of Scope)

- Marketplace publishing (Git clone / `--plugin-dir` distribution only)
- Languages beyond Python and TypeScript
- Enterprise features (org policies, audit trails, private registry)
- Cross-session state persistence
- Long-running daemon-style subagents (subagents are one-shot only)

### Success Metrics

| Metric | Baseline | Target | Timeline |
|---|---|---|---|
| Plugin loads via `claude --plugin-dir ./horse` | Not a plugin | All commands, skills, agents load correctly | End of Phase 1 |
| Slash commands work as `/horse:*` | Commands at `/horse-sense:*` (root) | All 9 commands namespaced under `horse` | End of Phase 1 |
| Agents have proper frontmatter and appear in `/agents` | Flat markdown, no frontmatter | All agents discoverable with name, description, model | End of Phase 1 |
| Skills adapt to Python and TypeScript projects | Python only | Both via `.claude/config.json` | End of Phase 1 |
| Orchestrator executes feature-delivery process | No orchestration | Full SDLC flow with gates and human checkpoints | End of Phase 2 |
| Orchestrator dispatches containerized subagents | Manual agent invocation only | One-shot tasks run in Docker sandbox, results collected as JSON | End of Phase 3 |

---

## 2. Stakeholders

| Role | Name | Responsibilities |
|---|---|---|
| Owner / Developer | Ed Wentworth | Everything — planning, architecture, implementation, testing |

---

## 3. Timeline & Milestones

| Milestone | Description | Target Date | Status |
|---|---|---|---|
| M0: Planning complete | Requirements, architecture, ADRs, project plan | 2026-04-03 | ✅ Done |
| M0.5: Spec review | Review official plugin docs, resolve open questions, update plans | 2026-04-04 | 🔵 In Progress |
| M1: Plugin structure | `horse/` module with `.claude-plugin/plugin.json`, `commands/`, flat `agents/` with frontmatter | Sprint 1 | ⬜ |
| M2: Skills & agents migrated | SKILL.md format, config.json support, rules folded into agent prompts | Sprint 2 | ⬜ |
| M3: Dual toolchain + CI | TypeScript support, GitHub Actions template, documentation | Sprint 3 | ⬜ |
| M4: Phase 1 complete — usable plugin | End-to-end `claude --plugin-dir ./horse` → use in a real project | Sprint 3 | ⬜ |
| M5: Process definitions & orchestrators | Process docs, orchestrator agents, monitor agent | Sprint 4 | ⬜ |
| M6: Phase 2 complete — orchestrated SDLC | Feature-delivery workflow running end-to-end | Sprint 5 | ⬜ |
| M7: Subagent dispatch infrastructure | `bin/claude-sandbox` runner, Dockerfile, dispatch skill working | Sprint 6 | ⬜ |
| M8: Phase 3 complete — containerized subagents | Orchestrator can dispatch one-shot Claude tasks in Docker, collect JSON results | Sprint 7 | ⬜ |

---

## 4. Epics & Stories

### Phase 1: Plugin Packaging

#### Epic 1: Plugin Structure & Installation (Sprint 1)
> Create the `horse/` plugin module conforming to the official Claude Code plugin spec, installable via `claude --plugin-dir ./horse`.

**Note (2026-04-04)**: Sprint 1 was originally scoped to restructure at the repo root as `horse-sense`. After reviewing the official plugin docs, the scope has been revised: the plugin is now a module named `horse` in a `horse/` subdirectory, agents must be flat with frontmatter, and `rules/`/`templates/` are supporting files (not auto-discovered). Tasks T-001 through T-007 were completed under the old structure and need rework.

| Story ID | Title | Priority | Points | Sprint | Status |
|---|---|---|---|---|---|
| T-001 | ~~Create `.claude-plugin/plugin.json` manifest~~ | Must | 1 | 1 | ✅ Done (needs rework → T-009) |
| T-002 | ~~Move `.claude/commands/*.md` → `commands/*.md` at plugin root~~ | Must | 2 | 1 | ✅ Done (needs rework → T-009) |
| T-003 | ~~Update command content: replace `/user:` refs with `/horse-sense:`~~ | Must | 2 | 1 | ✅ Done (needs rework → T-009) |
| T-004 | ~~Rename `skills/*/README.md` → `skills/*/SKILL.md` with frontmatter~~ | Must | 3 | 1 | ✅ Done (needs rework → T-009) |
| T-005 | ~~Restructure `agents/` into `agents/workers/`~~ | Must | 1 | 1 | ✅ Done (needs rework → T-009) |
| T-006 | ~~Create `bin/` directory (placeholder)~~ | Could | 1 | 1 | ✅ Done (needs rework → T-009) |
| T-007 | ~~Remove `.claude/settings.json` (replaced by plugin.json)~~ | Must | 1 | 1 | ✅ Done |
| T-008 | Verify plugin loads: `claude --plugin-dir ./horse` smoke test | Must | 2 | 1 | ⬜ To Do |
| T-009 | Create `horse/` plugin module — move all plugin files into `horse/` subdir, rename to `horse`, flatten agents with frontmatter, update all `/horse-sense:` → `/horse:` refs | Must | 5 | 1 | ⬜ To Do |
| T-009a | Add YAML frontmatter to all 5 agent files (name, description, model, maxTurns) | Must | 3 | 1 | ⬜ To Do |
| T-009b | Update commands to reference `${CLAUDE_PLUGIN_ROOT}/` paths for rules, templates, scripts | Must | 2 | 1 | ⬜ To Do |
| T-009c | Update CLAUDE.md and README.md for new `horse/` structure | Must | 1 | 1 | ⬜ To Do |
| | **Sprint 1 Total (revised)** | | **13** | | |

#### Epic 2: Skills, Agents & Configuration (Sprint 2)
> Make skills config-aware, add project configuration model, fold rules content into agent prompts and skill references.

| Story ID | Title | Priority | Points | Sprint | Status |
|---|---|---|---|---|---|
| T-010 | Define `.claude/config.json` schema with defaults and auto-detection | Must | 3 | 2 | ⬜ |
| T-011 | Update all 6 skills to read config variables (language, testRunner, srcDir, etc.) | Must | 5 | 2 | ⬜ |
| T-012 | Update agent system prompts to incorporate rules content and reference `${CLAUDE_PLUGIN_ROOT}/rules/` | Must | 3 | 2 | ⬜ |
| T-013 | ~~Add glob frontmatter to all 4 rule files~~ → Fold key rules into agent prompts (rules/ not auto-discovered) | Must | 3 | 2 | ⬜ |
| T-014 | Update CLAUDE.md for plugin context (new structure, new commands, config) | Must | 2 | 2 | ⬜ |
| | **Sprint 2 Total** | | **16** | | |

#### Epic 3: Dual Toolchain, CI & Documentation (Sprint 3)
> Add TypeScript support, GitHub Actions template, update all documentation for v1.0 release.

| Story ID | Title | Priority | Points | Sprint | Status |
|---|---|---|---|---|---|
| T-020 | Create `skills/typescript-setup/SKILL.md` (npm, vitest, eslint, tsc) | Must | 5 | 3 | ⬜ |
| T-021 | Create `rules/typescript_quality.md` with glob `**/*.ts,**/*.tsx` | Must | 3 | 3 | ⬜ |
| T-022 | Update scripts (setup_env, run_tests, lint) to detect and support TypeScript | Must | 5 | 3 | ⬜ |
| T-023 | Create `templates/ci.yml` GitHub Actions workflow (Python + TS matrix) | Should | 3 | 3 | ⬜ |
| T-024 | Update README.md for plugin installation, configuration, and usage | Must | 2 | 3 | ⬜ |
| T-025 | Update `scripts/new_project.sh` to support TypeScript scaffolding | Should | 3 | 3 | ⬜ |
| T-026 | End-to-end validation: install plugin into a fresh Python project, run full SDLC manually | Must | 3 | 3 | ⬜ |
| T-027 | End-to-end validation: install plugin into a fresh TypeScript project | Must | 3 | 3 | ⬜ |
| | **Sprint 3 Total** | | **27** | | |

**Phase 1 Total: 55 story points across 3 sprints**

---

### Phase 2: Process Orchestration

#### Epic 4: Process Definitions (Sprint 4)
> Create the process definition format and initial workflow documents that orchestrators will execute.

| Story ID | Title | Priority | Points | Sprint | Status |
|---|---|---|---|---|---|
| T-030 | Define process document format (frontmatter, steps, gates, flow control) | Must | 5 | 4 | ⬜ |
| T-031 | Create `processes/feature_delivery.md` (full SDLC lifecycle) | Must | 5 | 4 | ⬜ |
| T-032 | Create `processes/sprint_execution.md` (story-level iteration) | Must | 3 | 4 | ⬜ |
| T-033 | Create `processes/bug_fix.md` (triage → fix → verify) | Should | 3 | 4 | ⬜ |
| T-034 | Create `processes/code_review.md` (review → feedback → resolve) | Should | 2 | 4 | ⬜ |
| | **Sprint 4 Total** | | **18** | | |

#### Epic 5: Orchestrator & Monitor Agents (Sprint 5)
> Create orchestrator agents that read process definitions and direct worker agents, plus monitor agents for loop quality.

| Story ID | Title | Priority | Points | Sprint | Status |
|---|---|---|---|---|---|
| T-040 | Create `agents/sdlc.md` — SDLC orchestrator agent (flat, with frontmatter) | Must | 8 | 5 | ⬜ |
| T-041 | Create `agents/sprint-orchestrator.md` — Sprint orchestrator agent | Must | 5 | 5 | ⬜ |
| T-042 | Create `agents/monitor.md` — Loop quality monitor agent | Should | 5 | 5 | ⬜ |
| T-043 | Update `/horse:sdlc-start` command to invoke SDLC orchestrator | Must | 3 | 5 | ⬜ |
| T-044 | Update `/horse:sprint` command to invoke Sprint orchestrator | Must | 2 | 5 | ⬜ |
| T-045 | End-to-end validation: run feature-delivery process on a test project | Must | 5 | 5 | ⬜ |
| | **Sprint 5 Total** | | **28** | | |

**Phase 2 Total: 46 story points across 2 sprints**

---

### Phase 3: Containerized Subagent Execution

#### Epic 6: Subagent Dispatch Infrastructure (Sprint 6)
> Build the scaffolding for spawning `claude` CLI instances in Docker containers as one-shot subagents. The orchestrator invokes `claude -p "<prompt>" --output-format json` inside a sandboxed container and collects structured results.

**Rationale**: The orchestrator/subagent model is explicitly part of Claude Code's design. The `claude` CLI supports non-interactive use (`-p`, `--output-format json`, `--input-file`), and Anthropic's multi-agent patterns describe orchestrators spawning subagents. The SKILL.md layer encodes _when_ and _how_ to dispatch as reusable instruction.

| Story ID | Title | Priority | Points | Sprint | Status |
|---|---|---|---|---|---|
| T-050 | Create `Dockerfile.claude-sandbox` — minimal image with `claude` CLI, Node.js, Python, git | Must | 5 | 6 | ⬜ |
| T-051 | Create `bin/claude-sandbox` — shell wrapper that runs `docker run` with volume mounts, env passthrough, and timeout | Must | 5 | 6 | ⬜ |
| T-052 | Create `skills/subagent-dispatch/SKILL.md` — when and how to spawn a containerized subagent (prompt construction, JSON parsing, error handling) | Must | 3 | 6 | ⬜ |
| T-053 | Define subagent invocation contract: input (prompt + context files), output (JSON with `result`, `exit_code`, `stderr`), timeout, resource limits | Must | 3 | 6 | ⬜ |
| T-054 | Create `templates/subagent_prompt.md` — template for constructing well-formed one-shot prompts with task description, constraints, and output format | Should | 2 | 6 | ⬜ |
| T-055 | Smoke test: orchestrator dispatches a trivial task ("list files in /src") to containerized subagent, parses JSON result | Must | 3 | 6 | ⬜ |
| | **Sprint 6 Total** | | **21** | | |

#### Epic 7: Orchestrator Integration & Patterns (Sprint 7)
> Wire subagent dispatch into the orchestrator agents from Phase 2. Define reusable patterns for common one-shot tasks (code generation, test execution, linting, security scanning).

| Story ID | Title | Priority | Points | Sprint | Status |
|---|---|---|---|---|---|
| T-060 | Update `agents/sdlc.md` orchestrator to dispatch implementation subtasks as containerized subagents | Must | 5 | 7 | ⬜ |
| T-061 | Create fan-out pattern: orchestrator dispatches N parallel subagents (e.g., lint + test + security scan), aggregates results | Must | 5 | 7 | ⬜ |
| T-062 | Create `skills/subagent-patterns/SKILL.md` — catalog of one-shot task patterns (code-gen, test-run, lint, review, file-transform) with prompt templates | Should | 3 | 7 | ⬜ |
| T-063 | Add subagent result validation — orchestrator checks exit code, parses JSON, retries on transient failure (max 1 retry) | Must | 3 | 7 | ⬜ |
| T-064 | Security: ensure containers run as non-root, no network by default (`--network none`), read-only root FS, tmpfs for `/tmp` | Must | 3 | 7 | ⬜ |
| T-065 | End-to-end validation: run feature-delivery process with at least 2 steps delegated to containerized subagents | Must | 5 | 7 | ⬜ |
| | **Sprint 7 Total** | | **24** | | |

**Phase 3 Total: 45 story points across 2 sprints**

---

### Backlog (Future)

| Story ID | Title | Priority | Points | Notes |
|---|---|---|---|---|
| T-100 | Process parameterization (configurable loop limits, gate overrides) | Could | 5 | Depends on Phase 2 learnings |
| T-101 | `bin/hs` CLI helper for common operations | Could | 3 | Defer unless needed |
| T-102 | Plugin marketplace publishing | Won't | 5 | Out of scope for v1 |
| T-103 | Additional language support (Go, Rust, Java) | Won't | 8 | Future version |
| T-104 | Warm container pool — pre-built images cached for faster subagent startup | Could | 5 | Depends on Phase 3 perf findings |
| T-105 | Subagent cost/usage tracking — log token usage per dispatch for budgeting | Could | 3 | Depends on Claude CLI output |
| T-106 | `--input-file` support — pass large context via mounted file instead of prompt string | Could | 3 | Depends on T-053 contract |

---

## 5. Technical Approach

Details in [docs/architecture/architecture_doc.md](../architecture/architecture_doc.md) and ADRs:

- **Format**: Static plugin — Markdown + shell scripts, no build step, no runtime deps
- **Plugin spec**: `.claude-plugin/plugin.json` manifest ([ADR-0001](../adr/0001-adopt-official-plugin-format.md))
- **Configuration**: Two-tier — plugin.json + `.claude/config.json` ([ADR-0002](../adr/0002-two-tier-configuration.md))
- **Toolchains**: Python (venv/pytest/ruff) + TypeScript (npm/vitest/eslint) ([ADR-0003](../adr/0003-dual-toolchain-support.md))
- **Orchestration**: Process definitions + orchestrator/worker/monitor agents ([ADR-0004](../adr/0004-process-orchestration-model.md))
- **Subagent Execution**: Containerized one-shot `claude -p` invocations in Docker for sandboxed task delegation ([ADR-0005](../adr/0005-containerized-subagent-execution.md)). Orchestrator constructs prompt, mounts workspace, collects JSON result. Degrades to local CLI when Docker unavailable.
- **CI/CD**: GitHub Actions workflow template shipped with the plugin

### Migration Map (Phase 1)

```
CURRENT (repo root)              → TARGET (horse/ subdir)
.claude-plugin/plugin.json       → horse/.claude-plugin/plugin.json (name: "horse")
commands/*.md                    → horse/commands/*.md (refs: /horse:*)
skills/*/SKILL.md                → horse/skills/*/SKILL.md
agents/workers/*.md              → horse/agents/*.md (FLAT + YAML frontmatter)
rules/*.md                       → horse/rules/*.md (supporting files, NOT auto-discovered)
templates/*.md                   → horse/templates/*.md (supporting files, NOT auto-discovered)
scripts/*.sh                     → horse/scripts/*.sh (supporting files)
bin/                             → horse/bin/ (auto-discovered, added to PATH)
(none)                           → horse/agents/sdlc.md, etc. (Phase 2, flat in agents/)
(none)                           → horse/processes/*.md (Phase 2, supporting files)
(none)                           → .claude/config.json (per-project, in host project)
```

---

## 6. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| ~~Plugin spec doesn't load `rules/` and `templates/` dirs~~ | ~~Med~~ | ~~High~~ | ✅ **Confirmed 2026-04-04** — they are NOT auto-loaded. Mitigation: reference via `${CLAUDE_PLUGIN_ROOT}/` paths in agent prompts and skills. |
| ~~SKILL.md frontmatter fields are limited~~ | ~~Med~~ | ~~Med~~ | ✅ **Resolved** — skills support `name`, `description`, `disable-model-invocation`. Agents support full frontmatter. |
| ~~Glob frontmatter in rules not recognized by plugin manager~~ | ~~Med~~ | ~~Med~~ | ✅ **Confirmed** — `rules/` is not a plugin component. Rules content must be folded into agent system prompts or referenced by skills. |
| Orchestrator "dispatch worker" pattern not supported natively | Med | High | Plugin agents appear in `/agents` and can be invoked as subagents. Test in Sprint 5 (T-045). |
| Long processes exceed context limits | Low | High | Keep process steps small. Orchestrators summarize between steps. |
| TypeScript scripts more complex than expected | Low | Med | Start with detection + thin wrappers. Enhance iteratively. |
| Agent frontmatter schema changes in future Claude Code updates | Low | Med | Pin to known-working fields. Monitor release notes. |
| Docker not available in all environments (CI, Codespaces, restricted hosts) | Med | High | `bin/claude-sandbox` should degrade gracefully to local `claude -p` when Docker unavailable. Document requirement. |
| Subagent API key / auth passthrough into container | Med | Med | Pass `ANTHROPIC_API_KEY` via `--env` flag. Never bake into image. Document in T-053 contract. |
| Container cold-start latency makes subagent dispatch slow | Med | Med | Start with pre-pulled images. Backlog T-104 (warm pool) if latency > 10s. |
| Subagent prompt size exceeds CLI limits | Low | Med | Use `--input-file` with mounted volume (backlog T-106). Define max prompt size in T-053 contract. |

---

## 7. Dependencies

| Dependency | Type | Owner | Status |
|---|---|---|---|
| Claude Code plugin spec (`.claude-plugin/plugin.json`) | External | Anthropic | ✅ Available — documented at code.claude.com |
| Claude Code `--plugin-dir` flag | External | Anthropic | ✅ Available |
| Claude Code Agent tool (for orchestrator dispatch) | External | Anthropic | ⬜ Needs testing |
| Python >= 3.11 | External | User | ✅ Available |
| Node.js >= 20 | External | User | ✅ Available |
| Docker Engine (for Phase 3 containerized subagents) | External | User | ⬜ Required for Phase 3 |
| Claude CLI non-interactive mode (`-p`, `--output-format json`) | External | Anthropic | ⬜ Needs testing |

---

## 8. Definition of Done

A story is **Done** when:

- [ ] Changes made and consistent with official plugin spec
- [ ] All affected skills, agents, and commands are internally consistent (no broken references)
- [ ] Plugin loads without errors via `claude --plugin-dir ./horse`
- [ ] Slash commands resolve as `/horse:*`
- [ ] Agents appear in `/agents` with correct name and description
- [ ] Config variables are read correctly (tested with both Python and TypeScript configs)
- [ ] CLAUDE.md and README.md are updated if structure changed
- [ ] Changes committed with Conventional Commits format

---

## 9. Requirement Traceability

Maps implementation tasks to requirement user stories:

| Task | Requirement Stories Addressed |
|---|---|
| **Sprint 1 (Structure)** | |
| T-001 through T-008 | US-001 (install plugin) |
| **Sprint 2 (Skills & Config)** | |
| T-010 | US-002 (configure for project), US-013 (config variables) |
| T-011 | US-010 (skill as guide), US-013 (config variables) |
| T-012 | US-020 (worker personas), US-021 (agents compose skills) |
| T-013 | US-030 (glob-matched rules), US-031 (rules customize skills) |
| **Sprint 3 (Toolchain & Docs)** | |
| T-020, T-021 | US-051 (TypeScript toolchain) |
| T-022 | US-050 (Python toolchain), US-051 (TypeScript toolchain) |
| T-023 | US-060 (GitHub Actions) |
| T-026, T-027 | US-001, US-002, US-011 (end-to-end validation) |
| **Sprint 4 (Processes)** | |
| T-030 | US-025 (process definitions), US-026 (flow control), US-027 (gates) |
| T-031 through T-034 | US-025, US-040 (SDLC flow) |
| **Sprint 5 (Orchestration)** | |
| T-040 through T-042 | US-023 (orchestrator), US-024 (monitor), US-028 (human-in-loop) |
| T-043, T-044 | US-040 (SDLC flow), US-041 (quality gates) |
| T-045 | US-029 (process tracking), US-040, US-041 |
| **Sprint 6 (Subagent Infra)** | |
| T-050, T-051 | Containerized sandbox environment and CLI wrapper |
| T-052, T-053 | Subagent dispatch skill and invocation contract |
| T-054, T-055 | Prompt template and smoke test |
| **Sprint 7 (Orchestrator Integration)** | |
| T-060 | US-023 (orchestrator dispatches subagents) |
| T-061 | Fan-out parallel dispatch pattern |
| T-062, T-063 | Subagent patterns catalog and result validation |
| T-064 | Security hardening for containers |
| T-065 | End-to-end validation with subagent delegation |

---

## 10. Change Log

| Date | Author | Change Description |
|---|---|---|
| 2026-04-03 | Ed Wentworth | Initial draft — Phase 1 + Phase 2 plan based on requirements v1.0, architecture v1.0, ADR-0001 through ADR-0004 |
| 2026-04-04 | Ed Wentworth | v1.1 — Reviewed official plugin docs. Plugin renamed to `horse` in `horse/` subdir. `rules/`/`templates/` confirmed not auto-discovered. Agents must be flat with YAML frontmatter. Sprint 1 stories revised (T-009 series added). Open questions 1-3, 5, 8 resolved. Risks updated. |
| 2026-04-04 | Ed Wentworth | v1.2 — Added Phase 3: Containerized Subagent Execution. Removed "Dynamic agent spawning" from Non-Goals. Added Epic 6 (Sprint 6: subagent infra) and Epic 7 (Sprint 7: orchestrator integration). New milestones M7, M8. Docker and Claude CLI non-interactive mode added as dependencies. |
