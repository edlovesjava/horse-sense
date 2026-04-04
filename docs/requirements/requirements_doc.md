# Requirements Document: horse-sense — Claude Code SDLC Plugin

> **Document version**: 2.0  
> **Created**: 2026-04-03  
> **Last updated**: 2026-04-04  
> **Owner**: Ed Wentworth  
> **Status**: Draft

---

## 1. Background & Motivation

Claude Code is a powerful autonomous coding assistant, but without structured guidance it produces inconsistent results — skipping tests, ignoring project conventions, generating code that doesn't fit the existing architecture, or losing context across long sessions.

**horse-sense** solves this by packaging an opinionated SDLC methodology as a Claude Code plugin. Once installed, it gives Claude:

- **Skills** that define *how* to do things (write tests, design architecture, implement features) with step-by-step guidance that adapts to the project's language and toolchain
- **Agents** that define *who* is doing the work — persistent role personas (planner, architect, developer, tester, reviewer) that compose skills from a focused perspective
- **Rules** that define *what standards apply* — glob-matched context injected when editing specific file types or directories, ensuring language-specific conventions are followed
- **Configuration** that defines *what this project looks like* — project variables (language, framework, test runner, paths) that skills read to tailor their guidance

The goal: install the plugin, configure it for a project, and use it to develop significant, high-quality, deployable, testable software — not just snippets, but real systems.

---

## 2. Stakeholders & User Roles

| Role | Description | Key Goals |
|---|---|---|
| **Solo Developer** | Individual using Claude Code for personal or professional projects | Produce high-quality code faster with consistent process; avoid rework from skipped steps |
| **Small Team Lead** | Developer leading a 2-5 person team using Claude Code | Enforce consistent standards across the team; ensure AI-assisted code meets review bar |
| **Plugin Author** | Developer extending horse-sense with new skills, rules, or agents | Add capabilities without understanding the full system; clear extension points |

---

## 3. Functional Requirements

Individual user stories live in [`stories/`](stories/). Each file is named `US-NNN-description-STATUS.md`.

### 3.1 Plugin Installation & Configuration

| Story | Title | Priority | SP | Status |
|---|---|---|---|---|
| [US-001](stories/US-001-install-plugin-draft.md) | Install plugin | Must Have | 3 | Draft |
| [US-002](stories/US-002-configure-for-a-project-draft.md) | Configure for a project | Must Have | 5 | Draft |
| [US-003](stories/US-003-project-scaffolding-draft.md) | Project scaffolding | Must Have | 5 | Draft |

### 3.2 Skills — Primary Behavior Definition

| Story | Title | Priority | SP | Status |
|---|---|---|---|---|
| [US-010](stories/US-010-skill-as-step-by-step-guide-draft.md) | Skill as step-by-step guide | Must Have | 3 | Draft |
| [US-011](stories/US-011-slash-command-skills-draft.md) | Slash-command skills (user-invoked) | Must Have | 3 | Draft |
| [US-012](stories/US-012-model-invoked-skills-draft.md) | Model-invoked skills (automatic) | Should Have | 3 | Draft |
| [US-013](stories/US-013-skills-read-project-config-variables-draft.md) | Skills read project config variables | Must Have | 5 | Draft |

### 3.3 Agents — Workers and Orchestrators

| Story | Title | Priority | SP | Status |
|---|---|---|---|---|
| [US-020](stories/US-020-worker-agent-personas-draft.md) | Worker agent personas | Must Have | 5 | Draft |
| [US-021](stories/US-021-worker-agents-compose-skills-draft.md) | Worker agents compose skills | Must Have | 3 | Draft |
| [US-022](stories/US-022-agents-as-independent-long-lived-sessions-draft.md) | Agents as independent long-lived sessions | Should Have | 3 | Draft |
| [US-023](stories/US-023-orchestrator-agents-direct-worker-agents-draft.md) | Orchestrator agents direct worker agents | Must Have | 8 | Draft |
| [US-024](stories/US-024-monitor-agents-observe-and-refine-draft.md) | Monitor agents observe and refine | Should Have | 5 | Draft |

### 3.4 Trail Definitions — Workflow Specification

| Story | Title | Priority | SP | Status |
|---|---|---|---|---|
| [US-025](stories/US-025-process-definition-documents-draft.md) | Trail definition documents | Must Have | 8 | Draft |
| [US-026](stories/US-026-process-flow-control-draft.md) | Process flow control | Must Have | 8 | Draft |
| [US-027](stories/US-027-entry-gates-and-completion-criteria-draft.md) | Entry gates and completion criteria | Must Have | 5 | Draft |
| [US-028](stories/US-028-human-in-the-loop-decision-points-draft.md) | Human-in-the-loop decision points | Must Have | 5 | Draft |
| [US-029](stories/US-029-process-execution-tracking-draft.md) | Process execution tracking | Should Have | 3 | Draft |

### 3.5 Rules — Contextual Standards

| Story | Title | Priority | SP | Status |
|---|---|---|---|---|
| [US-030](stories/US-030-glob-matched-rules-draft.md) | Glob-matched rules | Must Have | 3 | Draft |
| [US-031](stories/US-031-rules-customize-skill-behavior-draft.md) | Rules customize skill behavior | Must Have | 3 | Draft |
| [US-032](stories/US-032-user-customizable-rules-draft.md) | User-customizable rules | Should Have | 2 | Draft |

### 3.6 SDLC Workflow (Orchestrated)

| Story | Title | Priority | SP | Status |
|---|---|---|---|---|
| [US-040](stories/US-040-end-to-end-sdlc-flow-draft.md) | End-to-end SDLC flow via process orchestration | Must Have | 8 | Draft |
| [US-041](stories/US-041-quality-gates-enforced-by-orchestrator-draft.md) | Quality gates enforced by orchestrator | Must Have | 3 | Draft |

### 3.7 Dual Toolchain Support

| Story | Title | Priority | SP | Status |
|---|---|---|---|---|
| [US-050](stories/US-050-python-toolchain-draft.md) | Python toolchain | Must Have | 3 | Draft |
| [US-051](stories/US-051-typescript-toolchain-draft.md) | TypeScript toolchain | Must Have | 5 | Draft |

### 3.8 CI/CD Integration (User Projects)

| Story | Title | Priority | SP | Status |
|---|---|---|---|---|
| [US-060](stories/US-060-github-actions-workflow-draft.md) | GitHub Actions workflow | Should Have | 5 | Draft |

### 3.9 Plugin Toolchain & CI/CD

| Story | Title | Priority | SP | Status |
|---|---|---|---|---|
| [US-070](stories/US-070-plugin-structure-validation-draft.md) | Plugin structure validation | Must Have | 5 | Draft |
| [US-071](stories/US-071-markdown-linting-draft.md) | Markdown linting | Must Have | 3 | Draft |
| [US-072](stories/US-072-shell-script-linting-draft.md) | Shell script linting | Must Have | 2 | Draft |
| [US-073](stories/US-073-json-schema-validation-draft.md) | JSON schema validation | Should Have | 2 | Draft |
| [US-074](stories/US-074-frontmatter-schema-validation-draft.md) | Frontmatter schema validation | Must Have | 3 | Draft |
| [US-075](stories/US-075-documentation-generation-draft.md) | Documentation generation | Should Have | 3 | Draft |
| [US-076](stories/US-076-distribution-via-git-releases-draft.md) | Distribution via Git releases | Should Have | 3 | Draft |
| [US-077](stories/US-077-cicd-pipeline-via-github-actions-draft.md) | CI/CD pipeline via GitHub Actions | Must Have | 5 | Draft |
| [US-078](stories/US-078-local-developer-workflow-draft.md) | Local developer workflow | Must Have | 3 | Draft |

### 3.10 PR Review & Fix Skills

| Story | Title | Priority | SP | Status |
|---|---|---|---|---|
| [US-080](stories/US-080-pr-review-skill-draft.md) | PR review skill | Must Have | 8 | Draft |
| [US-081](stories/US-081-pr-fix-skill-draft.md) | PR fix skill | Must Have | 8 | Draft |

### Summary

| Priority | Count | Total SP |
|---|---|---|
| Must Have | 27 | 136 |
| Should Have | 9 | 29 |
| **Total** | **36** | **165** |

---

## 4. Non-Functional Requirements

### 4.1 Performance

| Requirement | Target |
|---|---|
| Plugin load time | Negligible — static Markdown files, no compilation |
| Skill execution overhead | Zero — skills are context/instructions, not running code |
| Script execution | < 30 seconds for lint, < 5 minutes for full test suite |

### 4.2 Compatibility

| Requirement | Target |
|---|---|
| Claude Code version | Compatible with plugin spec (`.claude-plugin/plugin.json`) |
| Python support | Python >= 3.11 |
| Node.js support | Node.js >= 20 |
| Operating systems | Linux, macOS, WSL (Bash-compatible shell) |
| Git | Required — all workflows assume Git version control |

### 4.3 Maintainability

| Requirement | Target |
|---|---|
| Plugin self-documentation | Every skill, agent, and rule has a clear description |
| Extension pattern | New skills added by creating a directory with SKILL.md — no core changes needed |
| Rule customization | Users can add/modify/delete rules without affecting other components |
| Config backward compatibility | New config fields always have defaults; missing fields never break skills |

### 4.4 Usability

| Requirement | Target |
|---|---|
| Time to first use | < 5 minutes from install to first skill invocation |
| Discoverability | `/horse:guide` walks users through the SDLC trail |
| Error messages | Skills explain what's wrong and what to do next (e.g., missing config, failed prerequisites) |
| Learning curve | Developer familiar with Claude Code productive within one session |

---

## 5. Constraints & Assumptions

### Constraints

- Must conform to the official Claude Code plugin specification
- No runtime dependencies beyond Claude Code, Bash, Git, and standard CLI tools
- Plugin is static content (Markdown + scripts) — no compilation, no server, no database
- Skills must work offline (no external API calls from the plugin itself)

### Assumptions

- Users have Claude Code installed and are familiar with basic usage
- Users have either Python >= 3.11 or Node.js >= 20 (or both) installed
- Projects use Git for version control
- Projects use GitHub for hosting (GitHub Actions for CI, PRs for review)
- The Claude Code plugin spec supports glob-matched rule files and non-standard directories (rules/, templates/)

---

## 6. Out of Scope

The following are **explicitly excluded** from this version:

- **Marketplace publishing** — personal/small-team distribution only (Git clone or `--plugin-dir`)
- **IDE-specific integrations** — plugin works through Claude Code CLI; no VS Code extension
- **Languages beyond Python and TypeScript** — additional language support deferred to future versions
- **Custom LLM providers** — plugin assumes Claude Code (Anthropic models) only
- **Cross-session state persistence** — orchestrator tracks state within a session; no database or file-based state across conversations
- **Automated deployment execution** — plugin prepares deployment artifacts but does not deploy
- **Enterprise features** — org-wide policies, audit trails, private registry, compliance hooks
- **Dynamic agent spawning** — orchestrators direct agents within the Claude Code agent framework; they do not spawn OS-level processes

---

## 7. Open Questions

| # | Question | Owner | Due Date | Resolution |
|---|---|---|---|---|
| 1 | Does the plugin manager load non-standard directories (rules/, templates/) into context? | Ed | 2026-04-10 | ⬜ Open |
| 2 | What SKILL.md frontmatter fields are supported beyond `name` and `description`? | Ed | 2026-04-10 | ⬜ Open |
| 3 | Can hooks/ auto-inject rules based on file globs, or must rules use a different mechanism? | Ed | 2026-04-10 | ⬜ Open |
| 4 | How do agents persist across long sessions — does Claude Code handle this or must the plugin? | Ed | 2026-04-10 | ⬜ Open |
| 5 | Should config.json support inheritance (base config + environment overrides)? | Ed | 2026-04-17 | ⬜ Open |
| 6 | How do orchestrator agents "dispatch" worker agents — via Claude Code's Agent tool, subagent spawning, or context switching within a single session? | Ed | 2026-04-10 | ⬜ Open |
| 7 | What is the best format for trail definitions — Markdown with conventions (as proposed), YAML, or a DSL? | Ed | 2026-04-10 | ⬜ Open |
| 8 | Can monitor agents run concurrently with worker agents, or must they observe after each iteration? | Ed | 2026-04-10 | ⬜ Open |
| 9 | How should process execution state (current step, iteration count, decisions) be tracked within a session? | Ed | 2026-04-10 | ⬜ Open |
| 10 | Should trail definitions support parameterization (e.g., same trail for different feature sizes with different loop limits)? | Ed | 2026-04-17 | ⬜ Open |
| 11 | Which JSON schema validator to use — ajv-cli (Node.js) or check-jsonschema (Python)? Depends on which runtime we want as a dev dependency. | Ed | 2026-04-10 | ⬜ Open |
| 12 | Should the validation script be Python or Bash? Python is easier for YAML parsing; Bash avoids a runtime dependency. | Ed | 2026-04-10 | ⬜ Open |
| 13 | Should we publish to a plugin registry if/when Claude Code adds one, or stay Git-only? | Ed | 2026-04-17 | ⬜ Open |

---

## 8. Approval

| Stakeholder | Role | Date | Signature |
|---|---|---|---|
| Ed Wentworth | Owner / Developer | 2026-04-03 | ⬜ Pending |
