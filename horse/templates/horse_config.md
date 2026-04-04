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
