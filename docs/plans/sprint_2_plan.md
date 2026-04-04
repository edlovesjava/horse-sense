# Sprint 2 Plan: Toolchain & Configuration

> **Sprint**: 2  
> **Duration**: 2026-04-04 → 2026-04-11 (1 week)  
> **Sprint goal**: Establish the plugin's own development toolchain (validation, linting, local checks) and make skills config-aware so they adapt to the host project's language and tooling.

---

## Sprint Goal

Two objectives, in priority order:

1. **Toolchain first** — set up validation, linting, and a `make check` workflow so that every future change to the plugin is automatically verified. This gives us a safety net before we start modifying skills and agents.

2. **Config & skills** — define the `.claude/config.json` schema, update skills to read config variables, and fold rules content into agent prompts so the plugin actually adapts to host projects.

---

## Sprint Backlog

### Part 1: Plugin Toolchain (new tasks, mapped to US-070–US-078)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-100 | Create Makefile with `check` and `fix` targets (orchestrates all checks) | US-078 | 2 | ✅ Done |
| T-101 | Create plugin structure validation script (`scripts/validate-plugin.sh`) | US-070 | 3 | ✅ Done |
| T-102 | Add frontmatter validation for agents, commands, skills, rules | US-074 | 3 | ✅ Done |
| T-103 | Add markdownlint configuration (`.markdownlint.json`) and integrate into Makefile | US-071 | 2 | ✅ Done |
| T-104 | Add shellcheck integration for `scripts/` and `bin/` | US-072 | 1 | ✅ Done |
| T-105 | Create GitHub Actions CI workflow (`.github/workflows/ci.yml`) | US-077 | 3 | ✅ Done |
| | **Part 1 subtotal** | | **14** | |

### Part 2: Skills, Agents & Configuration (existing tasks from Epic 2)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-010 | Define `.claude/config.json` schema with defaults and auto-detection | US-002, US-013 | 3 | ✅ Done |
| T-011 | Update all 6 skills to read config variables (language, testRunner, srcDir, etc.) | US-010, US-013 | 5 | ✅ Done |
| T-012 | Update agent system prompts to incorporate rules content and reference `${CLAUDE_PLUGIN_ROOT}/rules/` | US-020, US-021 | 3 | ✅ Done |
| T-013 | Fold key rules into agent prompts (rules/ not auto-discovered) | US-030, US-031 | 3 | ✅ Done |
| T-014 | Update CLAUDE.md for plugin context (trail naming, new structure, config) | — | 2 | ✅ Done |
| | **Part 2 subtotal** | | **16** | |

| | **Sprint 2 Total** | | **30** | |

### Status Key

- ⬜ To Do
- 🔵 In Progress
- 🔍 In Review
- ✅ Done
- 🚫 Blocked

---

## Task Details

### T-100: Create Makefile with `check` and `fix` targets

The Makefile is the entry point for all local validation. It should:

- `make check` — run all checks (structure, frontmatter, markdownlint, shellcheck), exit non-zero on any failure
- `make fix` — auto-fix what's fixable (markdownlint --fix)
- `make validate` — just the plugin structure validation
- `make lint` — just the linters (markdownlint + shellcheck)

Keep it simple — each target calls one script or tool. No complex Make logic.

**Acceptance**: `make check` runs all checks and completes in under 30 seconds.

---

### T-101: Create plugin structure validation script

Create `scripts/validate-plugin.sh` that checks:

1. `horse/.claude-plugin/plugin.json` exists and is valid JSON
2. `plugin.json` has required fields (`name`, `description`)
3. Every `.md` file in `horse/agents/` exists and is non-empty
4. Every `.md` file in `horse/commands/` exists and is non-empty
5. Every `horse/skills/*/SKILL.md` exists and is non-empty
6. Every `.sh` file in `horse/scripts/` is executable
7. No broken cross-references (commands referencing templates that don't exist)

**Tool**: Pure Bash — no runtime dependencies beyond `jq` for JSON parsing.

**Acceptance**: Script exits 0 on valid plugin, non-zero with clear error messages on invalid.

---

### T-102: Add frontmatter validation

Extend validation to check YAML frontmatter in all Markdown components:

| Component | Required fields |
|---|---|
| `agents/*.md` | `name` (string), `description` (string) |
| `commands/*.md` | (validated as non-empty, frontmatter optional per spec) |
| `skills/*/SKILL.md` | `name` (string), `description` (string) |
| `rules/*.md` | (validated as non-empty) |

**Tool**: Python script (`scripts/validate-frontmatter.py`) using PyYAML — simple and portable. Falls back to a grep-based Bash check if Python unavailable.

**Acceptance**: Validates all frontmatter. Reports missing/invalid fields with file path and field name.

---

### T-103: Add markdownlint configuration

1. Create `.markdownlint.json` at repo root with sensible defaults:
   - Allow long lines in tables and code blocks
   - Require fenced code blocks (not indented)
   - Allow multiple H1s (each file is standalone)
   - Disable line-length rule for frontmatter

2. Add `npx markdownlint-cli2 "horse/**/*.md"` to Makefile `lint` target.

3. Auto-fix target: `npx markdownlint-cli2 --fix "horse/**/*.md"`.

**Acceptance**: `make lint` runs markdownlint on all plugin Markdown. Config is committed.

---

### T-104: Add shellcheck integration

1. Add `shellcheck horse/scripts/*.sh` to Makefile `lint` target.
2. Create `.shellcheckrc` if any rules need suppression.
3. Fix any existing shellcheck findings in `horse/scripts/`.

**Acceptance**: `make lint` runs shellcheck on all `.sh` files. Zero errors on current scripts.

---

### T-105: Create GitHub Actions CI workflow

Create `.github/workflows/ci.yml` that runs on PRs to `main`:

```yaml
steps:
  - Plugin structure validation (scripts/validate-plugin.sh)
  - Frontmatter validation (scripts/validate-frontmatter.py)
  - Markdown lint (markdownlint-cli2)
  - Shell lint (shellcheck)
```

Keep it simple — single job, Ubuntu latest, install tools via apt/npm.

**Acceptance**: CI runs on PRs. Fails if any check fails. Green on current `main`.

---

### T-010: Define `.claude/config.json` schema

Create a JSON schema file (`horse/schemas/config.schema.json`) defining:

| Variable | Type | Default | Description |
|---|---|---|---|
| `language` | string | auto-detect | `"python"` or `"typescript"` |
| `framework` | string | none | e.g., `"fastapi"`, `"express"` |
| `testRunner` | string | per-language | e.g., `"pytest"`, `"vitest"` |
| `linter` | string | per-language | e.g., `"ruff"`, `"eslint"` |
| `typeChecker` | string | per-language | e.g., `"mypy"`, `"tsc"` |
| `formatter` | string | per-language | e.g., `"ruff format"`, `"prettier"` |
| `srcDir` | string | `"src"` | Source directory |
| `testDir` | string | `"tests"` | Test directory |
| `packageManager` | string | per-language | e.g., `"pip"`, `"npm"` |
| `coverageThreshold` | number | `80` | Minimum coverage % |

Also create an example config file (`horse/templates/config.example.json`).

Skills should auto-detect language from `pyproject.toml` / `package.json` if no config exists.

**Acceptance**: Schema file validates example configs. Skills reference schema for defaults.

---

### T-011: Update skills to read config variables

Update all 6 skills (`requirements-analysis`, `architecture-design`, `implementation`, `testing`, `deployment`, `python-venv`) to:

1. Read `.claude/config.json` at the start of execution
2. Use config values for commands, paths, and tool choices
3. Fall back to documented defaults if config is missing

This is the biggest task in the sprint — each skill needs language-aware branching.

**Acceptance**: Each skill produces language-appropriate guidance for both Python and TypeScript configs.

---

### T-012: Update agent prompts to incorporate rules

Each agent prompt in `horse/agents/*.md` should reference the relevant rules:

| Agent | Rules to incorporate |
|---|---|
| developer | `code_quality.md`, `git_workflow.md` |
| tester | `testing.md`, `code_quality.md` |
| reviewer | `code_quality.md`, `testing.md`, `documentation.md`, `git_workflow.md` |
| architect | `documentation.md` |
| planner | `documentation.md` |

Use `${CLAUDE_PLUGIN_ROOT}/rules/<file>` paths so Claude reads them at agent activation.

**Acceptance**: Each agent references its relevant rules. Agent behavior reflects rule content.

---

### T-013: Fold key rules into agent prompts

Since `rules/` is not auto-discovered, the most critical rules should be inlined or summarized in agent prompts rather than relying solely on file references.

- Inline the top 5-10 rules from each relevant rules file directly into the agent's system prompt
- Keep the full rules files as reference documents for when Claude needs detail
- This ensures rules are applied even if `${CLAUDE_PLUGIN_ROOT}` path resolution fails

**Acceptance**: Agent prompts contain inlined key rules. Full rules files still exist as reference.

---

### T-014: Update CLAUDE.md for plugin context

Update CLAUDE.md to reflect:

- Trail naming convention (guide, trails/)
- Sprint 2 completion state
- Config schema reference
- Updated command list (`/horse:guide` not `/horse:sdlc-start`)

**Acceptance**: CLAUDE.md is accurate and complete. No stale references.

---

## Risks & Blockers

| Risk | Impact | Mitigation |
|---|---|---|
| markdownlint-cli2 not available in Codespaces | Med | Use `npx` (no global install needed). Add to `package.json` devDependencies if we create one. |
| Python not available for frontmatter validation | Low | Fallback to grep-based Bash validation. Python 3.11 is an environment assumption. |
| shellcheck not installed | Low | Available via `apt` in Ubuntu. CI installs it. Codespaces has it pre-installed. |
| Sprint too large (30 SP) | Med | Part 1 (toolchain) is mostly scaffolding — fast to implement. Part 2 tasks are independent — can drop T-013 to next sprint if needed. |

---

## Definition of Done

A task is **Done** when:

- [ ] Implementation matches task description and acceptance criteria
- [ ] `make check` passes (once T-100 is complete)
- [ ] No broken internal references in plugin
- [ ] Changes committed with Conventional Commits format
