# SPIKE-005: Project-Level Planning & Prioritization Gaps

> **Status**: Complete
> **Author**: Scout agent
> **Date**: 2026-04-07
> **Timebox**: 1 hour

---

## Question

The planner agent and `/horse:sprint` command handle sprint-level planning well — story selection, capacity, velocity, close-out. But what project-level planning capabilities are missing, and how should they be addressed? Specifically: dependency analysis, release phasing, capacity forecasting, backlog refinement, story splitting, and multi-release roadmaps.

## Approach

- [x] Audit the planner agent persona (`agents/planner.md`) for planning responsibilities
- [x] Audit `/horse:plan` and `/horse:sprint` commands for planning workflows
- [x] Audit the requirements-analysis skill for backlog grooming capabilities
- [x] Audit project_plan.md and sprint_plan.md templates for structural support
- [x] Audit user_story.md frontmatter for dependency/phasing fields
- [x] Evaluate options for closing the gaps: enhance existing components vs. add new ones

## Findings

### Finding 1: Sprint-Level Planning Is Solid

The existing planner agent + `/horse:sprint` command covers sprint planning well:

- **MoSCoW prioritization** with Fibonacci story points
- **Capacity-based sprint filling** at ~80% (deliberate buffer)
- **Velocity tracking** at sprint close-out
- **Sprint lifecycle** — pre-flight check, daily standups, close-out, retrospective

No changes needed at the sprint level.

### Finding 2: No Dependency Analysis

Stories have no `depends_on` or `blocked_by` field in the user_story.md frontmatter. The sprint command can assign a blocked story to a sprint without warning. The project_plan.md template has a "Dependencies" section (section 7), but it tracks *external* dependencies (APIs, teams), not *inter-story* dependencies.

**Impact**: Stories get assigned to sprints in the wrong order. A developer picks up US-040 (end-to-end SDLC flow) before US-025 (trail definitions) is done — the prerequisite.

### Finding 3: No Release Phasing

The project_plan.md template supports up to 4 milestones (section 3), but milestones are flat — there's no grouping into phases (e.g., "Phase 1: Core Plugin = Sprints 1-3, Phase 2: Advanced Skills = Sprints 4-6"). Stories are assigned directly to sprints, not to phases or releases.

**Impact**: Hard to communicate a roadmap to stakeholders. "When will the documentation capabilities ship?" requires manually scanning sprint plans.

### Finding 4: No Capacity Forecasting

The `/horse:sprint` command asks for current team capacity (person-days) but doesn't use historical velocity to predict how many sprints remain or when a milestone will be reached.

**Impact**: No way to answer "Will we finish the Must Have stories by sprint 6?" without manual calculation.

### Finding 5: No Backlog Refinement Command

The planner is implicitly responsible for backlog grooming, but there's no `/horse:refine` command or refinement skill. Refinement happens ad-hoc during `/horse:plan` or `/horse:sprint`. There's no guided workflow for: re-estimating stories as scope clarifies, splitting large stories, re-prioritizing based on new information, or archiving stories that are no longer relevant.

**Impact**: Backlog grows stale. 13-point stories never get split. Priorities drift without a formal review.

### Finding 6: No Story Splitting Guidance

When a story is too large (8+ SP), there's no skill or guidance for decomposing it into smaller, independently deliverable stories. The planner creates stories but doesn't have a structured approach for splitting them.

**Impact**: Large stories span multiple sprints or get deferred repeatedly.

## Trade-off Matrix

| Option | Pros | Cons | Effort | Risk |
|---|---|---|---|---|
| **A. Enhance planner agent + existing commands** | Minimal new components; builds on proven patterns; lower cognitive overhead | Planner agent prompt gets very long; sprint command becomes complex; mixed responsibilities | Medium (5-8 SP per enhancement) | Low — incremental changes to working system |
| **B. Add a release-planning skill + refine command** | Clean separation of concerns; sprint planning stays focused; release planning gets dedicated workflow | New skill + command to maintain; planner agent needs to know when to compose each skill | Medium (13-21 SP total) | Low — additive, no breaking changes |
| **C. Add a dedicated "program manager" agent** | Full separation of project-level vs. sprint-level planning; mirrors real team structure | Over-engineering for a plugin; adds another agent to an already large roster (8 agents) | High (21+ SP) | Medium — may confuse users about planner vs. PM roles |

## Recommendation

**Option B: Add a release-planning skill and a backlog refinement command.**

Rationale:

1. **The planner agent stays focused on sprint-level work** — it already does this well. Adding release phasing and forecasting to the planner prompt would bloat it and mix planning horizons.

2. **A release-planning skill** (`skills/release-planning/SKILL.md`) handles the project-level horizon:
   - Group stories into phases/releases
   - Define phase goals and exit criteria
   - Track dependencies between stories (add `depends_on` to user_story.md frontmatter)
   - Forecast completion using historical velocity
   - Produce a release roadmap artifact

3. **A backlog refinement command** (`/horse:refine`) handles ongoing backlog health:
   - Re-estimate stories as scope clarifies
   - Split large stories (8+ SP) into smaller deliverables
   - Re-prioritize based on new information or completed spikes
   - Archive stories that are no longer relevant
   - Review and update story dependencies

4. **Option C is over-engineering.** The planner agent can compose the release-planning skill when working at the project level — no need for a separate agent persona. The planner *is* the PM in a small-team context.

### Supporting Changes

- Add `depends_on: [US-NNN, ...]` field to user_story.md frontmatter schema
- Add a "Release Roadmap" section to project_plan.md template (phases → milestones → sprints)
- Add velocity history to sprint_plan.md template (historical SP/sprint for forecasting)

## Open Questions

- [ ] Should dependency analysis be enforced (block sprint assignment of stories with unmet dependencies) or advisory (warn but allow)?
- [ ] Should velocity forecasting use simple averaging or weighted recent sprints?
- [ ] Should the release roadmap be a separate artifact or a section in project_plan.md?

## Next Steps

- [ ] Draft user stories for the release-planning skill (US-090 or next available)
- [ ] Draft user story for the `/horse:refine` command
- [ ] Draft user story for `depends_on` frontmatter field in user_story.md
- [ ] Update project_plan.md template with release roadmap section
- [ ] Prioritize these stories for an upcoming sprint
