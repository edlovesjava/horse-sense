# E2E Validation: TypeScript Project

> **Date**: 2026-04-06
> **Tester**: Ed Wentworth
> **Task**: T-027

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
- [x] `npm install` completes without errors
- [x] `npm run lint` passes
- [x] `npm run typecheck` passes
- [x] `npm run test` passes
- [x] All `/horse:*` commands load

## Issues Found During Validation

1. **Missing devDependencies** — `package.json` had scripts but no packages. Fixed in `24a3bbc`.

## Result

**PASS** (after fix)
