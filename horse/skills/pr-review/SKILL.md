---
name: pr-review
description: Review a pull request and post structured comments with severity labels using the gh CLI
---

# Skill: PR Review

## Purpose

Review a pull request for correctness, code quality, security, and adherence to project standards. Post actionable inline comments directly on the PR using the GitHub CLI, categorized by severity.

## Configuration

Read `.claude/config.json` (if present) to understand the project's language and toolchain. Apply the appropriate rules:

- **Python**: `${CLAUDE_PLUGIN_ROOT}/rules/code_quality.md`
- **TypeScript**: `${CLAUDE_PLUGIN_ROOT}/rules/typescript_quality.md`
- **Both**: `${CLAUDE_PLUGIN_ROOT}/rules/testing.md`, `${CLAUDE_PLUGIN_ROOT}/rules/documentation.md`, `${CLAUDE_PLUGIN_ROOT}/rules/git_workflow.md`

See `${CLAUDE_PLUGIN_ROOT}/schemas/config.schema.json` for the full schema.

## Prerequisites

- `gh` CLI installed and authenticated (`gh auth status`)
- An open pull request on the current repository

## Workflow

```
Identify PR → Fetch diff → Analyze changes → Post comments → Post summary
```

### Step 1: Identify the PR

If a PR number or URL is provided, use it directly. Otherwise, detect the PR for the current branch:

```bash
# Auto-detect PR for current branch
gh pr view --json number,title,url,headRefName,baseRefName
```

If no PR exists for the current branch, report an error and suggest creating one.

### Step 2: Fetch the PR Diff and Changed Files

```bash
# Get the full diff
gh pr diff <PR_NUMBER>

# Get list of changed files with stats
gh pr diff <PR_NUMBER> --stat

# Get PR details (description, labels, checks)
gh pr view <PR_NUMBER> --json title,body,labels,statusCheckRollup,files
```

### Step 3: Fetch Existing Comments

Before posting, check for existing review comments to avoid duplicates:

```bash
# Get all review comments on the PR
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments --jq '.[].body'
```

Skip posting a comment if a substantially similar comment already exists on the same file and line.

### Step 4: Analyze Each Changed File

For each changed file, apply the review checklist from `${CLAUDE_PLUGIN_ROOT}/agents/reviewer.md`:

#### Correctness

- Does the code correctly implement the stated requirements?
- Are edge cases and error conditions handled?
- Are there obvious logic errors or off-by-one mistakes?

#### Code Quality

- Is the code readable and self-explanatory?
- Are functions and variables named clearly?
- Does it follow project naming conventions and style?
- Are there length limit violations (function > 30 lines, class > 200)?

#### Testing

- Are there sufficient tests for the new code?
- Do tests validate behavior, not just assert true?
- Are edge cases covered?

#### Security

- Is user input validated and sanitized?
- Are secrets handled via environment variables?
- Are there injection risks (SQL, XSS, path traversal)?
- Are dependencies up-to-date?

#### Performance

- Are there N+1 query problems?
- Are expensive operations cached?
- Are large data sets streamed?

#### Documentation

- Are public APIs documented?
- Are new environment variables documented?
- Is README or relevant docs updated?

### Step 5: Post Inline Review Comments

For each issue found, post an inline comment on the specific line using the GitHub API:

```bash
# Post a review with inline comments
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/reviews \
  --method POST \
  --field event="COMMENT" \
  --field body="<summary>" \
  --field 'comments=[{"path":"<file>","line":<line>,"body":"<comment>"}]'
```

#### Comment Format

Each comment should follow this structure:

```
**[must-fix]** Brief title

Description of the issue and why it matters.

**Suggestion:**
\`\`\`<language>
// suggested fix here
\`\`\`
```

#### Severity Labels

| Label | Meaning | Merge? |
|---|---|---|
| `[must-fix]` | Correctness or security issue | Block merge |
| `[should-fix]` | Code quality or maintainability concern | Should address |
| `[nit]` | Minor style or preference | Author's discretion |

### Step 6: Post Summary Review

After analyzing all files, post a summary review comment:

```bash
# Approve if no issues
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/reviews \
  --method POST \
  --field event="APPROVE" \
  --field body="<summary>"

# Request changes if must-fix issues found
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/reviews \
  --method POST \
  --field event="REQUEST_CHANGES" \
  --field body="<summary>"
```

#### Summary Format

```markdown
## PR Review Summary

**Overall**: Approve / Request Changes / Needs Discussion

| Severity | Count |
|---|---|
| must-fix | N |
| should-fix | N |
| nit | N |

### Key Findings
- [Brief description of most important issues]

### What's Good
- [Acknowledge well-written code or good decisions]
```

## Error Handling

- If `gh` is not installed: report error with install instructions
- If not authenticated: suggest `gh auth login`
- If no PR found: suggest creating one with `gh pr create`
- If API rate limited: report the limit and suggest waiting

## Tips

- Review the PR description and linked ticket before analyzing code
- Consider the full context of a change, not just individual lines
- Praise good patterns — reviews shouldn't be only negative
- If unsure about intent, ask a question rather than assuming a bug
