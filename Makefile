PLUGIN_DIR := horse
DOCS_VENV := .venv-docs
DOCS_PY := $(DOCS_VENV)/bin/python

.PHONY: check fix validate lint docs docs-serve docs-deps docs-clean

# Run all checks — exits non-zero if any check fails.
check: validate lint

# Auto-fix what is fixable (markdownlint).
fix:
	npx markdownlint-cli2 --fix "$(PLUGIN_DIR)/**/*.md" "docs/**/*.md"

# Validate plugin structure and frontmatter.
validate:
	scripts/validate-plugin.sh
	python3 scripts/validate-frontmatter.py

# Lint Markdown files and shell scripts.
lint:
	npx markdownlint-cli2 "$(PLUGIN_DIR)/**/*.md" "docs/**/*.md"
	shellcheck $(PLUGIN_DIR)/scripts/*.sh scripts/*.sh

# Install docs dependencies into a local venv.
docs-deps:
	@test -d $(DOCS_VENV) || python3 -m venv $(DOCS_VENV)
	$(DOCS_PY) -m pip install --quiet --upgrade pip
	$(DOCS_PY) -m pip install --quiet -r docs/requirements.txt

# Build the MkDocs site (strict mode — fails on warnings).
docs: docs-deps
	$(DOCS_VENV)/bin/mkdocs build --strict

# Serve the MkDocs site locally with live reload.
docs-serve: docs-deps
	$(DOCS_VENV)/bin/mkdocs serve

# Remove built site and docs venv.
docs-clean:
	rm -rf site $(DOCS_VENV)
