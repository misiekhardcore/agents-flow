---
name: scope-assessment
description: Given a list of work units (each with an id and resource list), group them by shared resources and output one agent entry per conflict-free group. Use when an orchestrator needs to fan out work without resource conflicts.
model: haiku
user-invocable: false
---
## Input

Caller sets `work_units` in context before invoking. Each unit must have:

```yaml
work_units:
  - id: "<identifier>"
    resources: [<file_or_path>, ...]
```

`id` is a human-readable label (issue number, file name, task description). `resources` is the exhaustive list of files or paths the unit reads or writes.

## Process

1. Receive `work_units` list from caller context.
2. Build a resource-to-unit index: for each resource, record which units reference it.
3. Identify overlapping pairs: two units overlap when they share at least one resource.
4. Merge overlapping units into a single group — repeat until no two groups share a resource (transitive closure).
5. For each resulting disjoint group, produce one agent entry:
   - `scope`: one sentence describing what this agent will do, derived from the group's unit IDs.
   - `resources`: deduplicated, sorted union of all resources in the group.
6. Output the agent plan (see Output).

## Output

```yaml
agents:
  - scope: "<one sentence>"
    resources: [<file_or_path>, ...]
```

- One entry per disjoint group.
- `scope` is a single sentence; no bullet lists or sub-items.
- `resources` is a flat, deduplicated, sorted list.
- No sizing or complexity labels — output is agent-consumable only.

## Rules

- Never produce sizing or complexity labels of any kind.
- Never infer resources not explicitly listed in the input — callers own resource enumeration.
- When all work units are disjoint, output N agents (one per unit).
- When all work units overlap, output 1 agent covering the full resource union.
- Output only the YAML block; no prose explanation unless the caller explicitly requests one.
