# horse-sense

> Mr. Ed's practical and powerful Claude Code plugin with agents, skills and rules.

**horse-sense** is a publicly available [Claude Code](https://claude.ai/code) plugin that guides autonomous software development through a structured SDLC methodology. It provides agents, skills, rules, templates, and bash scripts to help you ship software faster and more consistently.

## Quick Start

```bash
# Clone the plugin
git clone https://github.com/edlovesjava/horse-sense

# Use it with Claude Code
claude --plugin-dir ./horse-sense/horse

# Start the SDLC workflow
# Type /horse:guide in Claude Code to begin
```

## What's Inside

| Capability | Description |
|---|---|
| **[Commands](commands.md)** | Slash commands that drive the SDLC workflow |
| **[Agents](agents.md)** | Specialized role personas: planner, architect, developer, tester, reviewer, scout, trainer |
| **[Skills](skills.md)** | Step-by-step guides for every SDLC phase (Python + TypeScript) |
| **[Rules](rules.md)** | Coding standards, documentation, testing, and git workflow rules |
| **[Templates](templates.md)** | Fill-in-the-blank scaffolds for plans, requirements, architecture, ADRs, and sprints |

## Next Steps

- [Installation](getting-started/installation.md)
- [Configuration](getting-started/configuration.md)
- [Architecture Overview](architecture/index.md)
