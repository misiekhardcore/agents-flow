# Layer 1: Orchestrator Pattern

Orchestrators are high-level coordinators. They do not perform domain work; they manage the process and delegate execution.

## Structural Blueprint

### SKILL.md (The Process Map)
- **Length**: ≤ 150 lines.
- **Focus**: The "What" and the "Order," not the "How."
- **Key Components**:
    - High-level phase definitions (e.g., Discovery → Define → Implement).
    - Loop conditions and exit criteria.
    - Mapping of phases to Layer 2 skills or Worker Agents.

### Execution Logic (The Coordination)
An orchestrator's main loop typically looks like this:
1. **Initialize State**: Set `cycle = 0`.
2. **Loop**:
    - Increment `cycle`.
    - Check `cycle > max_cycles` → hard stop.
    - **Delegate**: Call `Skill("layer-2-skill")` or `Agent(general-purpose)` with a **Seed-Brief**.
    - **Synthesize**: Aggregate the report from the worker.
    - **Update State**: Record progress in `NOTES.md`.
    - **Verify**: Determine if the cycle is complete or if another iteration is needed.

## Example Delegation (Seed-Brief)

Instead of "Fix the bug in X," a Layer 1 orchestrator provides a structured brief:

```typescript
Agent({
  description: "Implement fix for #123",
  prompt: `
    # Task: Fix Race Condition in Request Handler

    ## Context
    - Issue: #123
    - Target Files: src/handler.ts, src/queue.ts
    - Prior Findings: [Reference to previous cycle report]

    ## Requirements
    - Implement locking mechanism in queue.ts.
    - Ensure handler.ts releases lock in finally block.

    ## Constraints
    - Do not modify the public API.
    - Must pass the provided test case in tests/race.test.ts.

    ## Output
    - Report implementation details and verification results to the main thread.
  `,
  isolation: "worktree"
})
```

## Anti-Patterns to Avoid
- **The "Fat" Orchestrator**: Writing code or performing detailed file audits directly within the orchestrator.
- **The "Blind" Spawn**: Spawning an agent without a complete seed-brief, assuming it "knows" the current state.
- **Infinite Loops**: Failing to implement a `max_cycles` hard stop.
