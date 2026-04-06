# /horse:audit

Audit SDLC artifacts for completeness, consistency, and traceability.

## What This Command Does

- Invokes the trainer agent to audit project artifacts
- Checks requirements, designs, plans, and process trails
- Produces a structured report with severity-labelled findings
- Verifies cross-artifact traceability (requirement → design → code → test)

## Instructions for Claude

When this command is invoked:

1. Parse the optional scope argument. Valid scopes: `full`, `requirements`, `design`, `plan`, `trail`. Default to `full` if no scope is provided.
2. Ask: *"What phase is the project in? (early exploration / active development / pre-release / maintenance)"* — this calibrates severity expectations.
3. Follow `${CLAUDE_PLUGIN_ROOT}/skills/process-audit/SKILL.md` to execute the audit:
   - Load artifacts for the selected scope
   - Apply the audit checklists from `${CLAUDE_PLUGIN_ROOT}/agents/trainer.md`
   - Check cross-artifact consistency
   - Generate a report using `${CLAUDE_PLUGIN_ROOT}/templates/audit_report.md`
4. Save the report to `docs/audits/audit-<date>-<scope>.md`.
5. Present a summary to the user with:
   - Executive summary (one paragraph)
   - Finding counts by severity (`[gap]`, `[weak]`, `[drift]`, `[good]`)
   - Top 3 findings to address first
   - Recommended next steps

## Usage

```
/horse:audit              # Full audit (all categories)
/horse:audit requirements  # Audit requirements only
/horse:audit design        # Audit design artifacts only
/horse:audit plan          # Audit plans and sprints only
/horse:audit trail         # Audit cross-artifact traceability only
```

## Severity Labels

- `[gap]` — Missing artifact or broken trail; must be addressed
- `[weak]` — Artifact exists but is incomplete or vague
- `[drift]` — Process followed inconsistently; course correction needed
- `[good]` — Practice worth highlighting; team is doing this well
