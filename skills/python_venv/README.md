# Skill: Python Virtual Environment Setup

## Purpose
Establish a clean, reproducible Python environment for every project using `venv`. This skill ensures all contributors use the same dependencies and avoids conflicts with system Python packages.

## Prerequisites
- Python ≥ 3.11 installed and available as `python3`
- `pip` ≥ 23.0
- Git repository initialized at the project root

## Quick Start

```bash
# Bootstrap the environment (idempotent — safe to re-run)
bash scripts/setup_env.sh
```

## Manual Setup Steps

### 1. Create the Virtual Environment

```bash
python3 -m venv .venv
```

### 2. Activate the Environment

```bash
# Linux / macOS
source .venv/bin/activate

# Windows (PowerShell)
.venv\Scripts\Activate.ps1

# Windows (CMD)
.venv\Scripts\activate.bat
```

Your prompt will now show `(.venv)` to confirm activation.

### 3. Upgrade pip

```bash
pip install --upgrade pip
```

### 4. Install Dependencies

```bash
# Production dependencies
pip install -r requirements.txt

# Development and test dependencies
pip install -r requirements-dev.txt
```

### 5. Verify the Environment

```bash
python --version
pip list
```

## Dependency Management

### Adding a New Dependency

```bash
# Install and record the package
pip install <package-name>

# Pin the exact version
pip freeze | grep <package-name> >> requirements.txt
```

### Updating requirements.txt

```bash
pip freeze > requirements.txt
```

### Separating Dev vs Production Dependencies

- `requirements.txt` — packages needed to run the application
- `requirements-dev.txt` — packages for development and testing only

Example `requirements-dev.txt`:
```
-r requirements.txt
pytest>=8.0
pytest-cov>=5.0
ruff>=0.4
mypy>=1.10
```

## Environment Variables

Use a `.env` file for local secrets and configuration (never commit it):

```bash
cp .env.example .env
# Edit .env with your local values
```

Load environment variables in Python using `python-dotenv`:
```python
from dotenv import load_dotenv
load_dotenv()
```

## Deactivating the Environment

```bash
deactivate
```

## Recreating the Environment

```bash
rm -rf .venv
bash scripts/setup_env.sh
```

## CI/CD Considerations

In CI pipelines, skip the `activate` step and call Python/pip directly:
```bash
python3 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install -r requirements-dev.txt
.venv/bin/pytest tests/
```

## Troubleshooting

| Problem | Solution |
|---|---|
| `python3: command not found` | Install Python 3.11+ via your OS package manager |
| `pip` installs to wrong location | Ensure venv is activated before running `pip` |
| Import errors after activation | Re-run `pip install -r requirements.txt` |
| `.venv` in git | Check `.gitignore` includes `.venv/` and `venv/` |
