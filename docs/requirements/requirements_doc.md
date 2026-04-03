# Requirements Document: horse-sense — Claude Code SDLC Plugin

> **Document version**: 1.0  
> **Created**: 2026-04-03  
> **Last updated**: 2026-04-03  
> **Owner**: Ed Wentworth  
> **Status**: Draft

---

## 1. Background & Motivation

Claude Code is a powerful autonomous coding assistant, but without structured guidance it produces inconsistent results — skipping tests, ignoring project conventions, generating code that doesn't fit the existing architecture, or losing context across long sessions.

**horse-sense** solves this by packaging an opinionated SDLC methodology as a Claude Code plugin. Once installed, it gives Claude:

- **Skills** that define *how* to do things (write tests, design architecture, implement features) with step-by-step guidance that adapts to the project's language and toolchain
- **Agents** that define *who* is doing the work — persistent role personas (planner, architect, developer, tester, reviewer) that compose skills from a focused perspective
- **Rules** that define *what standards apply* — glob-matched context injected when editing specific file types or directories, ensuring language-specific conventions are followed
- **Configuration** that defines *what this project looks like* — project variables (language, framework, test runner, paths) that skills read to tailor their guidance

The goal: install the plugin, configure it for a project, and use it to develop significant, high-quality, deployable, testable software — not just snippets, but real systems.

---

## 2. Stakeholders & User Roles

| Role | Description | Key Goals |
|---|---|---|
| **Solo Developer** | Individual using Claude Code for personal or professional projects | Produce high-quality code faster with consistent process; avoid rework from skipped steps |
| **Small Team Lead** | Developer leading a 2-5 person team using Claude Code | Enforce consistent standards across the team; ensure AI-assisted code meets review bar |
| **Plugin Author** | Developer extending horse-sense with new skills, rules, or agents | Add capabilities without understanding the full system; clear extension points |

---

## 3. Functional Requirements

### 3.1 Plugin Installation & Configuration

#### User Story: US-001 — Install plugin
> As a **developer**, I want to **install horse-sense as a Claude Code plugin** so that **its skills, agents, and rules are available in my Claude Code sessions**.

**Acceptance Criteria:**
```gherkin
Given I have Claude Code installed
When  I install horse-sense via `claude --plugin-dir ./horse-sense` or plugin marketplace
Then  all slash commands are available as /horse-sense:<command>
And   agents are listed in the agent selector
And   rules are active based on glob patterns
And   CLAUDE.md instructions are loaded into context
```

**Priority**: Must Have  
**Story Points**: 3

---

#### User Story: US-002 — Configure for a project
> As a **developer**, I want to **create a `.claude/config.json` with my project's language, framework, and tooling** so that **skills adapt their guidance to my specific project**.

**Acceptance Criteria:**
```gherkin
Given horse-sense is installed
When  I create .claude/config.json with {"language": "python", "testRunner": "pytest", ...}
Then  skills reference pytest commands instead of generic test commands
And   implementation skills use Python conventions (venv, ruff, mypy)
And   rules for **/*.py are active

Given horse-sense is installed
When  I create .claude/config.json with {"language": "typescript", "testRunner": "vitest", ...}
Then  skills reference vitest commands instead of generic test commands
And   implementation skills use TypeScript conventions (npm, eslint, tsc)
And   rules for **/*.ts are active

Given horse-sense is installed and no .claude/config.json exists
When  I invoke a skill
Then  it auto-detects language from pyproject.toml or package.json presence
And   uses sensible defaults for all config values
```

**Priority**: Must Have  
**Story Points**: 5

---

#### User Story: US-003 — Project scaffolding
> As a **developer starting a new project**, I want to **run a scaffolding command** so that **the project structure, config, CI, and templates are set up correctly from the start**.

**Acceptance Criteria:**
```gherkin
Given horse-sense is installed
When  I run /horse-sense:sdlc-start with a project name
Then  project directories are created (src/, tests/, docs/adr/)
And   .claude/config.json is generated with prompted values
And   CI workflow template is placed in .github/workflows/
And   CLAUDE.md is initialized with project-specific instructions
And   requirements and architecture templates are copied to docs/
```

**Priority**: Must Have  
**Story Points**: 5

---

### 3.2 Skills — Primary Behavior Definition

#### User Story: US-010 — Skill as step-by-step guide
> As a **developer**, I want **each skill to be a complete, self-contained guide** so that **Claude follows a consistent, high-quality process for each activity**.

**Acceptance Criteria:**
```gherkin
Given I invoke a skill (e.g., /horse-sense:implement)
When  Claude executes the skill
Then  it follows the steps defined in the skill's Markdown guide
And   it reads .claude/config.json to adapt commands and paths
And   it references relevant rules for the files being modified
And   it produces output consistent with the skill's defined structure
```

**Priority**: Must Have  
**Story Points**: 3  
**Notes**: Skills are the workhorse of the system. They can be: (a) a Markdown guide only, (b) a guide with reference documents, or (c) a guide with executable scripts.

---

#### User Story: US-011 — Slash-command skills (user-invoked)
> As a **developer**, I want to **invoke skills via slash commands** so that **I can explicitly trigger a specific SDLC activity**.

**Acceptance Criteria:**
```gherkin
Given horse-sense is installed
When  I type /horse-sense:plan
Then  Claude enters planning mode following the plan skill guide
And   $ARGUMENTS are passed through to the skill

Given horse-sense is installed
When  I type /horse-sense:implement add user authentication
Then  Claude follows the implementation skill guide
And   "add user authentication" is available as $ARGUMENTS context
```

**Required slash commands:**
- `/horse-sense:sdlc-start` — full SDLC kickoff workflow
- `/horse-sense:plan` — create or update a project plan
- `/horse-sense:arch` — design system architecture
- `/horse-sense:implement` — begin a feature implementation
- `/horse-sense:review` — perform a code review
- `/horse-sense:test` — create and run tests
- `/horse-sense:deploy` — prepare deployment artifacts
- `/horse-sense:sprint` — plan and manage a sprint
- `/horse-sense:retrospective` — facilitate a sprint retrospective

**Priority**: Must Have  
**Story Points**: 3

---

#### User Story: US-012 — Model-invoked skills (automatic)
> As a **developer**, I want **Claude to automatically invoke relevant skills based on context** so that **I don't have to remember which command to use for every activity**.

**Acceptance Criteria:**
```gherkin
Given I ask Claude to "set up the Python environment"
When  Claude recognizes this matches the python-venv skill description
Then  it follows the python-venv SKILL.md guide automatically

Given I ask Claude to "write tests for the user service"
When  Claude recognizes this matches the testing skill description
Then  it follows the testing SKILL.md guide automatically
And   adapts to the project's configured test runner
```

**Priority**: Should Have  
**Story Points**: 3  
**Notes**: Requires SKILL.md files with descriptive `name` and `description` frontmatter fields.

---

#### User Story: US-013 — Skills read project config variables
> As a **developer**, I want **skills to read project configuration variables** so that **guidance is tailored to my project's specific language, framework, paths, and tooling**.

**Acceptance Criteria:**
```gherkin
Given .claude/config.json contains {"language": "python", "srcDir": "src", "testRunner": "pytest"}
When  the implementation skill runs
Then  it references src/ as the source directory
And   it uses pytest commands for running tests
And   it uses Python-specific patterns (type hints, docstrings, venv)

Given .claude/config.json contains {"coverageThreshold": 90}
When  the testing skill runs
Then  it enforces 90% coverage instead of the default 80%

Given a config variable is missing from .claude/config.json
When  a skill reads it
Then  it falls back to a documented default value
```

**Priority**: Must Have  
**Story Points**: 5

**Config schema:**

| Variable | Type | Default | Description |
|---|---|---|---|
| `language` | string | auto-detect | `"python"` or `"typescript"` |
| `framework` | string | none | Framework name (e.g., `"fastapi"`, `"express"`) |
| `testRunner` | string | per-language default | Test runner command (e.g., `"pytest"`, `"vitest"`) |
| `linter` | string | per-language default | Linter (e.g., `"ruff"`, `"eslint"`) |
| `typeChecker` | string | per-language default | Type checker (e.g., `"mypy"`, `"tsc"`) |
| `formatter` | string | per-language default | Formatter (e.g., `"ruff format"`, `"prettier"`) |
| `srcDir` | string | `"src"` | Source code directory |
| `testDir` | string | `"tests"` | Test directory |
| `packageManager` | string | per-language default | Package manager (e.g., `"pip"`, `"npm"`) |
| `coverageThreshold` | number | `80` | Minimum test coverage percentage |
| `branchingStrategy` | string | `"github-flow"` | Git branching model |
| `pythonVersion` | string | `"3.11"` | Python version (if language=python) |
| `nodeVersion` | string | `"20"` | Node.js version (if language=typescript) |

---

### 3.3 Agents — Workers and Orchestrators

Agents are divided into two categories:

- **Worker agents** perform focused tasks from a specific role perspective, using skills and rules
- **Orchestrator agents** direct worker agents through process definitions, managing workflow execution, gating, and human-in-the-loop decision points

#### User Story: US-020 — Worker agent personas
> As a **developer**, I want to **switch to a specialized worker agent persona** so that **Claude approaches work from a specific role's perspective with the right skills loaded**.

**Acceptance Criteria:**
```gherkin
Given I select the "developer" worker agent
When  Claude enters that agent context
Then  it prioritizes implementation, debugging, and refactoring skills
And   it follows code quality and testing rules
And   it maintains the developer persona across the session

Given I select the "tester" worker agent
When  Claude enters that agent context
Then  it prioritizes test strategy, test writing, and coverage skills
And   it enforces testing rules and coverage thresholds
And   it reviews code from a quality-assurance perspective
```

**Required agents:**

| Agent | Type | Role | Primary Skills | Perspective |
|---|---|---|---|---|
| **Planner** | Worker | Project Manager | requirements-analysis, sprint planning | Scope, priorities, timelines |
| **Architect** | Worker | System Designer | architecture-design, tech selection | Components, interfaces, trade-offs |
| **Developer** | Worker | Implementer | implementation, python-venv/ts-setup | Code quality, TDD, shipping |
| **Tester** | Worker | QA Engineer | testing, security audit | Coverage, edge cases, reliability |
| **Reviewer** | Worker | Code Reviewer | review checklist, security, perf | Correctness, standards, maintainability |
| **SDLC Orchestrator** | Orchestrator | Process Director | all workflow processes | End-to-end delivery lifecycle |
| **Sprint Orchestrator** | Orchestrator | Sprint Director | sprint process | Story-level iteration within a sprint |
| **Monitor** | Orchestrator | Quality Watcher | testing, review skills | Observes loops, checks quality, guides refinement |

**Priority**: Must Have  
**Story Points**: 5

---

#### User Story: US-021 — Worker agents compose skills
> As a **developer**, I want **worker agents to automatically use relevant skills** so that **I don't have to manually invoke each skill during a focused work session**.

**Acceptance Criteria:**
```gherkin
Given the developer worker agent is active
When  I ask it to implement a feature
Then  it follows the implementation skill (branch, write test, implement, lint, commit)
And   it references the testing skill for test structure
And   it reads project config for language-specific commands
And   it applies code quality rules to the files it creates

Given the architect worker agent is active
When  I ask it to design a new component
Then  it follows the architecture-design skill
And   it creates an ADR using the ADR template
And   it generates Mermaid diagrams per the documentation rules
```

**Priority**: Must Have  
**Story Points**: 3

---

#### User Story: US-022 — Agents as independent long-lived sessions
> As a **developer**, I want **agents to maintain context across a long session** so that **I can work on complex, multi-step tasks without re-explaining the project**.

**Acceptance Criteria:**
```gherkin
Given the developer agent has been working on a feature for 30+ minutes
When  I ask a follow-up question about the same feature
Then  it remembers the feature context, decisions made, and files modified
And   it does not re-read files it has already analyzed

Given I switch from the developer agent to the reviewer agent
When  the reviewer starts a code review
Then  it has access to the same project context (config, rules)
But   it approaches the code from a review perspective, not an implementation one
```

**Priority**: Should Have  
**Story Points**: 3

---

#### User Story: US-023 — Orchestrator agents direct worker agents
> As a **developer**, I want **orchestrator agents to coordinate worker agents through a defined process** so that **complex multi-step workflows are executed consistently without me manually sequencing each step**.

**Acceptance Criteria:**
```gherkin
Given the SDLC Orchestrator is active and a process definition exists for "feature delivery"
When  I ask it to deliver a feature
Then  it reads the process definition from processes/feature_delivery.md
And   it dispatches the planner worker to gather requirements
And   it waits for the entry gate to pass before advancing to the next step
And   it dispatches the architect worker for design
And   it continues through implementation, testing, review, and deployment steps
And   it tracks overall progress and reports status at each transition

Given the Sprint Orchestrator is active
When  I ask it to execute the current sprint
Then  it reads the sprint plan and iterates over each story
And   for each story it dispatches developer → tester → reviewer workers in sequence
And   it aggregates results and reports sprint completion status
```

**Priority**: Must Have  
**Story Points**: 8

---

#### User Story: US-024 — Monitor agents observe and refine
> As a **developer**, I want **monitor agents to watch long-running loops and provide feedback** so that **iterative processes converge on quality rather than spinning**.

**Acceptance Criteria:**
```gherkin
Given a develop-test-fix loop is running for a story
When  the monitor agent observes the third iteration without test convergence
Then  it analyzes the pattern of failures
And   it suggests a different approach or escalates to the human

Given the monitor agent detects code quality degrading across iterations
When  it evaluates the current state against rules
Then  it intervenes with specific guidance to the worker agent
And   logs the intervention for the orchestrator's status report

Given the monitor agent detects all quality criteria are met
When  it evaluates the current iteration
Then  it signals the orchestrator that the loop can exit
```

**Priority**: Should Have  
**Story Points**: 5  
**Notes**: Monitor agents are optional — orchestrators can run without them, but monitors improve quality on complex or long-running tasks.

---

### 3.4 Process Definitions — Workflow Specification

#### User Story: US-025 — Process definition documents
> As a **plugin author**, I want to **define workflows as structured process documents** so that **orchestrator agents have a clear, repeatable specification to follow**.

**Acceptance Criteria:**
```gherkin
Given a process document exists at processes/feature_delivery.md
When  an orchestrator reads it
Then  it can identify:
  | Element              | Description                                      |
  | Name                 | Process identifier                                |
  | Entry gate           | Preconditions to start (artifacts, state, config) |
  | Steps                | Ordered sequence of work                          |
  | Agent assignment     | Which worker agent executes each step             |
  | Skills & tools       | Which skills and tools each step uses              |
  | Completion criteria  | How to know a step succeeded                      |
  | Fail conditions      | When to abort or escalate                         |
  | Human checkpoints    | Explicit points requiring human decision          |
And  it executes the process by following the steps in order
```

**Process document structure:**

```markdown
---
name: feature-delivery
description: End-to-end feature delivery from requirements to deployment
trigger: /horse-sense:deliver
---

# Feature Delivery Process

## Entry Gate
- [ ] Feature request or user story exists
- [ ] .claude/config.json is configured
- [ ] CI pipeline is green on main branch

## Steps

### Step 1: Requirements
- **Agent**: planner
- **Skills**: requirements-analysis
- **Action**: Gather and document requirements
- **Completion**: requirements_doc.md exists and has all sections filled
- **Fail**: Unable to clarify requirements after 2 rounds → HUMAN DECISION

### Step 2: Architecture
- **Agent**: architect
- **Skills**: architecture-design
- **Action**: Design system architecture, create ADRs
- **Completion**: architecture_doc.md updated, ADRs created
- **Gate**: HUMAN APPROVAL — review architecture before implementation

### Step 3: Implementation
- **Agent**: developer
- **Skills**: implementation
- **Monitor**: monitor (optional, on develop-test loop)
- **Action**: Implement feature with TDD
- **Loop**: write test → implement → run tests → fix failures
- **Loop exit**: All tests pass, lint clean, type check clean
- **Fail**: Loop exceeds 5 iterations without convergence → HUMAN DECISION

### Step 4: Testing
- **Agent**: tester
- **Skills**: testing
- **Action**: Expand test coverage, integration and e2e tests
- **Completion**: Coverage ≥ threshold, all test categories pass
- **Fail**: Coverage cannot reach threshold → HUMAN DECISION

### Step 5: Review
- **Agent**: reviewer
- **Skills**: review
- **Action**: Code review against quality standards
- **Branch**: If blocking issues found → GOTO Step 3 (implementation fixes)
- **Completion**: No blocking issues, PR approved
- **Gate**: HUMAN APPROVAL — final review sign-off

### Step 6: Deployment
- **Agent**: developer
- **Skills**: deployment
- **Action**: Prepare deployment artifacts and runbook
- **Completion**: CI green, artifacts built, runbook documented
```

**Priority**: Must Have  
**Story Points**: 8

---

#### User Story: US-026 — Process flow control (sequence, loop, branch, conditional)
> As a **plugin author**, I want **process steps to support sequential execution, loops, conditional branching, and recursion** so that **real-world workflows with iterative and conditional logic can be modeled**.

**Acceptance Criteria:**
```gherkin
Given a process with sequential steps 1 → 2 → 3
When  the orchestrator executes it
Then  it completes each step before starting the next
And   it checks completion criteria between steps

Given a process step with a loop (e.g., develop-test-fix)
When  the orchestrator enters the loop
Then  it repeats the loop body until exit criteria are met
And   a monitor agent (if assigned) observes each iteration
And   the loop aborts if the fail condition is reached

Given a process step with a conditional branch (e.g., "if review has blocking issues → goto implementation")
When  the branch condition is true
Then  the orchestrator jumps to the target step
And   re-executes from that point forward
And   tracks the number of branch-backs to prevent infinite loops

Given a process step with a recursive sub-process reference
When  the orchestrator encounters it
Then  it loads and executes the referenced process document
And   returns control to the parent process when the sub-process completes
```

**Priority**: Must Have  
**Story Points**: 8

---

#### User Story: US-027 — Entry gates and completion criteria
> As a **developer**, I want **each process step to have explicit entry gates and completion criteria** so that **work doesn't start prematurely and doesn't end before quality is met**.

**Acceptance Criteria:**
```gherkin
Given a process step has an entry gate requiring "requirements_doc.md exists"
When  the orchestrator attempts to start that step
And   requirements_doc.md does not exist
Then  the step is blocked
And   the orchestrator reports what is missing
And   it suggests which prior step or action would satisfy the gate

Given a process step has completion criteria "all tests pass, coverage ≥ 80%"
When  the worker agent finishes its work
Then  the orchestrator evaluates the completion criteria
And   if met, advances to the next step
And   if not met, the worker continues or the step enters its fail path

Given a process step has a fail condition "loop exceeds 5 iterations"
When  the iteration count exceeds 5
Then  the orchestrator halts the step
And   reports the failure reason and iteration history
And   invokes the fail action (typically HUMAN DECISION)
```

**Priority**: Must Have  
**Story Points**: 5

---

#### User Story: US-028 — Human-in-the-loop decision points
> As a **developer**, I want **explicit human decision points in workflows** so that **I maintain control over critical decisions while letting automation handle routine work**.

**Acceptance Criteria:**
```gherkin
Given a process step is marked "Gate: HUMAN APPROVAL"
When  the orchestrator reaches that point
Then  it pauses execution
And   presents a summary of work completed so far
And   presents the specific decision needed (approve / reject / modify)
And   waits for the human to respond before continuing

Given a process step fails and the fail action is "HUMAN DECISION"
When  the orchestrator reaches the fail condition
Then  it pauses execution
And   presents what went wrong, what was tried, and iteration history
And   offers options: retry with guidance, skip step, abort process, or take manual action
And   waits for the human to decide before continuing

Given a human approves at a decision point
When  the orchestrator resumes
Then  it continues from the next step in the process
And   logs the approval in the process execution record

Given a human rejects at a decision point
When  the orchestrator receives the rejection with feedback
Then  it routes back to the appropriate earlier step
And   passes the human's feedback as additional context to the worker agent
```

**Priority**: Must Have  
**Story Points**: 5

---

#### User Story: US-029 — Process execution tracking
> As a **developer**, I want **the orchestrator to track and report process execution status** so that **I can see where a workflow stands, what's completed, and what's next**.

**Acceptance Criteria:**
```gherkin
Given a process is being executed by an orchestrator
When  I ask for status
Then  it reports:
  | Field              | Example                                     |
  | Process            | feature-delivery                             |
  | Current step       | Step 3: Implementation (iteration 2 of 5)   |
  | Steps completed    | 1. Requirements ✓  2. Architecture ✓        |
  | Steps remaining    | 4. Testing  5. Review  6. Deployment         |
  | Blocked by         | (none) or "Waiting for human approval"       |
  | Worker agent       | developer                                    |
  | Monitor            | monitor (active, no interventions)           |

Given a process completes all steps
When  the orchestrator finishes
Then  it produces a summary of the entire execution
And   includes: steps completed, human decisions made, iterations on loops, total time context
```

**Priority**: Should Have  
**Story Points**: 3

---

### 3.5 Rules — Contextual Standards

#### User Story: US-030 — Glob-matched rules
> As a **developer**, I want **coding standards to be automatically injected based on the files I'm editing** so that **Claude follows the right conventions without me having to specify them**.

**Acceptance Criteria:**
```gherkin
Given rules/code_quality.md has glob frontmatter for **/*.py
When  I ask Claude to edit a Python file
Then  the Python code quality rules are loaded into context
And   Claude follows naming conventions, type hint requirements, and line length limits

Given rules/typescript_quality.md has glob frontmatter for **/*.ts
When  I ask Claude to edit a TypeScript file
Then  the TypeScript quality rules are loaded into context
And   Claude follows TypeScript naming, strict mode, and ESLint conventions

Given I'm editing a file that matches no rule globs
When  Claude generates code
Then  it uses general best practices without language-specific enforcement
```

**Priority**: Must Have  
**Story Points**: 3

---

#### User Story: US-031 — Rules customize skill behavior
> As a **developer**, I want **rules to refine how skills operate for my language and standards** so that **the same skill works correctly across Python and TypeScript projects**.

**Acceptance Criteria:**
```gherkin
Given the implementation skill is active and rules/code_quality.md is loaded
When  Claude writes Python code
Then  it uses snake_case, Google-style docstrings, type hints on all public functions
And   it keeps functions under 30 lines

Given the implementation skill is active and rules/typescript_quality.md is loaded
When  Claude writes TypeScript code
Then  it uses camelCase, JSDoc or inline types, strict TypeScript
And   it follows the project's ESLint configuration
```

**Priority**: Must Have  
**Story Points**: 3

---

#### User Story: US-032 — User-customizable rules
> As a **developer**, I want to **add, modify, or override rules** so that **I can adapt the plugin to my project's specific standards**.

**Acceptance Criteria:**
```gherkin
Given I create a new rule file rules/my_api_standards.md with glob **/*_api.py
When  I edit a file matching that glob
Then  my custom rule is loaded alongside the built-in rules

Given I modify rules/code_quality.md to change the line length from 100 to 120
When  Claude generates Python code
Then  it respects the 120-character line length limit

Given I delete a built-in rule file
When  Claude operates on matching files
Then  that rule is no longer applied
And   other rules continue to function normally
```

**Priority**: Should Have  
**Story Points**: 2

---

### 3.6 SDLC Workflow (Orchestrated)

#### User Story: US-040 — End-to-end SDLC flow via process orchestration
> As a **developer**, I want to **follow a structured workflow from requirements through deployment** so that **I produce well-documented, tested, deployable software**.

**Acceptance Criteria:**
```gherkin
Given I run /horse-sense:sdlc-start on a new project
When  the SDLC Orchestrator loads the feature-delivery process definition
Then  it guides me through these phases using worker agents:
  | Phase          | Worker Agent | Output                                    |
  | Requirements   | Planner      | Filled requirements_doc.md                |
  | Architecture   | Architect    | Filled architecture_doc.md + ADRs         |
  | Sprint Plan    | Planner      | Filled sprint_plan.md with stories        |
  | Implementation | Developer    | Working code with tests, passing CI       |
  | Review         | Reviewer     | Code review feedback addressed            |
  | Deployment     | Developer    | Deployment artifacts and runbook created  |
And  each phase has entry gates checked by the orchestrator
And  human approval is required before implementation and after review
And  I can re-enter any phase to iterate
```

**Priority**: Must Have  
**Story Points**: 8  
**Notes**: Implemented via process definitions (US-025) and orchestrator agents (US-023). The SDLC flow is defined in `processes/feature_delivery.md`.

---

#### User Story: US-041 — Quality gates enforced by orchestrator
> As a **developer**, I want **the orchestrator to enforce quality gates between phases** so that **I don't skip essential steps**.

**Acceptance Criteria:**
```gherkin
Given the orchestrator reaches the implementation phase
And   requirements_doc.md is missing or empty
When  the entry gate is evaluated
Then  the orchestrator blocks the step
And   reports that requirements are missing
And   dispatches the planner worker or asks the human to provide requirements

Given the orchestrator reaches the deployment phase
And   tests are failing or coverage is below threshold
When  the entry gate is evaluated
Then  the orchestrator blocks the step
And   routes back to the testing phase
And   the tester worker addresses the gaps

Given all entry gates for a phase are satisfied
When  the orchestrator evaluates the gate
Then  it advances to the phase and dispatches the appropriate worker
```

**Priority**: Must Have  
**Story Points**: 3  
**Notes**: Gates are defined in the process document, not hardcoded in skills. This makes them customizable per workflow.

---

### 3.7 Dual Toolchain Support

#### User Story: US-050 — Python toolchain
> As a **Python developer**, I want **skills and scripts to fully support the Python ecosystem** so that **I can use venv, pytest, ruff, and mypy seamlessly**.

**Acceptance Criteria:**
```gherkin
Given .claude/config.json has language=python
When  I run /horse-sense:implement
Then  it activates venv, writes pytest tests, runs ruff, runs mypy
And   commit messages follow Conventional Commits
And   CI workflow uses Python-specific steps
```

**Priority**: Must Have  
**Story Points**: 3

---

#### User Story: US-051 — TypeScript toolchain
> As a **TypeScript developer**, I want **skills and scripts to fully support the TypeScript/Node.js ecosystem** so that **I can use npm, vitest, eslint, and tsc seamlessly**.

**Acceptance Criteria:**
```gherkin
Given .claude/config.json has language=typescript
When  I run /horse-sense:implement
Then  it uses npm, writes vitest tests, runs eslint, runs tsc
And   commit messages follow Conventional Commits
And   CI workflow uses Node.js-specific steps
```

**Priority**: Must Have  
**Story Points**: 5  
**Notes**: Requires new skills/typescript-setup/SKILL.md and rules/typescript_quality.md

---

### 3.8 CI/CD Integration

#### User Story: US-060 — GitHub Actions workflow
> As a **developer**, I want **a CI workflow template that enforces the plugin's quality standards** so that **PRs are automatically validated before review**.

**Acceptance Criteria:**
```gherkin
Given a project configured with horse-sense
When  a PR is opened
Then  CI runs: lint, type check, test suite with coverage, security audit
And   the PR is blocked if any check fails
And   coverage report is posted as a PR comment

Given the project uses Python
Then  CI runs: ruff check, mypy, pytest --cov, pip audit

Given the project uses TypeScript
Then  CI runs: eslint, tsc --noEmit, vitest --coverage, npm audit
```

**Priority**: Should Have  
**Story Points**: 5

---

## 4. Non-Functional Requirements

### 4.1 Performance

| Requirement | Target |
|---|---|
| Plugin load time | Negligible — static Markdown files, no compilation |
| Skill execution overhead | Zero — skills are context/instructions, not running code |
| Script execution | < 30 seconds for lint, < 5 minutes for full test suite |

### 4.2 Compatibility

| Requirement | Target |
|---|---|
| Claude Code version | Compatible with plugin spec (`.claude-plugin/plugin.json`) |
| Python support | Python >= 3.11 |
| Node.js support | Node.js >= 20 |
| Operating systems | Linux, macOS, WSL (Bash-compatible shell) |
| Git | Required — all workflows assume Git version control |

### 4.3 Maintainability

| Requirement | Target |
|---|---|
| Plugin self-documentation | Every skill, agent, and rule has a clear description |
| Extension pattern | New skills added by creating a directory with SKILL.md — no core changes needed |
| Rule customization | Users can add/modify/delete rules without affecting other components |
| Config backward compatibility | New config fields always have defaults; missing fields never break skills |

### 4.4 Usability

| Requirement | Target |
|---|---|
| Time to first use | < 5 minutes from install to first skill invocation |
| Discoverability | `/horse-sense:sdlc-start` guides users through all capabilities |
| Error messages | Skills explain what's wrong and what to do next (e.g., missing config, failed prerequisites) |
| Learning curve | Developer familiar with Claude Code productive within one session |

---

## 5. Constraints & Assumptions

### Constraints
- Must conform to the official Claude Code plugin specification
- No runtime dependencies beyond Claude Code, Bash, Git, and standard CLI tools
- Plugin is static content (Markdown + scripts) — no compilation, no server, no database
- Skills must work offline (no external API calls from the plugin itself)

### Assumptions
- Users have Claude Code installed and are familiar with basic usage
- Users have either Python >= 3.11 or Node.js >= 20 (or both) installed
- Projects use Git for version control
- Projects use GitHub for hosting (GitHub Actions for CI, PRs for review)
- The Claude Code plugin spec supports glob-matched rule files and non-standard directories (rules/, templates/)

---

## 6. Out of Scope

The following are **explicitly excluded** from this version:

- **Marketplace publishing** — personal/small-team distribution only (Git clone or `--plugin-dir`)
- **IDE-specific integrations** — plugin works through Claude Code CLI; no VS Code extension
- **Languages beyond Python and TypeScript** — additional language support deferred to future versions
- **Custom LLM providers** — plugin assumes Claude Code (Anthropic models) only
- **Cross-session state persistence** — orchestrator tracks state within a session; no database or file-based state across conversations
- **Automated deployment execution** — plugin prepares deployment artifacts but does not deploy
- **Enterprise features** — org-wide policies, audit trails, private registry, compliance hooks
- **Dynamic agent spawning** — orchestrators direct agents within the Claude Code agent framework; they do not spawn OS-level processes

---

## 7. Open Questions

| # | Question | Owner | Due Date | Resolution |
|---|---|---|---|---|
| 1 | Does the plugin manager load non-standard directories (rules/, templates/) into context? | Ed | 2026-04-10 | ⬜ Open |
| 2 | What SKILL.md frontmatter fields are supported beyond `name` and `description`? | Ed | 2026-04-10 | ⬜ Open |
| 3 | Can hooks/ auto-inject rules based on file globs, or must rules use a different mechanism? | Ed | 2026-04-10 | ⬜ Open |
| 4 | How do agents persist across long sessions — does Claude Code handle this or must the plugin? | Ed | 2026-04-10 | ⬜ Open |
| 5 | Should config.json support inheritance (base config + environment overrides)? | Ed | 2026-04-17 | ⬜ Open |
| 6 | How do orchestrator agents "dispatch" worker agents — via Claude Code's Agent tool, subagent spawning, or context switching within a single session? | Ed | 2026-04-10 | ⬜ Open |
| 7 | What is the best format for process definitions — Markdown with conventions (as proposed), YAML, or a DSL? | Ed | 2026-04-10 | ⬜ Open |
| 8 | Can monitor agents run concurrently with worker agents, or must they observe after each iteration? | Ed | 2026-04-10 | ⬜ Open |
| 9 | How should process execution state (current step, iteration count, decisions) be tracked within a session? | Ed | 2026-04-10 | ⬜ Open |
| 10 | Should process definitions support parameterization (e.g., same process for different feature sizes with different loop limits)? | Ed | 2026-04-17 | ⬜ Open |

---

## 8. Approval

| Stakeholder | Role | Date | Signature |
|---|---|---|---|
| Ed Wentworth | Owner / Developer | 2026-04-03 | ⬜ Pending |
