# SPIKE-002: Jekyll vs MkDocs+Material for the horse-sense Documentation Site

> **Status**: Complete
> **Author**: Scout (Claude Sonnet 4.6)
> **Date**: 2026-04-06
> **Timebox**: 3 hours

---

## Question

ADR-0006 accepted MkDocs+Material as the documentation generator for horse-sense. Before that decision
is treated as final, is there a credible case for switching to Jekyll? Specifically: does Jekyll offer
any meaningful advantages in setup burden, feature parity, include/transclusion support, link checking,
GitHub Pages integration, plugin ecosystem, build performance, or AI agent friendliness that would
justify the migration cost?

## Approach

- [x] Read ADR-0006 and the existing `mkdocs.yml` to understand the current configuration and the
      reasons already documented
- [x] Research Jekyll vs MkDocs+Material general comparisons (2025-2026 sources)
- [x] Investigate Jekyll's include/transclusion capability for files outside the site directory
- [x] Investigate Jekyll's equivalent to `mkdocs build --strict` for link checking
- [x] Research Jekyll theme quality: which themes compete with Material?
- [x] Investigate GitHub Pages native build advantages vs Actions-based build
- [x] Research Jekyll's plugin ecosystem for documentation sites
- [x] Gather build performance data for 100+ page sites
- [x] Assess AI agent friendliness of each toolchain
- [x] Research Jekyll's maintenance and project health

---

## Findings

### Finding 1: Setup and maintenance burden — Jekyll is heavier

**MkDocs+Material** installs as a Python package into a virtualenv:

```bash
pip install mkdocs mkdocs-material mkdocs-include-markdown-plugin
```

The project already has `docs/requirements.txt` and `make docs-deps` to automate this. No system-level
dependencies beyond Python (which is already required for the project). The entire toolchain is
isolated in `.venv-docs/`.

**Jekyll** requires:

- A specific version of Ruby (system Ruby on macOS is frequently wrong; rbenv or rvm needed)
- Bundler
- Native gem compilation (e.g., `nokogiri` requires libxml2 headers)
- A `Gemfile` + `Gemfile.lock` pinning Ruby gem versions

Ruby version management is a well-documented source of friction. In 2024-2025, users report build
failures when Homebrew auto-upgrades Ruby (from 3.2 to 3.3), requiring full gem reinstalls. Bundler
v4 dropped the `--path` flag, breaking Netlify/GitHub Actions builds for existing sites. The
`github-pages` gem locks the site to specific versions of Jekyll and its dependencies, which
frequently falls behind the current Jekyll release.

**Assessment**: For a Python-native project with no Ruby in the stack, Jekyll adds a foreign
language runtime, a version manager, and a fragile dependency chain. MkDocs is a clear win here.

### Finding 2: Markdown features — Material has a substantial lead

Jekyll uses **Kramdown** as its default Markdown processor. Kramdown supports standard Markdown
and a few extensions (footnotes, definition lists, abbreviations), but has no native support for
admonitions, content tabs, or code copy.

The CommonMark spec does not include admonitions; neither does Kramdown. Adding admonition-like
callouts to Jekyll requires custom CSS and Liquid templating workarounds, or a third-party plugin
(`jekyll-callouts` or similar). These are community-maintained, not officially part of the ecosystem.

**MkDocs+Material** provides, via Python Markdown + PyMdown Extensions:

| Feature | MkDocs+Material | Jekyll (Kramdown) |
|---|---|---|
| Admonitions (`!!! note`, `!!! warning`, etc.) | Built in, 12 types, collapsible | Requires custom CSS + Liquid |
| Content tabs (`=== "Tab"`) | Built in, linked tabs | Not available natively |
| Code copy button | Built in, `content.code.copy` feature flag | Requires JS snippet |
| Annotated code blocks | Built in | Not available |
| Inline code highlighting | Built in (`pymdownx.inlinehilite`) | Basic only |
| Task lists with custom checkboxes | Built in | Basic only |
| Mermaid diagrams | Built in (`pymdownx.superfences`) | Requires third-party plugin |
| Emoji shortcodes | Built in | Requires plugin |
| Footnotes | Built in | Built in |
| Definition lists | Built in | Built in |

The horse-sense docs site already uses admonitions, content tabs, and annotated code blocks in its
`mkdocs.yml` configuration. Migrating to Jekyll would mean losing these features entirely or
building workarounds.

### Finding 3: Theme quality — Material is in a different tier

The best-reviewed Jekyll themes for technical documentation are:

- **Just the Docs** — clean, built-in search, callouts (basic), dark mode, GitHub Pages compatible,
  actively maintained by Matt Wang. The closest Jekyll equivalent to Material.
- **Minimal Mistakes** — flexible two-column layout, broad feature set, but designed for
  blogs/portfolios more than structured documentation.
- **mkdocs-jekyll** — a community port of the Material theme design to Jekyll, but unmaintained
  and incomplete (the port description explicitly says "almost as beautiful").
- **jekyll-theme-rtd** — a port of Read the Docs to Jekyll, no active development.

Just the Docs is a legitimate documentation theme with search, dark mode, and callouts. However,
compared to Material it lacks:

- Content tabs
- Annotated code blocks
- The Material icon set and extensive visual component library
- A built-in blog plugin
- The `pymdownx` extension ecosystem
- Insiders program with additional features (tags, search boosting, social cards, versioning)

Material for MkDocs is actively developed by a single dedicated maintainer (Martin Donath /
squidfunk) with a commercially sponsored "Insiders" program that funds ongoing development. The
project is used by FastAPI, uv, Pydantic, and hundreds of other major Python projects — the same
ecosystem this project inhabits.

**Assessment**: Just the Docs is viable. Material is noticeably richer and more purpose-built
for documentation. For a site that already uses advanced Material features, the switch would be a
visible downgrade.

### Finding 4: Include/transclusion — Jekyll has a critical gap for this project

This is the single most important dimension for horse-sense. The `mkdocs-include-markdown-plugin`
enables wrapper pages in `docs/` to inline content from `horse/commands/`, `horse/agents/`,
`horse/skills/`, and `horse/rules/` at build time — keeping plugin source files as the single
source of truth without duplicating them into `docs/`.

**Jekyll's built-in include behavior:**

- `{% include file.html %}` — looks only in `_includes/` at the site root
- `{% include_relative file.html %}` — relative to the current file, but **cannot traverse up with `../`**
- Neither can reference files outside the Jekyll source directory

**Available workarounds for Jekyll:**

1. **`jekyll_flexible_include` plugin** (gem: `jekyll_flexible_include_plugin`) — supports absolute
   paths and relative paths with `../`. Confirmed to work for cross-directory inclusion.
   **Critical limitation**: This plugin is not on the GitHub Pages whitelist. Using it requires
   building via GitHub Actions (which the project already does) rather than the native Jekyll build.
   Additionally, the plugin executes arbitrary shell commands — a deliberate design feature that
   creates a security surface requiring careful configuration.

2. **`jekyll-include-absolute-plugin`** — older, less maintained, similar capability.

3. **Symlinking** — create symlinks from `_includes/` into `horse/` directories. Works locally but
   symlinks are unreliable in GitHub Actions runners and are not portable.

4. **File copying as a pre-build step** — a `make` target that copies files from `horse/` into
   `_includes/` before `jekyll build`. This defeats the single-source-of-truth requirement: the
   generated copies could diverge if the copy step is skipped.

**MkDocs+Material equivalent:**

```yaml
# In a wrapper page inside docs/:
{% include-markdown "../../horse/commands/guide.md" %}
```

This is a first-class, well-maintained plugin with 100% support for the use case. It runs
within the MkDocs build process with no security implications.

**Assessment**: Jekyll can technically achieve cross-directory inclusion via `jekyll_flexible_include`,
but it requires an unsupported-on-GitHub-Pages plugin that executes shell commands and cannot be
used with the native GitHub Pages build. The MkDocs solution is simpler, safer, and officially
supported. This is the highest-risk dimension of a potential Jekyll migration.

### Finding 5: Strict link checking — Jekyll requires an external tool; MkDocs has it built in

**MkDocs+Material**: `mkdocs build --strict` is a first-class flag that treats all warnings
(including broken links detected by `mkdocs-include-markdown-plugin` and internal cross-references)
as build errors. Already wired into `make docs` and the CI `docs` job.

**Jekyll**: Jekyll has no equivalent built-in strict mode. The standard approach is **html-proofer**:

```bash
bundle exec jekyll build
bundle exec htmlproofer ./_site --disable-external
```

html-proofer is a well-regarded Ruby gem that checks the generated HTML output for:

- Broken internal links (404s)
- Missing image `alt` attributes
- Missing `title` attributes
- Optionally, broken external links

It is invoked as a separate post-build step, not integrated into the Jekyll build command.
Integrating it into CI requires a two-step job (build, then check) rather than a single
`mkdocs build --strict` call.

**Assessment**: html-proofer is a capable solution. The extra step is a minor inconvenience, not
a fundamental limitation. Both tools can fail a CI build on broken links. Slight edge to MkDocs
for integration simplicity.

### Finding 6: GitHub Pages native integration — Jekyll's advantage is smaller than it appears

GitHub Pages has native Jekyll support: push to `main` (or `gh-pages`), GitHub builds and
deploys automatically, no Actions workflow needed. This is Jekyll's historically strongest
advantage.

However, this advantage is largely negated by two factors:

1. **Plugin restrictions**: GitHub Pages builds Jekyll in `--safe` mode, whitelisting only a
   small set of approved plugins. `jekyll_flexible_include` — the plugin required for the
   cross-directory include use case — is **not** on that whitelist. So Jekyll on native GitHub
   Pages cannot support this project's transclusion requirement.

2. **GitHub Actions is now the standard**: GitHub Actions workflows for both Jekyll and MkDocs
   are equally simple. The existing `mkdocs gh-deploy --force --no-history` approach works
   flawlessly. The horse-sense CI already uses Actions; there is no native Jekyll build to
   switch to.

The one genuine advantage Jekyll retains: the `actions/jekyll-build-pages` official Action is
maintained by GitHub itself, which provides some assurance of long-term support. MkDocs deploys
via `mkdocs gh-deploy`, a third-party command — though this has been stable for years and is
the community standard.

**Assessment**: Jekyll's GitHub Pages advantage is real in principle but irrelevant in practice
for this project. Both deploy via Actions; the native Jekyll build cannot support the required
plugin.

### Finding 7: Plugin ecosystem — MkDocs wins for documentation; Jekyll wins for general web

Jekyll's plugin ecosystem is broader in absolute terms (~700+ community plugins on RubyGems vs
~200+ for MkDocs). However, for the specific needs of a technical documentation site, MkDocs
has purpose-built solutions:

| Need | MkDocs | Jekyll |
|---|---|---|
| File transclusion | `mkdocs-include-markdown-plugin` (first-party) | `jekyll_flexible_include` (community, not GH Pages compatible) |
| Search | Built-in, lunr.js | Built-in (Just the Docs), lunr.js |
| SEO | Built-in (Material) | `jekyll-seo-tag` (whitelisted) |
| Sitemap | Built-in (Material) | `jekyll-sitemap` (whitelisted) |
| Navigation | Built-in | Built-in |
| Versioning | `mike` (established, works with `mkdocs gh-deploy`) | Complex multi-branch setup or third-party |
| Link checking | `--strict` flag | html-proofer (separate step) |
| Blog | Built-in (Material Insiders, now public) | Native Jekyll feature |
| Tags/categories | Built-in (Material) | Native Jekyll feature |

For Jekyll, many of the useful documentation plugins (including `jekyll_flexible_include`) require
building via Actions rather than the native GitHub Pages pipeline.

**Assessment**: Jekyll has more total plugins, but fewer that address the specific needs of this
documentation site without workarounds.

### Finding 8: Build performance — MkDocs is adequate; Jekyll is slower at scale

Benchmark data for a ~200-page site (from the MkDocs Material GitHub discussions and published
benchmarks):

| SSG | ~200 pages | ~1,000 pages |
|---|---|---|
| Hugo | ~0.7 seconds | ~2 seconds |
| MkDocs+Material | ~3.2 seconds | ~15 seconds (estimated linear) |
| Jekyll 4 | ~3-4 seconds | ~30-60 seconds |

For 100+ pages, both MkDocs and Jekyll deliver builds in a few seconds — well within acceptable
range for a docs CI job. Jekyll's Ruby-based single-threaded processing degrades faster at scale
than MkDocs' Python-based processing, but neither is a bottleneck at this project's size.

The MkDocs maintainer (squidfunk) acknowledges that achieving parallelism in MkDocs would
require compromising the plugin system's design. A next-gen tool called **Zensical** is being
developed by the same maintainer to address this architectural limitation, but it is not yet
publicly available.

**Assessment**: No meaningful performance difference at 100 pages. Both are fast enough. If the
site ever reaches thousands of pages, this dimension would favor Hugo — not Jekyll.

### Finding 9: Jekyll project health — in maintenance mode

Jekyll's development activity peaked around 2016 and has declined significantly. Key facts:

- Jekyll 4.3.x is the current release line (4.4.1 released January 2025, primarily a bug fix)
- Feature development is effectively frozen — the core maintainer stated in 2021 the project is
  in "frozen mode," with only bug fixes and security patches going forward
- The version used by GitHub Pages is Jekyll 3.10.x — a separate maintenance branch from the
  actively installed version
- A former core maintainer has redirected energy to **Bridgetown**, a Jekyll successor

Material for MkDocs, by contrast:

- Has active weekly commits
- Maintains a commercial Insiders sponsorship program funding ongoing development
- Is used by flagship Python projects (FastAPI, uv, Pydantic, Typer)
- Has a roadmap and regular feature releases

**Assessment**: Jekyll is a stable, maintained project, but it is not receiving new features.
Material for MkDocs is on an upward trajectory. Adopting Jekyll now means adopting a technology
in managed decline.

### Finding 10: AI agent friendliness — MkDocs has a structural edge

Both tools generate documentation from plain Markdown files, which are equally readable and
writable by AI agents. The key differences that affect agent workflows:

**Configuration surface:**

- **MkDocs**: Single `mkdocs.yml` with a well-documented YAML schema. Material extensions are
  configured in one place. An AI agent can read the full configuration in one file and understand
  the complete site structure.
- **Jekyll**: Configuration is split across `_config.yml`, `Gemfile`, `Gemfile.lock`, Liquid
  front matter per file, and potentially a `Rakefile`. The Liquid template language is an
  additional cognitive surface. Plugin configuration can appear in `_config.yml` or the plugin
  itself.

**Error diagnosis:**

- **MkDocs**: `--strict` produces clear, structured warnings tied to specific files and line
  numbers. Errors from `include-markdown` reference the wrapper page.
- **Jekyll**: Build errors from Ruby/Liquid can be cryptic. Gem version conflicts produce
  opaque Bundler error messages that are difficult for an AI to diagnose without Ruby expertise.

**Debugging broken includes:**

- **MkDocs**: `mkdocs serve` with `--strict` shows errors in the terminal in real-time.
- **Jekyll**: `jekyll serve` plus a separate `htmlproofer` pass; two different failure surfaces.

**Language consistency:**

The project stack is Python + shell. An AI agent debugging a MkDocs build can draw on Python
knowledge (pip, virtualenvs, Python Markdown). An AI agent debugging a Jekyll build needs Ruby
knowledge (bundler, RubyGems, Liquid, Kramdown) — a foreign language for this project.

**Assessment**: MkDocs is more AI-agent-friendly for this project due to simpler configuration,
clearer error messages, and alignment with the project's primary language.

---

## Trade-off Matrix

| Dimension | MkDocs+Material | Jekyll (Just the Docs) | Winner |
|---|---|---|---|
| **Setup complexity** | `pip install`, one venv, no system deps | Ruby + rbenv + bundler + gem compilation | MkDocs |
| **Maintenance burden** | Python ecosystem, stable installs | Ruby versioning friction, Bundler conflicts | MkDocs |
| **Admonitions** | Built in, 12 types, collapsible | Basic callouts via custom CSS | MkDocs |
| **Content tabs** | Built in | Not available | MkDocs |
| **Code copy** | Built in | Requires custom JS | MkDocs |
| **Mermaid diagrams** | Built in (superfences) | Requires third-party plugin | MkDocs |
| **Theme richness** | Material: 30+ UI components, icon set | Just the Docs: clean but limited | MkDocs |
| **File transclusion** | `include-markdown` plugin, any path | `jekyll_flexible_include`, not GH Pages native | MkDocs |
| **Strict link checking** | `--strict` flag, single command | html-proofer, separate post-build step | MkDocs (slight) |
| **GitHub Pages native** | Actions-based, 1-step workflow | Native build, but restricted plugins | Tie |
| **Search** | Built in, instant, fuzzy | Built in (lunr.js), comparable | Tie |
| **Dark mode** | Built in, system preference aware | Built in (Just the Docs) | Tie |
| **SEO** | Built in (Material) | `jekyll-seo-tag` (whitelisted) | Tie |
| **100-page build speed** | ~3 sec | ~3-4 sec | Tie |
| **Versioning** | `mike` plugin, mature | Complex multi-branch | MkDocs |
| **Project health** | Active development, Insiders program | Maintenance mode since ~2021 | MkDocs |
| **AI agent friendliness** | Python stack, clear errors, simple config | Ruby stack, cryptic errors, split config | MkDocs |
| **Blog capability** | Material blog plugin | Native Jekyll strength | Jekyll |
| **Total plugin count** | ~200 plugins | ~700+ plugins | Jekyll |
| **Ecosystem maturity** | 10 years, Python-native | 15+ years, Ruby-native | Jekyll (marginal) |

**Score: MkDocs wins 12 dimensions, Jekyll wins 2 (blog, total plugin count), 5 ties.**

---

## Recommendation

**Stick with MkDocs+Material. Confidence: High.**

The case for Jekyll does not survive scrutiny when examined against the specific requirements
of this project:

1. **The transclusion requirement is the deciding factor.** Jekyll cannot natively inline content
   from outside its site directory. The only viable workaround (`jekyll_flexible_include`) is
   not compatible with GitHub Pages' native build and introduces shell-execution security
   concerns. MkDocs' `include-markdown` plugin handles this requirement as a first-class feature
   with no workarounds needed.

2. **Markdown feature richness is a close second.** The horse-sense docs already use admonitions,
   content tabs, and annotated code blocks — all of which require Material's extension stack.
   None of these exist in standard Kramdown or in Just the Docs. A migration would visibly
   degrade the documentation.

3. **Jekyll's GitHub Pages native advantage does not apply here.** The project builds via
   GitHub Actions, which makes both tools equivalent on deployment. Jekyll's native Pages
   build would actually break the transclusion requirement.

4. **Jekyll is in maintenance mode.** The project has effectively frozen feature development.
   Material for MkDocs is actively developed and used by the same Python project ecosystem
   horse-sense is part of.

5. **The Ruby toolchain is a net cost.** Adding Ruby, Bundler, and rbenv to a Python+shell
   project increases onboarding friction for developers and AI agents without providing any
   benefit not already available in MkDocs.

**Jekyll's only genuine advantages** are a larger total plugin count (irrelevant if those plugins
don't address the specific needs) and stronger native blogging capabilities (not a requirement
for this site). Just the Docs is a quality theme, but it does not match Material's feature set
for technical documentation.

**Do not migrate.** Implement ADR-0006 as written.

---

## Open Questions

- [ ] **Zensical watch**: The MkDocs maintainer (squidfunk) is building Zensical as a next-gen
  replacement for MkDocs with better build performance and docs-as-code support. If/when it
  reaches stability, it may be worth a short evaluation spike before any future docs toolchain
  revisit.
- [ ] **`mike` versioning**: If the docs site ever needs multi-version navigation (e.g., v1 vs
  v2 of the horse plugin), evaluate `mike` (the MkDocs versioning plugin) as a follow-up spike.
  This is not needed now but is a natural next step.
- [ ] **html-proofer for external link checking**: MkDocs `--strict` checks internal links
  only. If external link rot becomes a concern, html-proofer could be added as a separate
  weekly CI job regardless of the SSG choice.

---

## Next Steps

- [ ] No action on the docs toolchain — ADR-0006 stands.
- [ ] File as supporting evidence in ADR-0006 by adding a reference to this spike under the
  "Alternatives considered" section if desired.
- [ ] Monitor Zensical for future evaluation (no urgency).

---

## Sources

- [Delve 9: Migrating from Jekyll to Material for MkDocs — DataDelver](https://www.datadelver.com/2025/03/15/delve-9-migrating-from-jekyll-to-material-for-mkdocs.html)
- [Alternatives — Material for MkDocs](https://squidfunk.github.io/mkdocs-material/alternatives/)
- [A Flight of Static Site Generators — Just Write Click (Feb 2025)](https://justwriteclick.com/2025/02/06/a-flight-of-static-site-generators-sampling-the-best-for-documentation/)
- [Compare Jekyll vs MkDocs in 2026 — SlashDot](https://slashdot.org/software/comparison/Jekyll-vs-MkDocs/)
- [Just the Docs — Official Site](https://just-the-docs.com/)
- [jekyll_flexible_include_plugin — GitHub](https://github.com/mslinn/jekyll_flexible_include_plugin)
- [Jekyll Transclusion Feature Request — GitHub Issue #6789](https://github.com/jekyll/jekyll/issues/6789)
- [Jekyll Includes — Official Docs](https://jekyllrb.com/docs/includes/)
- [Checking Broken Links in Jekyll — Daniel Sieger](https://danielsieger.com/blog/2021/03/28/check-broken-links-jekyll.html)
- [About GitHub Pages and Jekyll — GitHub Docs](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll)
- [Build speed: mkdocs vs Hugo — MkDocs Material Discussion #6802](https://github.com/squidfunk/mkdocs-material/discussions/6802)
- [Jekyll endoflife.date](https://endoflife.date/jekyll)
- [Ruby versioning hell with Jekyll and GitHub Pages — Ritvik Nag](https://ritviknag.com/tech-tips/ruby-versioning-hell-with-jekyll-&-github-pages/)
- [Bundle install failing with Bundler v4 — Netlify Support Forums](https://answers.netlify.com/t/bundle-install-failing-with-bundler-v4-x-in-ruby-jekyll-sites/158308)
- [Future of Jekyll project in doubt — The Register (2021)](https://www.theregister.com/2021/09/14/future_of_jekyll_project_engine/)
- [Making GitHub Pages Work with Jekyll 4+ — Moncef Belyamani](https://www.moncefbelyamani.com/making-github-pages-work-with-latest-jekyll/)
- [mkdocs-include-markdown-plugin — GitHub](https://github.com/mondeja/mkdocs-include-markdown-plugin)
- [mkdocs-include-markdown-plugin — PyPI](https://pypi.org/project/mkdocs-material/)
- [GitHub — just-the-docs/just-the-docs](https://github.com/just-the-docs/just-the-docs)
- [Bridgetown: RIP Jekyll — Bridgetown Project](https://www.bridgetownrb.com/future/rip-jekyll/)
