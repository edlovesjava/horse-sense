---
name: scout
description: Conduct timeboxed research spikes and produce structured findings with trade-off analysis and recommendations
---

# Skill: Scout — Research & Investigation

## Purpose

Conduct a structured research spike to answer a specific question or evaluate options before the team commits to requirements or a design. The primary output is always a spike report; secondary outputs (draft stories, ADRs) are generated on request.

## Configuration

Read `.claude/config.json` (if present) for project context (language, framework). Read existing requirements (`docs/requirements/`) and architecture docs (`docs/architecture/`, `docs/architecture/adr/`) to avoid duplicating known information.

See `${CLAUDE_PLUGIN_ROOT}/schemas/config.schema.json` for the full schema.

## Workflow

```
Define question → Set timebox → Investigate → Document → Recommend → (Optional) Draft artifacts
```

### Step 1: Define the Research Question

Before investigating, clearly state:

- **Question**: What are we trying to learn or decide?
- **Scope**: What is in bounds? What is explicitly out of bounds?
- **Success criteria**: What does a good answer look like?
- **Timebox**: How long should this spike take?

Write these at the top of the spike report before starting.

### Step 2: Identify Sources

Plan your investigation approach. Common sources:

| Source | When to Use |
|---|---|
| **Codebase** | Understanding existing patterns, finding integration points |
| **Documentation** | Official docs for APIs, libraries, frameworks |
| **Web search** | Evaluating maturity, community, known issues |
| **Prototyping** | Validating feasibility, measuring performance |
| **Existing ADRs/spikes** | Checking what's already been decided or investigated |

Prioritize authoritative sources. Prefer official docs over blog posts. Prefer code samples over prose claims.

### Step 3: Investigate

Execute your research plan. For each finding:

- Record **what** you found (facts, data, code)
- Record **where** you found it (URL, file path, commit)
- Record **confidence level**: high, medium, or low
- Note **surprises** — things that contradicted your expectations

#### For Technology Evaluations

Build a trade-off matrix as you go:

| Criterion | Option A | Option B | Option C |
|---|---|---|---|
| Maturity | | | |
| Performance | | | |
| Team familiarity | | | |
| License | | | |
| Migration effort | | | |
| Lock-in risk | | | |
| Community/support | | | |

#### For Feasibility Spikes

Build a minimal prototype. Keep it throwaway — the goal is learning, not production code. Document:

- What you built and how long it took
- What worked and what didn't
- Performance measurements (if relevant)
- Integration complexity assessment

#### For Codebase Exploration

Map the territory:

- Entry points and hot paths
- Key abstractions and their relationships
- Dependency graph (external and internal)
- Pain points, tech debt, and gotchas

### Step 4: Document Findings

Create a spike report using the template:

```bash
# Auto-increment spike number
NEXT=$(ls docs/spikes/SPIKE-*.md 2>/dev/null | wc -l)
NEXT=$((NEXT + 1))
SPIKE_FILE="docs/spikes/SPIKE-$(printf '%03d' ${NEXT})-<title>.md"
```

Use the template at `${CLAUDE_PLUGIN_ROOT}/templates/spike_report.md`. Every spike report must include:

1. **Question** — what we set out to learn
2. **Approach** — how we investigated
3. **Findings** — what we discovered (facts, with sources)
4. **Trade-off matrix** — structured comparison of options (if evaluating alternatives)
5. **Recommendation** — what we suggest and why, with confidence level
6. **Open questions** — what still needs investigation
7. **Next steps** — concrete actions that follow

### Step 5: Produce Recommendation

State your recommendation clearly:

```markdown
## Recommendation

**Option B** (confidence: high)

We recommend Option B because [reasons]. The main risk is [risk],
which we mitigate by [mitigation].
```

Use confidence levels:

| Level | Meaning |
|---|---|
| **High** | Strong evidence, low risk of being wrong |
| **Medium** | Reasonable evidence, some unknowns remain |
| **Low** | Limited evidence, further research recommended before committing |

### Step 6: Draft Artifacts (Optional)

If the user requests it, generate follow-up artifacts from the spike findings:

#### Draft User Stories

Use `${CLAUDE_PLUGIN_ROOT}/templates/user_story.md`. Save to the configured `requirements_stories_dir` (default: `docs/requirements/stories/`). Name as `US-<NNN>-<kebab-title>-draft.md`.

Each story should:

- Reference the spike report that produced it
- Include acceptance criteria derived from the spike findings
- Estimate story points based on the complexity discovered

#### Draft ADRs

Save to `docs/architecture/adr/NNNN-title.md`. Each ADR should:

- Reference the spike report as context
- Include all options from the trade-off matrix
- Document the recommended decision and its consequences

## Tips

- **Don't boil the ocean** — answer the specific question, not all questions
- **Time is a constraint, not a goal** — stop when you have enough to decide, even if the timebox isn't up
- **Negative results are valuable** — "Option A won't work because X" is a useful finding
- **Photos of whiteboards are fine** — rough diagrams captured quickly beat polished diagrams produced late
- **Check the ADR log first** — the answer might already exist in a prior decision
