# Rule: TypeScript Code Quality

These rules apply to all TypeScript code. They are enforced by automated tooling (eslint, tsc) and reinforced in code review. For general principles (clarity, single responsibility, fail loudly), see `code_quality.md`.

## TypeScript-Specific Rules

### Strict Mode

Always enable `strict: true` in `tsconfig.json`. Never use `// @ts-ignore` or `// @ts-expect-error` without a comment explaining why.

### No `any`

Avoid `any`. Use `unknown` for truly unknown types, then narrow with type guards:

```typescript
// Bad
function parse(input: any): string {
  return input.name
}

// Good
function parse(input: unknown): string {
  if (typeof input === 'object' && input !== null && 'name' in input) {
    return String((input as { name: unknown }).name)
  }
  throw new Error('Invalid input: missing name property')
}
```

### Naming

| Type | Convention | Example |
|---|---|---|
| Variables, functions | `camelCase` | `userId`, `getUser()` |
| Classes, interfaces, types | `PascalCase` | `UserRepository`, `ApiResponse` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_RETRIES = 3` |
| Private members | `#` prefix (ES private) | `#internalState` |
| Files | `kebab-case` | `user-service.ts` |
| Test files | `kebab-case.test.ts` | `user-service.test.ts` |
| Enum members | `PascalCase` | `HttpStatus.NotFound` |

### Interfaces vs Types

Prefer `interface` for object shapes (extendable). Use `type` for unions, intersections, and mapped types:

```typescript
// Good — object shape
interface User {
  id: string
  email: string
  readonly createdAt: Date
}

// Good — union type
type Result<T> = { ok: true; value: T } | { ok: false; error: Error }
```

### Immutability

Use `readonly` for properties that should not change after construction. Prefer `const` over `let`; never use `var`:

```typescript
interface Config {
  readonly port: number
  readonly host: string
}

const MAX_RETRIES = 3  // const, not let
```

### Exports

Prefer named exports over default exports. Named exports improve refactoring, auto-imports, and tree-shaking:

```typescript
// Good
export function getUser(id: string): User { ... }
export interface User { ... }

// Avoid
export default function getUser(id: string): User { ... }
```

### Error Handling

Use typed errors. Never catch without handling:

```typescript
// Good — specific error class
class NotFoundError extends Error {
  constructor(public readonly resource: string, public readonly id: string) {
    super(`${resource} not found: ${id}`)
    this.name = 'NotFoundError'
  }
}

// Good — typed catch
try {
  const user = await getUser(id)
} catch (error) {
  if (error instanceof NotFoundError) {
    return res.status(404).json({ error: error.message })
  }
  throw error  // re-throw unexpected errors
}

// Bad — swallowing errors
try {
  await riskyOperation()
} catch {
  // silent fail
}
```

### Imports

Organize imports: external packages, then internal modules, then types:

```typescript
// External
import express from 'express'
import { z } from 'zod'

// Internal
import { UserService } from './services/user-service.js'
import { logger } from './utils/logger.js'

// Types
import type { Request, Response } from 'express'
```

### Functions

- Explicit return types on exported functions
- Use arrow functions for callbacks, regular functions for top-level
- Prefer early returns over nested conditionals

```typescript
// Good — explicit return type, early return
export function validateEmail(email: string): boolean {
  if (!email.includes('@')) return false
  if (email.length > 254) return false
  return /^[^@]+@[^@]+\.[^@]+$/.test(email)
}
```

### Null Handling

Prefer `undefined` over `null` for absent values (aligns with TypeScript's optional properties). Use nullish coalescing (`??`) and optional chaining (`?.`):

```typescript
// Good
const name = user?.profile?.displayName ?? 'Anonymous'

// Bad
const name = user && user.profile && user.profile.displayName
  ? user.profile.displayName
  : 'Anonymous'
```

## File & Module Length Limits

| Unit | Soft Limit | Hard Limit |
|---|---|---|
| Function / method | 30 lines | 50 lines |
| Class | 200 lines | 300 lines |
| Module | 300 lines | 500 lines |

## Linting Configuration

See `${CLAUDE_PLUGIN_ROOT}/skills/typescript-setup/SKILL.md` for eslint and prettier configuration.

```bash
npx eslint src/ --fix
npx prettier --write src/
npx tsc --noEmit
```

## Code Review Standards

- **No new linter warnings** in submitted code
- **No `any` types** without a justifying comment
- **No TODO comments** without a linked ticket
- **No commented-out code** — delete it; git has history
- **No hardcoded secrets** — use environment variables
- **No default exports** unless required by a framework
