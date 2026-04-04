# ADR-0001: Adopt Official Claude Code Plugin Format

**Status**: Accepted  
**Date**: 2026-04-03  
**Decision makers**: Ed Wentworth

## Context

horse-sense was initially built with a custom layout (`.claude/settings.json`, `.claude/commands/`) before the official Claude Code plugin specification was finalized. The official spec defines a standard structure with `.claude-plugin/plugin.json`, `commands/`, `skills/` (with `SKILL.md` frontmatter), `agents/`, `hooks/`, and `bin/` directories.

Continuing with the custom layout means:

- No marketplace distribution without manual repackaging
- Plugin manager won't recognize the plugin natively
- Skills won't get namespaced (`/horse-sense:<skill>`) automatically
- No access to hooks or bin/ PATH injection

## Decision

Restructure horse-sense to fully conform to the official Claude Code plugin specification:

1. Add `.claude-plugin/plugin.json` manifest
2. Move slash commands from `.claude/commands/` to `commands/` at plugin root
3. Convert `skills/*/README.md` to `skills/*/SKILL.md` with required YAML frontmatter (`name`, `description`)
4. Keep `agents/`, `rules/`, `templates/`, `scripts/` at root (agents/ is standard; others are referenced resources)
5. Add `bin/` directory for executable scripts
6. Remove `.claude/settings.json` (replace with plugin.json)

## Consequences

**Positive:**

- Native recognition by Claude Code plugin manager
- Automatic skill namespacing (`/horse-sense:*`)
- Future marketplace distribution without restructuring
- Access to hooks and bin/ PATH features
- Consistent with community plugins

**Negative:**

- One-time migration effort (move files, rename README.md → SKILL.md)
- Slash commands change from `/user:plan` to `/horse-sense:plan` — users need to update muscle memory
- `rules/` and `templates/` are not standard plugin directories — need to verify they're included in plugin loading

**Risks:**

- Plugin spec may evolve; need to track changes
- Non-standard directories (rules/, templates/) may require workarounds if plugin manager ignores them
