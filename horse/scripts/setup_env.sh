#!/usr/bin/env bash
# setup_env.sh — Bootstrap the Python virtual environment
# Usage: bash scripts/setup_env.sh [python_executable]
# Example: bash scripts/setup_env.sh python3.11

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

# ── Prerequisite check ────────────────────────────────────────────────────────
if ! command -v "${PYTHON}" &>/dev/null; then
    error "'${PYTHON}' not found. Install Python 3.11+ and retry."
    exit 1
fi

PYTHON_VERSION=$("${PYTHON}" --version 2>&1)
info "Using ${PYTHON_VERSION}"

# ── Create virtual environment ────────────────────────────────────────────────
if [ -d "${VENV_DIR}" ]; then
    warn "Virtual environment '${VENV_DIR}' already exists — skipping creation."
else
    info "Creating virtual environment in '${VENV_DIR}'..."
    "${PYTHON}" -m venv "${VENV_DIR}"
fi

# ── Activate ──────────────────────────────────────────────────────────────────
# shellcheck source=/dev/null
source "${VENV_DIR}/bin/activate"
info "Activated ${VENV_DIR}"

# ── Upgrade pip ───────────────────────────────────────────────────────────────
info "Upgrading pip..."
pip install --quiet --upgrade pip

# ── Install production dependencies ──────────────────────────────────────────
if [ -f "${REQ_FILE}" ]; then
    info "Installing production dependencies from ${REQ_FILE}..."
    pip install --quiet -r "${REQ_FILE}"
else
    warn "${REQ_FILE} not found — skipping production dependencies."
fi

# ── Install dev/test dependencies ─────────────────────────────────────────────
if [ -f "${REQ_DEV_FILE}" ]; then
    info "Installing dev/test dependencies from ${REQ_DEV_FILE}..."
    pip install --quiet -r "${REQ_DEV_FILE}"
else
    warn "${REQ_DEV_FILE} not found — skipping dev dependencies."
fi

# ── Copy .env.example if .env is missing ─────────────────────────────────────
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    cp .env.example .env
    warn "Copied .env.example → .env. Edit .env with your local values."
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
info "Environment ready! Activate it with:"
echo ""
echo "    source ${VENV_DIR}/bin/activate"
echo ""
info "Run tests with:"
echo ""
echo "    python -m pytest tests/ -x --tb=short"
echo ""
