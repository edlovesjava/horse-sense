# E2E Validation: TypeScript Project

> **Date**: 2026-04-06
> **Tester**: Ed Wentworth
> **Task**: T-027
> **Note**: Not yet manually validated — scaffolding and plugin loading covered by Python validation. TypeScript-specific toolchain (npm install, vitest, eslint, tsc, prettier) to be validated separately.

## Setup

```bash
mkdir /tmp/test-ts && cd /tmp/test-ts
bash horse/scripts/new_project.sh --language typescript my-app
npm install
claude --plugin-dir /workspaces/horse-sense/horse
```

## Checklist

- [x] `new_project.sh --language typescript` scaffolds directory structure
- [x] `.claude/config.json` created with `language: typescript`
- [x] `package.json`, `tsconfig.json`, `vitest.config.ts`, `eslint.config.js`, `.prettierrc` generated
- [x] Starter `src/index.ts` and `tests/unit/index.test.ts` created
- [ ] `npm install` completes without errors
- [ ] `npm run lint` passes
- [ ] `npm run typecheck` passes
- [ ] `npm run test` passes
- [ ] All `/horse:*` commands load

## Result

**PENDING** — plugin and scaffolding validated; TS toolchain run pending
