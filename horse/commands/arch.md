# /horse:arch

Design or update the system architecture.

## What This Command Does

- Gathers context about the project's requirements and constraints
- Proposes architectural options with trade-offs
- Creates or updates `${CLAUDE_PLUGIN_ROOT}/templates/architecture_doc.md`
- Creates Architecture Decision Records (ADRs) in `docs/architecture/adr/`

## Instructions for Claude

When this command is invoked:

1. **Entry gate** — evaluate whether this work needs explicit architecture:
   - Read the requirements (story or prompt). Check whether a parent scope (epic, service) already defines the architecture this work falls under.
   - If the change fits an existing pattern, is a small bug fix, the requirements already specify the technical approach, or the parent epic's architecture already covers this story's design, tell the user: *"This looks like it fits the existing architecture [from epic/service X] — do you still want to do a design pass, or skip straight to implementation?"*
   - If the user agrees to skip, stop here and suggest `/horse:implement`.
2. Read `${CLAUDE_PLUGIN_ROOT}/templates/requirements_doc.md` if it exists.
3. Ask clarifying questions:
   - *"What is the expected scale (concurrent users, requests/second)?"*
   - *"Are there existing systems this must integrate with?"*
   - *"What is the team's technology expertise?"*
   - *"Are there compliance or regulatory requirements?"*
4. Propose two or three architecture options (e.g., monolith vs. microservices) with:
   - Pros and cons for each option
   - Recommended option with rationale
5. Once the user confirms the architecture:
   - Generate a component diagram using Mermaid
   - Define the API contracts for key endpoints
   - Design the data model (ER diagram in Mermaid)
   - Identify cross-cutting concerns (auth, logging, observability)
6. Write the architecture to `${CLAUDE_PLUGIN_ROOT}/templates/architecture_doc.md`.
7. Create an ADR for each significant decision in `docs/architecture/adr/NNNN-title.md`.

## ADR Numbering

ADRs are numbered sequentially: `0001`, `0002`, etc.
Check `docs/architecture/adr/` for the highest existing number before creating a new one.

## Output

- Updated `${CLAUDE_PLUGIN_ROOT}/templates/architecture_doc.md`
- One or more new `docs/architecture/adr/NNNN-title.md` files
