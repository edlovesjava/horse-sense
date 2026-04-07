---
id: US-087
title: Mermaid diagrams skill
status: draft
priority: Must Have
story_points: 8
section: "3.13 Doc Writer — Documentation Authoring & Maintenance"
---

# US-087 — Mermaid diagrams skill

> As a **developer**, I want **a diagrams skill that guides creating, reviewing, and fixing Mermaid diagrams** so that **technical information is presented visually and diagrams stay accurate as the system evolves**.

## Context

The plugin mandates Mermaid diagrams over binary images (`rules/documentation.md` lines 73-84), but only the `architecture-design` skill covers diagram creation — and only for component and sequence diagrams. There is no skill for creating flowcharts, state diagrams, deployment pipelines, swimlanes, ER diagrams, or dependency graphs. There is also no skill for reviewing or fixing broken/outdated diagrams.

The diagrams skill (`skills/diagrams/SKILL.md`) provides guided workflows for:

- **Creating** diagrams across all Mermaid-supported types
- **Reviewing** diagrams for syntax correctness, clarity, and accuracy vs. the codebase
- **Fixing** broken or outdated diagrams found during reviews or audits

## Acceptance Criteria

```gherkin
Given a request to create a diagram
When  the diagrams skill is invoked
Then  it asks for the diagram type (flowchart, sequence, state, ER, class, deployment, gantt, etc.)
And   it produces a valid Mermaid code block
And   the diagram accurately represents the system or process described

Given a request to document a workflow or process
When  the diagrams skill creates a flowchart
Then  the flowchart includes all decision points, branches, and terminal states
And   it uses consistent styling (classDef) that matches project conventions

Given a request to document system interactions
When  the diagrams skill creates a sequence diagram
Then  it includes all participants, message flows, and alt/opt/loop fragments
And   participant names match actual component or service names in the codebase

Given an existing Mermaid diagram
When  the diagrams skill is invoked for review
Then  it validates Mermaid syntax is correct
And   it checks that entity names (components, services, states) match the current codebase
And   it reports any inaccuracies or missing elements

Given a broken or outdated Mermaid diagram
When  the diagrams skill is invoked for fixing
Then  it corrects syntax errors
And   it updates entity names and relationships to match the current codebase
And   it preserves the original diagram intent and layout style

Given a diagram is created or updated
When  the skill finishes
Then  the diagram is embedded in the appropriate Markdown file as a fenced mermaid code block
And   a static SVG fallback is generated for viewers without Mermaid support
```

## Notes

- The skill should support all Mermaid diagram types: flowchart, sequence, class, state, ER, gantt, pie, journey, quadrant, mindmap, timeline, sankey, block
- SVG fallback generation may require an external tool (mermaid-cli or MCP rendering) — document the approach
- The architecture-design skill already covers architecture-specific diagrams; this skill is for general-purpose diagramming
- The skill should reference `rules/documentation.md` for Mermaid standards (no binary images, text-based, version-controlled)
