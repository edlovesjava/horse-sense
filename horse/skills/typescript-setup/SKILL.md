---
name: typescript-setup
description: Set up and manage TypeScript/Node.js projects with npm, vitest, eslint, and prettier
---

# Skill: TypeScript Project Setup

## Purpose

Establish a clean, reproducible TypeScript/Node.js development environment. This skill ensures consistent tooling (compiler, test runner, linter, formatter) across all contributors.

## Configuration

Read `.claude/config.json` (if it exists) for:

- `nodeVersion` — target Node.js version (default: `20`)
- `testRunner` — test framework (default: `vitest`)
- `linter` — linter command (default: `eslint`)
- `formatter` — formatter command (default: `prettier --write`)
- `packageManager` — package manager (default: `npm`)

See `${CLAUDE_PLUGIN_ROOT}/schemas/config.schema.json` for the full schema.

## Prerequisites

- Node.js >= `nodeVersion` (default 20) installed
- npm >= 9.0
- Git repository initialized at the project root

## Quick Start

```bash
# Bootstrap the environment (idempotent — safe to re-run)
bash ${CLAUDE_PLUGIN_ROOT}/scripts/setup_env.sh
```

## Manual Setup Steps

### 1. Initialize the Project

```bash
npm init -y
```

Edit `package.json` to set `name`, `version`, `description`, and add:

```json
{
  "type": "module",
  "engines": {
    "node": ">=20"
  }
}
```

### 2. Install TypeScript

```bash
npm install --save-dev typescript
npx tsc --init
```

### 3. Configure `tsconfig.json`

Use strict mode as the baseline:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist",
    "rootDir": "src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

### 4. Install Dev Dependencies

```bash
# Test runner
npm install --save-dev vitest @vitest/coverage-v8

# Linting
npm install --save-dev eslint @eslint/js typescript-eslint

# Formatting
npm install --save-dev prettier

# Type definitions (as needed)
npm install --save-dev @types/node
```

### 5. Configure ESLint

Create `eslint.config.js`:

```javascript
import eslint from '@eslint/js'
import tseslint from 'typescript-eslint'

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.strict,
  {
    rules: {
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/explicit-function-return-type': 'warn',
    },
  },
  {
    ignores: ['dist/', 'node_modules/', 'coverage/'],
  }
)
```

### 6. Configure Prettier

Create `.prettierrc`:

```json
{
  "semi": false,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2
}
```

Create `.prettierignore`:

```text
dist/
node_modules/
coverage/
```

### 7. Configure Vitest

Create `vitest.config.ts`:

```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      thresholds: {
        lines: 80,
      },
    },
  },
})
```

### 8. Add npm Scripts

Add to `package.json`:

```json
{
  "scripts": {
    "build": "tsc",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix",
    "format": "prettier --write src/ tests/",
    "typecheck": "tsc --noEmit",
    "check": "npm run typecheck && npm run lint && npm test"
  }
}
```

### 9. Verify the Environment

```bash
npx tsc --noEmit        # Type checking
npx eslint src/          # Linting
npx prettier --check .   # Format check
npx vitest run           # Tests
```

## Project Layout

```
src/
├── index.ts
├── models/
├── services/
├── routes/
└── utils/
tests/
├── unit/
├── integration/
└── setup.ts
package.json
tsconfig.json
eslint.config.js
vitest.config.ts
.prettierrc
```

## Dependency Management

### Adding a New Dependency

```bash
# Production dependency
npm install <package-name>

# Dev dependency
npm install --save-dev <package-name>
```

### Updating Dependencies

```bash
# Check for outdated packages
npm outdated

# Update to latest within semver range
npm update

# Update a specific package
npm install <package-name>@latest
```

### Lock File

Always commit `package-lock.json`. Use `npm ci` in CI for reproducible installs.

## Environment Variables

Use a `.env` file for local secrets (never commit it):

```bash
cp .env.example .env
```

Load environment variables using `dotenv`:

```bash
npm install dotenv
```

```typescript
import 'dotenv/config'
```

## CI/CD Considerations

In CI pipelines, use `npm ci` for faster, reproducible installs:

```bash
npm ci
npx tsc --noEmit
npx eslint src/
npx vitest run --coverage
npm audit
```

## Troubleshooting

| Problem | Solution |
|---|---|
| `tsc: command not found` | Run `npm install` to install dev deps, then use `npx tsc` |
| Import errors after install | Check `tsconfig.json` paths and `moduleResolution` setting |
| ESLint not finding config | Ensure `eslint.config.js` exists (flat config format) |
| Vitest can't find tests | Check `vitest.config.ts` and test file naming (`*.test.ts`) |
| `node_modules` in git | Check `.gitignore` includes `node_modules/` |
