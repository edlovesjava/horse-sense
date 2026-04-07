# SPIKE-007: Extended Leadership Views (Phase 2)

> **Status**: Complete
> **Author**: Scout agent
> **Date**: 2026-04-07
> **Timebox**: 1 hour

---

## Question

SPIKE-006 identified seven leadership views and recommended a phased approach. Phase 1 covers Product Manager, Project Manager, and QA Lead. This spike investigates the three Phase 2 views in detail: Designer, Architect (enhanced), and Ops Lead. What agents, skills, templates, and diagram types does each view require? What is the most effective delivery strategy — new agents, enhanced existing components, or skills-only?

## Approach

- [x] Review SPIKE-006 Phase 2 recommendations and open questions
- [x] Analyze the Designer view: agent vs. lens, required diagram types, template needs
- [x] Analyze the Architect (enhanced) view: technical vision, DDD artifacts, quality attribute scenarios
- [x] Analyze the Ops Lead view: observability, infrastructure, cost modeling, runbooks
- [x] Evaluate current plugin components for reuse and extension points
- [x] Build trade-off matrix comparing three delivery strategies
- [x] Formulate recommendation with story-level estimates

## Findings

### Finding 1: Designer View — "How People Use It"

**Current coverage**: None. No agent, skill, or template addresses UX design, usability, or human factors. The architect agent handles *system* design but not *user experience* design.

#### Should This Be a New Agent or an Architect Lens?

| Factor | New Designer Agent | Architect Lens |
|---|---|---|
| **Persona clarity** | Clean separation: architect thinks in components, designer thinks in user journeys | Muddled — architect's system prompt would need two distinct modes |
| **Prompt quality** | Dedicated system prompt tuned for UX vocabulary and heuristics | UX guidance diluted by architecture concerns |
| **Agent discovery** | Users see a `designer` agent and know to invoke it for UX work | Users must know to ask the architect to "think like a designer" |
| **Maintenance** | Separate file, independent evolution | Entangled with architect prompt changes |
| **Collaboration** | Architect and designer can review each other's work (separation of concerns) | Self-review is weaker than cross-agent review |

**Verdict**: A dedicated **designer agent** is the right call. The mindset gap between structural system design and human-centered experience design is too large for a single persona to serve well.

#### Diagram Types Needed in the Diagrams Skill

The existing diagrams skill supports Mermaid diagram generation. The designer view requires these additions:

| Diagram Type | Mermaid Support | Purpose |
|---|---|---|
| **User Flow** | `flowchart TD` | Step-by-step task completion paths through the UI |
| **Journey Map** | `journey` | User emotional arc across touchpoints (Mermaid `journey` chart type) |
| **State Diagram** | `stateDiagram-v2` | UI state transitions for complex interactions (already supported) |
| **Sitemap / IA** | `flowchart TD` | Information architecture hierarchy |

Mermaid's `journey` chart type is natively supported but not currently referenced in the diagrams skill. User flows and sitemaps can use the existing `flowchart` type with guidance on conventions (e.g., diamond for decision points, rounded boxes for pages).

#### Templates Needed

| Template | Purpose | Key Sections |
|---|---|---|
| `ux_research.md` | Capture user research findings | User personas, interview summaries, pain points, jobs-to-be-done, journey maps |
| `design_system.md` | Define UI component standards | Design principles, component inventory, color/typography tokens, spacing scale, accessibility standards (WCAG level) |
| `usability_criteria.md` | Define measurable UX quality targets | Task success rate targets, error rate thresholds, learnability benchmarks, accessibility compliance level (WCAG 2.1 AA/AAA), cognitive load limits |

#### Skill Needed

A new **ux-design** skill that guides the designer agent through:

1. UX research synthesis (personas, journey maps, pain points)
2. Interaction design (user flows, wireframe descriptions, state transitions)
3. Usability criteria definition (measurable targets per Finding above)
4. Human factors checklist (Nielsen heuristics, error prevention, feedback, consistency)
5. Accessibility review (WCAG 2.1 AA checklist, ARIA landmark guidance)
6. Design system bootstrapping (component inventory, token definitions)

**Estimated effort**: 8 SP (1 agent + 1 skill + 3 templates + diagrams skill update)

### Finding 2: Architect View (Enhanced) — "How It's Built, Strategically"

**Current coverage**: Good. The architect agent handles system architecture, ADRs, component diagrams, and API contracts via the architecture-design skill. What is missing falls into three categories.

#### Gap 1: Technical Vision Document

The architect currently jumps straight to component-level design. There is no artifact that captures:

- **Architectural principles** — guiding rules (e.g., "prefer async over sync," "design for horizontal scaling")
- **Quality attributes** — the "-ilities" with priority ranking (availability > performance > scalability)
- **Quality attribute scenarios** — stimulus-response format (e.g., "When 1000 concurrent users submit forms, the system responds within 200ms under normal operation")
- **Technology strategy** — language/framework choices with rationale, upgrade cadence, deprecation policy

**Solution**: A `technical_vision.md` template is sufficient. The architecture-design skill should be enhanced with a "vision phase" step that precedes component design. No new skill is needed — the existing skill's workflow just needs an additional entry point.

#### Gap 2: Domain-Driven Design Artifacts

For domain-rich applications, the architect needs to produce:

| Artifact | Purpose |
|---|---|
| **Bounded Context Map** | Visual map of domain boundaries and their relationships (partnership, customer-supplier, conformist, ACL, open host, published language) |
| **Aggregate Definitions** | Root entities, invariants, consistency boundaries |
| **Ubiquitous Language Glossary** | Shared vocabulary between domain experts and developers, linked to bounded contexts |

**Should DDD be its own skill?** The case is borderline:

- **For separate skill**: DDD is a distinct methodology with its own vocabulary and workflow; not every project needs it; keeping it separate avoids bloating the architecture-design skill.
- **Against separate skill**: DDD is fundamentally an architectural concern; splitting it creates artificial boundaries; the architect agent would need to know when to invoke which skill.

**Verdict**: Make DDD a **separate skill** (`domain-modeling`). Rationale: DDD is opt-in. Many projects (scripts, CLI tools, simple APIs) do not need bounded contexts or aggregates. A dedicated skill can be invoked when the architect identifies domain complexity, and skipped otherwise. The architecture-design skill should reference the domain-modeling skill as an optional next step.

#### Gap 3: Quality Attribute Scenarios

Quality attribute scenarios follow a structured format (SEI/ATAM style):

```
Source: [who/what triggers]
Stimulus: [the event]
Artifact: [what part of the system]
Environment: [under what conditions]
Response: [what the system does]
Measure: [how we know it succeeded]
```

These should live inside the `technical_vision.md` template as a repeatable section, not as a separate artifact.

#### Templates Needed

| Template | Purpose | Key Sections |
|---|---|---|
| `technical_vision.md` | Capture architectural direction before detailed design | Architectural principles, quality attribute priority matrix, quality attribute scenarios, technology strategy, upgrade/deprecation policy |
| `domain_model.md` | Capture DDD artifacts | Bounded context map (Mermaid), context relationships, aggregate definitions, ubiquitous language glossary |

#### Skill Changes

| Component | Change |
|---|---|
| architecture-design skill | Add "vision phase" step; add reference to domain-modeling skill as optional step |
| New `domain-modeling` skill | Guide through bounded context identification, context mapping, aggregate definition, glossary construction |

**Estimated effort**: 5 SP (2 templates + 1 new skill + architecture-design skill enhancement)

### Finding 3: Ops Lead View — "How It Runs"

**Current coverage**: Partial. The deployment skill covers CI/CD pipeline generation, Dockerfile creation, and rollback strategy. It does not address ongoing operational concerns.

#### Gap 1: Observability Requirements

The plugin has no artifact for defining:

- **SLOs** (Service Level Objectives) — target reliability/performance per service
- **SLIs** (Service Level Indicators) — the metrics that measure SLOs
- **Alerting thresholds** — warning and critical levels, escalation paths
- **Logging strategy** — structured logging standards, log levels, retention policy
- **Tracing strategy** — distributed tracing instrumentation, sampling rates, trace context propagation
- **Metrics strategy** — RED (Rate, Errors, Duration) or USE (Utilization, Saturation, Errors) methodology, custom business metrics

#### Gap 2: Infrastructure Planning

Missing entirely:

- **Compute requirements** — instance types, container resource limits, auto-scaling policies
- **Storage requirements** — database sizing, backup schedule, replication strategy
- **Networking** — VPC layout, security groups, DNS, CDN, load balancer configuration
- **Scaling strategy** — horizontal vs. vertical, scaling triggers, cooldown periods
- **Disaster recovery** — RPO/RTO targets, failover procedure, data replication across regions

#### Gap 3: Cost Modeling

No template or guidance for:

- **Infrastructure cost estimates** — per-environment monthly cost projection
- **Scaling cost projections** — cost at 1x, 5x, 10x current load
- **Budget constraints** — spending limits, cost alerts, reserved instance strategy
- **Cost optimization** — right-sizing recommendations, spot/preemptible instance opportunities

#### Gap 4: Runbooks

The deployment skill handles initial deployment but not ongoing operations:

- **Incident response** — severity classification, triage procedure, communication template
- **Failover procedures** — step-by-step failover to secondary region/instance
- **Maintenance windows** — pre-maintenance checklist, rollback criteria, post-maintenance validation
- **Scaling operations** — manual scaling procedure for emergencies

#### New Agent or Enhanced Deployment Skill?

| Factor | New Ops Agent | Enhanced Deployment Skill |
|---|---|---|
| **Scope alignment** | Ops concerns span the full system lifecycle, not just deployment | Deployment is a subset of ops; stretching the skill loses focus |
| **Persona value** | An ops agent thinks about reliability, cost, and incident response natively | The deployment skill has no persona — it's procedural guidance |
| **Artifact ownership** | Ops agent owns observability, infra, cost, and runbook artifacts | Deployment skill would own too many unrelated artifact types |
| **Collaboration** | Ops agent can review architect's deployment architecture and provide operational feedback | Skill-only approach has no review capability |

**Verdict**: A dedicated **ops agent** is warranted. The operational concern is broad enough (observability + infrastructure + cost + incident response) that it needs a persona with operational thinking, not just procedural steps bolted onto the deployment skill.

A new **ops-planning** skill should guide the ops agent through:

1. SLO/SLI definition and alerting threshold setup
2. Observability strategy (logging, tracing, metrics methodology selection)
3. Infrastructure requirements gathering and sizing
4. Cost estimation and budget constraint definition
5. Runbook creation for standard operational procedures
6. Disaster recovery planning (RPO/RTO, failover procedures)

The existing deployment skill remains focused on CI/CD and release mechanics. The ops agent would use the deployment skill for release concerns and the ops-planning skill for operational concerns.

#### Templates Needed

| Template | Purpose | Key Sections |
|---|---|---|
| `observability_requirements.md` | Define monitoring and alerting strategy | SLO table, SLI definitions, alerting thresholds (warning/critical), logging standards, tracing strategy, metrics methodology (RED/USE), dashboard requirements |
| `infrastructure_plan.md` | Define compute/storage/network requirements | Environment inventory, compute sizing, storage requirements, networking topology, scaling policy, disaster recovery (RPO/RTO), security controls |
| `cost_model.md` | Estimate and constrain infrastructure costs | Per-environment cost breakdown, scaling cost projections (1x/5x/10x), reserved vs. on-demand mix, budget limits, cost optimization opportunities |
| `runbook.md` | Standardize operational procedures | Incident severity classification, triage steps, escalation path, failover procedure, maintenance window checklist, rollback criteria |

**Estimated effort**: 8 SP (1 agent + 1 skill + 4 templates)

## Trade-off Matrix

| | **A. Three New Agents** | **B. Enhance Existing + One New Agent** | **C. Skills-Only** |
|---|---|---|---|
| **Description** | New designer agent, new ops agent, and refactor architect into architect + architect-vision agent | New designer agent, new ops agent, enhance existing architect agent with vision/DDD skills | Add ux-design, ops-planning, domain-modeling, and technical-vision skills only — no new agents |
| **Agents added** | 3 (designer, ops, architect-vision) | 2 (designer, ops) | 0 |
| **Skills added** | 3 (ux-design, ops-planning, domain-modeling) | 3 (ux-design, ops-planning, domain-modeling) | 4 (ux-design, ops-planning, domain-modeling, technical-vision) |
| **Templates added** | 9 | 9 | 9 |
| **Estimated effort** | 25-28 SP | 21 SP | 15-18 SP |
| **Persona quality** | High — each role has dedicated, focused guidance | High — designer and ops get dedicated personas; architect extends naturally | Low — skills lack persona context; guidance is procedural, not perspective-driven |
| **Agent discoverability** | Users see designer, ops, architect-vision in agent list — clear but crowded | Users see designer and ops — clear and manageable | No new agents to discover; users must know which skills to invoke |
| **Maintenance burden** | Three new agent files + three skills to maintain | Two new agent files + three skills to maintain | Four skills to maintain, but skills are simpler than agents |
| **Collaboration quality** | Strong — three distinct viewpoints for cross-review | Strong — designer and ops provide new review perspectives; architect self-reviews vision work | Weak — skills don't review; no new perspectives for cross-agent feedback |
| **Extensibility** | Most extensible but highest upfront investment | Good balance — leaves room to add agents later if needed | Least extensible; adding agents later requires rework |
| **Risk** | Over-engineering for small projects; agent proliferation fatigue | Low — delivers value without overwhelming; proven pattern from Phase 1 | Under-serving complex projects; UX and ops concerns lack depth without dedicated personas |

## Recommendation

**Option B: Enhance existing + one new agent (designer + ops agents, architect skill enhancements).**

This aligns with SPIKE-006's Phase 2 recommendation and balances coverage with complexity:

| View | Delivery Approach | Components | Est. SP |
|---|---|---|---|
| **Designer** | New `designer` agent + `ux-design` skill | 1 agent, 1 skill, 3 templates (`ux_research.md`, `design_system.md`, `usability_criteria.md`), diagrams skill update | 8 |
| **Architect (enhanced)** | Enhance architecture-design skill + new `domain-modeling` skill | 2 templates (`technical_vision.md`, `domain_model.md`), 1 new skill, 1 skill update | 5 |
| **Ops Lead** | New `ops` agent + `ops-planning` skill | 1 agent, 1 skill, 4 templates (`observability_requirements.md`, `infrastructure_plan.md`, `cost_model.md`, `runbook.md`) | 8 |
| **Total** | | 2 agents, 3 skills (1 new + 2 updated), 9 templates | **21 SP** |

**Why not Option A?** Splitting the architect into two agents adds complexity without proportional benefit. The architect agent already has a strong persona — adding a vision/DDD phase to its workflow is cleaner than creating a separate agent for strategic architecture.

**Why not Option C?** The designer and ops views represent genuinely new perspectives that the plugin lacks entirely. Skills alone cannot provide the persona-driven thinking that makes agent guidance effective. A `ux-design` skill without a designer persona would produce checklists, not user-centered thinking.

## Open Questions

- [ ] Should the designer agent own accessibility concerns exclusively, or should the tester agent also audit WCAG compliance during quality gates?
- [ ] Should the ops agent own the existing deployment skill, or should deployment remain independent with the ops agent referencing it?
- [ ] How should the domain-modeling skill interact with the requirements-analysis skill? Domain language often emerges during requirements gathering.
- [ ] Should runbook templates be parameterized per infrastructure provider (AWS, GCP, Azure) or kept provider-agnostic?
- [ ] What is the minimum viable ops-planning skill — SLO/SLI definition alone, or must infrastructure planning be included in the first iteration?

## Next Steps

- [ ] Deliver and validate Phase 1 (Product Manager, Project Manager, QA Lead views) before beginning Phase 2 work
- [ ] Draft user stories for the designer agent and ux-design skill after Phase 1 validates the leadership view model
- [ ] Draft user stories for architect enhancements (technical-vision template, domain-modeling skill) after Phase 1 validates
- [ ] Draft user stories for the ops agent and ops-planning skill after Phase 1 validates
- [ ] Resolve open questions through Phase 1 retrospective findings
- [ ] Validate Phase 2 scope (21 SP) against sprint capacity at time of scheduling
