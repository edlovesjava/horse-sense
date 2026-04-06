# ADR-0007: Readiness-Gate Policy

**Status**: Accepted
**Date**: 2026-04-06
**Decision makers**: Ed Wentworth

## Context

Sprint 3 exposed process drift: stories were never transitioned out of `draft` status, doc-sync between frontmatter and index tables broke silently, and there was no automated guardrail preventing incomplete work from landing. The Sprint 3 retrospective proposed a five-gate readiness ladder to catch these problems before they propagate.

The gates must be:

- **Incremental** — each gate checks only what is new since the previous gate, so feedback is fast.
- **Automatable** — the first four gates run without human intervention (trainer agent + CI). Only the merge gate requires human approval.
- **Bypassable with ceremony** — in emergencies, any automated gate can be overridden, but the override must be recorded.

### Alternatives considered

1. **No gates (status quo)** — rely on developer discipline and post-sprint audits. Failed in Sprint 3; drift was caught too late.
2. **Single CI gate at PR time** — runs everything at once. Feedback is slow and developers don't know which stage failed.
3. **Five-gate ladder (chosen)** — progressive checks at natural development boundaries. Fast feedback, clear ownership, explicit bypass rules.

## Decision

Adopt a five-gate readiness ladder. Each gate defines: what is checked, who owns the check, what happens on failure, and how to bypass.

### Gate 1: Ready for Sprint

**When**: Before a story enters a sprint backlog (during `/horse:sprint`).

| Check | Owner | Automation |
|---|---|---|
| Story has title, description, acceptance criteria, priority, and estimate | Planner / Trainer | Manual review (trainer checklist) |
| Dependencies identified | Planner | Manual review |
| Story follows INVEST principles | Planner / Trainer | Manual review |

**On failure**: Story stays in backlog as `draft` or `ready`; does not enter sprint.
**Bypass**: Sprint owner can pull a story with documented gaps if capacity allows addressing them in-sprint.

### Gate 2: Ready for Commit

**When**: Before `git commit` (can be enforced via pre-commit hook or developer discipline).

| Check | Owner | Automation |
|---|---|---|
| Unit tests pass | Developer | `pytest -m unit` / `vitest run tests/unit` |
| Linter passes | Developer | `ruff check` / `eslint` |
| Type checker passes | Developer | `mypy` / `tsc --noEmit` |

**On failure**: Commit blocked (if hook) or developer fixes before committing.
**Bypass**: `--no-verify` with a comment in the commit message explaining why.
**Local command**: `make gate-commit`

### Gate 3: Ready for Push

**When**: Before `git push` (can be enforced via pre-push hook or CI on push).

| Check | Owner | Automation |
|---|---|---|
| All tests pass (unit + integration + e2e) | Developer | `pytest` / `vitest run` |
| No test regressions | CI | Full test suite in CI |

**On failure**: Push blocked (if hook) or CI marks the branch as failing.
**Bypass**: `--no-verify` with justification; CI failure is visible to reviewers.
**Local command**: `make gate-push`

### Gate 4: Ready for Review

**When**: Before requesting PR review (enforced by CI check on PR).

| Check | Owner | Automation |
|---|---|---|
| Doc-sync check passes (story frontmatter ↔ index table ↔ sprint plan) | Trainer / CI | `scripts/doc_sync_check.sh` |
| Markdown lint passes | CI | `markdownlint-cli2` |
| Frontmatter validation passes | CI | `scripts/validate_plugin.sh` |
| Plugin structure validation passes | CI | `scripts/validate_plugin.sh` |

**On failure**: PR is not reviewable; author fixes doc-sync or lint issues first.
**Bypass**: Reviewer can approve with documented exceptions for non-material doc drift.
**Local command**: `make gate-review`

### Gate 5: Ready for Merge

**When**: Before merging a PR to the target branch.

| Check | Owner | Automation |
|---|---|---|
| Human review approval | Reviewer | GitHub PR approval |
| All CI checks green | CI | GitHub branch protection |
| No unresolved blocking comments | Reviewer | Manual verification |

**On failure**: PR cannot be merged; author addresses review feedback.
**Bypass**: Repository admin can merge with justification recorded in PR description.

## Gate Sequence

```
Ready for Sprint → Ready for Commit → Ready for Push → Ready for Review → Ready for Merge
      (manual)         (local/hook)       (local/CI)        (CI)              (human)
```

Gates run in order. A downstream gate assumes all upstream gates have passed. CI jobs enforce this by skipping downstream gates when an upstream gate fails.

## Local Execution

Developers can run any gate locally:

```bash
make gate-commit   # unit tests + lint + typecheck
make gate-push     # full test suite
make gate-review   # doc-sync + markdown lint + frontmatter + structure
make check         # all gates (equivalent to gate-review)
```

## Consequences

### Positive

- Drift is caught at the earliest possible point, reducing rework.
- Clear ownership: developers own gates 2–3, trainer/CI owns gate 4, humans own gates 1 and 5.
- Progressive feedback: developers get fast unit-test feedback at commit time, not 10 minutes later in CI.
- Bypass rules prevent the gates from becoming a bottleneck in emergencies.

### Negative

- Pre-commit/pre-push hooks add friction to the local development loop. Mitigated by keeping gate-commit fast (unit tests only).
- Doc-sync check (gate 4) is a new script that must be maintained. Mitigated by starting with exact-string status comparison only.
- Five gates may feel ceremonial for small changes. Mitigated by allowing bypass with justification.

### Neutral

- This ADR does not mandate git hooks; it defines the gates. Hook installation is optional (documented in workflow rules).
