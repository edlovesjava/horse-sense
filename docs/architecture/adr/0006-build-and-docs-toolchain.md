# ADR-0006: Build, CI, and Documentation Toolchain

**Status**: Accepted
**Date**: 2026-04-05
**Decision makers**: Ed Wentworth

## Context

horse-sense needs three pieces of project infrastructure:

1. **A task runner** — a single, discoverable entry point for running validation, linting, building the docs site, and other repeatable project chores.
2. **A continuous integration system** — to validate every pull request and push to `main`, enforcing the same checks a developer runs locally.
3. **A documentation generator** — to render the plugin's commands, agents, skills, rules, and architecture docs as a navigable, searchable static site, published automatically on merge to `main`.

These choices have been de-facto in place since Sprint 2 (Makefile, GitHub Actions) and Sprint 3 Part 4 (MkDocs). This ADR records the rationale so future contributors understand why, and so a change of toolchain is treated as a deliberate decision rather than drift.

### Alternatives considered

**Task runner:**

1. **Make / Makefile** — ubiquitous, zero extra install, text-based, self-documenting via `make -p` / target names
2. **Just** (`just` / justfile) — nicer syntax, better error messages, but requires a separate install
3. **npm scripts** — forces a `package.json` at the repo root even though the plugin is polyglot (Python + shell)
4. **Shell scripts only** — no central entry point; contributors have to discover `scripts/*.sh` themselves

**CI system:**

1. **GitHub Actions** — native to the host, PR integration out of the box, free tier for public repos, huge action ecosystem
2. **CircleCI / Travis / GitLab CI** — either requires an external account or the project to live elsewhere
3. **No CI, local `make check` only** — breaks the "every PR validated" guarantee; easy to regress

**Docs generator:**

1. **MkDocs + Material theme** — Python-native, strict mode for link checking, live-reload dev server, Material theme provides search, dark mode, code-copy, admonitions, and tabs with zero custom work
2. **Sphinx** — more powerful but reStructuredText-first; our content is already Markdown
3. **Docusaurus** — excellent theme, but brings a full React/Node toolchain that duplicates the npm footprint we deliberately keep out of the plugin
4. **GitHub's built-in README rendering** — adequate for one file, inadequate for 100+ pages of commands/agents/skills/rules

## Decision

Adopt the following toolchain for project infrastructure:

### Task runner: `make`

- Root `Makefile` with the canonical targets: `check`, `fix`, `validate`, `lint`, `docs`, `docs-serve`, `docs-deps`, `docs-clean`.
- `make check` is the single command every contributor and CI job runs to validate the plugin.
- `make docs` builds the documentation site from a dedicated `.venv-docs/` virtualenv (isolated from any Python venv the user may have active).
- All targets are `.PHONY` — the Makefile is a task runner, not a dependency graph.

### CI system: GitHub Actions

- Single workflow file: `.github/workflows/ci.yml`.
- Jobs:
  - **check** — mirrors `make check` exactly (plugin structure validation, frontmatter, markdownlint, shellcheck). Runs on every PR and push to `main`.
  - **docs** — runs `mkdocs build --strict`, failing the build on any broken link or warning. Runs on every PR and push.
  - **deploy-docs** — runs `mkdocs gh-deploy --force --no-history` on push to `main` only, gated on both `check` and `docs` passing. Publishes to the `gh-pages` branch.
- Pin actions to major version only (`@v5`, `@v6`). Track upstream deprecation notices (e.g., Node runtime bumps) and update promptly.

### Documentation generator: MkDocs + Material

- Config at repo root: `mkdocs.yml`.
- `docs_dir: docs` — existing project docs (ADRs, architecture, requirements, plans) live here unchanged.
- Dependencies pinned in `docs/requirements.txt`: `mkdocs`, `mkdocs-material`, `mkdocs-include-markdown-plugin`.
- Plugin content (`horse/commands/`, `horse/agents/`, `horse/skills/`, `horse/rules/`) is **not** duplicated into `docs/`. Instead, wrapper pages in `docs/` use `mkdocs-include-markdown-plugin` to inline the source files at build time. The plugin remains the single source of truth.
- `strict: true` (via `--strict` on build) is mandatory in CI — broken links are build failures, not warnings.
- Published to GitHub Pages at `https://edlovesjava.github.io/horse-sense/`.

## Consequences

**Positive:**

- Zero extra install for the core task runner — `make` is on every developer machine.
- `make check` local ↔ `check` CI job parity means "green locally" and "green in CI" agree.
- MkDocs + Material is low-effort for high-quality output: search, dark mode, code-copy, mobile nav all for free.
- `include-markdown` avoids content duplication — plugin authors edit `horse/` as normal and the site updates automatically.
- Strict-mode docs build catches broken references across the whole plugin on every PR.
- Publishing to `gh-pages` is push-to-deploy — no manual release step.

**Negative:**

- Makefiles have historical baggage (tabs-vs-spaces, implicit rules) that can trip up newcomers. Mitigated by keeping every target `.PHONY` and explicit.
- GitHub Actions locks CI to GitHub hosting. If the project ever moves, the workflow must be rewritten.
- MkDocs is Python-only; TypeScript-native contributors must still run a Python venv to build docs locally (mitigated by `make docs-deps` which creates `.venv-docs/` automatically).
- The `include-markdown` indirection means a broken link inside an included file surfaces as a warning on the *wrapper* page, not the source. Error messages require one extra step of interpretation.
- GitHub Pages requires a one-time manual setting (`Settings → Pages → Source: gh-pages`) that must be configured by a repo admin after the first `deploy-docs` run.

## Revisit when

- The plugin adds content beyond what Markdown can express (API reference, interactive examples) — may justify a move to Docusaurus or MDX.
- CI runtime on GitHub-hosted runners becomes a bottleneck — may justify self-hosted runners or a different CI system.
- A second contributor expresses friction with `make` — consider `just` as a drop-in replacement.
