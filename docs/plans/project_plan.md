# Project Plan: horse-sense v1.0

> **Document version**: 1.1  
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

### Non-Goals (Out of Scope)

- Marketplace publishing (Git clone / `--plugin-dir` distribution only)
- Languages beyond Python and TypeScript
- Enterprise features (org policies, audit trails, private registry)
- Dynamic agent spawning (OS-level processes)
- Cross-session state persistence

### Success Metrics

| Metric | Baseline | Target | Timeline |
|---|---|---|---|
| Plugin loads via `claude --plugin-dir ./horse` | Not a plugin | All commands, skills, agents load correctly | End of Phase 1 |
| Slash commands work as `/horse:*` | Commands at `/horse-sense:*` (root) | All 9 commands namespaced under `horse` | End of Phase 1 |
| Agents have proper frontmatter and appear in `/agents` | Flat markdown, no frontmatter | All agents discoverable with name, description, model | End of Phase 1 |
| Skills adapt to Python and TypeScript projects | Python only | Both via `.claude/config.json` | End of Phase 1 |
| Orchestrator executes feature-delivery process | No orchestration | Full SDLC flow with gates and human checkpoints | End of Phase 2 |

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

### Backlog (Future)

| Story ID | Title | Priority | Points | Notes |
|---|---|---|---|---|
| T-100 | Process parameterization (configurable loop limits, gate overrides) | Could | 5 | Depends on Phase 2 learnings |
| T-101 | `bin/hs` CLI helper for common operations | Could | 3 | Defer unless needed |
| T-102 | Plugin marketplace publishing | Won't | 5 | Out of scope for v1 |
| T-103 | Additional language support (Go, Rust, Java) | Won't | 8 | Future version |

---

## 5. Technical Approach

Details in [docs/architecture/architecture_doc.md](../architecture/architecture_doc.md) and ADRs:

- **Format**: Static plugin — Markdown + shell scripts, no build step, no runtime deps
- **Plugin spec**: `.claude-plugin/plugin.json` manifest ([ADR-0001](../adr/0001-adopt-official-plugin-format.md))
- **Configuration**: Two-tier — plugin.json + `.claude/config.json` ([ADR-0002](../adr/0002-two-tier-configuration.md))
- **Toolchains**: Python (venv/pytest/ruff) + TypeScript (npm/vitest/eslint) ([ADR-0003](../adr/0003-dual-toolchain-support.md))
- **Orchestration**: Process definitions + orchestrator/worker/monitor agents ([ADR-0004](../adr/0004-process-orchestration-model.md))
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

---

## 7. Dependencies

| Dependency | Type | Owner | Status |
|---|---|---|---|
| Claude Code plugin spec (`.claude-plugin/plugin.json`) | External | Anthropic | ✅ Available — documented at code.claude.com |
| Claude Code `--plugin-dir` flag | External | Anthropic | ✅ Available |
| Claude Code Agent tool (for orchestrator dispatch) | External | Anthropic | ⬜ Needs testing |
| Python >= 3.11 | External | User | ✅ Available |
| Node.js >= 20 | External | User | ✅ Available |

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

---

## 10. Change Log

| Date | Author | Change Description |
|---|---|---|
| 2026-04-03 | Ed Wentworth | Initial draft — Phase 1 + Phase 2 plan based on requirements v1.0, architecture v1.0, ADR-0001 through ADR-0004 |
| 2026-04-04 | Ed Wentworth | v1.1 — Reviewed official plugin docs. Plugin renamed to `horse` in `horse/` subdir. `rules/`/`templates/` confirmed not auto-discovered. Agents must be flat with YAML frontmatter. Sprint 1 stories revised (T-009 series added). Open questions 1-3, 5, 8 resolved. Risks updated. |
