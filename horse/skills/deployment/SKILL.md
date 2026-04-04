---
name: deployment
description: Prepare deployment artifacts, CI/CD workflows, and runbooks
---

# Skill: Deployment

## Purpose

Package, configure, and ship software to its target environment reliably and repeatably. A good deployment process is automated, auditable, and reversible.

## Deployment Checklist

Before any deployment:

- [ ] All tests pass in CI
- [ ] Coverage meets the project threshold
- [ ] No known security vulnerabilities (`pip audit`)
- [ ] `CHANGELOG.md` updated
- [ ] Version bumped (`pyproject.toml` or `setup.cfg`)
- [ ] Database migration scripts reviewed and tested
- [ ] Rollback plan documented

## Environments

| Environment | Purpose | Trigger |
|---|---|---|
| **Development** | Local development | Manual / file-watch |
| **Staging** | Integration testing, QA | Merge to `develop` |
| **Production** | Live users | Tagged release |

## Environment Variables

Never hardcode secrets. Use environment variables:

```bash
# .env.example (commit this)
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
SECRET_KEY=change-me
DEBUG=false
LOG_LEVEL=INFO
```

```bash
# .env (never commit — in .gitignore)
DATABASE_URL=postgresql://prod-user:s3cr3t@db.example.com:5432/proddb
SECRET_KEY=a-long-random-string-generated-by-secrets-module
DEBUG=false
LOG_LEVEL=WARNING
```

Generate a secure secret key:

```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

## Containerization with Docker

### Dockerfile (Python)

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies first (layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src/ ./src/

# Run as non-root user
RUN adduser --disabled-password --gecos "" appuser
USER appuser

EXPOSE 8000
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Docker Compose (local dev)

```yaml
services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://dev:dev@db:5432/devdb
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
      POSTGRES_DB: devdb
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U dev"]
      interval: 5s
      retries: 5
```

```bash
# Start services
docker compose up -d

# View logs
docker compose logs -f app

# Stop and remove containers
docker compose down
```

## CI/CD Pipeline

### GitHub Actions Example

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: |
          python -m venv .venv
          source .venv/bin/activate
          pip install -r requirements-dev.txt
          pytest tests/ --cov=src --cov-fail-under=80
          pip audit

  deploy:
    needs: test
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - name: Build and push Docker image
        run: |
          docker build -t myapp:${{ github.ref_name }} .
          docker push registry.example.com/myapp:${{ github.ref_name }}
      - name: Deploy to production
        run: bash scripts/deploy.sh ${{ github.ref_name }}
```

## Database Migrations

```bash
# Run pending migrations (Alembic)
alembic upgrade head

# Create a new migration
alembic revision --autogenerate -m "add users table"

# Rollback one migration
alembic downgrade -1
```

Always test migrations on a copy of the production database before deploying.

## Rollback Procedure

```bash
# 1. Revert to the previous Docker image tag
docker pull registry.example.com/myapp:<previous-tag>
bash scripts/deploy.sh <previous-tag>

# 2. Roll back database migration (if applicable)
alembic downgrade -1

# 3. Verify health check passes
curl https://app.example.com/health
```

## Health Checks

Every service should expose a `/health` endpoint:

```python
@app.get("/health")
def health_check():
    return {"status": "ok", "version": settings.APP_VERSION}
```

## Deployment Scripts

See `scripts/deploy.sh` for the deployment automation script.
