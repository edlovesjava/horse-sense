# horse-sense — Claude Code Plugin

## Overview

**horse-sense** is a Claude Code plugin that guides autonomous software development through a structured SDLC (Software Development Life Cycle) methodology. It provides agents, skills, rules, and templates to help you build software more systematically and with less manual intervention.

## Plugin Structure

```
horse-sense/
├── .claude-plugin/
│   └── plugin.json            ← Plugin manifest
├── CLAUDE.md                  ← You are here
├── commands/                  ← Slash commands (/horse-sense:*)
├── agents/
│   └── workers/               ← Specialized role agents
├── skills/                    ← Reusable capability guides (SKILL.md)
├── rules/                     ← Coding and workflow standards
├── templates/                 ← Document templates
├── scripts/                   ← Bash helper scripts
└── bin/                       ← Executables (added to PATH)
```

## How to Use This Plugin

### Installation

```bash
claude --plugin-dir ./horse-sense
```

### Starting a New Project

1. Install the plugin (see above).
2. Begin with `/horse-sense:sdlc-start` to kick off the SDLC workflow.
3. Follow the phase-by-phase prompts to move from requirements → design → implementation → testing → deployment.

### Slash Commands

| Command | Description |
|---|---|
| `/horse-sense:plan` | Create or update a project plan |
| `/horse-sense:arch` | Design system architecture |
| `/horse-sense:implement` | Begin a feature implementation |
| `/horse-sense:review` | Perform a code review |
| `/horse-sense:test` | Create and run tests |
| `/horse-sense:deploy` | Prepare deployment artifacts |
| `/horse-sense:sdlc-start` | Run the full SDLC kickoff workflow |
| `/horse-sense:sprint` | Plan and manage a sprint |
| `/horse-sense:retrospective` | Facilitate a sprint retrospective |

### Agent Roles

Switch context to a specialized agent when needed:

- **Planner** (`agents/workers/planner.md`) — requirements, roadmaps, sprint planning
- **Architect** (`agents/workers/architect.md`) — system design, tech selection, ADRs
- **Developer** (`agents/workers/developer.md`) — implementation, refactoring, debugging
- **Tester** (`agents/workers/tester.md`) — test strategy, unit/integration/e2e tests
- **Reviewer** (`agents/workers/reviewer.md`) — code review, security, performance

## Environment Assumptions

- Python ≥ 3.11 with `venv` for isolated environments
- Git for version control
- Bash-compatible shell (Linux / macOS / WSL)
- Standard CLI tools: `curl`, `jq`, `make`, `docker` (optional)

## Core Principles

1. **Document first** — write requirements and design docs before code.
2. **Small iterations** — prefer short cycles with clear, testable outcomes.
3. **Automate everything repeatable** — scripts live in `scripts/`, Makefiles welcomed.
4. **Test as you build** — no feature is done without tests.
5. **Keep humans in the loop** — autonomous means assisted, not unattended.

## Quick-Start Checklist

- [ ] Run `scripts/setup_env.sh` to bootstrap the Python venv and dependencies
- [ ] Fill out `templates/requirements_doc.md` for your project
- [ ] Fill out `templates/architecture_doc.md` for system design
- [ ] Create your first sprint using `templates/sprint_plan.md`
- [ ] Follow the rules in `rules/` for consistent code quality

## Reading Order for New Projects

1. `rules/git_workflow.md` — branching strategy and commit conventions
2. `rules/documentation.md` — documentation standards
3. `skills/requirements_analysis/SKILL.md` — capture requirements
4. `skills/architecture_design/SKILL.md` — design the system
5. `skills/implementation/SKILL.md` — write the code
6. `skills/testing/SKILL.md` — validate the code
7. `skills/deployment/SKILL.md` — ship it
