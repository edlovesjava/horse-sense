# Horse Project Configuration

> Place this file in your project root as `horse.config.md`.
> Commands and skills read this file to adapt their behavior.

## Requirements Format

<!-- Choose one: "monolith" or "per-story" -->

requirements_format: monolith

### Options

- **monolith** — All user stories live in a single `requirements_doc.md` file.
  Best for small projects with fewer than ~15 stories.

- **per-story** — Each user story is a separate file under `docs/requirements/stories/`.
  Files are named `US-<NNN>-<kebab-title>-<status>.md` with YAML frontmatter.
  A lightweight `requirements_doc.md` serves as the index (background, NFRs, stakeholders)
  while story details live in individual files.

## Requirements Directory

<!-- Only used when requirements_format is "per-story" -->

requirements_stories_dir: docs/requirements/stories

## Git Strategy

<!-- Choose one: "rebase" or "merge" -->

git_strategy: rebase

### Options

- **rebase** — Prefer rebasing feature branches onto the target branch before merging.
  Produces a linear commit history. Best for small teams and solo developers.

- **merge** — Prefer merge commits to integrate feature branches.
  Preserves branch topology and is easier to revert. Best for larger teams or when
  branch history matters.
