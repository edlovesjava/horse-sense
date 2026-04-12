# SPIKE-003: Should the horse plugin add a dedicated project-init command?

> **Status**: Complete
> **Author**: Scout (Claude Sonnet 4.6)
> **Date**: 2026-04-06
> **Timebox**: 3 hours

---

## Question

Should the horse plugin introduce a dedicated `/horse:init` (or `/horse:setup`) command — and/or a
companion skill — that interviews the user and fully scaffolds a new project directory? If yes, what
form should it take, and how does it differ from the existing `/horse:guide` command and `new_project.sh`
script?

**Scope in bounds:**

- Auditing current project-setup coverage across all plugin components
- Identifying gaps between what exists and what a fully initialized project needs
- Evaluating design options (command vs skill vs script enhancement)
- Recommending an interview flow and feature scope

**Scope out of bounds:**

- Implementation of any new command or skill (this spike informs design only)
- Package-manager comparison (pip vs uv vs poetry, npm vs pnpm vs yarn) — a separate spike if needed
- CI systems other than GitHub Actions

---

## Approach

- [x] Read `horse/commands/guide.md` — understand the existing SDLC kickoff command
- [x] Read `horse/scripts/new_project.sh` — understand what the existing scaffolding script does
- [x] Read `horse/scripts/setup_env.sh` — understand post-scaffold environment bootstrap
- [x] Read `horse/skills/typescript-setup/SKILL.md` and `horse/skills/python-venv/SKILL.md`
- [x] Read `horse/templates/horse_config.md` and both `config.example.*.json` templates
- [x] Read `horse/schemas/config.schema.json`
- [x] Read `horse/templates/ci.yml` — assess CI scaffold coverage
- [x] Read ADR-0002 (two-tier config) and ADR-0003 (dual toolchain) for architectural constraints
- [x] Survey prior-art patterns: npm init, cargo init, django-admin startproject, create-react-app,
      Cookiecutter, Yeoman, and recent AI-native analogues
- [x] Map gaps between current coverage and a complete new-project checklist

---

## Findings

### Finding 1: What the current setup path actually covers

The horse plugin already contains substantial project-initialization machinery. Understanding it
precisely is the prerequisite for a sound gap analysis.

**`/horse:guide` (command)**

The guide command is a conversational SDLC kickoff. It asks six questions:

1. What are you building?
2. Who are the primary users?
3. Must-have features for the first release?
4. Technology preferences or constraints?
5. Requirements format (monolith vs per-story)?
6. Git strategy (rebase vs merge)?

It then generates `horse.config.md`, a requirements document, a high-level architecture proposal,
and a sprint plan — and tells the user to run `setup_env.sh`. The command's scope is the SDLC
workflow, not the filesystem scaffold. It intentionally defers toolchain setup to the script.

**`new_project.sh` (script)**

This is the most complete initialization artifact in the plugin. It takes `--language` and a project
name and produces, for Python:

- `src/<pkg_name>/__init__.py`, test `__init__.py` files
- `pyproject.toml` with ruff, mypy, pytest, and coverage config
- `requirements.txt` + `requirements-dev.txt`
- `.env.example`
- `tests/conftest.py`
- `.github/workflows/ci.yml` (GitHub Actions, lint + type check + test + pip-audit)
- `.claude/config.json`
- `CHANGELOG.md`
- Directory tree: `src/`, `tests/unit/`, `tests/integration/`, `tests/e2e/`,
  `docs/architecture/adr/`, `docs/runbooks/`, `docs/retros/`, `.github/workflows/`

For TypeScript it produces an equivalent set: `package.json`, `tsconfig.json`,
`vitest.config.ts`, `eslint.config.js`, `.prettierrc`, starter `src/index.ts` and test file,
`.github/workflows/ci.yml`, `.claude/config.json`, `CHANGELOG.md`.

**`setup_env.sh` (script)**

Auto-detects language from file presence, then either creates and activates a Python venv or runs
`npm install`. Handles the `.env.example` → `.env` copy. Does not create any files.

**`horse/skills/typescript-setup/SKILL.md` and `horse/skills/python-venv/SKILL.md`**

Reference guides explaining what the scripts do and why. They document manual steps, dependency
management patterns, troubleshooting. They read `.claude/config.json` for their configuration.
They are invoked by agents (particularly the developer) as procedural guides, not by users directly.

**Summary of what is already covered:**

| Area | Covered by | Status |
|---|---|---|
| Directory scaffold | `new_project.sh` | Complete for Python + TypeScript |
| Python toolchain config | `new_project.sh` | Complete (pyproject.toml, ruff, mypy, pytest) |
| TypeScript toolchain config | `new_project.sh` | Complete (package.json, tsconfig, vitest, eslint, prettier) |
| `.claude/config.json` generation | `new_project.sh` | Complete |
| GitHub Actions CI | `new_project.sh` | Basic; `ci.yml` template is richer |
| Environment bootstrap | `setup_env.sh` | Complete for Python + TypeScript |
| `horse.config.md` generation | `/horse:guide` | Complete (requirements_format + git_strategy) |
| Requirements documents | `/horse:guide` | Complete |
| Architecture docs | `/horse:guide` | Complete |
| Sprint plan | `/horse:guide` | Complete |
| CHANGELOG.md | `new_project.sh` | Present (minimal) |
| `.env.example` | `new_project.sh` | Present (Python only) |

### Finding 2: The gap — the script and the command are disconnected

The most significant finding is not a missing feature but a broken seam in the user journey.

`new_project.sh` and `/horse:guide` are parallel, independent paths. Neither calls the other.
A new user faces an immediate ambiguity: do I run the script first or start the command? The
documentation in CLAUDE.md says to run `/horse:guide` to kick off the workflow, but `/horse:guide`
does not mention `new_project.sh` by name and does not invoke it. The script's next-steps output
points the user back to `/horse:guide`, but only after the scaffold is complete.

The result is that a user who follows the CLAUDE.md "Quick Start" path (`/horse:guide`) gets:

- `horse.config.md` (yes)
- Requirements docs (yes)
- Architecture doc (yes)
- Sprint plan (yes)
- `.claude/config.json` (NO — unless they also run the script)
- Directory scaffold (NO)
- CI workflow (NO)
- Toolchain config files (NO)

A user who runs `new_project.sh` first gets the filesystem structure and config files but none
of the SDLC planning documents.

This is the primary gap: **the two halves of project initialization are not connected.**

### Finding 3: Uncovered decisions in the current interview flow

Beyond the connection problem, there are specific decisions that neither the script nor the guide
currently handles:

**Package manager selection** — The schema has a `packageManager` field. The Python script
hardcodes pip. The TypeScript script hardcodes npm. Users of uv, poetry, pnpm, or yarn get no
guidance. The python-venv skill explicitly acknowledges only pip.

**Framework selection** — The `config.example.python.json` shows `"framework": "fastapi"`. The
guide asks "technology preferences or constraints?" but this is an open-ended question. The
answer is not parsed into a framework field written to `.claude/config.json`. A CLI-first project,
a data-processing script, a FastAPI service, and a Django app have very different directory needs.

**Python version** — The schema has `pythonVersion`. The script hardcodes `3.11` in every
generated file (pyproject.toml requires-python, setup-python action, mypy target-version, etc.)
without asking the user.

**Node version** — Similarly hardcoded to `20` in the TypeScript path.

**License selection** — No `LICENSE` file is generated. No question about license is asked.

**README.md** — No `README.md` is generated despite the documentation rule requiring one. The
`documentation.md` rule defines exactly what a README must cover, but nothing scaffolds it.

**devcontainer / `.devcontainer/devcontainer.json`** — Not generated. Relevant for teams using
GitHub Codespaces or VS Code Dev Containers.

**Git initialization** — `new_project.sh` does not run `git init` or create a `.gitignore`. A
new project directory has no git repository until the user creates one separately.

**`.gitignore`** — Not generated. Python projects need `.venv/`, `__pycache__/`, `*.pyc`,
`.env`, `dist/`. TypeScript projects need `node_modules/`, `dist/`, `coverage/`, `.env`.

**SDLC config written by guide vs toolchain config written by script** — The guide writes
`horse.config.md` but does not write `.claude/config.json`. The script writes `.claude/config.json`
but not `horse.config.md`. No single step writes both.

**Richer CI from the template** — `horse/templates/ci.yml` is a multi-job workflow implementing
the five-gate readiness policy (ADR-0007). The CI generated by `new_project.sh` is a simpler
single-job workflow that does not implement the gates. The richer template exists but is not used
in the init path.

### Finding 4: Prior-art patterns and what works for AI-assisted setup

**Traditional CLI tools:**

`npm init` / `cargo init` / `go mod init` — minimal: they create one manifest file and stop. The
user is expected to add everything else manually. Fast but leaves most decisions open.

`django-admin startproject` / `rails new` — opinionated full-scaffold: one command creates the
entire application skeleton with framework-specific conventions hard-wired. No interview; the user
accepts the defaults or passes flags.

`create-react-app` / `create-next-app` — minimal interactive interview (project name, TypeScript
yes/no, a few framework options) followed by full scaffold. Became the industry standard pattern
for frontend starters. Notable design choice: one question at a time, not a form.

**Generator frameworks:**

Cookiecutter (Python) — template repository cloned and variables substituted via a `cookiecutter.json`
interview. Templates are version-controlled and shareable. Strength: arbitrary template complexity.
Weakness: template drift requires maintenance; users clone a template that may be stale.

Yeoman — generator plugins that implement a structured `prompting → configuring → writing →
installing → end` lifecycle. More powerful than Cookiecutter but requires writing a generator
in JavaScript. Essentially abandoned as a pattern (last major adoption peak ~2015).

**AI-native analogues:**

GitHub Copilot Workspace — generates an entire project from a natural-language description.
No interview; the user writes a free-text task description and the AI proposes a plan. The user
reviews and approves before any files are created. This is the current frontier: shifting from
structured interview to plan-review-approve.

Cursor's project scaffolding — similar free-text → plan → generate loop, with AI proposing the
directory structure and the user editing the proposal before accepting.

**Key lessons from prior art:**

1. One question at a time consistently outperforms forms (create-next-app research, Yeoman UX
   studies). Users abandon forms; they answer one question.

2. Showing the plan before writing files is critical for trust. The user should see "I'm going to
   create these files and make these decisions" and confirm before any filesystem changes happen.

3. Idempotency matters. `npm install` and `setup_env.sh` can be re-run safely. Scaffold scripts
   should refuse to overwrite existing files without explicit `--force`.

4. The sweet spot for AI-assisted init is between a dumb template clone and a full natural-language
   conversation: a structured interview that produces a reviewable plan.

5. The most painful part of project initialization is not creating files — it's making the decisions
   that determine what to create. Tools that force decisions (rather than leaving them to "add later")
   produce better-maintained projects.

### Finding 5: The guide command's design is the right model — but needs to be extended

`/horse:guide` already uses the correct interaction pattern: one question at a time, document
decisions immediately, never start the next phase without completing the current one. These
principles are explicitly stated in the command's "Guiding Principles" section.

The guide is designed as an SDLC kickoff: it produces planning and requirements artifacts. The
filesystem scaffold is treated as a side-effect to be handled by running a script. This separation
made sense when the plugin was first designed, but creates the broken seam documented in Finding 2.

The right design direction is to extend the guide's responsibilities to include the filesystem
scaffold, or to introduce a lightweight `init` command that bridges the gap and is invoked as
step 0 of the guide.

---

## Trade-off Matrix

| Design option | Description | Pros | Cons | Effort | Risk |
|---|---|---|---|---|---|
| **A: Enhance `/horse:guide`** | Add filesystem scaffold step to the existing guide command, after config questions and before requirements | Single entry point; user runs one command; coherent flow; guide already owns the interview | Guide is already long; SDLC kickoff and filesystem init are conceptually distinct; harder to run init without full SDLC planning | Low–medium | Low |
| **B: New `/horse:init` command** | Dedicated command for project initialization only; guide calls init as step 0, or init stands alone | Clean separation of concerns; can be run without triggering full SDLC; reusable for adding toolchain to an existing project | Adds a command to learn; users may not know which to run first; increases plugin surface area | Medium | Low |
| **C: New `init` skill** | Model-invoked skill that agents call when they detect a new project | Consistent with how typescript-setup and python-venv work; composable | No user-facing entry point; users can't invoke it directly; harder to discover | Low | Medium (discoverability) |
| **D: Script enhancement only** | Improve `new_project.sh` to handle more decisions; update guide to call it explicitly | Lowest effort; no new plugin components | Shell scripts can't conduct interactive interviews well; does not fix the conceptual gap | Low | Medium (UX debt) |
| **E: `/horse:init` + guide integration** | New init command that guide invokes as step 0; init can also be run standalone | Best of both worlds; clean entry point; full SDLC path works end-to-end | Most implementation effort; two components to maintain | Medium–high | Low |

---

## Recommendation

**Build option E: a new `/horse:init` command, integrated into `/horse:guide` as step 0.
Confidence: High.**

### Rationale

The existing `/horse:guide` is the right conceptual home for a new user's first interaction with
the plugin. But the guide currently leaves a critical gap: it does not produce a working filesystem
scaffold, and the user must separately discover and run `new_project.sh`. This gap is not a minor
inconvenience — it means that after running `/horse:guide`, the user does not have a `.claude/config.json`
that skills need to function, no `.gitignore`, no toolchain config files, and no git repository.

A dedicated `/horse:init` command fixes this by:

1. Owning the structured interview for toolchain and project identity decisions
2. Generating the filesystem scaffold (directory structure, `.gitignore`, toolchain config,
   `.claude/config.json`, `horse.config.md`, `README.md`, `CHANGELOG.md`, `LICENSE`)
3. Bootstrapping the environment (delegating to `setup_env.sh` after scaffolding)
4. Handing off cleanly to `/horse:guide` for the SDLC planning phases

The guide then becomes a two-phase command: it detects whether init has already been run (by
checking for `horse.config.md` and `.claude/config.json`) and either invokes init first or skips
to requirements.

**Why not option A (enhance guide only):** The guide's conversational style is well-suited to
SDLC planning questions (what are you building, who are the users). Filesystem and toolchain
questions are a different category — more closed-ended, more technical. Keeping them separate
makes each component easier to understand and maintain. The guide should be expressly designed
for returning users planning a sprint or a feature, not just for first-time project creation.

**Why not option B (standalone init, no guide integration):** Without explicit guide integration,
users face the original discovery problem. The guide must be updated to call init or check for
its completion; that is the integration step that makes the user journey coherent.

**Why not option C (skill only):** Skills are model-invoked guides for agents. They cannot serve
as a user-facing entry point for a first-time setup experience. Discoverability is essential here.

**Why not option D (script enhancement):** Shell scripts are the wrong medium for a multi-question
interview with plan review. Claude-executed commands have the conversational capability; the scripts
should be relegated to execution helpers.

### Proposed interview flow for `/horse:init`

The interview follows the "one question at a time" principle from the guide. Questions are ordered
from broadest to most specific, and later questions adapt based on earlier answers.

```
1. What is the project name? (used for package.json "name", pyproject.toml [project] name,
   directory naming if not already in a project dir)

2. Describe the project in one sentence. (used for package.json "description",
   pyproject.toml description, and the README tagline)

3. What is the primary language? [Python / TypeScript]

   → If Python:
   4a. Which Python version? [3.11 / 3.12 / 3.13, default 3.11]
   4b. Which package manager? [pip / uv / poetry, default pip]
   4c. Is this a web service, CLI tool, or library? (determines directory layout hints
       and framework question below)
   4d. Framework? [fastapi / flask / django / none, with "none" as default]

   → If TypeScript:
   4a. Which Node.js version? [20 / 22, default 20]
   4b. Which package manager? [npm / pnpm / yarn, default npm]
   4c. Is this a web service, CLI tool, or library? (same purpose)
   4d. Framework? [express / fastify / nextjs / none, default none]

5. How would you like to organize requirements? [single document / one file per story]
   (writes horse.config.md requirements_format)

6. Git integration strategy for feature branches? [rebase / merge, default rebase]
   (writes horse.config.md git_strategy)

7. License? [MIT / Apache-2.0 / GPL-3.0 / proprietary / skip]

8. Set up a devcontainer? [yes / no, default no]
```

After question 8, the command presents a summary plan:

```
I'm going to create the following for project "my-api":

Language: Python 3.11 with pip
Framework: FastAPI
Test runner: pytest + pytest-cov
Linter/formatter: ruff
Type checker: mypy
Git strategy: rebase (linear history)
Requirements: one file per story (docs/requirements/stories/)
License: MIT

Files to be created:
  .gitignore
  pyproject.toml
  requirements.txt / requirements-dev.txt
  .env.example
  .claude/config.json
  horse.config.md
  README.md
  CHANGELOG.md
  LICENSE
  src/my_api/__init__.py
  tests/unit/__init__.py
  tests/integration/__init__.py
  tests/e2e/__init__.py
  tests/conftest.py
  .github/workflows/ci.yml (five-gate policy)

Shall I proceed? [yes / adjust first]
```

The "adjust first" branch loops back to review individual answers before writing.

After confirmation, the command writes all files and runs `setup_env.sh`. It then asks whether to
proceed into the SDLC planning phases (effectively handing off to `/horse:guide` step 2 onward).

### What new gaps to fill (beyond the interview flow)

| Gap | Resolution |
|---|---|
| `.gitignore` not generated | `horse:init` generates a language-appropriate `.gitignore` |
| `git init` not run | `horse:init` checks for `.git/`, offers to run `git init` if absent |
| `README.md` not generated | `horse:init` generates a README from the `documentation.md` template |
| `LICENSE` not generated | `horse:init` asks which license and writes it |
| Rich CI template not used | `horse:init` uses `ci.yml` template (five-gate) instead of the simplified one |
| Python version not asked | `horse:init` interview includes it; written to pyproject.toml and `.claude/config.json` |
| Framework not parsed | `horse:init` writes `"framework"` field to `.claude/config.json` |
| `.claude/config.json` not written by guide | `horse:init` always writes it; guide detects and skips |
| `horse.config.md` only written by guide | `horse:init` writes it; guide detects and skips |
| Package manager not asked | `horse:init` asks; updates pyproject.toml, config.json accordingly |
| `.env.example` missing for TypeScript | `horse:init` generates it for both languages |
| devcontainer not offered | `horse:init` optionally generates `.devcontainer/devcontainer.json` |

### What to keep unchanged

- `new_project.sh` — retain as a non-interactive scripted path for automation and CI. Update to
  accept `--python-version`, `--framework`, and `--package-manager` flags to fill its current
  hardcoding gaps. The command and the script can share the same underlying work.
- `setup_env.sh` — no changes needed; `horse:init` delegates to it after scaffolding.
- `/horse:guide` — update to check for `horse.config.md` + `.claude/config.json` at startup; if
  absent, invoke `horse:init` before proceeding to requirements.
- Existing skills (`typescript-setup`, `python-venv`) — retain as reference guides for agents.
  They become documented alternatives to `horse:init` for users who prefer manual control.

---

## Open Questions

- [ ] **Package manager depth**: Should `horse:init` install dependencies after scaffolding, or
  only generate the manifest files and leave `setup_env.sh` to install? The latter is safer for
  environments where the runtime is not yet installed. Recommended: generate manifests, then run
  `setup_env.sh`, which already handles idempotency.

- [ ] **uv support**: uv is rapidly displacing pip in Python projects (as of 2025-2026). Should
  `horse:init` offer uv as the default for Python, displacing pip? This is a separate spike
  (package manager evaluation), but the interview design should accommodate it.

- [ ] **`new_project.sh` fate**: Once `horse:init` exists, `new_project.sh` becomes partially
  redundant. The script should be retained for non-interactive automation use cases, but its
  hardcoded defaults should be updated to match whatever `horse:init` decides. A future refactor
  could have `horse:init` generate a project-specific setup script rather than calling a generic one.

- [ ] **Multi-language projects**: The current binary Python / TypeScript choice does not cover
  monorepos or projects with both a Python backend and a TypeScript frontend. Out of scope for the
  initial `horse:init`, but the design should not actively block it (i.e., `packageManager` in
  `.claude/config.json` could be an object with per-language keys).

- [ ] **Devcontainer template quality**: If devcontainer support is added, what base images and
  features should the generated `devcontainer.json` include? Requires a short sub-spike or a
  reasonable opinionated default.

---

## Next Steps

- [ ] **Accept this spike as justification** to add `/horse:init` to the sprint backlog as a new
  feature.
- [ ] **Draft user story** for `/horse:init` (planner or scout can draft from this spike).
- [ ] **Update `/horse:guide`** to check for prior `horse:init` completion and skip init steps
  if both `horse.config.md` and `.claude/config.json` exist. This is a low-effort improvement
  that can ship before `horse:init` is built.
- [ ] **Update `new_project.sh`** to accept `--python-version`, `--node-version`, and
  `--framework` flags, eliminating hardcoded defaults. Low effort, immediate value.
- [ ] **Spike on package manager selection** (uv vs pip, pnpm vs npm) before `horse:init`
  interview questions are finalized.
- [ ] **Draft ADR** for the new command's architecture: whether it is a pure command (Markdown
  instruction file) or whether it will require a companion shell script for the
  file-writing step (as `new_project.sh` serves today).

---

## Sources

- `/workspaces/horse-sense/horse/commands/guide.md` — existing guide command
- `/workspaces/horse-sense/horse/scripts/new_project.sh` — existing scaffold script
- `/workspaces/horse-sense/horse/scripts/setup_env.sh` — environment bootstrap
- `/workspaces/horse-sense/horse/skills/typescript-setup/SKILL.md` — TypeScript setup skill
- `/workspaces/horse-sense/horse/skills/python-venv/SKILL.md` — Python venv skill
- `/workspaces/horse-sense/horse/templates/horse_config.md` — config template
- `/workspaces/horse-sense/horse/templates/config.example.python.json` — Python config example
- `/workspaces/horse-sense/horse/templates/config.example.typescript.json` — TypeScript config example
- `/workspaces/horse-sense/horse/templates/ci.yml` — five-gate CI template
- `/workspaces/horse-sense/horse/schemas/config.schema.json` — config schema
- `/workspaces/horse-sense/docs/architecture/adr/0002-two-tier-configuration.md` — config architecture
- `/workspaces/horse-sense/docs/architecture/adr/0003-dual-toolchain-support.md` — toolchain decisions
- npm init docs: <https://docs.npmjs.com/cli/v10/commands/npm-init>
- cargo init docs: <https://doc.rust-lang.org/cargo/commands/cargo-init.html>
- create-next-app source: <https://github.com/vercel/next.js/tree/canary/packages/create-next-app>
- Cookiecutter docs: <https://cookiecutter.readthedocs.io/en/stable/>
- GitHub Copilot Workspace announcement (2024): <https://githubnext.com/projects/copilot-workspace>
