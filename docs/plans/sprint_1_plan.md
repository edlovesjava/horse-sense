# Sprint 1 Plan: Plugin Structure & Installation

> **Sprint**: 1 (revised)  
> **Duration**: 2026-04-03 → 2026-04-10 (1 week)  
> **Team capacity**: 13 story points  
> **Sprint goal**: Create the `horse/` plugin module conforming to the official Claude Code plugin spec, with flat agents (YAML frontmatter), proper namespacing (`/horse:*`), and verified loading via `claude --plugin-dir ./horse`

---

## Sprint Goal

Create the `horse/` plugin module within the horse-sense repo, conforming to the official Claude Code plugin spec. The plugin must have flat `agents/` with YAML frontmatter, properly namespaced commands (`/horse:*`), and supporting files (rules, templates, scripts) referenced via `${CLAUDE_PLUGIN_ROOT}` paths. By the end of this sprint, `claude --plugin-dir ./horse` should load the plugin with all commands and agents discoverable.

### Mid-Sprint Course Correction (2026-04-04)

After reviewing the [official plugin docs](https://code.claude.com/docs/en/plugins), several assumptions from the original Sprint 1 scope proved incorrect:

1. **Plugin location**: Must be a subdirectory (`horse/`), not the repo root — separates plugin from project docs
2. **Plugin name**: `horse` not `horse-sense` — shorter, cleaner namespace (`/horse:*`)
3. **`agents/` must be flat** with YAML frontmatter (`name`, `description`, `model`, etc.) — not in subdirectories
4. **`rules/` and `templates/` are NOT auto-discovered** by the plugin manager — must be referenced explicitly
5. **`commands/` is legacy** but still functional — kept for user-invoked slash commands

Tasks T-001 through T-007 were completed under the old structure (plugin at root, name `horse-sense`, agents in `agents/workers/`). New tasks T-009 through T-009c address the rework.

---

## Sprint Backlog

| Story ID | Title | Priority | Points | Status |
|---|---|---|---|---|
| T-001 | ~~Create `.claude-plugin/plugin.json` manifest~~ | Must | 1 | ✅ Done (superseded by T-009) |
| T-002 | ~~Move `.claude/commands/*.md` → `commands/*.md` at plugin root~~ | Must | 2 | ✅ Done (superseded by T-009) |
| T-003 | ~~Update command content: replace `/user:` refs with `/horse-sense:`~~ | Must | 2 | ✅ Done (superseded by T-009) |
| T-004 | ~~Rename `skills/*/README.md` → `skills/*/SKILL.md` with frontmatter~~ | Must | 3 | ✅ Done (superseded by T-009) |
| T-005 | ~~Restructure `agents/` into `agents/workers/`~~ | Must | 1 | ✅ Done (superseded by T-009) |
| T-006 | ~~Create `bin/` directory (placeholder)~~ | Could | 1 | ✅ Done (superseded by T-009) |
| T-007 | Remove `.claude/settings.json` (replaced by plugin.json) | Must | 1 | ✅ Done |
| T-009 | Create `horse/` plugin module — move all plugin content into `horse/` subdir, rename plugin to `horse`, flatten agents, update all `/horse-sense:` → `/horse:` references | Must | 5 | ⬜ To Do |
| T-009a | Add YAML frontmatter to all 5 agent files (name, description, model, maxTurns) | Must | 3 | ⬜ To Do |
| T-009b | Update commands/skills to reference `${CLAUDE_PLUGIN_ROOT}/` paths for rules, templates, scripts | Must | 2 | ⬜ To Do |
| T-009c | Update CLAUDE.md and README.md for new `horse/` structure and `/horse:*` namespace | Must | 1 | ⬜ To Do |
| T-008 | Verify plugin loads via `claude --plugin-dir ./horse` smoke test | Must | 2 | ⬜ To Do |
| **Total (revised)** | | | **13** | |

### Status Key
- ⬜ To Do
- 🔵 In Progress
- 🔍 In Review
- ✅ Done
- 🚫 Blocked

---

## Task Details

### T-001 through T-007: Original Sprint 1 Tasks (Completed)

These tasks were completed under the original plan (plugin at repo root, name `horse-sense`, agents in `agents/workers/`). The work is preserved and will be migrated by T-009.

---

### T-009: Create `horse/` plugin module

Move all plugin content from the repo root into a `horse/` subdirectory, conforming to the official plugin spec.

**Directory structure to create:**

```
horse/
├── .claude-plugin/
│   └── plugin.json              # name: "horse"
├── commands/                     # /horse:* slash commands [auto-discovered]
│   ├── sdlc-start.md
│   ├── plan.md
│   ├── arch.md
│   ├── implement.md
│   ├── review.md
│   ├── test.md
│   ├── deploy.md
│   ├── sprint.md
│   └── retrospective.md
├── agents/                       # FLAT with YAML frontmatter [auto-discovered]
│   ├── planner.md
│   ├── architect.md
│   ├── developer.md
│   ├── tester.md
│   └── reviewer.md
├── skills/                       # Model-invoked skills [auto-discovered]
│   ├── requirements-analysis/SKILL.md
│   ├── architecture-design/SKILL.md
│   ├── implementation/SKILL.md
│   ├── testing/SKILL.md
│   ├── deployment/SKILL.md
│   └── python-venv/SKILL.md
├── bin/.gitkeep                  # Executables [auto-discovered]
├── rules/                        # Reference files [NOT auto-discovered]
├── templates/                    # Reference files [NOT auto-discovered]
└── scripts/                      # Reference files [NOT auto-discovered]
```

**Steps:**
1. Create `horse/` directory with all subdirectories
2. Create `horse/.claude-plugin/plugin.json` with `name: "horse"`
3. Copy `commands/*.md` → `horse/commands/*.md`, updating `/horse-sense:` → `/horse:`
4. Copy `agents/workers/*.md` → `horse/agents/*.md` (flatten)
5. Copy `skills/*/SKILL.md` → `horse/skills/*/SKILL.md`
6. Copy `rules/*.md` → `horse/rules/*.md`
7. Copy `templates/*.md` → `horse/templates/*.md`
8. Copy `scripts/*.sh` → `horse/scripts/*.sh`
9. Create `horse/bin/.gitkeep`

**Acceptance**: All plugin files in `horse/`. `grep -r '/horse-sense:' horse/` returns no results.

---

### T-009a: Add YAML frontmatter to agent files

Each agent in `horse/agents/` must have YAML frontmatter per the plugin spec:

```yaml
---
name: agent-name
description: When to invoke this agent and what it specializes in
model: sonnet
maxTurns: 20
---
```

| Agent | name | description |
|---|---|---|
| `planner.md` | `planner` | Project planning specialist — requirements gathering, roadmaps, sprint planning, backlog management, and progress tracking |
| `architect.md` | `architect` | Software architecture specialist — system design, technology selection, API design, ADRs, and non-functional requirements |
| `developer.md` | `developer` | Software development specialist — feature implementation, TDD, debugging, refactoring, and code quality |
| `tester.md` | `tester` | QA and test automation specialist — test strategy, unit/integration/e2e testing, coverage analysis, and security testing |
| `reviewer.md` | `reviewer` | Code review specialist — correctness, security, performance, and adherence to project standards |

**Acceptance**: All 5 agent files have valid YAML frontmatter. `claude --plugin-dir ./horse` shows agents in `/agents`.

---

### T-009b: Update path references for plugin context

Commands and skills currently reference `rules/code_quality.md`, `templates/architecture_doc.md`, `scripts/run_tests.sh`, etc. as bare relative paths. Since `rules/`, `templates/`, and `scripts/` are not auto-discovered, these references should be clear they're plugin-relative.

**Update pattern in commands/skills:**
- `rules/code_quality.md` → `Read the code quality rules from ${CLAUDE_PLUGIN_ROOT}/rules/code_quality.md`
- `templates/architecture_doc.md` → `Use the template at ${CLAUDE_PLUGIN_ROOT}/templates/architecture_doc.md`
- `scripts/run_tests.sh` → `Run ${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.sh`
- `agents/workers/reviewer.md` → `agents/reviewer.md` (now flat)

**Acceptance**: No references to `agents/workers/`. All references to `rules/`, `templates/`, `scripts/` are prefixed with `${CLAUDE_PLUGIN_ROOT}/` or clearly described as plugin-relative paths.

---

### T-009c: Update CLAUDE.md and README.md

Update project-level documentation to reflect:
- Plugin lives in `horse/` subdirectory
- Installation: `claude --plugin-dir ./horse`
- Commands: `/horse:*` namespace
- Agents are flat with frontmatter
- `rules/` and `templates/` are supporting files, not auto-discovered

**Acceptance**: CLAUDE.md and README.md are accurate. No references to old structure.

---

### T-008: Smoke test plugin loading

Run `claude --plugin-dir ./horse` and verify:
- [ ] Plugin is recognized (check plugin list or `/help`)
- [ ] `/horse:plan` and other commands are available
- [ ] Agents appear in `/agents` with correct names and descriptions
- [ ] Skills are listed (check via `/help` or model invocation)
- [ ] No errors in plugin loading (`claude --debug`)
- [ ] `${CLAUDE_PLUGIN_ROOT}` resolves correctly in referenced paths

Document any issues found — they inform Sprint 2 work.

**Acceptance**: Plugin loads. Commands resolve. Agents discoverable. Issues documented.

---

## Risks & Blockers

| Risk / Blocker | Impact | Action |
|---|---|---|
| ~~Plugin spec may not support `rules/` or `templates/` directories~~ | ~~High~~ | ✅ **Confirmed** — NOT supported. Mitigated by using `${CLAUDE_PLUGIN_ROOT}/` paths. |
| ~~SKILL.md frontmatter schema may have undocumented requirements~~ | ~~Med~~ | ✅ **Resolved** — documented in official spec. Skills: `name`, `description`, `disable-model-invocation`. Agents: full frontmatter including `model`, `maxTurns`, etc. |
| Agent frontmatter not recognized by older Claude Code versions | Med | Test in T-008. If agents don't appear, check Claude Code version. |
| `${CLAUDE_PLUGIN_ROOT}` may not expand in skill/command Markdown content | Med | Test in T-008. If not, fall back to relative paths with instructions for Claude to look in the plugin directory. |

---

## Definition of Done

A story is **Done** when:
- [ ] All plugin files are in `horse/` subdirectory
- [ ] No broken internal references (grep for old paths, `/horse-sense:`, `agents/workers/`)
- [ ] Plugin structure matches official spec (flat agents, YAML frontmatter, auto-discovered dirs correct)
- [ ] `claude --plugin-dir ./horse` loads without errors
- [ ] Commands resolve as `/horse:*`
- [ ] Agents appear in `/agents`
- [ ] Changes committed with Conventional Commits format
