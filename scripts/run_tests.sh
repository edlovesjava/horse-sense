#!/usr/bin/env bash
# run_tests.sh — Run the full test suite with coverage
# Usage: bash scripts/run_tests.sh [--unit | --integration | --e2e | --all]

set -euo pipefail

VENV_DIR=".venv"
COVERAGE_THRESHOLD=80

# ── Colour helpers ────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[test]${NC} $*"; }
warn()  { echo -e "${YELLOW}[test]${NC} $*"; }
error() { echo -e "${RED}[test]${NC} $*" >&2; }

# ── Activate venv ─────────────────────────────────────────────────────────────
if [ ! -d "${VENV_DIR}" ]; then
    error "Virtual environment not found. Run 'bash scripts/setup_env.sh' first."
    exit 1
fi
# shellcheck source=/dev/null
source "${VENV_DIR}/bin/activate"

# ── Parse arguments ───────────────────────────────────────────────────────────
MODE="${1:---all}"
PYTEST_ARGS=()

case "${MODE}" in
    --unit)
        info "Running unit tests only..."
        PYTEST_ARGS+=("-m" "unit")
        ;;
    --integration)
        info "Running integration tests only..."
        PYTEST_ARGS+=("-m" "integration")
        ;;
    --e2e)
        info "Running end-to-end tests only..."
        PYTEST_ARGS+=("-m" "e2e")
        ;;
    --all | *)
        info "Running all tests..."
        ;;
esac

# ── Run tests ─────────────────────────────────────────────────────────────────
python -m pytest tests/ \
    "${PYTEST_ARGS[@]+"${PYTEST_ARGS[@]}"}" \
    --cov=src \
    --cov-report=term-missing \
    --cov-report=html:htmlcov \
    --cov-fail-under="${COVERAGE_THRESHOLD}" \
    -x \
    --tb=short \
    -v

info "Tests passed. Coverage report: htmlcov/index.html"

# ── Security scan ─────────────────────────────────────────────────────────────
if command -v pip &>/dev/null; then
    info "Running dependency vulnerability scan..."
    pip audit || warn "pip audit found issues — review before deploying."
fi
