# horse-sense — Claude Code Plugin

## Overview

**horse-sense** is a Claude Code plugin that guides autonomous software development through a structured SDLC (Software Development Life Cycle) methodology. It provides agents, skills, rules, and templates to help you build software more systematically and with less manual intervention.

## Plugin Structure

```
horse-sense/
├── CLAUDE.md              ← You are here
├── agents/                ← Specialized role agents
├── skills/                ← Reusable capability guides
├── rules/                 ← Coding and workflow standards
├── templates/             ← Document templates
└── scripts/               ← Bash helper scripts
```

## How to Use This Plugin

### Starting a New Project

1. Copy this plugin into your project's root directory (or reference it via Claude's memory).
2. Begin with `/user:sdlc-start` to kick off the SDLC workflow.
3. Follow the phase-by-phase prompts to move from requirements → design → implementation → testing → deployment.

### Custom Slash Commands

| Command | Description |
|---|---|
| `/user:plan` | Create or update a project plan |
| `/user:arch` | Design system architecture |
| `/user:implement` | Begin a feature implementation |
| `/user:review` | Perform a code review |
| `/user:test` | Create and run tests |
| `/user:deploy` | Prepare deployment artifacts |
| `/user:sdlc-start` | Run the full SDLC kickoff workflow |
| `/user:sprint` | Plan and manage a sprint |
| `/user:retrospective` | Facilitate a sprint retrospective |

### Agent Roles

Switch context to a specialized agent when needed:

- **Planner** (`agents/planner.md`) — requirements, roadmaps, sprint planning
- **Architect** (`agents/architect.md`) — system design, tech selection, ADRs
- **Developer** (`agents/developer.md`) — implementation, refactoring, debugging
- **Tester** (`agents/tester.md`) — test strategy, unit/integration/e2e tests
- **Reviewer** (`agents/reviewer.md`) — code review, security, performance

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
3. `skills/requirements_analysis/README.md` — capture requirements
4. `skills/architecture_design/README.md` — design the system
5. `skills/implementation/README.md` — write the code
6. `skills/testing/README.md` — validate the code
7. `skills/deployment/README.md` — ship it
