---
name: requirements-analysis
description: Elicit, analyze, document, and validate project requirements
---

# Skill: Requirements Analysis

## Purpose

Systematically gather, document, and validate what the software must do — before any design or code is written. Well-written requirements reduce rework, prevent scope creep, and create a shared understanding between stakeholders and the development team.

## Configuration

This skill reads `horse.config.md` in the project root for the `requirements_format` setting. It also reads `.claude/config.json` for project-level settings (language, framework) to tailor requirement templates.

See `${CLAUDE_PLUGIN_ROOT}/schemas/config.schema.json` for the full config schema.

## The Requirements Process

```
Elicit → Analyze → Document → Validate → Baseline
```

### 1. Elicit Requirements

**Techniques:**

- Stakeholder interviews — ask open-ended questions, then drill down
- User story mapping — visualize the user journey end-to-end
- Prototyping / wireframes — surface hidden assumptions early
- Review of existing systems, competitors, or industry standards

**Key questions to ask:**

- Who are the users of this system? What are their goals?
- What problem does this software solve?
- What does success look like in 3 months? 12 months?
- What are the constraints (budget, timeline, technology, regulations)?
- What are the absolute must-haves vs. nice-to-haves?

### 2. Categorize Requirements

**Functional Requirements** — what the system *does*:

- User authentication and authorization
- Data input, processing, and output
- Business rules and calculations
- Integrations with external systems

**Non-Functional Requirements (NFRs)** — quality attributes:

- Performance (response time, throughput)
- Scalability (concurrent users, data volume)
- Availability (uptime SLA)
- Security (data protection, access control)
- Maintainability (code quality standards)
- Compliance (GDPR, HIPAA, SOC 2, etc.)

### 3. Write User Stories

Use the standard format:

```
As a <role>, I want to <action> so that <benefit>.
```

**Example:**

```
As a registered user, I want to reset my password via email
so that I can regain access to my account if I forget it.
```

Every user story must have **Acceptance Criteria** in Given/When/Then format:

```
Given I am on the login page
When I click "Forgot password" and enter my email
Then I receive a password-reset email within 2 minutes
And the link expires after 24 hours
```

### 4. Apply MoSCoW Prioritization

| Priority | Meaning |
|---|---|
| **Must Have** | Critical — system fails without it |
| **Should Have** | Important — significant value, but a workaround exists |
| **Could Have** | Nice-to-have — low effort, low impact |
| **Won't Have** | Explicitly out of scope for this release |

### 5. Validate Requirements

- Review with stakeholders for completeness and accuracy
- Check for conflicts between requirements
- Ensure all requirements are testable
- Confirm NFR targets are measurable (e.g., "p99 response < 200ms")

### 6. Baseline and Change Control

Once approved:

- Store the requirements document in version control
- Require formal review for any changes
- Track changes with dates and rationale

## Output

Check the project's `horse.config.md` for the `requirements_format` setting:

- **monolith** (default): Fill out `templates/requirements_doc.md` with all user stories inline.
- **per-story**: Fill out `templates/requirements_index.md` for background, stakeholders, NFRs, and a story index table. Create each user story as a separate file using `templates/user_story.md`, saved to the directory specified by `requirements_stories_dir` (default: `docs/requirements/stories/`). Name files as `US-<NNN>-<kebab-title>.md` (no status suffix — status lives in the YAML frontmatter and the index table).

## Common Anti-Patterns to Avoid

- **"The system shall be fast"** — not measurable; specify SLAs
- **"The system shall be easy to use"** — not testable; use usability metrics
- **Gold-plating** — implementing features nobody asked for
- **Analysis paralysis** — spending weeks on requirements instead of iterating
- **Missing NFRs** — functional requirements without quality constraints
