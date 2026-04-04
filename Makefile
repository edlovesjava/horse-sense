PLUGIN_DIR := horse

.PHONY: check fix validate lint

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
