# ADR-0003: Dual Python/TypeScript Toolchain Support

**Status**: Accepted  
**Date**: 2026-04-03  
**Decision makers**: Ed Wentworth

## Context

horse-sense was initially Python-only (venv, pytest, ruff, mypy). To be useful across more projects, it needs to support TypeScript/Node.js as well. We considered:

1. **Python + TypeScript** — support both via configuration, scripts detect which toolchain to use
2. **Python only first** — defer TypeScript, add later
3. **Language-agnostic** — thin wrappers only, all specifics in rules

Option 2 limits adoption. Option 3 pushes too much complexity into rules and loses the "opinionated guide" value proposition.

## Decision

Support both Python and TypeScript toolchains from the start, driven by `.claude/config.json`:

- **Skills** include conditional sections: "If Python, do X. If TypeScript, do Y."
- **Rules** use glob patterns to inject language-specific context (e.g., `**/*.py` → Python rules, `**/*.ts` → TypeScript rules)
- **Scripts** detect language from config or file presence and branch accordingly
- **Templates** remain language-neutral (requirements, architecture, sprint plans are universal)

### Toolchain mapping:

| Concern | Python | TypeScript |
|---|---|---|
| Environment | venv | npm / pnpm |
| Linter | ruff | eslint |
| Formatter | ruff format | prettier |
| Type checker | mypy | tsc |
| Test runner | pytest | vitest / jest |
| Coverage | pytest-cov | c8 / istanbul |
| Security | pip audit | npm audit |

### New skills needed:
- `skills/typescript-setup/SKILL.md` — analogous to `skills/python-venv/SKILL.md`

### New rules needed:
- `rules/typescript_quality.md` — TypeScript naming, style, linting standards (globs: `**/*.ts`, `**/*.tsx`)

## Consequences

**Positive:**
- Plugin useful for both Python and TypeScript projects immediately
- Config-driven approach means adding a third language later is straightforward
- Shared SDLC process across languages (same agents, templates, workflow)

**Negative:**
- Skills are longer (conditional sections for each language)
- Scripts need branching logic (adds complexity)
- Must test plugin behavior against both toolchains
- TypeScript rules and skills need to be written (upfront effort)
