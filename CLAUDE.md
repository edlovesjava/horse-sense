# horse-sense

## Overview

**horse-sense** is a project that produces a Claude Code plugin named **horse**. The plugin guides autonomous software development through a structured SDLC methodology, providing agents, skills, and templates to help you build software more systematically.

## Plugin Location

The plugin lives in the `horse/` subdirectory. Project documentation (docs/, this file) stays at the repo root.

```
horse-sense/
├── horse/                     ← THE PLUGIN (--plugin-dir target)
│   ├── .claude-plugin/
│   │   └── plugin.json       ← Plugin manifest (name: "horse")
│   ├── commands/              ← Slash commands (/horse:*) [auto-discovered]
│   ├── agents/                ← Specialized role agents [auto-discovered]
│   ├── skills/                ← Model-invoked SKILL.md guides [auto-discovered]
│   ├── bin/                   ← Executables added to PATH [auto-discovered]
│   ├── rules/                 ← Coding standards (supporting files)
│   ├── templates/             ← Document scaffolds (supporting files)
│   └── scripts/               ← Shell automation (supporting files)
├── docs/                      ← Project docs (not part of plugin)
├── CLAUDE.md                  ← You are here
└── README.md
```

## How to Use This Plugin

### Installation

```bash
claude --plugin-dir ./horse
```

### Starting a New Project

1. Install the plugin (see above).
2. Begin with `/horse:sdlc-start` to kick off the SDLC workflow.
3. Follow the phase-by-phase prompts to move from requirements → design → implementation → testing → deployment.

### Slash Commands

| Command | Description |
|---|---|
| `/horse:plan` | Create or update a project plan |
| `/horse:arch` | Design system architecture |
| `/horse:implement` | Begin a feature implementation |
| `/horse:review` | Perform a code review |
| `/horse:test` | Create and run tests |
| `/horse:deploy` | Prepare deployment artifacts |
| `/horse:sdlc-start` | Run the full SDLC kickoff workflow |
| `/horse:sprint` | Plan and manage a sprint |
| `/horse:retrospective` | Facilitate a sprint retrospective |

### Agent Roles

Agents are auto-discovered by the plugin manager and appear in `/agents`:

- **planner** — requirements, roadmaps, sprint planning
- **architect** — system design, tech selection, ADRs
- **developer** — implementation, refactoring, debugging
- **tester** — test strategy, unit/integration/e2e tests
- **reviewer** — code review, security, performance

### Plugin Component Types

| Directory | Auto-discovered? | Description |
|---|---|---|
| `commands/` | Yes | User-invoked slash commands |
| `agents/` | Yes | Agent personas with YAML frontmatter |
| `skills/` | Yes | Model-invoked capability guides |
| `bin/` | Yes | Executables added to PATH |
| `rules/` | No | Coding standards referenced by agents/skills |
| `templates/` | No | Document scaffolds referenced by commands |
| `scripts/` | No | Shell automation referenced by commands |

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
