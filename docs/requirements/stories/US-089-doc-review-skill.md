---
id: US-089
title: Documentation review skill
status: draft
priority: Should Have
story_points: 5
section: "3.13 Doc Writer — Documentation Authoring & Maintenance"
---

# US-089 — Documentation review skill

> As a **developer**, I want **a documentation review skill that evaluates docs for clarity, accuracy, and completeness** so that **documentation is genuinely useful to readers, not just structurally compliant**.

## Context

The trainer audits documentation artifacts for structural completeness (are required sections present?) and the reviewer checks that docs exist in PRs. Neither evaluates whether documentation is *clear*, *accurate*, or *helpful*. A README can pass all structural checks while being confusing, outdated, or misleading.

The doc-review skill (`skills/doc-review/SKILL.md`) provides a guided workflow for deep documentation review covering:

- **Accuracy** — do docs match the current state of the code?
- **Clarity** — is the language clear, concise, and free of jargon?
- **Completeness** — are all user-facing features and configuration options documented?
- **Consistency** — do docs use consistent terminology, formatting, and tone?
- **Links & references** — do all internal links resolve? Are code examples valid?

## Acceptance Criteria

```gherkin
Given a documentation file (README, guide, API doc, or architecture doc)
When  the doc-review skill is invoked
Then  it evaluates the document against accuracy, clarity, completeness, and consistency criteria
And   it produces a structured review with findings categorized by severity (error, warning, suggestion)

Given a document that references code (function names, file paths, CLI flags, config options)
When  the doc-review skill checks accuracy
Then  it verifies each reference exists in the current codebase
And   it flags references to renamed, removed, or non-existent entities

Given a document with internal links
When  the doc-review skill checks links
Then  it verifies all relative links resolve to existing files
And   it reports broken links with the expected target

Given a document with code examples
When  the doc-review skill checks examples
Then  it verifies code examples are syntactically valid for the project's language
And   it flags examples that use deprecated APIs or patterns

Given a set of related documents (e.g., all docs in docs/)
When  the doc-review skill checks consistency
Then  it verifies terminology is consistent across documents
And   it flags contradictions between documents (e.g., README says X, architecture doc says Y)

Given the doc-review skill produces findings
When  the review is complete
Then  findings include the file path, line reference, severity, and a suggested fix
And   the summary indicates whether the documentation is ready for publication
```

## Notes

- Doc review is distinct from the trainer's process audit: the trainer checks "do required artifacts exist?"; doc review checks "are existing artifacts good?"
- Doc review is distinct from the reviewer's PR review: the reviewer checks "did this PR update docs?"; doc review checks "is the documentation effective?"
- The skill should be invocable on a single file, a directory, or the entire `docs/` tree
- Consider integration with the diagrams skill for verifying Mermaid diagram accuracy
