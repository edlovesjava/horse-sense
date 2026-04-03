# /horse-sense:arch

Design or update the system architecture.

## What This Command Does

- Gathers context about the project's requirements and constraints
- Proposes architectural options with trade-offs
- Creates or updates `templates/architecture_doc.md`
- Creates Architecture Decision Records (ADRs) in `docs/adr/`

## Instructions for Claude

When this command is invoked:

1. Read `templates/requirements_doc.md` if it exists.
2. Ask clarifying questions:
   - *"What is the expected scale (concurrent users, requests/second)?"*
   - *"Are there existing systems this must integrate with?"*
   - *"What is the team's technology expertise?"*
   - *"Are there compliance or regulatory requirements?"*
3. Propose two or three architecture options (e.g., monolith vs. microservices) with:
   - Pros and cons for each option
   - Recommended option with rationale
4. Once the user confirms the architecture:
   - Generate a component diagram using Mermaid
   - Define the API contracts for key endpoints
   - Design the data model (ER diagram in Mermaid)
   - Identify cross-cutting concerns (auth, logging, observability)
5. Write the architecture to `templates/architecture_doc.md`.
6. Create an ADR for each significant decision in `docs/adr/NNNN-title.md`.

## ADR Numbering

ADRs are numbered sequentially: `0001`, `0002`, etc.
Check `docs/adr/` for the highest existing number before creating a new one.

## Output

- Updated `templates/architecture_doc.md`
- One or more new `docs/adr/NNNN-title.md` files
