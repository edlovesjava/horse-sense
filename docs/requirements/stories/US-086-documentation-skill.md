---
id: US-086
title: Documentation authoring skill
status: draft
priority: Must Have
story_points: 8
section: "3.13 Doc Writer — Documentation Authoring & Maintenance"
---

# US-086 — Documentation authoring skill

> As a **developer**, I want **a documentation skill that guides authoring READMEs, markdown docs, and CHANGELOGs** so that **project documentation is structured, complete, and follows established standards**.

## Context

The plugin mandates README structure (7 sections), CHANGELOG format (Keep a Changelog), and Markdown standards (ATX headings, fenced code blocks, 100-char line wrap) in `rules/documentation.md` — but no skill provides step-by-step guidance for creating or updating these artifacts.

The documentation skill (`skills/documentation/SKILL.md`) provides guided workflows for:

- **README authoring** — elicit project info, structure sections, write content, verify completeness
- **Markdown docs** — create/update docs in `docs/` subdirectories (API reference, guides, runbooks)
- **CHANGELOG maintenance** — extract changes from commits/PRs, categorize, format per Keep a Changelog

## Acceptance Criteria

```gherkin
Given a project without a README or with an incomplete README
When  the documentation skill is invoked for README authoring
Then  it scaffolds a README covering all 7 mandatory sections from rules/documentation.md
And   it populates sections from the current project state (config, commands, structure)

Given an existing README
When  the documentation skill is invoked for README update
Then  it identifies sections that are outdated or incomplete
And   it proposes updates based on the current codebase state
And   it preserves user-authored content that is still accurate

Given a project using the per-story requirements format
When  the documentation skill creates docs in docs/
Then  it follows the directory structure defined in rules/documentation.md
And   each document uses ATX headings, fenced code blocks, and tables per Markdown standards

Given a project with recent commits or merged PRs
When  the documentation skill is invoked for CHANGELOG maintenance
Then  it extracts changes from git history since the last release tag
And   it categorizes entries as Added, Changed, Fixed, Deprecated, Removed, or Security
And   it formats the output per Keep a Changelog convention

Given any documentation artifact
When  the documentation skill finishes authoring
Then  it verifies all internal links resolve to existing files
And   it verifies code examples are syntactically valid
```

## Notes

- The skill should read `.claude/config.json` for language, framework, paths, and test runner
- The skill should read `horse.config.md` for requirements format and git strategy
- README authoring should reference `rules/documentation.md` lines 9-17 for the mandatory section list
- CHANGELOG authoring should reference `rules/documentation.md` lines 19-37 for format
- Consider adding a `templates/readme.md` scaffold for the README workflow
