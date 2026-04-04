#!/usr/bin/env bash
# lint.sh — Run all linters and type checkers
# Detects language (Python or TypeScript) and runs the appropriate tools.
# Usage: bash scripts/lint.sh [--fix]

set -euo pipefail

FIX="${1:-}"

# ── Colour helpers ────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[lint]${NC} $*"; }
warn()  { echo -e "${YELLOW}[lint]${NC} $*"; }
error() { echo -e "${RED}[lint]${NC} $*" >&2; }
pass()  { echo -e "${GREEN}[lint]${NC} ✓ $*"; }
fail()  { echo -e "${RED}[lint]${NC} ✗ $*" >&2; }

# ── Language detection ────────────────────────────────────────────────────────
detect_language() {
    if [ -f "package.json" ]; then
        echo "typescript"
    elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
        echo "python"
    else
        echo "unknown"
    fi
}

LANG=$(detect_language)
EXIT_CODE=0

# ── Python linting ────────────────────────────────────────────────────────────
lint_python() {
    VENV_DIR=".venv"
    if [ ! -d "${VENV_DIR}" ]; then
        error "Virtual environment not found. Run 'bash scripts/setup_env.sh' first."
        exit 1
    fi
    # shellcheck source=/dev/null
    source "${VENV_DIR}/bin/activate"

    # ruff lint
    if command -v ruff &>/dev/null; then
        info "Running ruff linter..."
        if [ "${FIX}" = "--fix" ]; then
            if ruff check . --fix; then pass "ruff check (with auto-fix)"; else fail "ruff check"; EXIT_CODE=1; fi
        else
            if ruff check .; then pass "ruff check"; else fail "ruff check (run with --fix to auto-fix)"; EXIT_CODE=1; fi
        fi
    else
        warn "ruff not installed — skipping lint."
    fi

    # ruff format
    if command -v ruff &>/dev/null; then
        info "Running ruff formatter..."
        if [ "${FIX}" = "--fix" ]; then
            if ruff format .; then pass "ruff format"; else fail "ruff format"; EXIT_CODE=1; fi
        else
            if ruff format --check .; then pass "ruff format"; else fail "ruff format (run with --fix to auto-format)"; EXIT_CODE=1; fi
        fi
    fi

    # mypy
    if command -v mypy &>/dev/null; then
        info "Running mypy type checker..."
        if [ -d "src" ]; then
            if mypy src/; then pass "mypy"; else fail "mypy"; EXIT_CODE=1; fi
        else
            warn "No 'src/' directory found — skipping mypy."
        fi
    else
        warn "mypy not installed — skipping type check."
    fi
}

# ── TypeScript linting ────────────────────────────────────────────────────────
lint_typescript() {
    if [ ! -d "node_modules" ]; then
        error "node_modules/ not found. Run 'bash scripts/setup_env.sh' first."
        exit 1
    fi

    # eslint
    info "Running eslint..."
    if [ "${FIX}" = "--fix" ]; then
        if npx eslint src/ --fix; then pass "eslint (with auto-fix)"; else fail "eslint"; EXIT_CODE=1; fi
    else
        if npx eslint src/; then pass "eslint"; else fail "eslint (run with --fix to auto-fix)"; EXIT_CODE=1; fi
    fi

    # prettier
    info "Running prettier..."
    if [ "${FIX}" = "--fix" ]; then
        if npx prettier --write src/ tests/; then pass "prettier"; else fail "prettier"; EXIT_CODE=1; fi
    else
        if npx prettier --check src/ tests/; then pass "prettier"; else fail "prettier (run with --fix to auto-format)"; EXIT_CODE=1; fi
    fi

    # tsc type checking
    info "Running tsc type checker..."
    if npx tsc --noEmit; then pass "tsc --noEmit"; else fail "tsc"; EXIT_CODE=1; fi
}

# ── Dispatch ──────────────────────────────────────────────────────────────────
case "${LANG}" in
    python)
        lint_python
        ;;
    typescript)
        lint_typescript
        ;;
    *)
        error "Could not auto-detect language. No package.json, pyproject.toml, or requirements.txt found."
        exit 1
        ;;
esac

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
if [ "${EXIT_CODE}" -eq 0 ]; then
    pass "All checks passed!"
else
    fail "Some checks failed. See output above."
fi

exit "${EXIT_CODE}"
