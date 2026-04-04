#!/usr/bin/env bash
# lint.sh — Run all linters and type checkers
# Usage: bash scripts/lint.sh [--fix]

set -euo pipefail

VENV_DIR=".venv"
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

# ── Activate venv ─────────────────────────────────────────────────────────────
if [ ! -d "${VENV_DIR}" ]; then
    error "Virtual environment not found. Run 'bash scripts/setup_env.sh' first."
    exit 1
fi
# shellcheck source=/dev/null
source "${VENV_DIR}/bin/activate"

EXIT_CODE=0

# ── ruff lint ─────────────────────────────────────────────────────────────────
if command -v ruff &>/dev/null; then
    info "Running ruff linter..."
    if [ "${FIX}" = "--fix" ]; then
        if ruff check . --fix; then
            pass "ruff check (with auto-fix)"
        else
            fail "ruff check"; EXIT_CODE=1
        fi
    else
        if ruff check .; then
            pass "ruff check"
        else
            fail "ruff check (run with --fix to auto-fix)"; EXIT_CODE=1
        fi
    fi
else
    warn "ruff not installed — skipping lint. Install with: pip install ruff"
fi

# ── ruff format ───────────────────────────────────────────────────────────────
if command -v ruff &>/dev/null; then
    info "Running ruff formatter..."
    if [ "${FIX}" = "--fix" ]; then
        if ruff format .; then
            pass "ruff format"
        else
            fail "ruff format"; EXIT_CODE=1
        fi
    else
        if ruff format --check .; then
            pass "ruff format"
        else
            fail "ruff format (run with --fix to auto-format)"; EXIT_CODE=1
        fi
    fi
fi

# ── mypy type checking ────────────────────────────────────────────────────────
if command -v mypy &>/dev/null; then
    info "Running mypy type checker..."
    if [ -d "src" ]; then
        if mypy src/; then
            pass "mypy"
        else
            fail "mypy"; EXIT_CODE=1
        fi
    else
        warn "No 'src/' directory found — skipping mypy."
    fi
else
    warn "mypy not installed — skipping type check. Install with: pip install mypy"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
if [ "${EXIT_CODE}" -eq 0 ]; then
    pass "All checks passed!"
else
    fail "Some checks failed. See output above."
fi

exit "${EXIT_CODE}"
