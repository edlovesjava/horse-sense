# Rule: Git Workflow

This rule defines the branching strategy, commit conventions, and pull request process for all projects using horse-sense.

## Branching Strategy: GitHub Flow

We follow [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow) — a lightweight, branch-based workflow:

```
main (always deployable)
  ├── feature/42-user-registration
  ├── fix/87-session-expiry-bug
  ├── refactor/101-extract-auth-service
  └── chore/55-upgrade-dependencies
```

### Rules

1. `main` is always in a deployable state — never commit broken code directly
2. All work happens on short-lived feature branches
3. Branches are merged via pull requests with at least one approval
4. Delete branches after merging

## Branch Naming

```bash
# Pattern: <type>/<ticket-id>-<short-description>
feature/42-user-registration
fix/87-session-expiry-bug
refactor/101-extract-auth-service
chore/55-upgrade-dependencies
docs/66-update-api-readme
test/73-add-coverage-for-auth
```

## Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>(<scope>): <short description>

[optional body]

[optional footer(s)]
```

### Types

| Type | When to Use |
|---|---|
| `feat` | New feature for the user |
| `fix` | Bug fix for the user |
| `refactor` | Code change that neither adds a feature nor fixes a bug |
| `test` | Adding or updating tests |
| `docs` | Documentation only changes |
| `chore` | Build process, dependency updates, tooling |
| `ci` | Changes to CI/CD configuration |
| `perf` | Performance improvement |
| `revert` | Reverts a previous commit |

### Examples

```bash
feat(auth): add password reset via email

Implements the password reset flow:
1. User requests reset via POST /auth/reset-request
2. System emails a 64-char token with 24h TTL
3. User POSTs token + new password to /auth/reset-confirm

Closes #42

---

fix(session): prevent session token reuse after logout

The previous implementation did not invalidate the server-side
session on logout, allowing replayed tokens to authenticate.

Fixes #87

---

chore(deps): upgrade pytest to 8.2.0

Resolves deprecation warnings introduced in 8.1.x.
```

### Commit Hygiene

- Commits should be atomic — one logical change per commit
- Write commit messages in the imperative mood: "add feature", not "added feature"
- Include the ticket number in the footer: `Closes #42` or `Fixes #87`
- Keep the subject line ≤ 72 characters

## Pull Request Process

### Opening a PR

1. Push your branch and open a PR against `main`
2. Fill out the PR description using the template
3. Link the relevant ticket
4. Request review from at least one team member (or the Reviewer agent)

### PR Description Template

```markdown
## Summary
Brief description of what this PR does and why.

## Changes
- Change 1
- Change 2

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing steps described

## Related Issues
Closes #<ticket-number>
```

### Review Requirements

- At least one approving review required
- All CI checks must pass
- No unresolved review comments

### Merging

- Use **Squash and Merge** for feature branches (clean history on `main`)
- Use **Merge Commit** only for release branches (preserve branch history)
- Delete the branch after merging

## Tags and Releases

Use [Semantic Versioning](https://semver.org/):

```bash
# MAJOR.MINOR.PATCH
v1.0.0   ← initial stable release
v1.1.0   ← new backward-compatible feature
v1.1.1   ← bug fix
v2.0.0   ← breaking change
```

Create a release:

```bash
git tag -a v1.1.0 -m "Release v1.1.0: add password reset"
git push origin v1.1.0
```

## Git Hooks (Optional)

Install pre-commit hooks to catch issues before they reach CI:

```bash
pip install pre-commit
pre-commit install
```

Example `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.4.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-merge-conflict
```
