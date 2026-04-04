---
name: pr-fix
description: Read PR review comments, triage each as fix/defer/accept, perform the work, and reply when done
---

# Skill: PR Fix

## Purpose

Process unresolved review comments on a pull request. For each comment, decide whether to fix, defer, or accept it — then perform the action and reply to the comment thread with what was done.

## Configuration

Read `.claude/config.json` (if present) to understand the project's language and toolchain for making code changes.

See `${CLAUDE_PLUGIN_ROOT}/schemas/config.schema.json` for the full schema.

## Prerequisites

- `gh` CLI installed and authenticated (`gh auth status`)
- An open pull request with review comments
- Working tree on the PR's head branch

## Workflow

```
Identify PR → Fetch comments → Triage each → Act → Commit → Reply → Summarize
```

### Step 1: Identify the PR

If a PR number is provided, use it. Otherwise, detect from the current branch:

```bash
gh pr view --json number,title,headRefName
```

Verify the current branch matches the PR's head branch. If not, warn the user.

### Step 2: Fetch All Review Comments

```bash
# Get all review comments with context
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments \
  --jq '.[] | {id, path, line, body, user: .user.login, created_at, in_reply_to_id}'
```

#### Filter Comments

- **Skip** comments that already have a reply indicating resolution (look for replies containing "Fixed in", "Addressed in", or "Resolved")
- **Skip** comments authored by the current user (don't fix your own review comments)
- **Group** comments by file for efficient processing

### Step 3: Triage Each Comment

For each unresolved comment, decide one of three actions:

| Action | When to Use | Code Change? |
|---|---|---|
| **fix** | Clear issue with a confident fix; within scope of the PR | Yes |
| **defer** | Valid concern but out of scope, needs discussion, or too risky | No |
| **accept** | Nit or style preference accepted as-is; already addressed elsewhere | No |

#### Triage Decision Criteria

**Fix** when:

- The comment identifies a clear bug or correctness issue
- The fix is localized (touches only files already in the PR)
- You have high confidence the fix is correct
- Tests can verify the fix

**Defer** when:

- The comment is valid but out of scope for this PR
- The fix would require significant refactoring
- The comment raises a design question that needs discussion
- You're not confident in the correct fix

**Accept** when:

- The comment is a nit or style preference and current code is acceptable
- The issue is already addressed elsewhere in the PR
- The comment is informational, not actionable

### Step 4: Apply Fixes

For each comment triaged as **fix**:

- Read the file and understand the context around the commented line
- Make the code change that addresses the feedback
- Run the relevant tests to verify the fix doesn't break anything
- Run the linter to ensure the fix meets standards

```bash
# Python — test and lint
python -m pytest tests/ -x --tb=short
ruff check . --fix && ruff format .

# TypeScript — test and lint
npx vitest run
npx eslint src/ --fix && npx prettier --write src/
```

**Important**: If a fix causes test failures, revert it and triage the comment as **defer** instead.

### Step 5: Commit All Fixes

Collect all fixes into a single commit:

```bash
git add <changed-files>
git commit -m "fix: address PR review comments

- <brief description of each fix>

Resolves review comments on #<PR_NUMBER>"
```

Push the commit:

```bash
git push origin <branch-name>
```

### Step 6: Reply to Each Comment

After committing, reply to each processed comment:

#### For **fix** comments:

```bash
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments/<COMMENT_ID>/replies \
  --method POST \
  --field body="**Fixed** in \`<commit-sha>\`. <brief description of what changed>."
```

#### For **defer** comments:

```bash
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments/<COMMENT_ID>/replies \
  --method POST \
  --field body="**Deferred.** <reason — e.g., out of scope for this PR, needs design discussion, tracked in #<issue>>."
```

#### For **accept** comments:

```bash
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments/<COMMENT_ID>/replies \
  --method POST \
  --field body="**Accepted (no change).** <brief rationale>."
```

### Step 7: Post Summary Comment

Post a summary on the PR listing all actions taken:

```bash
gh pr comment <PR_NUMBER> --body "<summary>"
```

#### Summary Format

```markdown
## Review Comment Resolution

| # | File | Comment | Action | Detail |
|---|---|---|---|---|
| 1 | `path/to/file.py:42` | Brief summary | Fixed | Commit `abc1234` |
| 2 | `path/to/other.ts:17` | Brief summary | Deferred | Out of scope |
| 3 | `path/to/file.py:88` | Brief summary | Accepted | Style preference |

**Fixes committed**: `<commit-sha>`
**Comments resolved**: N fixed, N deferred, N accepted
```

## Error Handling

- If `gh` is not installed: report error with install instructions
- If not on the PR branch: warn and suggest `git checkout <branch>`
- If a fix breaks tests: revert, triage as defer, explain in reply
- If API rate limited: report and suggest waiting
- If a comment cannot be confidently resolved: always defer rather than guess

## Safety Rules

1. **Never make speculative changes** — if you're not confident in the fix, defer it
2. **Always run tests** before committing fixes
3. **Never force-push** — always use regular push
4. **Preserve the author's intent** — fix the issue, don't rewrite the approach
5. **One commit for all fixes** — keep the PR history clean
