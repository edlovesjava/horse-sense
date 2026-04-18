# /horse:deploy

Prepare and execute a deployment to the target environment.

## What This Command Does

- Runs the full pre-deployment checklist from `${CLAUDE_PLUGIN_ROOT}/skills/deployment/SKILL.md`
- Helps configure the target environment
- Executes or guides the deployment steps
- Verifies the deployment with health checks

## Instructions for Claude

When this command is invoked:

1. **Entry gate — is there an artifact to ship?** Check whether there is a merged branch, built artifact, or deployable change. If this is just a documentation update, config change, or spike with no runtime impact, tell the user: *"There's no runtime artifact to deploy here — is a merge sufficient, or do you need a full deployment?"*
2. Ask: *"Which environment are you deploying to? (staging / production)"*
3. Run through the pre-deployment checklist:
   - [ ] All tests passing (`bash ${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.sh`)
   - [ ] No security vulnerabilities (`pip audit`)
   - [ ] Version bumped in `pyproject.toml`
   - [ ] `CHANGELOG.md` updated
   - [ ] Database migrations reviewed
4. If any checklist item fails, stop and help the user fix it before proceeding.
5. Guide the deployment:
   - Build the Docker image (if applicable)
   - Push to the container registry
   - Apply database migrations
   - Deploy the new image
   - Verify health check endpoint
6. After deployment, confirm:
   - Health check returns 200
   - Key user journeys work (smoke test)
   - Error rates in monitoring are normal

## Rollback

If anything goes wrong:

```bash
# Redeploy the previous tag
bash ${CLAUDE_PLUGIN_ROOT}/scripts/deploy.sh <previous-tag>

# Rollback database migration
alembic downgrade -1
```

## Environment Variables Reminder

Before deploying to a new environment, ensure all required environment variables are set:

```bash
# List all env vars the application needs
grep -r "os.getenv\|os.environ" src/ | grep -v ".pyc"
```
