---
id: US-084
title: Project init command
status: draft
priority: Must Have
story_points: 8
section: "3.1 Plugin Installation & Configuration"
---

# US-084 — Project init command

> As a **developer starting a new project**, I want **a `/horse:init` command that interviews me about my project and scaffolds everything in one step** so that **I don't have to discover and coordinate separate scripts and commands to get a working project**.

## Context

The plugin currently splits project initialization across two disconnected paths: `/horse:guide` (SDLC planning docs) and `new_project.sh` (filesystem scaffold). Neither calls the other. A user following `/horse:guide` ends up without `.claude/config.json`, `.gitignore`, toolchain config, or a git repo — all of which skills need to function. A user running the script gets no planning docs.

SPIKE-003 (`docs/spikes/SPIKE-003-project-init-command.md`) documents the full gap analysis and recommends a dedicated `/horse:init` command integrated into `/horse:guide` as step 0.

### Key gaps addressed

- `.gitignore` not generated
- `git init` not offered
- `README.md` not generated
- `LICENSE` not generated
- Python/Node version hardcoded, never asked
- Package manager hardcoded (no uv/poetry/pnpm/yarn)
- Framework field in config schema but never populated
- Rich five-gate CI template exists but unused in init path
- `.env.example` missing for TypeScript
- devcontainer not offered
- `horse.config.md` and `.claude/config.json` written by different tools

## Acceptance Criteria

```gherkin
Given horse-sense is installed and the user runs /horse:init
When  the command starts
Then  it conducts an 8-question interview (one at a time):
      | # | Question                        | Writes to                    |
      | 1 | Project name                    | package.json / pyproject.toml |
      | 2 | One-sentence description        | manifest + README            |
      | 3 | Primary language (Python / TS)  | .claude/config.json          |
      | 4 | Version, package mgr, framework | .claude/config.json + manifest |
      | 5 | Requirements format             | horse.config.md              |
      | 6 | Git strategy (rebase / merge)   | horse.config.md              |
      | 7 | License                         | LICENSE                      |
      | 8 | Devcontainer (yes / no)         | .devcontainer/               |

Given the interview is complete
When  the user reviews the summary plan
Then  the command presents all files to be created and decisions made
And   waits for confirmation before writing any files

Given the user confirms
When  the scaffold is written
Then  all listed files are created
And   .gitignore is language-appropriate
And   .github/workflows/ci.yml uses the five-gate template
And   setup_env.sh is run to bootstrap the environment
And   git init is offered if .git/ does not exist

Given /horse:guide is run on a project where /horse:init has already completed
When  the guide detects horse.config.md AND .claude/config.json
Then  it skips the init phase and proceeds to requirements planning
```

## Technical Notes

- Command file: `horse/commands/init.md`
- Delegates to `new_project.sh` (updated with `--python-version`, `--framework`, `--package-manager` flags) for file generation
- Delegates to `setup_env.sh` for environment bootstrap
- `/horse:guide` updated to invoke init as step 0 when config files are absent
- `new_project.sh` retained as non-interactive scripted path for automation/CI

## Dependencies

- US-003 (Project scaffolding) — this story supersedes and extends US-003
- SPIKE-003 — research spike justifying the design

## Open Questions

- Should uv be offered as the default Python package manager (displacing pip)?
- What devcontainer base images and features to include?
- How to handle multi-language projects (Python backend + TypeScript frontend)?
