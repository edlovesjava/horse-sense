---
id: US-051
title: TypeScript toolchain
status: draft
priority: Must Have
story_points: 5
section: "3.7 Dual Toolchain Support"
---

# US-051 — TypeScript toolchain

> As a **TypeScript developer**, I want **skills and scripts to fully support the TypeScript/Node.js ecosystem** so that **I can use npm, vitest, eslint, and tsc seamlessly**.

## Acceptance Criteria

```gherkin
Given .claude/config.json has language=typescript
When  I run /horse-sense:implement
Then  it uses npm, writes vitest tests, runs eslint, runs tsc
And   commit messages follow Conventional Commits
And   CI workflow uses Node.js-specific steps
```

**Notes**: Requires new skills/typescript-setup/SKILL.md and rules/typescript_quality.md
