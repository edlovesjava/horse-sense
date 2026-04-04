#!/usr/bin/env bash
# validate-plugin.sh — Validate the horse plugin structure.
# Run from the repo root: scripts/validate-plugin.sh

set -euo pipefail

PLUGIN_DIR="${PLUGIN_DIR:-horse}"

# ---------------------------------------------------------------------------
# Color helpers (degrade gracefully when not a terminal)
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  RESET='\033[0m'
else
  GREEN=''
  RED=''
  RESET=''
fi

PASS=0
FAIL=0

pass() { echo -e "${GREEN}✓${RESET} $*"; PASS=$((PASS + 1)); }
fail() { echo -e "${RED}✗${RESET} $*"; FAIL=$((FAIL + 1)); }

# ---------------------------------------------------------------------------
# 1. plugin.json exists and is valid JSON
# ---------------------------------------------------------------------------
PLUGIN_JSON="${PLUGIN_DIR}/.claude-plugin/plugin.json"

if [ -f "${PLUGIN_JSON}" ]; then
  pass "${PLUGIN_JSON} exists"
  if jq empty "${PLUGIN_JSON}" 2>/dev/null; then
    pass "${PLUGIN_JSON} is valid JSON"
  else
    fail "${PLUGIN_JSON} is not valid JSON"
  fi
else
  fail "${PLUGIN_JSON} does not exist"
fi

# ---------------------------------------------------------------------------
# 2. plugin.json has required fields: name, description
# ---------------------------------------------------------------------------
if [ -f "${PLUGIN_JSON}" ] && jq empty "${PLUGIN_JSON}" 2>/dev/null; then
  for field in name description; do
    value=$(jq -r ".${field} // empty" "${PLUGIN_JSON}")
    if [ -n "${value}" ]; then
      pass "plugin.json has required field: ${field}"
    else
      fail "plugin.json missing required field: ${field}"
    fi
  done
fi

# ---------------------------------------------------------------------------
# 3. Every .md file in horse/agents/ is non-empty
# ---------------------------------------------------------------------------
AGENTS_DIR="${PLUGIN_DIR}/agents"
if [ -d "${AGENTS_DIR}" ]; then
  agent_files=("${AGENTS_DIR}"/*.md)
  if [ "${#agent_files[@]}" -eq 0 ] || [ ! -f "${agent_files[0]}" ]; then
    fail "${AGENTS_DIR}/ contains no .md files"
  else
    for f in "${AGENTS_DIR}"/*.md; do
      if [ -s "${f}" ]; then
        pass "agents/$(basename "${f}") is non-empty"
      else
        fail "agents/$(basename "${f}") is empty"
      fi
    done
  fi
else
  fail "${AGENTS_DIR}/ directory does not exist"
fi

# ---------------------------------------------------------------------------
# 4. Every .md file in horse/commands/ is non-empty
# ---------------------------------------------------------------------------
COMMANDS_DIR="${PLUGIN_DIR}/commands"
if [ -d "${COMMANDS_DIR}" ]; then
  cmd_files=("${COMMANDS_DIR}"/*.md)
  if [ "${#cmd_files[@]}" -eq 0 ] || [ ! -f "${cmd_files[0]}" ]; then
    fail "${COMMANDS_DIR}/ contains no .md files"
  else
    for f in "${COMMANDS_DIR}"/*.md; do
      if [ -s "${f}" ]; then
        pass "commands/$(basename "${f}") is non-empty"
      else
        fail "commands/$(basename "${f}") is empty"
      fi
    done
  fi
else
  fail "${COMMANDS_DIR}/ directory does not exist"
fi

# ---------------------------------------------------------------------------
# 5. Every horse/skills/*/SKILL.md exists and is non-empty
# ---------------------------------------------------------------------------
SKILLS_DIR="${PLUGIN_DIR}/skills"
if [ -d "${SKILLS_DIR}" ]; then
  skill_dirs=("${SKILLS_DIR}"/*)
  if [ "${#skill_dirs[@]}" -eq 0 ] || [ ! -d "${skill_dirs[0]}" ]; then
    fail "${SKILLS_DIR}/ contains no skill subdirectories"
  else
    for d in "${SKILLS_DIR}"/*/; do
      [ -d "${d}" ] || continue
      skill_name=$(basename "${d}")
      skill_md="${d}SKILL.md"
      if [ -s "${skill_md}" ]; then
        pass "skills/${skill_name}/SKILL.md exists and is non-empty"
      elif [ -f "${skill_md}" ]; then
        fail "skills/${skill_name}/SKILL.md exists but is empty"
      else
        fail "skills/${skill_name}/SKILL.md does not exist"
      fi
    done
  fi
else
  fail "${SKILLS_DIR}/ directory does not exist"
fi

# ---------------------------------------------------------------------------
# 6. Every .sh file in horse/scripts/ is executable
# ---------------------------------------------------------------------------
HS_SCRIPTS_DIR="${PLUGIN_DIR}/scripts"
if [ -d "${HS_SCRIPTS_DIR}" ]; then
  sh_files=("${HS_SCRIPTS_DIR}"/*.sh)
  if [ "${#sh_files[@]}" -eq 0 ] || [ ! -f "${sh_files[0]}" ]; then
    pass "${HS_SCRIPTS_DIR}/ contains no .sh files (nothing to check)"
  else
    for f in "${HS_SCRIPTS_DIR}"/*.sh; do
      if [ -x "${f}" ]; then
        pass "scripts/$(basename "${f}") is executable"
      else
        fail "scripts/$(basename "${f}") is not executable"
      fi
    done
  fi
else
  fail "${HS_SCRIPTS_DIR}/ directory does not exist"
fi

# ---------------------------------------------------------------------------
# 7. No orphaned skill directories (dirs in skills/ without a SKILL.md)
# ---------------------------------------------------------------------------
if [ -d "${SKILLS_DIR}" ]; then
  for d in "${SKILLS_DIR}"/*/; do
    [ -d "${d}" ] || continue
    skill_name=$(basename "${d}")
    if [ ! -f "${d}SKILL.md" ]; then
      fail "skills/${skill_name}/ is an orphaned directory (no SKILL.md)"
    fi
    # Already reported pass/fail for non-empty above; skip double-counting here.
  done
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "----------------------------------------"
if [ "${FAIL}" -eq 0 ]; then
  echo -e "${GREEN}${PASS} checks passed, ${FAIL} checks failed${RESET}"
  exit 0
else
  echo -e "${RED}${PASS} checks passed, ${FAIL} checks failed${RESET}"
  exit 1
fi
