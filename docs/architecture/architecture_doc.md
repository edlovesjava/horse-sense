# Architecture Document: horse-sense

> **Document version**: 1.0  
> **Created**: 2026-04-03  
> **Last updated**: 2026-04-03  
> **Owner**: Ed Wentworth  
> **Status**: Draft

---

## 1. Context & Goals

### System Purpose

**horse-sense** is a Claude Code plugin that guides autonomous software development through a structured SDLC methodology. It extends Claude Code with specialized agents, reusable skills, configurable rules, and document templates — turning the AI assistant into a disciplined development partner.

The plugin is distributed via the official Claude Code plugin system (`.claude-plugin/plugin.json` manifest) and installed into target projects. Once installed, it provides slash commands, agent personas, and contextual rules that adapt to the host project's language, framework, and conventions through a configuration file.

### Target Users

- Individual developers and small teams using Claude Code for day-to-day development
- Teams wanting repeatable SDLC process without heavy tooling

### Quality Attribute Priorities

| # | Quality Attribute | Target |
|---|---|---|
| 1 | Extensibility | New skills, rules, and agents added without changing core structure |
| 2 | Adaptability | Works across Python and TypeScript projects via configuration |
| 3 | Simplicity | No build step, no runtime dependencies — plain Markdown + shell scripts |
| 4 | Discoverability | Users find the right skill/agent through clear naming and `/user:sdlc-start` |

### Constraints

- Must conform to official Claude Code plugin spec (`.claude-plugin/plugin.json`)
- No runtime dependencies beyond what Claude Code provides (Bash, standard CLI tools)
- Skills must work for both Python (venv, pytest, ruff) and TypeScript (npm, vitest/jest, eslint) projects
- Personal / small-team distribution — Git clone or simple marketplace install

---

## 2. System Architecture

### Architecture Style

**Static plugin with layered content and process orchestration** — horse-sense is not a running service. It is a structured collection of Markdown documents, shell scripts, configuration, and process definitions that Claude Code loads at session start. The architecture has five layers:

- **Process definitions** specify workflows — step sequences with gates, loops, branches, and human decision points
- **Orchestrator agents** execute process definitions, dispatching worker agents and enforcing gates
- **Worker agents** perform focused tasks from a role perspective, composing skills
- **Skills** are the workhorse — each is a self-contained guide (Markdown) that may include reference documents and executable scripts
- **Rules** are glob-matched context injected based on file type or directory, tailoring skill behavior to specific languages or standards
- **Configuration** adapts skills to a specific project (language, framework, test runner, paths)

### High-Level Component Diagram

```mermaid
graph TD
    subgraph "Claude Code Runtime"
        CC[Claude Code CLI]
        PM[Plugin Manager]
    end

    subgraph "horse-sense Plugin"
        Manifest[".claude-plugin/plugin.json"]
        Config[".claude/config.json<br/>(project-level)"]

        subgraph "Process Layer"
            Processes["processes/<br/>Workflow definitions<br/>(gates, steps, loops, branches)"]
        end

        subgraph "Orchestration Layer"
            Orchestrators["agents/orchestrators/<br/>SDLC Orchestrator<br/>Sprint Orchestrator<br/>Monitor"]
        end

        subgraph "Worker Agent Layer"
            Workers["agents/workers/<br/>Planner · Architect · Developer<br/>Tester · Reviewer"]
        end

        subgraph "Skills Layer"
            SlashCmds["commands/<br/>User-invoked slash commands"]
            AgentSkills["skills/<br/>Model-invoked SKILL.md"]
        end

        subgraph "Rules Layer"
            Rules["rules/<br/>Glob-matched context<br/>(code_quality, testing,<br/>git_workflow, docs)"]
        end

        subgraph "Resources"
            Templates["templates/<br/>Document scaffolds"]
            Scripts["scripts/ + bin/<br/>Shell automation"]
        end
    end

    subgraph "Host Project"
        ProjectConfig[".claude/config.json"]
        ProjectCode["src/ or lib/"]
        ProjectTests["tests/"]
    end

    subgraph "CI/CD"
        GHA["GitHub Actions<br/>Lint · Test · Review"]
    end

    CC --> PM
    PM --> Manifest
    PM --> SlashCmds
    PM --> AgentSkills
    PM --> Orchestrators
    PM --> Workers
    PM --> Rules

    Orchestrators --> Processes
    Orchestrators --> Workers
    Orchestrators -->|"human checkpoints"| CC
    Workers --> AgentSkills
    SlashCmds --> AgentSkills
    AgentSkills --> Rules
    AgentSkills --> Templates
    AgentSkills --> Scripts
    AgentSkills --> Config

    ProjectConfig -.-> Config
    ProjectCode -.-> Rules
    ProjectTests -.-> Rules
    ProjectCode --> GHA
```

### Component Descriptions

| Component | Responsibility | Format |
|---|---|---|
| **plugin.json** | Plugin identity, version, author — loaded by Claude Code plugin manager | JSON manifest |
| **processes/** | Workflow definitions with steps, gates, loops, branches, and human checkpoints | Markdown |
| **agents/orchestrators/** | Orchestrator agents that execute process definitions and dispatch workers | Markdown |
| **agents/workers/** | Worker agents — role-based personas that compose skills with focused context | Markdown |
| **commands/** | User-invoked slash commands (`/horse-sense:plan`, `/horse-sense:arch`, etc.) | Markdown files |
| **skills/** | Model-invoked capabilities with `SKILL.md` + optional reference docs and scripts | Markdown + shell |
| **rules/** | Glob-matched context files injected when editing specific file types/directories | Markdown |
| **templates/** | Scaffolds for requirements, architecture, sprint plans, project plans | Markdown |
| **scripts/** | Shell automation (env setup, linting, testing, scaffolding) | Bash |
| **bin/** | Executable scripts added to PATH by Claude Code | Bash/Python/Node |
| **.claude/config.json** | Project-specific configuration consumed by skills | JSON |

---

## 3. Data Architecture

### Configuration Model

horse-sense uses a two-tier configuration model:

**Tier 1: Plugin manifest** (`.claude-plugin/plugin.json`) — static, ships with the plugin:

```json
{
  "name": "horse-sense",
  "description": "Structured SDLC plugin for Claude Code",
  "version": "1.0.0",
  "author": { "name": "Ed Wentworth" }
}
```

**Tier 2: Project config** (`.claude/config.json`) — per-project, created by users:

```json
{
  "language": "python",
  "framework": "fastapi",
  "testRunner": "pytest",
  "linter": "ruff",
  "typeChecker": "mypy",
  "srcDir": "src",
  "testDir": "tests",
  "packageManager": "pip",
  "pythonVersion": "3.11",
  "coverageThreshold": 80,
  "branchingStrategy": "github-flow"
}
```

TypeScript project example:

```json
{
  "language": "typescript",
  "framework": "express",
  "testRunner": "vitest",
  "linter": "eslint",
  "typeChecker": "tsc",
  "srcDir": "src",
  "testDir": "tests",
  "packageManager": "npm",
  "nodeVersion": "20",
  "coverageThreshold": 80,
  "branchingStrategy": "github-flow"
}
```

Skills read `config.json` to adapt their guidance (e.g., which test command to run, which linter rules to reference).

### Content Relationships

```mermaid
erDiagram
    PLUGIN_JSON {
        string name
        string version
        string description
    }
    CONFIG_JSON {
        string language
        string framework
        string testRunner
        string linter
    }
    PROCESS {
        string name
        string description
        string trigger
        list steps
    }
    PROCESS_STEP {
        string name
        string agent
        list skills
        string entry_gate
        string completion_criteria
        string fail_condition
        string flow_control "sequence, loop, branch, recurse"
        boolean human_checkpoint
    }
    ORCHESTRATOR {
        string name
        string type "sdlc, sprint, monitor"
    }
    WORKER {
        string role
        list skills_used
    }
    SKILL {
        string name
        string description
        string type "slash-command or model-invoked"
    }
    RULE {
        list globs
        string scope
    }
    TEMPLATE {
        string name
        string purpose
    }
    SCRIPT {
        string name
        string purpose
    }

    PLUGIN_JSON ||--o{ SKILL : "namespaces"
    PROCESS ||--|{ PROCESS_STEP : "defines"
    ORCHESTRATOR ||--|{ PROCESS : "executes"
    ORCHESTRATOR ||--|{ WORKER : "dispatches"
    PROCESS_STEP ||--|| WORKER : "assigns"
    PROCESS_STEP ||--|{ SKILL : "uses"
    WORKER ||--|{ SKILL : "composes"
    SKILL ||--o{ RULE : "contextualized by"
    SKILL ||--o{ TEMPLATE : "generates from"
    SKILL ||--o{ SCRIPT : "executes"
    SKILL ||--o| CONFIG_JSON : "reads"
    RULE ||--o| CONFIG_JSON : "adapts via"
```

---

## 4. Plugin Directory Layout

### Official Plugin Spec Mapping

```
horse-sense/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest (name, version, author)
├── commands/                     # User-invoked slash commands
│   ├── sdlc-start.md           # /horse-sense:sdlc-start
│   ├── plan.md                  # /horse-sense:plan
│   ├── arch.md                  # /horse-sense:arch
│   ├── implement.md             # /horse-sense:implement
│   ├── review.md                # /horse-sense:review
│   ├── test.md                  # /horse-sense:test
│   ├── deploy.md                # /horse-sense:deploy
│   ├── sprint.md                # /horse-sense:sprint
│   └── retrospective.md        # /horse-sense:retrospective
├── skills/                       # Model-invoked agent skills
│   ├── requirements-analysis/
│   │   └── SKILL.md
│   ├── architecture-design/
│   │   └── SKILL.md
│   ├── implementation/
│   │   └── SKILL.md
│   ├── testing/
│   │   └── SKILL.md
│   ├── deployment/
│   │   └── SKILL.md
│   └── python-venv/
│       └── SKILL.md
├── agents/                       # Agent personas (workers + orchestrators)
│   ├── workers/
│   │   ├── planner.md
│   │   ├── architect.md
│   │   ├── developer.md
│   │   ├── tester.md
│   │   └── reviewer.md
│   └── orchestrators/
│       ├── sdlc.md               # End-to-end SDLC orchestrator
│       ├── sprint.md             # Sprint-level orchestrator
│       └── monitor.md            # Quality monitor for loops
├── processes/                    # Workflow definitions
│   ├── feature_delivery.md       # Full feature lifecycle
│   ├── sprint_execution.md       # Sprint iteration workflow
│   ├── bug_fix.md                # Bug triage → fix → verify
│   └── code_review.md            # Review → feedback → resolve
├── rules/                        # Glob-matched contextual rules
│   ├── code_quality.md
│   ├── testing.md
│   ├── git_workflow.md
│   └── documentation.md
├── templates/                    # Document scaffolds
│   ├── requirements_doc.md
│   ├── architecture_doc.md
│   ├── project_plan.md
│   └── sprint_plan.md
├── scripts/                      # Shell automation
│   ├── setup_env.sh
│   ├── run_tests.sh
│   ├── lint.sh
│   └── new_project.sh
├── bin/                          # Executables added to PATH
│   └── hs                       # CLI helper (optional)
├── CLAUDE.md                     # Plugin documentation
├── README.md                     # Repository README
└── LICENSE
```

### Key Structural Changes from Current Layout

| Current | New | Reason |
|---|---|---|
| `.claude/settings.json` | `.claude-plugin/plugin.json` | Official plugin manifest format |
| `.claude/commands/*.md` | `commands/*.md` | Plugin spec puts commands at root |
| `skills/*/README.md` | `skills/*/SKILL.md` | Plugin spec requires SKILL.md with frontmatter |
| `agents/*.md` (flat) | `agents/workers/*.md` + `agents/orchestrators/*.md` | Separate worker and orchestrator roles |
| (none) | `processes/*.md` | Workflow definitions for orchestrator agents |
| (none) | `bin/` | Plugin spec supports adding executables to PATH |
| (none) | `.claude/config.json` | Project-level configuration for skill adaptation |

---

## 5. Process & Orchestration Architecture

### Process Definition Format

Process documents live in `processes/` and define workflows as structured Markdown with frontmatter:

```markdown
---
name: process-name
description: What this process accomplishes
trigger: /horse-sense:command  # optional slash command trigger
---
```

Each process document contains:

| Element | Purpose | Example |
|---|---|---|
| **Entry gate** | Preconditions (checklist) that must be satisfied before the process starts | `- [ ] requirements_doc.md exists` |
| **Steps** | Ordered sequence of work units | `### Step 1: Requirements` |
| **Agent assignment** | Which worker agent executes the step | `- **Agent**: planner` |
| **Skills & tools** | Which skills the step uses | `- **Skills**: requirements-analysis` |
| **Monitor** | Optional monitor agent for loops | `- **Monitor**: monitor` |
| **Completion criteria** | How to know the step succeeded | `- **Completion**: all tests pass` |
| **Fail conditions** | When to abort or escalate | `- **Fail**: 5 iterations without convergence` |
| **Human checkpoints** | Points requiring human decision | `- **Gate**: HUMAN APPROVAL` |
| **Flow control** | Loops, branches, sub-process references | `- **Loop**: write → test → fix` |

### Flow Control Primitives

| Primitive | Syntax in Process Doc | Behavior |
|---|---|---|
| **Sequence** | Steps numbered in order | Execute step N, then step N+1 |
| **Loop** | `- **Loop**: step_a → step_b → step_c` | Repeat until `- **Loop exit**: condition` |
| **Branch** | `- **Branch**: If condition → GOTO Step N` | Conditional jump to another step |
| **Recurse** | `- **Sub-process**: processes/other.md` | Load and execute a child process, return when done |
| **Human gate** | `- **Gate**: HUMAN APPROVAL` | Pause, present summary, wait for human response |
| **Fail/escalate** | `- **Fail**: condition → HUMAN DECISION` | Halt step, present options to human |

### Orchestrator Execution Model

```mermaid
stateDiagram-v2
    [*] --> LoadProcess: Orchestrator activated
    LoadProcess --> CheckEntryGate: Parse process definition

    CheckEntryGate --> Blocked: Gate NOT satisfied
    Blocked --> CheckEntryGate: Prerequisite resolved
    CheckEntryGate --> ExecuteStep: Gate satisfied

    ExecuteStep --> DispatchWorker: Assign agent + skills
    DispatchWorker --> WorkerExecuting: Worker performs step

    WorkerExecuting --> MonitorCheck: Monitor observes (if assigned)
    MonitorCheck --> WorkerExecuting: Monitor provides guidance
    MonitorCheck --> EvalCompletion: Monitor signals done

    WorkerExecuting --> EvalCompletion: Step work finished

    EvalCompletion --> NextStep: Completion criteria met
    EvalCompletion --> LoopBack: Loop condition (iterate again)
    EvalCompletion --> BranchJump: Branch condition (goto other step)
    EvalCompletion --> FailPath: Fail condition reached

    LoopBack --> DispatchWorker: Re-dispatch worker
    BranchJump --> ExecuteStep: Jump to target step

    NextStep --> HumanGate: Human checkpoint?
    HumanGate --> WaitHuman: Yes — pause for decision
    WaitHuman --> ExecuteStep: Human approves → next step
    WaitHuman --> BranchJump: Human rejects → route back
    HumanGate --> ExecuteStep: No checkpoint → next step

    NextStep --> ProcessComplete: No more steps
    FailPath --> WaitHuman: Escalate to human

    ProcessComplete --> [*]: Report summary
```

### Agent Interaction Pattern

```
┌─────────────────────────────────────────────────────────┐
│ ORCHESTRATOR (e.g., SDLC Orchestrator)                  │
│                                                         │
│  1. Load process definition                             │
│  2. Check entry gate                                    │
│  3. For each step:                                      │
│     a. Evaluate entry conditions                        │
│     b. Dispatch worker agent with skills + context      │
│     c. (Optional) Activate monitor on loops             │
│     d. Evaluate completion / fail / loop / branch       │
│     e. If HUMAN GATE → pause, present, wait             │
│  4. Report execution summary                            │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Planner  │  │Developer │  │ Tester   │  ...workers  │
│  │ (worker) │  │(worker)  │  │ (worker) │              │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘             │
│       │              │              │                    │
│       ▼              ▼              ▼                    │
│    Skills         Skills         Skills                  │
│    + Rules        + Rules        + Rules                 │
│    + Config       + Config       + Config                │
│                                                         │
│  ┌──────────┐                                           │
│  │ Monitor  │ ← observes loops, intervenes if needed    │
│  │ (orch.)  │                                           │
│  └──────────┘                                           │
└─────────────────────────────────────────────────────────┘
```

### Shipped Process Definitions

| Process | Trigger | Steps | Use Case |
|---|---|---|---|
| `feature_delivery.md` | `/horse-sense:sdlc-start` | Requirements → Architecture → Implementation → Testing → Review → Deploy | Full feature lifecycle |
| `sprint_execution.md` | `/horse-sense:sprint` | For each story: Implement → Test → Review | Sprint iteration |
| `bug_fix.md` | (manual) | Reproduce → Root cause → Fix → Regression test → Review | Bug triage and fix |
| `code_review.md` | `/horse-sense:review` | Review → Feedback → Author fixes → Re-review | Review cycle |

---

## 6. Skill Architecture

### Skill Types

**Slash-command skills** (`commands/`) — explicitly invoked by users:
- Trigger: user types `/horse-sense:<command>`
- Content: Markdown instructions for Claude, with `$ARGUMENTS` placeholder
- Example: `/horse-sense:implement add user authentication`

**Model-invoked skills** (`skills/`) — automatically triggered by Claude based on context:
- Trigger: Claude recognizes the need based on SKILL.md `description` field
- Content: SKILL.md with YAML frontmatter (`name`, `description`) + guide body
- May include sibling reference docs and scripts

### Skill ↔ Config Integration

Skills read `.claude/config.json` to adapt behavior. Example pattern inside a SKILL.md:

```markdown
## Configuration

Read `.claude/config.json` for project settings. Adapt commands based on:
- `language`: "python" → use pytest, ruff; "typescript" → use vitest, eslint
- `testRunner`: determines test execution command
- `srcDir` / `testDir`: determines file paths
```

### Skill ↔ Rule Interaction

Rules provide ambient context. When a user edits a `.py` file, `rules/code_quality.md` (glob: `**/*.py`) injects Python-specific standards. When the `implementation` skill is active, it benefits from this context without explicitly loading it.

---

## 7. Dual Toolchain Support

### Detection Strategy

Scripts in `scripts/` and `bin/` detect the project language from `.claude/config.json` or by file presence:

| Signal | Language |
|---|---|
| `pyproject.toml` or `requirements.txt` | Python |
| `package.json` or `tsconfig.json` | TypeScript |
| `.claude/config.json` → `language` | Explicit override |

### Toolchain Matrix

| Concern | Python | TypeScript |
|---|---|---|
| Package manager | pip + venv | npm / pnpm |
| Linter | ruff | eslint |
| Formatter | ruff format | prettier |
| Type checker | mypy | tsc |
| Test runner | pytest | vitest / jest |
| Coverage | pytest-cov | c8 / istanbul |
| Security audit | pip audit | npm audit |
| Build | setuptools / hatch | tsc / esbuild |

Skills reference this matrix via config, not hardcoded assumptions.

---

## 8. CI/CD & GitHub Actions

### Review Workflow

```mermaid
graph LR
    PR[Pull Request] --> Lint[Lint & Format Check]
    PR --> Test[Run Tests + Coverage]
    PR --> TypeCheck[Type Check]
    PR --> Audit[Security Audit]
    Lint --> Gate{All Pass?}
    Test --> Gate
    TypeCheck --> Gate
    Audit --> Gate
    Gate -->|Yes| Review[Human / AI Review]
    Gate -->|No| Block[Block Merge]
    Review --> Merge[Squash & Merge]
```

### Shipped Workflow Template

The plugin ships a GitHub Actions workflow template in `templates/ci.yml` that projects can copy to `.github/workflows/`. It supports both Python and TypeScript via a matrix strategy keyed on `.claude/config.json`.

---

## 9. Architecture Decision Records

| ADR | Title | Status |
|---|---|---|
| [ADR-0001](../docs/adr/0001-adopt-official-plugin-format.md) | Adopt official Claude Code plugin format | Accepted |
| [ADR-0002](../docs/adr/0002-two-tier-configuration.md) | Two-tier configuration model (plugin.json + config.json) | Accepted |
| [ADR-0003](../docs/adr/0003-dual-toolchain-support.md) | Dual Python/TypeScript toolchain support via config | Accepted |
| [ADR-0004](../docs/adr/0004-process-orchestration-model.md) | Process orchestration — workers, orchestrators, and monitors | Accepted |

---

## 10. Open Questions & Risks

| # | Question / Risk | Owner | Resolution |
|---|---|---|---|
| 1 | Will `rules/` and `templates/` dirs be recognized by plugin manager or need workaround? | Ed | ⬜ Open — test with `claude --plugin-dir` |
| 2 | SKILL.md frontmatter schema — what fields beyond `name` and `description` are supported? | Ed | ⬜ Open — verify against latest plugin spec |
| 3 | Can hooks/ be used to auto-inject rules based on file globs, or is that handled by settings? | Ed | ⬜ Open — test hook event model |
| 4 | Should `bin/hs` CLI helper exist or is it unnecessary overhead for personal use? | Ed | ⬜ Open — defer until needed |
| 5 | How do orchestrators dispatch workers — Agent tool, subagents, or context switching? | Ed | ⬜ Open — test with Claude Code |
| 6 | Can monitor agents run concurrently with workers or only between iterations? | Ed | ⬜ Open — depends on Claude Code concurrency model |
| 7 | Should process definitions support parameters (e.g., max loop iterations configurable per project)? | Ed | ⬜ Open — start without, add if needed |
