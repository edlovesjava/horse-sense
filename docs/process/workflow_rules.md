# Workflow Rules: Branch, Commit, and PR Discipline

> **Status**: Active
> **Date**: 2026-04-06
> **Origin**: Sprint 3 retrospective — "Stop" items
> **See also**: [ADR-0007: Readiness-Gate Policy](../architecture/adr/0007-readiness-gate-policy.md)

---

## Three Rules

### 1. Fresh Branch

**Always start from a current base.**

```bash
git fetch origin
git checkout main && git pull
git checkout -b feature/my-feature
```

Before committing on an existing branch:

```bash
git fetch origin
git rebase origin/main   # or merge, per horse.config.md git_strategy
```

**Why**: Stale branches cause merge conflicts and mask integration issues. Sprint 3 had cases where work was done on branches that were days behind `main`.

**Enforcement options**:

- Pre-commit hook that warns if the branch is more than N commits behind `origin/main`
- CI check that fails if the branch cannot fast-forward from the target

### 2. Single Branch

**One active feature branch per developer at a time.**

Do not start a second feature branch while the first is in flight. Finish, merge, or explicitly park the first branch before starting another.

**Why**: Context-switching between branches leads to half-finished work, forgotten changes, and review bottlenecks. Sprint 3's "bonus work" (trainer agent) landed outside the sprint plan partly because of parallel branch work.

**Exceptions**:

- Hotfixes on `main` when the current branch is blocked
- Explicitly authorized by the sprint owner (documented in the sprint plan)

**Enforcement options**:

- `/horse:implement` could check for other open branches by the same author and warn
- A pre-push hook could list the developer's open branches

### 3. Single PR

**One pull request in flight per developer unless explicitly authorized.**

Do not open a second PR while the first is awaiting review. If the first PR is blocked, address the blocker rather than starting new work.

**Why**: Multiple open PRs split reviewer attention and increase the risk of merge conflicts between your own PRs. Sequential PRs land faster than parallel ones.

**Exceptions**:

- Stacked PRs that are explicitly dependent (PR 2 targets PR 1's branch)
- Emergency fixes that cannot wait for the current PR to merge

**Enforcement options**:

- CI or bot check that warns when a developer has more than one open PR
- `/horse:implement` could check `gh pr list --author @me` before starting

---

## Commit Discipline

These rules complement the readiness gates (ADR-0007) at the commit level:

- **Conventional Commits**: All commits follow the format `type(scope): description` (e.g., `feat(scaffold): add TS support`). This makes changelogs, release notes, and retro reconstruction trivial.
- **Task ID references**: Include the task ID in the commit body when applicable (e.g., `T-025`, `US-083`).
- **Atomic commits**: Each commit should be a single logical change. Don't mix feature code with formatting fixes or unrelated refactors.
- **No `--no-verify` without justification**: If you bypass a hook, explain why in the commit message.

---

## PR Discipline

- **Title under 70 characters**: Use the PR body for details.
- **Link to story/task**: Reference the story (e.g., `US-083`) and task IDs in the PR description.
- **Summary + test plan**: Every PR description should include what changed and how to verify it.
- **Address all blocking comments**: Don't merge with unresolved `[blocking]` review comments.
- **Squash or rebase per git strategy**: Follow the project's configured `git_strategy` in `horse.config.md`.

---

## How Gates Support These Rules

| Rule | Gate | Check |
|---|---|---|
| Fresh branch | Gate 3 (push) | CI fails if branch can't rebase cleanly |
| Single branch | Gate 1 (sprint) | Sprint planning assigns one story at a time |
| Single PR | Gate 5 (merge) | Reviewer checks for other open PRs by author |
| Conventional commits | Gate 2 (commit) | Commit message lint (optional hook) |
| Doc-sync | Gate 4 (review) | `scripts/doc_sync_check.sh` verifies parity |
