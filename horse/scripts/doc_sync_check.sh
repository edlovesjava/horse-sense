#!/usr/bin/env bash
# doc_sync_check.sh — Verify parity between story frontmatter status and
# the requirements index table status column.
#
# Usage: bash doc_sync_check.sh [requirements_doc] [stories_dir]
#   requirements_doc  defaults to docs/requirements/requirements_doc.md
#   stories_dir       defaults to docs/requirements/stories
#
# Exits 0 if all statuses match, 1 if drift is found.

set -euo pipefail

# ── Colour helpers ────────────────────────────────────────────────────────────
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  NC='\033[0m'
else
  GREEN='' RED='' YELLOW='' NC=''
fi

info()  { echo -e "${GREEN}[doc-sync]${NC} $*"; }
warn()  { echo -e "${YELLOW}[doc-sync]${NC} $*"; }
error() { echo -e "${RED}[doc-sync]${NC} $*" >&2; }

# ── Configuration ─────────────────────────────────────────────────────────────
REQ_DOC="${1:-docs/requirements/requirements_doc.md}"
STORIES_DIR="${2:-docs/requirements/stories}"

if [[ ! -f "${REQ_DOC}" ]]; then
  error "Requirements doc not found: ${REQ_DOC}"
  exit 1
fi

if [[ ! -d "${STORIES_DIR}" ]]; then
  error "Stories directory not found: ${STORIES_DIR}"
  exit 1
fi

# ── Extract statuses from the index table ─────────────────────────────────────
# Index table rows look like:
#   | [US-NNN](stories/US-NNN-title.md) | Title | Priority | SP | Status |
# We extract the story ID and the status column (last before trailing |).

declare -A index_status

while IFS= read -r line; do
  # Match rows containing a story link
  if [[ "${line}" =~ \[US-([0-9]+)\] ]]; then
    story_id="US-${BASH_REMATCH[1]}"
    # Split by | and grab the status (5th field, 1-indexed after leading |)
    # Table: | Link | Title | Priority | SP | Status |
    status=$(echo "${line}" | awk -F'|' '{print $6}' | xargs)
    if [[ -n "${status}" ]]; then
      # Normalize to lowercase for comparison
      # Normalize: lowercase, replace spaces with hyphens to match frontmatter convention
      index_status["${story_id}"]=$(echo "${status}" | tr '[:upper:]' '[:lower:]' | sed 's/^ *//;s/ *$//;s/ /-/g')
    fi
  fi
done < "${REQ_DOC}"

if [[ ${#index_status[@]} -eq 0 ]]; then
  warn "No story references found in ${REQ_DOC}"
  exit 0
fi

# ── Extract statuses from story frontmatter ───────────────────────────────────
declare -A frontmatter_status
drift_count=0

for story_file in "${STORIES_DIR}"/US-*.md; do
  [[ -f "${story_file}" ]] || continue

  # Extract id and status from YAML frontmatter
  fm_id=""
  fm_status=""
  in_frontmatter=false

  while IFS= read -r line; do
    if [[ "${line}" == "---" ]]; then
      if ${in_frontmatter}; then
        break  # end of frontmatter
      else
        in_frontmatter=true
        continue
      fi
    fi

    if ${in_frontmatter}; then
      if [[ "${line}" =~ ^id:\ *(.*) ]]; then
        fm_id=$(echo "${BASH_REMATCH[1]}" | xargs)
      elif [[ "${line}" =~ ^status:\ *(.*) ]]; then
        fm_status=$(echo "${BASH_REMATCH[1]}" | xargs | tr '[:upper:]' '[:lower:]')
      fi
    fi
  done < "${story_file}"

  if [[ -n "${fm_id}" && -n "${fm_status}" ]]; then
    frontmatter_status["${fm_id}"]="${fm_status}"
  elif [[ -n "${fm_id}" && -z "${fm_status}" ]]; then
    warn "PARSE: ${fm_id} — file found but missing 'status' in frontmatter (${story_file})"
    ((drift_count++))
  elif [[ -z "${fm_id}" ]]; then
    warn "PARSE: missing 'id' in frontmatter (${story_file})"
    ((drift_count++))
  fi
done

# ── Compare ───────────────────────────────────────────────────────────────────
info "Checking ${#index_status[@]} stories in index against frontmatter..."

for story_id in $(echo "${!index_status[@]}" | tr ' ' '\n' | sort); do
  idx="${index_status[${story_id}]}"
  fm="${frontmatter_status[${story_id}]:-}"

  if [[ -z "${fm}" ]]; then
    error "DRIFT: ${story_id} — in index (${idx}) but no frontmatter file found"
    ((drift_count++))
  elif [[ "${idx}" != "${fm}" ]]; then
    error "DRIFT: ${story_id} — index says '${idx}', frontmatter says '${fm}'"
    ((drift_count++))
  fi
done

# Check for stories in frontmatter but not in index
for story_id in $(echo "${!frontmatter_status[@]}" | tr ' ' '\n' | sort); do
  if [[ -z "${index_status[${story_id}]:-}" ]]; then
    error "DRIFT: ${story_id} — in frontmatter but not found in index table"
    ((drift_count++))
  fi
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
if [[ ${drift_count} -eq 0 ]]; then
  info "All ${#index_status[@]} stories in sync ✓"
  exit 0
else
  error "${drift_count} drift(s) found — story frontmatter and index table are out of sync"
  exit 1
fi
