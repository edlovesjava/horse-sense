# Sprint 3 Plan: Dual Toolchain, PR Skills & Scout

> **Sprint**: 3
> **Duration**: 2026-04-11 → 2026-04-18 (1 week)
> **Sprint goal**: Complete TypeScript toolchain support, add PR review/fix skills for daily workflow, and introduce the scout agent/skill for research spikes.

---

## Sprint Goal

Three objectives, in priority order:

1. **TypeScript toolchain** — complete the dual-language story with a dedicated TypeScript setup skill, TypeScript quality rules, and language-aware scripts. Sprint 2 laid the groundwork (config schema, dual-language skill sections); this sprint finishes the job.

2. **PR review & fix skills** — add high-value workflow skills that review PRs and address review comments using `gh` CLI. These are the most immediately useful features for daily development.

3. **Scout agent & skill** — introduce a research/investigation persona that produces spike reports and optional draft stories/ADRs. This fills a gap in the SDLC: structured discovery before committing to requirements or designs.

---

## Sprint Backlog

### Part 1: TypeScript Toolchain Completion (US-050, US-051, US-060)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-020 | Create `skills/typescript-setup/SKILL.md` (npm, vitest, eslint, tsc, prettier) | US-051 | 3 | ✅ Done |
| T-021 | Create `rules/typescript_quality.md` with TypeScript-specific code quality rules | US-051 | 3 | ✅ Done |
| T-022 | Update scripts (setup_env, run_tests, lint) to detect and support TypeScript | US-050, US-051 | 5 | ✅ Done |
| T-023 | Create `templates/ci.yml` GitHub Actions workflow template (Python + TS matrix) | US-060 | 3 | ✅ Done |
| T-024 | Update README.md for plugin installation, configuration, and usage | — | 2 | ✅ Done |
| | **Part 1 subtotal** | | **16** | |

### Part 2: PR Review & Fix Skills (US-080, US-081)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-028 | Create `skills/pr-review/SKILL.md` — PR review skill with gh CLI integration | US-080 | 5 | ✅ Done |
| T-029 | Create `skills/pr-fix/SKILL.md` — PR fix/triage/reply skill | US-081 | 5 | ✅ Done |
| | **Part 2 subtotal** | | **10** | |

### Part 3: Scout Agent & Skill (US-082)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-030s | Create `agents/scout.md` — research and investigation agent persona | US-082 | 3 | ⬜ To Do |
| T-031s | Create `skills/scout/SKILL.md` — spike research skill with report template | US-082 | 3 | ⬜ To Do |
| T-032s | Create `templates/spike_report.md` — spike report scaffold | US-082 | 1 | ⬜ To Do |
| | **Part 3 subtotal** | | **7** | |

| | **Parts 1–3 subtotal** | | **33** | |

### Part 4: MkDocs Documentation Site (Stretch Goal — US-075)

| Task ID | Title | Req | Points | Status |
|---|---|---|---|---|
| T-033s | Create `mkdocs.yml` with Material theme and nav structure | US-075 | 2 | ⬜ To Do |
| T-034s | Organize content — map `horse/` and `docs/` into nav hierarchy | US-075 | 2 | ⬜ To Do |
| T-035s | Add `make docs` target and build script | US-075 | 1 | ⬜ To Do |
| T-036s | Add docs build to CI and GitHub Pages deployment | US-075, US-077 | 3 | ⬜ To Do |
| | **Part 4 subtotal (stretch)** | | **8** | |

| | **Sprint 3 Total (with stretch)** | | **41** | |

### Status Key

- ⬜ To Do
- 🔵 In Progress
- 🔍 In Review
- ✅ Done
- 🚫 Blocked

---

## Task Details

### T-020: Create `skills/typescript-setup/SKILL.md`

Equivalent to `skills/python-venv/SKILL.md` but for the TypeScript/Node.js ecosystem. Should cover:

1. Initialize a Node.js project (`npm init`)
2. Install dev dependencies (vitest, eslint, prettier, typescript)
3. Configure `tsconfig.json` with strict mode
4. Configure eslint and prettier
5. Set up vitest config
6. Verify the environment (`npx tsc --noEmit`, `npx vitest run`)

Read `pythonVersion`/`nodeVersion` from `.claude/config.json`.

**Acceptance**: Skill produces working TypeScript environment from scratch.

---

### T-021: Create `rules/typescript_quality.md`

TypeScript-specific code quality rules, complementing `rules/code_quality.md` (which is Python-focused). Should cover:

- Strict TypeScript: `strict: true`, no `any` without justification
- Prefer `interface` over `type` for object shapes
- Use `readonly` for immutable properties
- Prefer `const` over `let`; never use `var`
- Named exports over default exports
- Error handling: typed errors, no bare `catch`
- Import organization: external, internal, types
- File naming: kebab-case for files, PascalCase for components

**Acceptance**: Rule file exists, is referenced by developer/tester/reviewer agent prompts.

---

### T-022: Update scripts for TypeScript detection

Update `horse/scripts/setup_env.sh`, `run_tests.sh`, and `lint.sh` to:

1. Auto-detect language from `package.json` (TypeScript) vs `pyproject.toml` (Python)
2. Read `.claude/config.json` if available for explicit language setting
3. Run the appropriate toolchain commands based on detected/configured language

**Acceptance**: `setup_env.sh` bootstraps a TypeScript project. `run_tests.sh` runs vitest. `lint.sh` runs eslint + prettier. All scripts fall back to Python if no TypeScript indicators found.

---

### T-023: Create `templates/ci.yml`

GitHub Actions workflow template for user projects. Should support:

- Language matrix (Python + TypeScript)
- Test, lint, type-check, coverage, security audit steps per language
- Coverage threshold from `.claude/config.json`
- PR triggers + push to main

**Acceptance**: Template produces a working CI workflow for both Python and TypeScript projects.

---

### T-024: Update README.md and clean up plan/docs discrepancies

Update the project README.md with:

- Clear installation instructions
- Configuration guide (both `horse.config.md` and `.claude/config.json`)
- Quick start walkthrough
- Command reference table
- Agent descriptions
- Link to example configs

Also clean up documentation discrepancies flagged in Sprint 2 PR review:

- **sprint_2_plan.md T-102**: states frontmatter validator uses PyYAML with Bash fallback, but actual implementation uses regex-based parsing. Update plan to reflect reality.
- **sprint_2_plan.md Part 2 intro**: describes `.claude/config.json` as the only config mechanism, but `horse.config.md` also exists (two-tier config). Clarify the two-tier approach in the plan text.

**Acceptance**: A new user can install and start using the plugin within 5 minutes by following the README. No stale or misleading descriptions in plan documents.

---

### T-028: Create `skills/pr-review/SKILL.md`

PR review skill that:

1. Accepts a PR number (or auto-detects from current branch)
2. Fetches PR diff and changed files via `gh pr view` and `gh api`
3. Analyzes each changed file against project rules and conventions
4. Posts inline review comments on specific lines using `gh api`
5. Posts a summary review with overall assessment
6. Categorizes issues as `[must-fix]`, `[should-fix]`, `[nit]`
7. Approves PRs with no issues

Should read `.claude/config.json` for language/toolchain context and reference relevant rules.

**Acceptance**: Skill reviews a real PR and posts structured comments via gh CLI.

---

### T-029: Create `skills/pr-fix/SKILL.md`

PR fix skill that:

1. Fetches all unresolved review comments on a PR via `gh api`
2. Triages each comment: `fix`, `defer`, or `accept`
3. For `fix`: modifies code, replies with what changed and commit SHA
4. For `defer`: replies with explanation of why
5. For `accept`: replies acknowledging the feedback
6. Commits all fixes in a single conventional commit
7. Pushes and posts a summary comment listing actions taken

Should handle comments from any reviewer (human, Copilot, horse review skill).

**Acceptance**: Skill processes review comments on a real PR, makes fixes, and replies to threads.

---

### T-030s: Create `agents/scout.md`

Scout agent persona with YAML frontmatter. The scout:

- Specializes in research, investigation, and feasibility analysis
- Conducts timeboxed spikes with clear questions
- Produces spike reports with findings, trade-offs, and recommendations
- Can optionally draft user stories or ADRs from findings
- Reads project context from config, requirements, and architecture docs
- Composes the scout skill and references documentation rules

**Acceptance**: Agent appears in `/agents` with correct frontmatter. Persona produces structured spike reports.

---

### T-031s: Create `skills/scout/SKILL.md`

Scout skill with step-by-step guidance for conducting a spike:

1. Define the research question and timebox
2. Identify sources (codebase, docs, APIs, libraries, web)
3. Conduct investigation using available tools
4. Document findings in spike report format
5. Build trade-off matrix for options discovered
6. Produce recommendation with confidence level
7. Optionally generate draft stories/ADRs from findings

Should reference `${CLAUDE_PLUGIN_ROOT}/templates/spike_report.md`.

**Acceptance**: Skill guides a productive spike and produces a usable report.

---

### T-032s: Create `templates/spike_report.md`

Spike report template with sections for:

- Question, approach, findings, trade-off matrix, recommendation, open questions, next steps

**Acceptance**: Template is scaffolded and referenced by scout skill. *(Note: already created as part of sprint planning.)*

---

### T-033s: Create `mkdocs.yml` with Material theme

Create `mkdocs.yml` at repo root with:

- `mkdocs-material` theme with search, dark mode
- `nav:` structure covering: Getting Started, Configuration, Commands, Agents, Skills, Rules, Templates, ADRs, Spikes
- Markdown extensions: admonitions, code highlighting, tables, tabs

Add `mkdocs` and `mkdocs-material` to `requirements-dev.txt` (or a dedicated `docs/requirements.txt`).

**Acceptance**: `mkdocs serve` renders the full documentation site locally.

---

### T-034s: Organize content into nav hierarchy

Map existing markdown into the MkDocs nav. This may require:

- An `index.md` for each nav section (can be thin wrappers that include/link existing files)
- Symlinking or copying `horse/` content into a `docs/` structure MkDocs can read (or using `mkdocs-include-markdown-plugin`)
- Ensuring relative links between docs still work

**Acceptance**: All plugin docs, rules, templates, ADRs, and spike reports are navigable in the site.

---

### T-035s: Add `make docs` target and build script

- `make docs` — build the static site to `site/`
- `make docs-serve` — run local dev server (`mkdocs serve`)
- Add `site/` to `.gitignore`

**Acceptance**: `make docs` builds clean. `make docs-serve` runs locally.

---

### T-036s: Add docs build to CI and GitHub Pages deployment

- Add `mkdocs build --strict` step to CI workflow (fails on broken links/warnings)
- Add a deploy job that runs `mkdocs gh-deploy` on merge to `main`
- Configure GitHub Pages to serve from `gh-pages` branch

**Acceptance**: CI validates docs build. Merges to main auto-deploy to GitHub Pages.

---

## Deferred to Sprint 4

| Task | Title | Reason |
|---|---|---|
| T-025 | Update `scripts/new_project.sh` for TypeScript scaffolding | Should Have; lower priority than PR skills and scout |
| T-026 | End-to-end validation: Python project | Better done after PR skills land |
| T-027 | End-to-end validation: TypeScript project | Better done after PR skills land |

---

## Risks & Blockers

| Risk | Impact | Mitigation |
|---|---|---|
| Sprint too large (33 SP) | Med | Parts are independent — can defer T-023 (CI template) or T-024 (README) to Sprint 4 if needed |
| gh CLI not available in all environments | Med | PR skills should degrade gracefully with clear error messages |
| Scout skill scope creep (research is open-ended) | Med | Timeboxing is built into the skill design; spike reports force structured output |
| TypeScript scripts complexity | Low | Detection logic is straightforward (check for package.json); keep scripts simple |

---

## Definition of Done

A task is **Done** when:

- [ ] Implementation matches task description and acceptance criteria
- [ ] `make check` passes
- [ ] No broken internal references in plugin
- [ ] New agents have valid YAML frontmatter
- [ ] New skills have valid frontmatter and are config-aware
- [ ] Changes committed with Conventional Commits format
