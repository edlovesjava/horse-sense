#!/usr/bin/env bash
# setup_env.sh — Bootstrap the project development environment
# Detects language (Python or TypeScript) and sets up the appropriate toolchain.
# Usage: bash ${CLAUDE_PLUGIN_ROOT}/scripts/setup_env.sh [python_executable]
# Example: bash ${CLAUDE_PLUGIN_ROOT}/scripts/setup_env.sh python3.11

set -euo pipefail

PYTHON="${1:-python3}"
VENV_DIR=".venv"
REQ_FILE="requirements.txt"
REQ_DEV_FILE="requirements-dev.txt"

# ── Colour helpers ────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Colour

info()    { echo -e "${GREEN}[setup]${NC} $*"; }
warn()    { echo -e "${YELLOW}[setup]${NC} $*"; }
error()   { echo -e "${RED}[setup]${NC} $*" >&2; }

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
info "Detected project language: ${LANG}"

# ── Python setup ──────────────────────────────────────────────────────────────
setup_python() {
    if ! command -v "${PYTHON}" &>/dev/null; then
        error "'${PYTHON}' not found. Install Python 3.11+ and retry."
        exit 1
    fi

    PYTHON_VERSION=$("${PYTHON}" --version 2>&1)
    info "Using ${PYTHON_VERSION}"

    if [ -d "${VENV_DIR}" ]; then
        warn "Virtual environment '${VENV_DIR}' already exists — skipping creation."
    else
        info "Creating virtual environment in '${VENV_DIR}'..."
        "${PYTHON}" -m venv "${VENV_DIR}"
    fi

    # shellcheck source=/dev/null
    source "${VENV_DIR}/bin/activate"
    info "Activated ${VENV_DIR}"

    info "Upgrading pip..."
    pip install --quiet --upgrade pip

    if [ -f "${REQ_FILE}" ]; then
        info "Installing production dependencies from ${REQ_FILE}..."
        pip install --quiet -r "${REQ_FILE}"
    else
        warn "${REQ_FILE} not found — skipping production dependencies."
    fi

    if [ -f "${REQ_DEV_FILE}" ]; then
        info "Installing dev/test dependencies from ${REQ_DEV_FILE}..."
        pip install --quiet -r "${REQ_DEV_FILE}"
    else
        warn "${REQ_DEV_FILE} not found — skipping dev dependencies."
    fi

    echo ""
    info "Python environment ready! Activate it with:"
    echo ""
    echo "    source ${VENV_DIR}/bin/activate"
    echo ""
    info "Run tests with:"
    echo ""
    echo "    python -m pytest tests/ -x --tb=short"
    echo ""
}

# ── TypeScript setup ──────────────────────────────────────────────────────────
setup_typescript() {
    if ! command -v node &>/dev/null; then
        error "Node.js not found. Install Node.js 20+ and retry."
        exit 1
    fi

    NODE_VERSION=$(node --version 2>&1)
    info "Using Node.js ${NODE_VERSION}"

    if [ -d "node_modules" ]; then
        warn "node_modules/ already exists — running npm install to sync."
    fi

    if [ -f "package-lock.json" ]; then
        info "Installing dependencies with npm ci (reproducible)..."
        npm ci --loglevel=warn
    else
        info "Installing dependencies with npm install..."
        npm install --loglevel=warn
    fi

    echo ""
    info "TypeScript environment ready!"
    echo ""
    info "Run tests with:"
    echo ""
    echo "    npx vitest run"
    echo ""
    info "Type-check with:"
    echo ""
    echo "    npx tsc --noEmit"
    echo ""
}

# ── .env copy (both languages) ───────────────────────────────────────────────
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    cp .env.example .env
    warn "Copied .env.example → .env. Edit .env with your local values."
fi

# ── Dispatch ──────────────────────────────────────────────────────────────────
case "${LANG}" in
    python)
        setup_python
        ;;
    typescript)
        setup_typescript
        ;;
    *)
        warn "Could not auto-detect language. No package.json, pyproject.toml, or requirements.txt found."
        warn "Create one of these files and re-run, or set up your environment manually."
        exit 1
        ;;
esac
