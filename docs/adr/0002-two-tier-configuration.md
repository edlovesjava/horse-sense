# ADR-0002: Two-Tier Configuration Model

**Status**: Accepted  
**Date**: 2026-04-03  
**Decision makers**: Ed Wentworth

## Context

Skills need to adapt to the host project's language, framework, test runner, and directory structure. We considered three approaches:

1. **plugin.json + .claude/config.json** — plugin metadata in manifest, project config in a separate JSON file
2. **CLAUDE.md frontmatter** — embed config as YAML in CLAUDE.md, skills parse at runtime
3. **Ecosystem files** — read pyproject.toml or package.json directly

Option 2 couples config to documentation and is fragile to parse. Option 3 is limited to what those files already contain (no custom fields like `branchingStrategy` or `coverageThreshold`).

## Decision

Adopt a two-tier configuration model:

**Tier 1 — Plugin manifest** (`.claude-plugin/plugin.json`): Static plugin identity (name, version, author). Ships with the plugin. Never modified by users.

**Tier 2 — Project config** (`.claude/config.json`): Project-specific settings created by users in their host project. Skills read this file to determine language, toolchain, paths, and thresholds.

Config schema (all fields optional with sensible defaults):

```json
{
  "language": "python | typescript",
  "framework": "string",
  "testRunner": "string",
  "linter": "string",
  "typeChecker": "string",
  "srcDir": "string",
  "testDir": "string",
  "packageManager": "string",
  "coverageThreshold": "number",
  "branchingStrategy": "string"
}
```

When `.claude/config.json` is absent, skills fall back to auto-detection (presence of `pyproject.toml` → Python, `package.json` → TypeScript) and built-in defaults.

## Consequences

**Positive:**

- Clean separation of plugin identity vs project settings
- JSON is easy for both humans and skills to read
- Explicit config beats heuristic detection
- Extensible — new fields can be added without breaking existing configs

**Negative:**

- Users must create `.claude/config.json` in their project (mitigated by auto-detection fallback)
- Two config files to understand (mitigated by clear purpose separation)
