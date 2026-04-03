# Sprint 1 Plan: Plugin Structure & Installation

> **Sprint**: 1  
> **Duration**: 2026-04-03 → 2026-04-10 (1 week)  
> **Team capacity**: 13 story points  
> **Sprint goal**: Restructure horse-sense into the official Claude Code plugin format and verify it loads correctly

---

## Sprint Goal

Transform the current repo layout into a conformant Claude Code plugin with `.claude-plugin/plugin.json`, top-level `commands/`, `SKILL.md` files, and restructured agent directories. By the end of this sprint, `claude --plugin-dir ./horse-sense` should load the plugin with all commands available as `/horse-sense:*`.

---

## Sprint Backlog

| Story ID | Title | Priority | Points | Status |
|---|---|---|---|---|
| T-001 | Create `.claude-plugin/plugin.json` manifest | Must | 1 | ✅ Done |
| T-002 | Move `.claude/commands/*.md` → `commands/*.md` at plugin root | Must | 2 | ✅ Done |
| T-003 | Update command content: replace `/user:` refs with `/horse-sense:` | Must | 2 | ✅ Done |
| T-004 | Rename `skills/*/README.md` → `skills/*/SKILL.md` with frontmatter | Must | 3 | ✅ Done |
| T-005 | Restructure `agents/` into `agents/workers/` | Must | 1 | ✅ Done |
| T-006 | Create `bin/` directory (placeholder) | Could | 1 | ✅ Done |
| T-007 | Remove `.claude/settings.json` (replaced by plugin.json) | Must | 1 | ✅ Done |
| T-008 | Verify plugin loads via `claude --plugin-dir ./horse-sense` | Must | 2 | ⬜ To Do |
| **Total** | | | **13** | |

### Status Key
- ⬜ To Do
- 🔵 In Progress
- 🔍 In Review
- ✅ Done
- 🚫 Blocked

---

## Task Details

### T-001: Create `.claude-plugin/plugin.json`

Create the manifest file:

```json
{
  "name": "horse-sense",
  "description": "Structured SDLC plugin for Claude Code — skills, agents, rules, and process orchestration for building high-quality software",
  "version": "1.0.0",
  "author": {
    "name": "Ed Wentworth"
  }
}
```

**Acceptance**: File exists at `.claude-plugin/plugin.json` with valid JSON.

---

### T-002: Move commands to plugin root

Move all 9 files from `.claude/commands/` to `commands/`:

| Source | Destination |
|---|---|
| `.claude/commands/sdlc-start.md` | `commands/sdlc-start.md` |
| `.claude/commands/plan.md` | `commands/plan.md` |
| `.claude/commands/arch.md` | `commands/arch.md` |
| `.claude/commands/implement.md` | `commands/implement.md` |
| `.claude/commands/review.md` | `commands/review.md` |
| `.claude/commands/test.md` | `commands/test.md` |
| `.claude/commands/deploy.md` | `commands/deploy.md` |
| `.claude/commands/sprint.md` | `commands/sprint.md` |
| `.claude/commands/retrospective.md` | `commands/retrospective.md` |

**Acceptance**: All commands in `commands/`. `.claude/commands/` removed. No broken references.

---

### T-003: Update `/user:` → `/horse-sense:` references

Search all files for `/user:` command references and replace with `/horse-sense:`. This includes:
- Command files themselves (cross-references)
- CLAUDE.md
- Agent files
- Skill files
- README.md

**Acceptance**: `grep -r '/user:' .` returns no results (excluding docs/ history).

---

### T-004: Rename README.md → SKILL.md with frontmatter

For each skill directory, rename `README.md` to `SKILL.md` and add YAML frontmatter:

| Skill | Frontmatter |
|---|---|
| `skills/requirements_analysis/` | `name: requirements-analysis`<br/>`description: Elicit, analyze, document, and validate project requirements` |
| `skills/architecture_design/` | `name: architecture-design`<br/>`description: Design system architecture, select technologies, create ADRs` |
| `skills/implementation/` | `name: implementation`<br/>`description: Implement features using TDD with language-appropriate tooling` |
| `skills/testing/` | `name: testing`<br/>`description: Create and run tests following the test pyramid strategy` |
| `skills/deployment/` | `name: deployment`<br/>`description: Prepare deployment artifacts, CI/CD workflows, and runbooks` |
| `skills/python_venv/` | `name: python-venv`<br/>`description: Set up and manage Python virtual environments with pip` |

**Acceptance**: All skills have `SKILL.md` with valid frontmatter. No `README.md` files in skill dirs.

---

### T-005: Restructure agents into workers/

```
agents/                →  agents/workers/
  architect.md              architect.md
  developer.md              developer.md
  planner.md                planner.md
  reviewer.md               reviewer.md
  tester.md                 tester.md
```

Update any internal references in agent files that point to other agents or skills.

**Acceptance**: All 5 agents in `agents/workers/`. `agents/` has only `workers/` subdirectory. No broken references.

---

### T-006: Create bin/ directory

```
bin/
  .gitkeep
```

Placeholder for future executables. Verify Claude Code plugin manager adds `bin/` to PATH.

**Acceptance**: Directory exists. Not blocking if PATH injection can't be verified.

---

### T-007: Remove .claude/settings.json

This file is replaced by `.claude-plugin/plugin.json`. The settings it contained (context includes/excludes, SDLC phases, feature flags) either:
- Move to plugin.json (if supported)
- Move to CLAUDE.md (context includes)
- Are no longer needed (custom config keys)

**Note**: Preserve `.claude/` directory itself — it's where per-project `config.json` will live (Sprint 2).

**Acceptance**: `.claude/settings.json` deleted. No functionality lost.

---

### T-008: Smoke test plugin loading

Run `claude --plugin-dir ./horse-sense` and verify:
- [ ] Plugin is recognized (check plugin list)
- [ ] `/horse-sense:plan` and other commands are available
- [ ] Agent files are accessible
- [ ] Rules files are loaded (test with a `.py` file edit)
- [ ] No errors in plugin loading

Document any issues found — they inform Sprint 2 work.

**Acceptance**: Plugin loads. Commands resolve. Issues documented.

---

## Risks & Blockers

| Risk / Blocker | Impact | Action |
|---|---|---|
| Plugin spec may not support `rules/` or `templates/` directories | High | Test in T-008. If not loaded, we'll add workaround in Sprint 2 (hooks or CLAUDE.md includes). |
| `.claude/settings.json` removal may break local dev experience | Med | Keep `.claude/` dir for future config.json. Test that removing settings.json doesn't break Claude Code. |
| SKILL.md frontmatter schema may have undocumented requirements | Med | Test in T-004/T-008. Adjust frontmatter if needed. |

---

## Definition of Done

A story is **Done** when:
- [ ] File changes are correct and consistent
- [ ] No broken internal references (grep for old paths)
- [ ] Plugin structure matches spec layout
- [ ] Changes committed with Conventional Commits format
