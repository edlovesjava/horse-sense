# Configuration

horse-sense uses two configuration layers.

## `horse.config.md` — SDLC Workflow Settings

Place in your project root. Scaffolded from `templates/horse_config.md`. Controls how the plugin organizes your project.

| Setting | Values | Default | Description |
|---|---|---|---|
| `requirements_format` | `monolith` / `per-story` | `monolith` | How user stories are organized |
| `requirements_stories_dir` | directory path | `docs/requirements/stories` | Where per-story files live |
| `git_strategy` | `rebase` / `merge` | `rebase` | How feature branches are integrated |

- **monolith** — all stories in a single `requirements_doc.md`
- **per-story** — lightweight `requirements_doc.md` index + individual `US-<NNN>-<title>-<status>.md` files
- **rebase** — rebase feature branches onto target before merging (linear history)
- **merge** — use merge commits to integrate branches (preserves branch topology)

## `.claude/config.json` — Toolchain Settings

Per-project toolchain configuration read by skills and agents. Auto-detected from `pyproject.toml` (Python) or `package.json` (TypeScript) if absent.

| Setting | Python default | TypeScript default |
|---|---|---|
| `language` | `python` | `typescript` |
| `framework` | (none) | (none) |
| `testRunner` | `pytest` | `vitest` |
| `linter` | `ruff check` | `eslint` |
| `typeChecker` | `mypy` | `tsc --noEmit` |
| `formatter` | `ruff format` | `prettier --write` |
| `srcDir` | `src` | `src` |
| `testDir` | `tests` | `tests` |
| `coverageThreshold` | `80` | `80` |

- Full schema: [`horse/schemas/config.schema.json`](https://github.com/edlovesjava/horse-sense/blob/main/horse/schemas/config.schema.json)
- Example configs: [Python](https://github.com/edlovesjava/horse-sense/blob/main/horse/templates/config.example.python.json), [TypeScript](https://github.com/edlovesjava/horse-sense/blob/main/horse/templates/config.example.typescript.json)
