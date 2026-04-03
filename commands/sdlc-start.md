# /horse-sense:sdlc-start

Kick off the full SDLC workflow for a new project or feature.

## What This Command Does

Guides you step-by-step through the horse-sense SDLC phases:

1. **Requirements** — populate `templates/requirements_doc.md`
2. **Architecture** — populate `templates/architecture_doc.md` and create ADRs
3. **Planning** — populate `templates/project_plan.md` and `templates/sprint_plan.md`
4. **Environment Setup** — run `scripts/setup_env.sh`
5. **Implementation** — follow `skills/implementation/SKILL.md`
6. **Testing** — follow `skills/testing/SKILL.md`
7. **Deployment** — follow `skills/deployment/SKILL.md`

## Instructions for Claude

When this command is invoked:

1. Ask the user: *"What are you building? Give me a one-sentence description."*
2. Ask: *"Who are the primary users and what problem does it solve for them?"*
3. Ask: *"What are the must-have features for the first release?"*
4. Ask: *"Do you have any technology preferences or constraints?"*
5. Based on the answers, generate a draft `requirements_doc.md` using `templates/requirements_doc.md`.
6. Propose a high-level architecture with two or three options and trade-offs.
7. Once the user selects an architecture, generate a draft `architecture_doc.md`.
8. Break the requirements into a sprint backlog and generate a `sprint_plan.md`.
9. Run `scripts/setup_env.sh` or guide the user to do so.
10. Confirm the user is ready to begin implementation and point them to `agents/workers/developer.md`.

## Guiding Principles

- Ask one clarifying question at a time.
- Never start the next phase without completing the current one.
- Document decisions immediately — don't defer to "we'll figure it out later".
- Keep the scope tight for the first sprint — better to ship less and iterate.
