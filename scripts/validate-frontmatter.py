#!/usr/bin/env python3
"""validate-frontmatter.py — Validate YAML frontmatter in horse plugin Markdown files.

Run from the repo root:
    python3 scripts/validate-frontmatter.py

Exit codes:
    0  All required checks passed (warnings are OK).
    1  One or more required fields are missing.
"""

import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Color helpers (degrade gracefully when stdout is not a terminal)
# ---------------------------------------------------------------------------
if sys.stdout.isatty():
    GREEN = "\033[0;32m"
    RED = "\033[0;31m"
    YELLOW = "\033[0;33m"
    RESET = "\033[0m"
else:
    GREEN = RED = YELLOW = RESET = ""

_files_checked = 0
_errors = 0
_warnings = 0


def _ok(msg: str) -> None:
    print(f"{GREEN}\u2713{RESET} {msg}")


def _err(msg: str) -> None:
    global _errors
    _errors += 1
    print(f"{RED}\u2717{RESET} {msg}")


def _warn(msg: str) -> None:
    global _warnings
    _warnings += 1
    print(f"{YELLOW}\u26a0{RESET}  {msg}")


# ---------------------------------------------------------------------------
# Frontmatter parser (stdlib only — no PyYAML dependency)
# ---------------------------------------------------------------------------
_FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
_KEY_VALUE_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.*?)\s*$")


def parse_frontmatter(text: str) -> dict[str, str] | None:
    """Return a dict of key/value pairs from the leading YAML frontmatter block.

    Returns None when no frontmatter block is present.  Only simple scalar
    key: value lines are extracted; nested YAML is intentionally ignored
    because the required fields (name, description) are always scalars.
    """
    m = _FRONTMATTER_RE.match(text)
    if m is None:
        return None
    fields: dict[str, str] = {}
    for line in m.group(1).splitlines():
        kv = _KEY_VALUE_RE.match(line)
        if kv:
            fields[kv.group(1)] = kv.group(2)
    return fields


# ---------------------------------------------------------------------------
# Per-component validators
# ---------------------------------------------------------------------------

def _check_required(
    path: Path,
    fields: dict[str, str],
    required: list[str],
    rel: str,
) -> None:
    """Verify that every required field is present and non-empty."""
    for field in required:
        value = fields.get(field, "").strip()
        if value:
            _ok(f"{rel}: '{field}' present")
        else:
            _err(f"{rel}: required field '{field}' is missing or empty")


def validate_agent(path: Path, plugin_root: Path) -> None:
    global _files_checked
    _files_checked += 1
    rel = str(path.relative_to(plugin_root.parent))
    text = path.read_text(encoding="utf-8")
    fields = parse_frontmatter(text)
    if fields is None:
        _err(f"{rel}: no frontmatter block found")
        return
    _check_required(path, fields, ["name", "description"], rel)


def validate_skill(path: Path, plugin_root: Path) -> None:
    global _files_checked
    _files_checked += 1
    rel = str(path.relative_to(plugin_root.parent))
    text = path.read_text(encoding="utf-8")
    fields = parse_frontmatter(text)
    if fields is None:
        _err(f"{rel}: no frontmatter block found")
        return
    _check_required(path, fields, ["name", "description"], rel)


def validate_command(path: Path, plugin_root: Path) -> None:
    global _files_checked
    _files_checked += 1
    rel = str(path.relative_to(plugin_root.parent))
    text = path.read_text(encoding="utf-8")
    fields = parse_frontmatter(text)
    if fields is None:
        _warn(f"{rel}: no frontmatter block (commands may omit frontmatter)")
    else:
        _ok(f"{rel}: frontmatter present")


def validate_rule(path: Path, plugin_root: Path) -> None:
    global _files_checked
    _files_checked += 1
    rel = str(path.relative_to(plugin_root.parent))
    text = path.read_text(encoding="utf-8")
    fields = parse_frontmatter(text)
    if fields is None:
        _warn(f"{rel}: no frontmatter block (rules may omit frontmatter)")
    else:
        _ok(f"{rel}: frontmatter present")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    # Resolve the plugin root relative to this script's location so the
    # script works when invoked from any directory.
    repo_root = Path(__file__).resolve().parent.parent
    plugin_root = repo_root / "horse"

    if not plugin_root.is_dir():
        print(f"{RED}\u2717{RESET} Plugin directory not found: {plugin_root}")
        return 1

    # --- Agents ---
    agents_dir = plugin_root / "agents"
    print(f"\nAgents ({agents_dir.relative_to(repo_root)}/):")
    for path in sorted(agents_dir.glob("*.md")):
        validate_agent(path, plugin_root)

    # --- Skills ---
    skills_dir = plugin_root / "skills"
    print(f"\nSkills ({skills_dir.relative_to(repo_root)}/*/):")
    for skill_dir in sorted(p for p in skills_dir.iterdir() if p.is_dir()):
        skill_md = skill_dir / "SKILL.md"
        if skill_md.is_file():
            validate_skill(skill_md, plugin_root)
        else:
            # Orphaned directory — count as a checked+errored file so it shows up.
            global _files_checked, _errors
            _files_checked += 1
            _errors += 1
            rel = str(skill_dir.relative_to(repo_root))
            print(f"{RED}\u2717{RESET} {rel}/: directory has no SKILL.md")

    # --- Commands ---
    commands_dir = plugin_root / "commands"
    print(f"\nCommands ({commands_dir.relative_to(repo_root)}/):")
    for path in sorted(commands_dir.glob("*.md")):
        validate_command(path, plugin_root)

    # --- Rules ---
    rules_dir = plugin_root / "rules"
    print(f"\nRules ({rules_dir.relative_to(repo_root)}/):")
    for path in sorted(rules_dir.glob("*.md")):
        validate_rule(path, plugin_root)

    # --- Summary ---
    print()
    print("-" * 40)
    summary = f"{_files_checked} files checked, {_errors} errors, {_warnings} warnings"
    if _errors == 0:
        print(f"{GREEN}{summary}{RESET}")
        return 0
    else:
        print(f"{RED}{summary}{RESET}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
