#!/usr/bin/env bash
# new_project.sh — Scaffold a new project structure within the current directory
# Usage: bash scripts/new_project.sh [--language python|typescript] <project-name>
# Example: bash scripts/new_project.sh my-api
# Example: bash scripts/new_project.sh --language typescript my-api

set -euo pipefail

# ── Colour helpers ────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[scaffold]${NC} $*"; }
warn()  { echo -e "${YELLOW}[scaffold]${NC} $*"; }
error() { echo -e "${RED}[scaffold]${NC} $*" >&2; }

# ── Argument parsing ─────────────────────────────────────────────────────────
LANGUAGE="python"
PROJECT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --language)
            LANGUAGE="${2:-}"
            if [[ -z "${LANGUAGE}" ]]; then
                error "--language requires a value (python or typescript)"
                exit 1
            fi
            shift 2
            ;;
        -*)
            error "Unknown option: $1"
            exit 1
            ;;
        *)
            PROJECT="$1"
            shift
            ;;
    esac
done

if [[ -z "${PROJECT}" ]]; then
    error "Usage: bash scripts/new_project.sh [--language python|typescript] <project-name>"
    exit 1
fi

if [[ "${LANGUAGE}" != "python" && "${LANGUAGE}" != "typescript" ]]; then
    error "Unsupported language: ${LANGUAGE} (use python or typescript)"
    exit 1
fi

# Sanitize name (lowercase, hyphens to underscores for Python packages)
PKG_NAME="$(echo "${PROJECT//-/_}" | tr '[:upper:]' '[:lower:]')"

info "Scaffolding ${LANGUAGE} project: ${PROJECT}"

# ── Common directory structure ────────────────────────────────────────────────
mkdir -p \
    "src" \
    "tests/unit" \
    "tests/integration" \
    "tests/e2e" \
    "docs/architecture/adr" \
    "docs/runbooks" \
    "docs/retros" \
    ".github/workflows"

info "Created directory structure."

# ══════════════════════════════════════════════════════════════════════════════
# PYTHON SCAFFOLDING
# ══════════════════════════════════════════════════════════════════════════════
if [[ "${LANGUAGE}" == "python" ]]; then

mkdir -p "src/${PKG_NAME}"

# ── Python package init files ─────────────────────────────────────────────────
touch "src/${PKG_NAME}/__init__.py"
touch "tests/__init__.py"
touch "tests/unit/__init__.py"
touch "tests/integration/__init__.py"
touch "tests/e2e/__init__.py"

# ── pyproject.toml ────────────────────────────────────────────────────────────
cat > "pyproject.toml" << TOML
[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.backends.legacy:build"

[project]
name = "${PROJECT}"
version = "0.1.0"
description = "TODO: Add project description"
requires-python = ">=3.11"
dependencies = []

[tool.pytest.ini_options]
testpaths = ["tests"]
markers = [
    "unit: fast, isolated unit tests",
    "integration: tests requiring external services",
    "e2e: end-to-end user journey tests",
    "slow: tests taking more than 1 second",
]

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "B", "SIM"]

[tool.mypy]
python_version = "3.11"
strict = true
ignore_missing_imports = true

[tool.coverage.run]
source = ["src"]
omit = ["tests/*"]
TOML

info "Created pyproject.toml"

# ── requirements files ────────────────────────────────────────────────────────
cat > "requirements.txt" << REQ
# Production dependencies
# Add your dependencies here, e.g.:
# fastapi>=0.111
# httpx>=0.27
REQ

cat > "requirements-dev.txt" << REQ_DEV
-r requirements.txt

# Testing
pytest>=8.0
pytest-cov>=5.0

# Linting & formatting
ruff>=0.4

# Type checking
mypy>=1.10

# Security
pip-audit>=2.7
REQ_DEV

info "Created requirements files."

# ── .env.example ─────────────────────────────────────────────────────────────
cat > ".env.example" << ENV
# Copy this file to .env and fill in your local values.
# NEVER commit .env to version control.

APP_ENV=development
LOG_LEVEL=DEBUG
SECRET_KEY=change-me-use-secrets-token-hex-32
ENV

info "Created .env.example"

# ── conftest.py ───────────────────────────────────────────────────────────────
cat > "tests/conftest.py" << CONFTEST
"""Shared pytest fixtures for all test categories."""

# Add shared fixtures here, e.g.:
# import pytest
#
# @pytest.fixture
# def sample_user():
#     return {"id": 1, "email": "alice@example.com"}
CONFTEST

info "Created tests/conftest.py"

# ── GitHub Actions CI workflow ────────────────────────────────────────────────
cat > ".github/workflows/ci.yml" << CI
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Set up virtual environment
        run: |
          python -m venv .venv
          source .venv/bin/activate
          pip install --upgrade pip
          pip install -r requirements-dev.txt

      - name: Lint
        run: |
          source .venv/bin/activate
          ruff check .
          ruff format --check .

      - name: Type check
        run: |
          source .venv/bin/activate
          mypy src/

      - name: Test with coverage
        run: |
          source .venv/bin/activate
          python -m pytest tests/ --cov=src --cov-report=term-missing --cov-fail-under=80 -x

      - name: Security scan
        run: |
          source .venv/bin/activate
          pip-audit
CI

info "Created .github/workflows/ci.yml"

# ── Python .claude/config.json ───────────────────────────────────────────────
mkdir -p ".claude"
cat > ".claude/config.json" << CONFIG
{
  "language": "python",
  "testRunner": "pytest",
  "linter": "ruff check",
  "typeChecker": "mypy",
  "formatter": "ruff format",
  "srcDir": "src",
  "testDir": "tests",
  "coverageThreshold": 80
}
CONFIG

info "Created .claude/config.json"

# ══════════════════════════════════════════════════════════════════════════════
# TYPESCRIPT SCAFFOLDING
# ══════════════════════════════════════════════════════════════════════════════
elif [[ "${LANGUAGE}" == "typescript" ]]; then

# ── package.json ──────────────────────────────────────────────────────────────
cat > "package.json" << PKG
{
  "name": "${PROJECT}",
  "version": "0.1.0",
  "description": "TODO: Add project description",
  "type": "module",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint src/ tests/",
    "lint:fix": "eslint --fix src/ tests/",
    "format": "prettier --write 'src/**/*.ts' 'tests/**/*.ts'",
    "format:check": "prettier --check 'src/**/*.ts' 'tests/**/*.ts'",
    "typecheck": "tsc --noEmit",
    "check": "npm run lint && npm run typecheck && npm run test"
  },
  "engines": {
    "node": ">=20"
  }
}
PKG

info "Created package.json"

# ── tsconfig.json ─────────────────────────────────────────────────────────────
cat > "tsconfig.json" << TSC
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
TSC

info "Created tsconfig.json"

# ── vitest.config.ts ──────────────────────────────────────────────────────────
cat > "vitest.config.ts" << VITEST
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    coverage: {
      provider: 'v8',
      include: ['src/**/*.ts'],
      exclude: ['src/**/*.d.ts'],
      thresholds: { lines: 80, functions: 80, branches: 80, statements: 80 },
    },
  },
});
VITEST

info "Created vitest.config.ts"

# ── eslint.config.js ─────────────────────────────────────────────────────────
cat > "eslint.config.js" << ESLINT
import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    ignores: ['dist/', 'node_modules/', 'coverage/'],
  },
);
ESLINT

info "Created eslint.config.js"

# ── .prettierrc ───────────────────────────────────────────────────────────────
cat > ".prettierrc" << PRETTIER
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2
}
PRETTIER

info "Created .prettierrc"

# ── Starter source file ──────────────────────────────────────────────────────
cat > "src/index.ts" << SRC
export function greet(name: string): string {
  return \`Hello, \${name}!\`;
}
SRC

# ── Starter test ──────────────────────────────────────────────────────────────
cat > "tests/unit/index.test.ts" << TEST
import { describe, it, expect } from 'vitest';
import { greet } from '../../src/index.js';

describe('greet', () => {
  it('returns a greeting', () => {
    expect(greet('World')).toBe('Hello, World!');
  });
});
TEST

info "Created starter source and test files."

# ── GitHub Actions CI workflow ────────────────────────────────────────────────
cat > ".github/workflows/ci.yml" << CI
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run typecheck

      - name: Test with coverage
        run: npm run test:coverage

      - name: Format check
        run: npm run format:check
CI

info "Created .github/workflows/ci.yml"

# ── TypeScript .claude/config.json ────────────────────────────────────────────
mkdir -p ".claude"
cat > ".claude/config.json" << CONFIG
{
  "language": "typescript",
  "testRunner": "vitest",
  "linter": "eslint",
  "typeChecker": "tsc --noEmit",
  "formatter": "prettier --write",
  "srcDir": "src",
  "testDir": "tests",
  "packageManager": "npm",
  "coverageThreshold": 80
}
CONFIG

info "Created .claude/config.json"

fi  # end language branch

# ── CHANGELOG ─────────────────────────────────────────────────────────────────
cat > "CHANGELOG.md" << CHANGELOG
# Changelog

All notable changes to this project are documented here.

## [Unreleased]

## [0.1.0] - $(date +%Y-%m-%d)
### Added
- Initial project scaffold
CHANGELOG

info "Created CHANGELOG.md"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
info "Project '${PROJECT}' scaffolded successfully!"
echo ""
echo "  Next steps:"
echo "    1. cd into your project directory (if not already there)"
echo "    2. bash \${CLAUDE_PLUGIN_ROOT}/scripts/setup_env.sh   # provided by the horse plugin"
echo "    3. Fill out templates/requirements_doc.md"
echo "    4. bash \${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.sh   # provided by the horse plugin"
echo ""
