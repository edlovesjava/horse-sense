#!/usr/bin/env bash
# run_tests.sh — Run the full test suite with coverage
# Detects language (Python or TypeScript) and runs the appropriate test runner.
# Usage: bash ${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.sh [--unit | --integration | --e2e | --all]

set -euo pipefail

COVERAGE_THRESHOLD=80

# ── Colour helpers ────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[test]${NC} $*"; }
warn()  { echo -e "${YELLOW}[test]${NC} $*"; }
error() { echo -e "${RED}[test]${NC} $*" >&2; }

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
MODE="${1:---all}"

# ── Python tests ──────────────────────────────────────────────────────────────
run_python_tests() {
    VENV_DIR=".venv"
    if [ ! -d "${VENV_DIR}" ]; then
        error "Virtual environment not found. Run 'bash ${CLAUDE_PLUGIN_ROOT}/scripts/setup_env.sh' first."
        exit 1
    fi
    # shellcheck source=/dev/null
    source "${VENV_DIR}/bin/activate"

    PYTEST_ARGS=()

    case "${MODE}" in
        --unit)
            info "Running Python unit tests only..."
            PYTEST_ARGS+=("-m" "unit")
            ;;
        --integration)
            info "Running Python integration tests only..."
            PYTEST_ARGS+=("-m" "integration")
            ;;
        --e2e)
            info "Running Python end-to-end tests only..."
            PYTEST_ARGS+=("-m" "e2e")
            ;;
        --all | *)
            info "Running all Python tests..."
            ;;
    esac

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

    if command -v pip &>/dev/null; then
        info "Running dependency vulnerability scan..."
        pip audit || warn "pip audit found issues — review before deploying."
    fi
}

# ── TypeScript tests ──────────────────────────────────────────────────────────
run_typescript_tests() {
    if [ ! -d "node_modules" ]; then
        error "node_modules/ not found. Run 'bash ${CLAUDE_PLUGIN_ROOT}/scripts/setup_env.sh' first."
        exit 1
    fi

    VITEST_ARGS=()

    case "${MODE}" in
        --unit)
            info "Running TypeScript unit tests only..."
            VITEST_ARGS+=("tests/unit/")
            ;;
        --integration)
            info "Running TypeScript integration tests only..."
            VITEST_ARGS+=("tests/integration/")
            ;;
        --e2e)
            info "Running TypeScript e2e tests only..."
            VITEST_ARGS+=("tests/e2e/")
            ;;
        --all | *)
            info "Running all TypeScript tests..."
            ;;
    esac

    npx vitest run \
        "${VITEST_ARGS[@]+"${VITEST_ARGS[@]}"}" \
        --coverage \
        --reporter=verbose

    info "Tests passed."

    info "Running dependency vulnerability scan..."
    npm audit --audit-level=moderate || warn "npm audit found issues — review before deploying."
}

# ── Dispatch ──────────────────────────────────────────────────────────────────
case "${LANG}" in
    python)
        run_python_tests
        ;;
    typescript)
        run_typescript_tests
        ;;
    *)
        error "Could not auto-detect language. No package.json, pyproject.toml, or requirements.txt found."
        exit 1
        ;;
esac
