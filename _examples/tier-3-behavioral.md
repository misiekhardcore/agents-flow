# Tier 3: Behavioral Convention Pattern

Tier 3 skills are non-user-invocable (`user-invocable: false`). They do not perform "tasks" in the traditional sense; they enforce **behavioral constraints** and **personas**.

## Structural Blueprint

### SKILL.md (The Behavioral Guardrail)
- **Role**: Defines *how* an agent must think, communicate, or operate.
- **Mechanism**: Activated via `Skill("behavioral-skill")` at the start of a phase.
- **Content**:
    - Strict formatting requirements (e.g., "Always use the following table for reports").
    - Negative constraints (e.g., "Never use `git add .`; always name files explicitly").
    - Communication protocols (e.g., "Surface tradeoffs as a 3-column table: Recommendation | Pro | Con").

## Why Tier-3 instead of `_shared/` reference?
A behavioral convention becomes a Tier 3 skill when it requires the agent to **adopt a specific set of constraints** that must be formally activated to ensure consistency.

- **`_shared/*.md` (Reference)**: "Here is a list of our naming conventions. Read this if you need it." (Passive)
- **Tier 3 Skill (Behavioral)**: "You are now in 'Naming Convention Mode'. You are forbidden from committing any file that violates the rules in this skill." (Active)

## Examples of Behavioral Conventions

### 1. `orchestrator-rules`
- **Encapsulation**: Rules for managing the loop cycle, handling sub-agent reports, and state management in `NOTES.md`.
- **Purpose**: Ensures all orchestrators follow the same meta-process for coordination.

### 2. `interviewing-rules`
- **Encapsulation**: Guidelines for asking clarifying questions and structuring requirements gathering.
- **Purpose**: Shifts the agent from "solving mode" to "discovery mode."

### 3. `notes-md-protocol`
- **Encapsulation**: The exact format and lifecycle of `NOTES.md`.
- **Purpose**: Enforces a strict state-tracking contract for reliable hand-offs.

### 4. `worktree-protocol`
- **Encapsulation**: Rules for managing git worktrees and CWD verification.
- **Purpose**: Prevents filesystem corruption during parallel execution.

### 5. `compaction-protocol`
- **Encapsulation**: Logic for summarizing conversation context.
- **Purpose**: Provides a consistent mechanism for context hygiene.
