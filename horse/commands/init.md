# /horse:init

Initialize a new project or add horse-sense toolchain configuration to an existing project.

## What This Command Does

Runs a structured interview to gather project identity and toolchain decisions, presents a scaffold plan for review, then generates all project files in one step. This bridges the gap between the filesystem scaffold (`new_project.sh`) and the SDLC workflow (`/horse:guide`) by producing both toolchain configuration and SDLC configuration in a single flow.

After initialization, the user can proceed directly into `/horse:guide` for requirements and sprint planning — or work independently with a fully configured project.

### What Gets Created

| Category | Files |
|---|---|
| **Project identity** | `README.md`, `CHANGELOG.md`, `LICENSE` (if selected) |
| **Git** | `.gitignore` (language-appropriate), `git init` if no `.git/` exists |
| **Toolchain config** | `.claude/config.json`, `pyproject.toml` or `package.json` + friends |
| **SDLC config** | `horse.config.md` |
| **Source scaffold** | `src/<pkg>/`, `tests/unit/`, `tests/integration/`, `tests/e2e/` |
| **CI** | `.github/workflows/ci.yml` (five-gate policy from `${CLAUDE_PLUGIN_ROOT}/templates/ci.yml`) |
| **Environment** | `.env.example`, venv or node_modules via `setup_env.sh` |

## Instructions for Claude

When this command is invoked:

### Phase 1: Detection — Check if init has already been run

1. Check for `horse.config.md` and `.claude/config.json` in the project root.
2. If **both exist**: tell the user *"This project is already initialized. horse.config.md and .claude/config.json are present. Would you like to re-run init (this will overwrite existing config), or proceed to `/horse:guide` for SDLC planning?"* Respect their choice.
3. If **one exists but not the other**: note which is missing and offer to fill the gap. Proceed with the interview, pre-filling answers from the existing config file.
4. If **neither exists**: proceed to Phase 2.

### Phase 2: Interview — One question at a time

Ask these questions sequentially. Adapt later questions based on earlier answers. Use the defaults shown in brackets when the user says "default" or presses enter without a specific answer.

**Q1**: *"What is the project name?"*
  - Used for: package name, directory naming, README title
  - Default: name of the current directory

**Q2**: *"Describe the project in one sentence."*
  - Used for: package description, README tagline

**Q3**: *"What is the primary language? [Python / TypeScript]"*
  - Determines the entire toolchain path below

**If Python:**

**Q4a**: *"Which Python version? [3.11 / 3.12 / 3.13]"*
  - Default: `3.11`

**Q4b**: *"Which package manager? [pip / uv / poetry]"*
  - Default: `pip`

**Q4c**: *"What type of project is this? [web service / CLI tool / library / script]"*
  - Influences directory layout hints and framework question

**Q4d**: *"Framework? [fastapi / flask / django / none]"*
  - Default: `none`
  - Skip if Q4c answer is "script" or "library" — default to none

**If TypeScript:**

**Q4a**: *"Which Node.js version? [20 / 22]"*
  - Default: `20`

**Q4b**: *"Which package manager? [npm / pnpm / yarn]"*
  - Default: `npm`

**Q4c**: *"What type of project is this? [web service / CLI tool / library]"*
  - Influences directory layout hints and framework question

**Q4d**: *"Framework? [express / fastify / nextjs / none]"*
  - Default: `none`
  - Skip if Q4c answer is "library" — default to none

**Common questions (both languages):**

**Q5**: *"How would you like to organize requirements — a single document or one file per story? [monolith / per-story]"*
  - Default: `monolith`
  - Writes `requirements_format` in `horse.config.md`

**Q6**: *"Git integration strategy for feature branches? [rebase / merge]"*
  - Default: `rebase`
  - Writes `git_strategy` in `horse.config.md`

**Q7**: *"License? [MIT / Apache-2.0 / GPL-3.0 / proprietary / skip]"*
  - Default: `MIT`
  - `skip` means no LICENSE file is generated
  - `proprietary` generates a simple "All rights reserved" LICENSE

**Q8**: *"Set up a devcontainer for VS Code / Codespaces? [yes / no]"*
  - Default: `no`

### Phase 3: Plan Review — Show before writing

After collecting all answers, present a summary plan. Do **not** write any files yet.

Format the plan as:

```
Here's what I'll set up for project "<name>":

  Language:       Python 3.12 with pip
  Framework:      FastAPI
  Project type:   web service
  Test runner:    pytest + pytest-cov
  Linter:         ruff check
  Formatter:      ruff format
  Type checker:   mypy
  Git strategy:   rebase (linear history)
  Requirements:   one file per story (docs/requirements/stories/)
  License:        MIT
  Devcontainer:   no

  Files to create:
    .gitignore
    pyproject.toml
    requirements.txt
    requirements-dev.txt
    .env.example
    .claude/config.json
    horse.config.md
    README.md
    CHANGELOG.md
    LICENSE
    src/my_api/__init__.py
    tests/__init__.py
    tests/unit/__init__.py
    tests/integration/__init__.py
    tests/e2e/__init__.py
    tests/conftest.py
    .github/workflows/ci.yml
    docs/architecture/adr/
    docs/runbooks/
    docs/retros/

Shall I proceed, or would you like to adjust any answers first?
```

- If the user says **"adjust"** or asks to change something: loop back to the specific question(s) and re-present the plan.
- If the user says **"proceed"** or equivalent: move to Phase 4.

### Phase 4: Scaffold Execution

Execute the scaffold in this order:

#### Step 1: Git initialization

- Check if `.git/` exists. If not, run `git init` and inform the user.

#### Step 2: Generate `.gitignore`

**Python `.gitignore`:**
```
__pycache__/
*.py[cod]
*.so
.venv/
venv/
.env
dist/
build/
*.egg-info/
.mypy_cache/
.ruff_cache/
.pytest_cache/
htmlcov/
coverage.xml
.coverage
```

**TypeScript `.gitignore`:**
```
node_modules/
dist/
build/
.env
coverage/
*.tsbuildinfo
.eslintcache
```

#### Step 3: Generate `.claude/config.json`

Build the config object from interview answers, following `${CLAUDE_PLUGIN_ROOT}/schemas/config.schema.json`. Use the language-appropriate defaults from `${CLAUDE_PLUGIN_ROOT}/templates/config.example.python.json` or `${CLAUDE_PLUGIN_ROOT}/templates/config.example.typescript.json` as the base, overriding with the user's answers.

Key fields to set from interview:
- `language` — from Q3
- `framework` — from Q4d (empty string if "none")
- `packageManager` — from Q4b
- `pythonVersion` or `nodeVersion` — from Q4a
- `dockerBaseImage` — derive from language + version (e.g., `python:3.12-slim`)
- All other fields use language defaults (testRunner, linter, typeChecker, formatter, srcDir, testDir, coverageThreshold)

#### Step 4: Generate `horse.config.md`

Use `${CLAUDE_PLUGIN_ROOT}/templates/horse_config.md` as the template. Set:
- `requirements_format` — from Q5
- `git_strategy` — from Q6

#### Step 5: Generate toolchain config files

**Python path** — delegate to `${CLAUDE_PLUGIN_ROOT}/scripts/new_project.sh`:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/new_project.sh" --language python "<project-name>"
```

Note: The script creates `pyproject.toml`, `requirements.txt`, `requirements-dev.txt`, `.env.example`, source directories, test directories, `conftest.py`, `.github/workflows/ci.yml`, and `CHANGELOG.md`. After it runs, overwrite `.claude/config.json` with the version from Step 3 (since the script generates a basic one).

**TypeScript path** — delegate to `${CLAUDE_PLUGIN_ROOT}/scripts/new_project.sh`:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/new_project.sh" --language typescript "<project-name>"
```

Same post-step: overwrite `.claude/config.json` with the version from Step 3.

**Important**: If the script would overwrite existing files (e.g., `pyproject.toml` already exists), warn the user and ask for confirmation before proceeding.

#### Step 6: Generate README.md

Create a `README.md` with:
- Project name as title
- One-sentence description from Q2
- Sections: Overview, Getting Started, Development (setup, test, lint, format commands), Project Structure, License
- Fill in the development commands based on the language and toolchain config

#### Step 7: Generate LICENSE (if selected)

- **MIT**: standard MIT license text with current year and "Contributors" as copyright holder
- **Apache-2.0**: standard Apache 2.0 license text
- **GPL-3.0**: standard GPL 3.0 license text
- **proprietary**: `All rights reserved. This software is proprietary and confidential.`
- **skip**: do not create a LICENSE file

#### Step 8: Generate devcontainer (if selected)

If the user chose devcontainer, create `.devcontainer/devcontainer.json`:

**Python:**
```json
{
  "name": "<project-name>",
  "image": "mcr.microsoft.com/devcontainers/python:<python-version>",
  "postCreateCommand": "bash scripts/setup_env.sh || pip install -r requirements-dev.txt",
  "customizations": {
    "vscode": {
      "extensions": ["ms-python.python", "charliermarsh.ruff"]
    }
  }
}
```

**TypeScript:**
```json
{
  "name": "<project-name>",
  "image": "mcr.microsoft.com/devcontainers/typescript-node:<node-version>",
  "postCreateCommand": "npm install",
  "customizations": {
    "vscode": {
      "extensions": ["dbaeumer.vscode-eslint", "esbenp.prettier-vscode"]
    }
  }
}
```

#### Step 9: Bootstrap environment

Run `${CLAUDE_PLUGIN_ROOT}/scripts/setup_env.sh` to install dependencies and create the virtual environment (Python) or run `npm install` (TypeScript).

If this fails (e.g., runtime not installed), warn the user but do not treat it as a fatal error — the scaffold is still valid.

#### Step 10: Create documentation directories

Ensure these directories exist (the script may have already created some):
- `docs/architecture/adr/`
- `docs/runbooks/`
- `docs/retros/`
- `docs/requirements/` (and `docs/requirements/stories/` if per-story format)

### Phase 5: Summary and Handoff

After all files are created, present a summary:

```
Project "<name>" initialized successfully!

Created:
  - .claude/config.json (Python 3.12, FastAPI, pytest, ruff)
  - horse.config.md (per-story requirements, rebase strategy)
  - pyproject.toml + requirements files
  - .github/workflows/ci.yml (five-gate policy)
  - README.md, CHANGELOG.md, LICENSE (MIT)
  - Source scaffold: src/<pkg>/, tests/unit/, tests/integration/, tests/e2e/
  - .gitignore
  - Environment bootstrapped (venv created, dependencies installed)

Next steps:
  1. Run `/horse:guide` to start the SDLC workflow (requirements → architecture → sprint planning)
  2. Or jump straight to coding — your toolchain is ready

Tip: `/horse:guide` will detect that init has already run and skip to requirements gathering.
```

## Idempotency

- **Never overwrite existing files without asking.** Before writing any file, check if it already exists. If it does, ask the user: *"<file> already exists. Overwrite, skip, or show diff?"*
- The command can be re-run safely on a partially initialized project to fill gaps.
- `setup_env.sh` is already idempotent.

## Integration with `/horse:guide`

The guide command (Step 1 of its instructions) should check for `horse.config.md` and `.claude/config.json`:
- If both exist → skip to requirements gathering (guide Step 2)
- If missing → suggest running `/horse:init` first, or offer to run it inline

This keeps the two commands complementary: init owns the scaffold, guide owns the SDLC planning.
