# Layer 3: Behavioral Convention Pattern

Layer 3 skills are non-user-invocable (`user-invocable: false`). They do not perform "tasks" in the traditional sense; they enforce **behavioral constraints** and **personas**.

## Structural Blueprint

### SKILL.md (The Behavioral Guardrail)
- **Role**: Defines *how* an agent must think, communicate, or operate.
- **Mechanism**: Activated via `Skill("behavioral-skill")` at the start of a phase.
- **Content**:
    - Strict formatting requirements (e.g., "Always use the following table for reports").
    - Negative constraints (e.g., "Never use `git add .`; always name files explicitly").
    - Communication protocols (e.g., "Surface tradeoffs as a 3-column table: Recommendation | Pro | Con").

## Why Layer-3 instead of `_shared/` reference?

A behavioral convention becomes a Layer 3 skill when it requires the agent to **actively adopt a set of constraints** — not just read information.

- **`_shared/*.md` (Reference)**: "Here is the format for the handoff fields. Read this when you need it." (Passive lookup)
- **Layer 3 Skill (Behavioral)**: "You are now operating under orchestrator rules. You are forbidden from prompting the user between sub-skills." (Active constraint)

**Decision rule**: Behavioral constraint Claude must actively operate under → layer-3 skill. Format table, field list, or lookup reference → `_shared/` doc.

## Examples of Behavioral Conventions

### 1. `orchestrator-rules`
- **Encapsulation**: Rules for managing the loop cycle, handling sub-agent reports, and state management in `NOTES.md`.
- **Purpose**: Ensures all orchestrators follow the same meta-process for coordination.

### 2. `interviewing-rules`
- **Encapsulation**: Guidelines for asking clarifying questions and structuring requirements gathering.
- **Purpose**: Shifts the agent from "solving mode" to "discovery mode."

### 3. `worktree`
- **Encapsulation**: Rules for managing git worktrees and CWD verification.
- **Purpose**: Prevents filesystem corruption during parallel execution.

### 4. `compaction-protocol`
- **Encapsulation**: Logic for summarizing conversation context before `/compact`.
- **Purpose**: Provides a consistent mechanism for context hygiene.

## Counter-examples (`_shared/` docs, not layer-3 skills)

- `handoff-artifact.md` — five-field issue-body format and shape template; callers read it on-demand at handoff steps.
- `notes-md-protocol.md` — `.claude/NOTES.md` format, lifecycle, and required sections; callers read it when creating or harvesting the file.
