# Installation

## Prerequisites

- **Python >= 3.11** (for Python projects) or **Node.js >= 20** (for TypeScript projects)
- Git
- Bash-compatible shell (Linux / macOS / WSL)
- [Claude Code](https://claude.ai/code) with plugin support

## Install the Plugin

```bash
# 1. Clone the repository
git clone https://github.com/edlovesjava/horse-sense

# 2. Launch Claude Code with the plugin
claude --plugin-dir ./horse-sense/horse
```

The plugin's commands, agents, and skills are auto-discovered by Claude Code at startup.

## Verify Installation

Inside Claude Code, run:

```
/horse:guide
```

If the command is recognized, the plugin is installed correctly.

## Next: [Configuration](configuration.md)
