# SPIKE-008: Project Scope Profiles — Adaptive Process Weight

> **Status**: Complete
> **Author**: Scout agent
> **Date**: 2026-04-07
> **Timebox**: 2 hours

---

## Question

The horse plugin currently applies the same full SDLC process regardless of project scope — a weekend PoC gets the same heavyweight artifacts (PRD, architecture doc, quality plan, sprint plans) as a production SaaS product. How should the plugin adapt its process weight, active roles, required artifacts, and workflow steps based on the actual scope of work?

## Approach

- [x] Audit current config layers (`horse.config.md` and `.claude/config.json`) for scope-related settings
- [x] Define a spectrum of project scopes from lightweight to heavyweight
- [x] Map which roles, artifacts, and process steps apply at each scope level
- [x] Design a guided Q&A flow that determines the right scope profile
- [x] Evaluate where scope profile should live (config, frontmatter, or both)
- [x] Assess impact on existing commands, skills, and agents

## Findings

### Finding 1: Current Config Has No Scope Awareness

The two config layers today cover:

- **`horse.config.md`** — requirements format, stories directory, git strategy (3 settings)
- **`.claude/config.json`** — language, toolchain, test runner, linter, coverage threshold (13 settings)

Neither addresses: *How big is this project? How formal should the process be? Which leadership views matter? What artifacts are required vs. optional?*

Every command and skill assumes the full process applies. A solo developer prototyping a CLI tool gets prompted for architecture ADRs, quality gates, and sprint retrospectives — friction that drives users to skip the plugin entirely.

### Finding 2: Five Natural Scope Profiles

Projects fall along a spectrum. Five profiles cover the range:

| Profile | Description | Typical Duration | Team Size | Examples |
|---|---|---|---|---|
| **spike** | Timeboxed investigation, throwaway code, learning exercise | Hours–days | 1 | Library evaluation, API feasibility test, tutorial project |
| **poc** | Proof of concept, quick implementation, validate an idea | Days–1 week | 1 | MVP demo, hackathon project, internal tool prototype |
| **project** | Small to medium project with real users and maintenance | Weeks–months | 1–3 | CLI tool, microservice, internal app, open-source library |
| **product** | Product with roadmap, releases, and business outcomes | Months–quarters | 2–5 | SaaS app, platform feature, customer-facing product |
| **enterprise** | Large-scale system with compliance, ops, and multiple teams | Quarters–years | 5+ | Platform, regulated system, multi-service architecture |

### Finding 3: Roles and Artifacts by Profile

Each profile activates a subset of roles and requires a subset of artifacts:

| Concern | spike | poc | project | product | enterprise |
|---|---|---|---|---|---|
| **Product Vision** | — | — | — | Required | Required |
| **PRD** | — | — | — | Required | Required |
| **Requirements Doc** | — | Lightweight | Full | Full | Full |
| **User Stories** | — | Informal notes | Per-story | Per-story | Per-story |
| **Architecture Doc** | — | — | Lightweight | Full | Full |
| **ADRs** | — | — | Optional | Required | Required |
| **Domain Model (DDD)** | — | — | — | Optional | Required |
| **Project Plan** | — | — | Lightweight | Full | Full |
| **Sprint Plans** | — | — | Optional | Required | Required |
| **Release Roadmap** | — | — | — | Required | Required |
| **Quality Plan** | — | — | Lightweight | Full | Full |
| **V&V Checklists** | — | — | Optional | Required | Required |
| **UX Design** | — | — | Optional | Optional | Required |
| **Observability Reqs** | — | — | — | Optional | Required |
| **Infrastructure Plan** | — | — | — | Optional | Required |
| **Code Tests** | Minimal | Basic | Full | Full | Full |
| **Code Review** | — | Optional | Required | Required | Required |
| **CHANGELOG** | — | — | Required | Required | Required |
| **README** | Minimal | Basic | Full | Full | Full |

| Active Roles | spike | poc | project | product | enterprise |
|---|---|---|---|---|---|
| Scout | Yes | — | — | — | — |
| Developer | Yes | Yes | Yes | Yes | Yes |
| Planner | — | — | Yes | Yes (+ PM lens) | Yes (+ PM lens) |
| Architect | — | — | Yes | Yes | Yes (+ DDD) |
| Tester | — | Basic | Yes | Yes (+ QA lens) | Yes (+ QA lens) |
| Reviewer | — | — | Yes | Yes | Yes |
| Trainer | — | — | Optional | Yes | Yes |
| Doc Writer | — | — | Yes | Yes | Yes |
| Designer | — | — | — | Optional | Yes |
| Ops | — | — | — | Optional | Yes |

### Finding 4: Active Process Steps by Profile

The SDLC workflow steps also scale:

| Step | spike | poc | project | product | enterprise |
|---|---|---|---|---|---|
| Requirements | Question only | Checklist | Full elicitation | PRD + stories | PRD + stories + personas |
| Design | — | Sketch | Architecture doc | Architecture + ADRs | Architecture + ADRs + DDD |
| Planning | — | Task list | Sprint plan | Roadmap + sprints | Roadmap + releases + sprints |
| Implementation | Code | Code + basic tests | TDD | TDD + code review | TDD + code review + pair |
| Testing | Manual/ad-hoc | Unit tests | Unit + integration | Full pyramid | Full pyramid + security + perf |
| Quality Gates | — | — | Lightweight | Phase gates | Phase gates + compliance |
| Deployment | — | Local only | CI + deploy script | CI/CD + staging | CI/CD + staging + prod + rollback |
| Documentation | Spike report | README | README + docs/ | Full docs + CHANGELOG | Full docs + ops runbooks |

### Finding 5: Guided Q&A for Profile Selection

Rather than asking users to pick a profile name, a short Q&A can determine the right profile naturally:

```
1. What are you building?
   a) Investigating or learning something          → spike
   b) Testing an idea or building a quick demo     → poc
   c) Building a tool or service for real use      → project / product / enterprise

2. (If c) Will this have paying users or business KPIs?
   a) No — internal tool or open-source project    → project
   b) Yes — product with roadmap and releases      → product / enterprise

3. (If b) How large is the team?
   a) 1–5 people, single codebase                  → product
   b) Multiple teams, multiple services, compliance → enterprise
```

Three questions, five outcomes. The Q&A can also ask optional refinement questions:

- "Will you need UX design?" (activates designer role at project+ level)
- "Is there infrastructure to manage?" (activates ops role at project+ level)
- "Are there compliance requirements?" (activates quality gates at project+ level)

### Finding 6: Where the Profile Lives

The scope profile should be a new setting in `horse.config.md`:

```markdown
## Project Scope

<!-- Determined by /horse:guide Q&A or set manually -->
<!-- Options: spike | poc | project | product | enterprise -->

project_scope: project
```

**Why `horse.config.md` and not `.claude/config.json`?**

- `.claude/config.json` is toolchain config (language, linter, test runner) — *how* to build
- `horse.config.md` is workflow config (requirements format, git strategy) — *how much process* to apply
- Scope profile is a workflow concern — it controls which steps, roles, and artifacts are active

**Optional overrides** in `horse.config.md` for fine-tuning after Q&A:

```markdown
## Role Overrides

<!-- Uncomment to add/remove roles for this project -->
<!-- active_roles: [developer, planner, architect, tester, reviewer, doc-writer] -->
<!-- skip_roles: [designer, ops] -->

## Artifact Overrides

<!-- Uncomment to require/skip specific artifacts -->
<!-- require: [prd, architecture_doc, quality_plan] -->
<!-- skip: [release_roadmap, observability_requirements] -->
```

### Finding 7: Impact on Existing Commands and Skills

Every command and skill that reads `horse.config.md` would need scope awareness:

| Component | Current Behavior | Scope-Aware Behavior |
|---|---|---|
| `/horse:guide` | Runs full SDLC kickoff | Runs Q&A first → sets profile → runs scoped kickoff |
| `/horse:plan` | Always creates project plan + sprint plan | spike/poc: skip. project: lightweight plan. product+: full plan + roadmap |
| `/horse:arch` | Always creates architecture doc + ADRs | spike/poc: skip. project: lightweight. product+: full |
| `/horse:implement` | Full TDD workflow | spike: just code. poc: code + basic tests. project+: full TDD |
| `/horse:test` | Full test pyramid | spike: skip. poc: unit only. project+: full pyramid |
| `/horse:review` | Full code review | spike/poc: skip. project+: full review |
| `/horse:sprint` | Full sprint planning | spike/poc: skip. project: optional. product+: required |
| `/horse:audit` | Full process audit | spike/poc: skip. project: lightweight. product+: full |
| Agent selection | All agents available | Only profile-active agents are suggested |
| Skill invocation | All skills available | Skills check profile before running heavyweight steps |

**Key design decision**: Scope should be *advisory, not blocking*. If a user on a "poc" profile wants to run `/horse:arch`, let them — but don't prompt for it during the guide workflow.

## Trade-off Matrix

| Option | Pros | Cons | Effort | Risk |
|---|---|---|---|---|
| **A. Profile in config + Q&A in /horse:guide** | Simple to implement; Q&A is natural onboarding; profile stored durably; commands adapt | Every command/skill needs conditional logic; profile may not fit all projects cleanly | Medium (13-21 SP) | Low — advisory approach means wrong profile isn't catastrophic |
| **B. Profile as command-line flag per invocation** | No config change; maximum flexibility per command | No persistence; user must remember to pass flag; no holistic process adaptation | Low (5-8 SP) | Medium — inconsistent process if user forgets flag |
| **C. Multiple CLAUDE.md templates per profile** | Zero runtime logic; profile baked into project instructions; Claude follows naturally | Multiple templates to maintain; switching profile means regenerating CLAUDE.md; brittle | Medium (8-13 SP) | High — template drift, hard to evolve |
| **D. Profile in config + skill-level adaptation + Q&A** | Full adaptivity; skills self-tailor; Q&A for initial setup; overrides for fine-tuning | Most complex implementation; risk of over-engineering conditional logic | High (21-30 SP) | Medium — complexity vs. flexibility trade-off |

## Recommendation

**Option A: Profile in `horse.config.md` with Q&A in `/horse:guide`.**

Rationale:

1. **Simple and durable.** One new config field (`project_scope`) with five enum values. Commands and skills read it and adjust their behavior. The Q&A in `/horse:guide` sets it once.

2. **Advisory, not blocking.** The profile determines what the guide workflow *prompts for* and what agents *suggest*, but any command can still be run manually. A poc developer who wants an architecture doc can still run `/horse:arch`.

3. **Override-friendly.** Optional `active_roles`, `skip_roles`, `require`, and `skip` fields let users fine-tune after the Q&A. A "project" that needs UX design can add the designer role without switching to "product" profile.

4. **Incremental implementation.** Phase 1: add `project_scope` field + Q&A in guide + conditional behavior in guide workflow only. Phase 2: propagate scope awareness to individual commands/skills. This avoids a big-bang refactor.

### Implementation Phases

**Phase 1 (MVP — Must Have):**

- Add `project_scope` field to `horse.config.md` template
- Add scope Q&A to `/horse:guide` command (3 questions)
- Guide workflow skips/includes steps based on profile
- Document profile definitions and artifact/role mappings

**Phase 2 (Propagation — Should Have):**

- Individual commands check `project_scope` and adjust prompts
- Skills check `project_scope` and skip heavyweight steps when not applicable
- Agent suggestions filtered by active roles for the profile

**Phase 3 (Overrides — Could Have):**

- `active_roles` / `skip_roles` override fields
- `require` / `skip` artifact override fields
- `/horse:scope` command to review and change profile mid-project

## Open Questions

- [ ] Should profile be upgradeable mid-project? (e.g., poc → project as scope grows)
- [ ] Should there be a "custom" profile that starts blank and lets users pick everything?
- [ ] How should profile interact with the leadership views (US-090–095)? Are views auto-activated by profile or always opt-in?
- [ ] Should the Q&A ask about deployment targets (local, cloud, on-prem) to inform ops role activation?
- [ ] Should skills fail gracefully when a required upstream artifact doesn't exist (e.g., architecture-design on a poc without a requirements doc)?

## Next Steps

- [ ] Draft user stories for scope profile configuration
- [ ] Draft user story for guided Q&A in `/horse:guide`
- [ ] Draft user story for scope-aware guide workflow
- [ ] Update `horse.config.md` template with `project_scope` field
- [ ] Define the exact artifact/role/step mappings per profile as a reference table in docs
