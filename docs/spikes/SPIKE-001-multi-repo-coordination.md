# SPIKE-001: Multi-Repository Coordination Patterns

> **Status**: Complete
> **Author**: Scout (Claude Sonnet 4.6)
> **Date**: 2026-04-06
> **Timebox**: 3 hours

---

## Question

How should the horse-sense project coordinate work across three repositories:

1. **horse-sense** — the Claude Code plugin (this repo)
2. **target application** — a separate repo using the horse plugin during development
3. **framework library** — a shared library consumed by the plugin and/or the target app

What processes, tools, and patterns exist for versioning, CI/CD, local development, and Claude Code-specific plugin workflows across these repos?

## Approach

- [x] Survey monorepo vs polyrepo vs hybrid structural options and their fitness for this scenario
- [x] Investigate git submodules vs git subtree — practical tradeoffs for a small team
- [x] Research cross-repo versioning patterns: semantic versioning, changelogs, dependency pinning
- [x] Research dependency update automation: Renovate vs Dependabot
- [x] Research cross-repo CI/CD: GitHub Actions `repository_dispatch`, contract testing
- [x] Research local development workflows: Python editable installs (uv), pnpm workspaces
- [x] Investigate Claude Code plugin-specific development patterns: `--plugin-dir`, dev marketplace
- [x] Identify what is unique about the plugin-as-dev-tool scenario vs plugin-as-library

---

## Findings

### Finding 1: Structural topology — the scenario favors a bounded polyrepo

The three-repo scenario described is not a standard microservices polyrepo (independent services
shipping independently) nor a monorepo (one unified repo). It is a **tool-plus-library-plus-consumer**
topology that appears frequently in developer tooling projects (e.g., a CLI framework repo, a shared
utilities library, and an example or reference application that consumes both).

Key structural facts:

- The horse plugin and the framework library are **coupled by contract** — breaking changes in the
  library ripple into the plugin, which then ripples into any target app.
- The target app is a **consumer, not a co-developer**; it does not contribute back to the library or
  plugin. Its primary concern is: "which version of the plugin am I using today?"
- The plugin is loaded at Claude Code startup via `--plugin-dir`, not imported at build time. This
  means the plugin's "API" is the directory structure and markdown files it exposes, not a compiled
  package interface.

This topology maps cleanly to a **polyrepo with a thin coordination layer** — three separate repos,
each with its own release cycle, tied together by:

- Semantic versioning on the library and plugin
- A manifest reference (the `--plugin-dir` path or a marketplace entry) in the target app
- Automated dependency update PRs (Renovate) to keep the target app's plugin version current

A full monorepo is achievable but adds tooling overhead (Nx/Turborepo, workspace configs) that buys
little for a team of 1–3 developers. The coupling between these repos is **version-mediated**, not
real-time, so atomic cross-repo commits are not a frequent requirement.

### Finding 2: Git submodules and subtrees are poor fits here

Both git submodules and git subtrees are designed for **embedding one repo inside another**. Neither
fits this topology cleanly:

**Submodules** bring a snapshot of a foreign repo into a parent repo as a tracked commit reference.
The operational burden is well-documented: developers must remember `git submodule update --init`,
CI pipelines need extra flags, and keeping the submodule reference current is a manual task.
Submodules make sense when the embedded code is a dependency you modify infrequently and want
isolated from your main history (e.g., embedding a vendor library).

**Subtrees** merge foreign repo history inline. They avoid the "forgot to init" footgun but produce
messy history and complicate upstream contributions. They also do not cleanly model a
library-consumer relationship — they model "absorbing code from another repo."

**Neither solves the coordination problem here.** The right model for the framework library is a
published package (PyPI, npm, or a GitHub Packages registry), not an embedded repo. The right model
for the plugin in the target app is a `--plugin-dir` path or marketplace reference.

### Finding 3: Semantic versioning + changelogs is the primary coordination mechanism

For a polyrepo of this type, the primary coordination mechanism is disciplined versioning:

- **Framework library**: follows semver strictly. `MAJOR` bumps signal breaking changes; all
  consumers must explicitly adopt them. Every release produces a `CHANGELOG.md` entry.
- **horse plugin**: also follows semver. The `plugin.json` `version` field is the authoritative
  version identifier. The plugin changelog documents changes to agents, skills, commands, and
  templates.
- **Target app**: pins the plugin to a specific version (via `--plugin-dir` pointing at a tagged
  checkout, or a marketplace entry with a locked version). Upgrading is a deliberate act, not
  automatic.

The `CHANGELOG.md` format from `rules/documentation.md` (Keep a Changelog style) already covers
this. The addition needed is a **release tagging convention** (`v1.2.3` tags on git) and a
**release notes step** in CI.

### Finding 4: Renovate is the right dependency update automation tool

For automating dependency bumps when a new library version is released and the plugin or target app
need to adopt it, **Renovate** is the better choice over Dependabot for this use case:

| Criterion | Renovate | Dependabot |
|---|---|---|
| Platform support | GitHub, GitLab, Bitbucket, Azure DevOps | GitHub only |
| Monorepo / workspace awareness | Yes — detects all package.json/pyproject.toml files, groups updates | Limited — requires manual group config |
| Cross-repo coordination | Can coordinate PRs across repos via a central config repo | No cross-repo awareness |
| Package manager coverage | 90+ (pip, poetry, uv, npm, pnpm, Docker, GH Actions, etc.) | ~30 ecosystems |
| Configuration expressiveness | Very high — packageRules, grouping, automerge policies | Lower |
| Self-hosted option | Yes (open source) | GitHub-hosted only |

For the specific scenario (library releases trigger PRs in plugin and target app), Renovate supports
a **central config repository** pattern: one `renovate-config` repo holds shared Renovate presets
that all repos inherit. This lets a small team maintain update policies in one place.

Renovate can be configured to:

- Automerge patch-level library bumps in the plugin repo (low risk, no review needed)
- Open PRs for minor/major bumps with a changelog link for human review
- Group related dependency updates into a single PR

### Finding 5: GitHub Actions `repository_dispatch` for cross-repo CI coordination

When the framework library publishes a new release, downstream repos (plugin, target app) should
be notified to run their integration tests against the new version. GitHub Actions supports this
via the `repository_dispatch` event:

```yaml
# In the framework library's release workflow:
- name: Notify downstream repos
  uses: peter-evans/repository-dispatch@v3
  with:
    token: ${{ secrets.CROSS_REPO_PAT }}
    repository: org/horse-sense
    event-type: library-released
    client-payload: '{"version": "${{ steps.release.outputs.version }}"}'
```

The receiving repo registers a workflow triggered by `repository_dispatch`:

```yaml
# In horse-sense/.github/workflows/downstream-check.yml:
on:
  repository_dispatch:
    types: [library-released]

jobs:
  integration-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test against new library version
        run: |
          pip install framework-library==${{ github.event.client_payload.version }}
          pytest tests/integration/
```

This creates a lightweight dependency chain without requiring a monorepo or shared CI system.

**Limitation**: The trigger token needs `repo` scope on the target repo, which means using a
Personal Access Token (PAT) or a GitHub App — the default `GITHUB_TOKEN` cannot trigger workflows
in other repos. For a small team, a dedicated machine-user PAT stored as an organization secret is
the pragmatic approach.

### Finding 6: Contract testing is optional but valuable at the plugin/library boundary

**Pact** contract testing is the standard approach for validating that a provider (library) and
consumer (plugin) remain compatible after changes. However, it is designed for HTTP-based
service contracts, not Python/TypeScript library APIs.

For a shared Python/TypeScript library, the practical equivalent of contract testing is:

- **Integration tests in the plugin repo** that import the library and exercise the specific
  functions/classes the plugin depends on. These run in CI against the pinned version and against
  the `main` branch of the library (via `repository_dispatch`).
- A **compatibility matrix**: CI runs against the last N supported versions of the library, not
  just the latest.

Full Pact adoption adds significant tooling complexity for a team of 1–3 developers. The
recommendation is to defer it unless the library becomes widely consumed by external teams.

### Finding 7: Local development workflow — editable installs and `--plugin-dir`

**For the Python stack (framework library consumed by plugin):**

`uv` supports editable installs across repositories via `uv add --editable /path/to/local/library`.
This creates a live symlink: changes to the library source are immediately reflected in the plugin's
environment without reinstalling.

Typical local dev layout:

```
~/projects/
├── horse-sense/          ← plugin repo (this repo)
├── framework-library/    ← library repo (checked out locally)
└── my-target-app/        ← target app repo
```

In `horse-sense/pyproject.toml` (development override, not committed to main):

```toml
[tool.uv.sources]
framework-library = { path = "../framework-library", editable = true }
```

Or via command:

```bash
cd horse-sense
uv add --editable ../framework-library
```

This is standard Python development practice and requires no special tooling beyond `uv`.

**For the TypeScript stack (if applicable):**

`pnpm` workspaces with the `workspace:` protocol provide the same capability within a monorepo.
For cross-repo local development, `pnpm link` or `npm link` achieves a similar live-symlink
result, though the `workspace:` protocol is only available within a single pnpm workspace root.

**For the Claude Code plugin specifically:**

The `--plugin-dir` flag is the primary local development mechanism. When developing the plugin
and testing it against a target app in another directory, the developer points `--plugin-dir`
at the local plugin checkout:

```bash
# From within the target app directory:
claude --plugin-dir /home/user/projects/horse-sense/horse
```

Claude Code documentation confirms that a `--plugin-dir` plugin takes precedence over any
installed marketplace version of the same plugin name for that session. This means the developer
can have the horse plugin installed globally (for production use) while overriding it locally
for development testing.

The `/reload-plugins` command reloads skills, agents, hooks, and MCP servers without restarting
Claude Code, enabling rapid iteration during plugin development.

**Multiple plugins can be loaded simultaneously:**

```bash
claude --plugin-dir ./horse --plugin-dir ../some-other-plugin
```

This is relevant if the target app also uses a secondary plugin — both can be loaded in the
same development session.

### Finding 8: Dev container as a cross-repo environment anchor

For a small team using GitHub Codespaces or VS Code dev containers, a `.devcontainer/` in the
target app repo can:

- Check out the plugin repo as a sibling directory during container initialization
- Install the framework library in editable mode
- Set an alias or script that launches `claude --plugin-dir ../horse-sense/horse`

This gives every developer (human or AI agent) an identical environment with the correct local
plugin wired in. The `devcontainer.json` `postCreateCommand` is the right hook:

```json
{
  "postCreateCommand": "git clone https://github.com/org/horse-sense ../horse-sense && uv sync && uv add --editable ../framework-library"
}
```

**Assumption** (unvalidated): GitHub Codespaces allows sibling directory checkouts via
`postCreateCommand`. This should be validated before committing to the pattern.

### Finding 9: Claude Code-specific consideration — plugin as dev tool, not runtime dependency

A critical distinction for this scenario: the horse plugin is a **development tool**, not a
runtime dependency of the target app. This changes the coordination calculus significantly:

- The target app does not ship with the plugin. There is no production deployment that includes
  `--plugin-dir`. The plugin only matters during development sessions.
- Breaking changes in the plugin do not break the target app at runtime — they only break
  developer workflows. Recovery is fast (pin an older plugin version, or fix and reload).
- The plugin's "versioned surface" is its skills, agents, and command behaviors — all markdown
  files. There is no compiled binary to version-check at import time.

This means the **urgency of cross-repo dependency coordination is lower** than it would be for a
runtime library. The team can be more relaxed about plugin versioning cadence. A weekly or
bi-weekly Renovate PR cadence for plugin updates is sufficient for most target apps.

---

## Trade-off Matrix

| Approach | Pros | Cons | Effort | Risk |
|---|---|---|---|---|
| **Full monorepo** (Nx/Turborepo) | Atomic commits; unified CI; shared tooling; AI context advantage | Tooling overhead; single blast radius; overkill for 1-3 devs | High | Medium |
| **Polyrepo + semver + Renovate** | Each repo ships independently; clear ownership; low tooling overhead | Coordination lag between repos; cross-repo changes require multiple PRs | Low | Low |
| **Git submodules** | Version-pins embedded code; no external registry needed | High operational friction; poor DX; CI complexity | Medium | High (developer error) |
| **Git subtrees** | Simpler than submodules; no extra commands after initial setup | Messy history; hard to contribute back upstream; not designed for library pattern | Medium | Medium |
| **Hybrid: polyrepo + shared devcontainer** | Consistent local environment; low coordination overhead; works well with Claude Code `--plugin-dir` | Devcontainer setup is one-time investment; sibling clone assumption needs validation | Low-Medium | Low |

---

## Recommendation

**Adopt the polyrepo + semver + Renovate + shared devcontainer pattern.** Confidence: **High**.

Rationale:

1. The three-repo topology is naturally polyrepo — the repos have different release cadences,
   different audiences, and the plugin is a dev-time tool, not a runtime dependency.
2. Semver on the framework library and plugin plugin.json, combined with a Keep a Changelog
   `CHANGELOG.md` in each repo, provides the coordination visibility the team needs without
   tooling overhead.
3. Renovate automates the "bump the dependency version" PRs across repos, handling both Python
   and TypeScript ecosystems with a single tool. Configure it with automerge for patch updates
   and human review for minor/major.
4. GitHub Actions `repository_dispatch` provides lightweight cross-repo CI coordination when the
   library releases. A PAT with repo scope stored as an org secret is sufficient.
5. Python editable installs (`uv add --editable ../framework-library`) and the Claude Code
   `--plugin-dir` flag together cover the local development workflow with no additional tooling.
6. A `.devcontainer/postCreateCommand` in the target app repo can encode the full local setup,
   giving AI agents and human developers a consistent starting point.

**Do not adopt** git submodules or subtrees for this scenario. They add friction without solving
the actual coordination problem (which is versioning, not embedding).

**Defer** full Pact contract testing until the framework library has external consumers beyond
this team. The overhead is not justified at the current scale.

**Revisit** the monorepo option if the team grows beyond 3 developers, if cross-repo atomic
changes become a weekly occurrence, or if Nx's Polygraph feature (cross-repo dependency graph
without moving code) matures further and becomes accessible to small teams.

---

## Open Questions

- [ ] **Assumption validation**: Can GitHub Codespaces `postCreateCommand` clone sibling repos
  in the workspace? (Test in a throwaway Codespace before committing the pattern to documentation.)
- [ ] **Registry choice**: Where will the framework library be published? PyPI (public), GitHub
  Packages (private/org), or a local path dependency only? This affects how Renovate discovers
  new versions.
- [ ] **Plugin marketplace vs `--plugin-dir`**: The Claude Code docs describe a "dev marketplace"
  pattern using a `.claude-plugin/marketplace.json` that references local plugins via relative
  paths. Is this more ergonomic than a shell alias wrapping `--plugin-dir`? Worth a short follow-up
  spike or direct experiment.
- [ ] **PAT management**: A cross-repo PAT for `repository_dispatch` needs rotation policy and
  secure storage. Is a GitHub App (no expiry, fine-grained permissions) preferable for longevity?

---

## Next Steps

- [ ] Validate the devcontainer sibling-clone assumption in a test Codespace.
- [ ] Draft an ADR: "ADR-001: Polyrepo coordination strategy for horse-sense ecosystem" capturing
  the decision to use polyrepo + semver + Renovate.
- [ ] Add `CHANGELOG.md` to this repo following Keep a Changelog format (the documentation rule
  already requires it; it is currently absent).
- [ ] Evaluate whether to add a `renovate.json` to this repo now (even before a framework library
  exists) to establish the Renovate pattern early.
- [ ] Experiment with the dev marketplace pattern (`marketplace.json` referencing a local
  `--plugin-dir` equivalent) as an alternative to the shell alias approach.

---

## Sources

- [GitHub Well-Architected: Repository Architecture Strategy](https://wellarchitected.github.com/library/architecture/recommendations/scaling-git-repositories/repository-architecture-strategy/)
- [Monorepo vs Polyrepo: Code at Scale in 2025 (Medium / Nexumo)](https://medium.com/@Nexumo_/monorepo-vs-polyrepo-code-at-scale-in-2025-9b0743b68b99)
- [Monorepo vs Polyrepo for Multi-Stack Vibe Coding (Medium)](https://medium.com/@arohitu/monorepo-vs-polyrepo-for-multi-stack-vibe-coding-a-developers-decision-framework-06d535fb110e)
- [Monorepo vs Polyrepo: AI's New Rules for Repo Architecture (Augment Code)](https://www.augmentcode.com/learn/monorepo-vs-polyrepo-ai-s-new-rules-for-repo-architecture)
- [Reasons to Avoid Git Submodules](https://blog.timhutt.co.uk/against-submodules/)
- [Git Subtree: Alternative to Git Submodule (Atlassian)](https://www.atlassian.com/git/tutorials/git-subtree)
- [Renovate vs Dependabot (TurboStarter)](https://www.turbostarter.dev/blog/renovate-vs-dependabot-whats-the-best-tool-to-automate-your-dependency-updates)
- [Renovate Docs — Bot Comparison](https://docs.renovatebot.com/bot-comparison/)
- [uv: Managing Dependencies](https://docs.astral.sh/uv/concepts/projects/dependencies/)
- [Using Python UV with Editable Source Code Dependencies](https://lonelyneuron.substack.com/p/using-python-uv-with-editable-source)
- [Claude Code: Create Plugins](https://code.claude.com/docs/en/plugins)
- [How to Set Up Cross-Repository Workflows in GitHub Actions](https://oneuptime.com/blog/post/2025-12-20-cross-repository-workflows-github-actions/view)
- [Automating Contract Testing in a CI/CD Pipeline with GitHub Actions](https://noraweisser.com/2025/02/04/automating-contract-testing-in-a-ci-cd-pipeline-with-github-actions/)
- [Nx vs Turborepo Comprehensive Guide (Wisp CMS)](https://www.wisp.blog/blog/nx-vs-turborepo-a-comprehensive-guide-to-monorepo-tools)
- [Monorepo Tools Comparison: Turborepo vs Nx vs Lerna in 2025 (DEV Community)](https://dev.to/_d7eb1c1703182e3ce1782/monorepo-tools-comparison-turborepo-vs-nx-vs-lerna-in-2025-15a6)
- [Dev Containers: Multiple Projects and Shared Configuration (DEV Community)](https://dev.to/graezykev/dev-containers-part-5-multiple-projects-shared-container-configuration-2hoi)
- [How to Simplify Multi-Repo Workflow with Podman (Red Hat Developer)](https://developers.redhat.com/articles/2025/05/28/how-simplify-your-multi-repo-workflow-podman)
- [Pact: Microservices Contract Testing](https://pact.io/)
