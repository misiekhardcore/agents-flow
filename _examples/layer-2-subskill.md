# Layer 2: Sub-skill Pattern

Sub-skills are specialized, reusable functional blocks. They are `user-invocable: true` and designed to be either called by a user or delegated to by an orchestrator.

## Structural Blueprint

### SKILL.md (The Specialist's Manual)
- **Role**: Expert in a specific domain (e.g., Architecture, Verification, Review).
- **Input**: Typically accepts a specific identifier (Issue #, PR #) or a brief from an orchestrator.
- **Specialist-Mode Contract**:
    - Reads current state from `NOTES.md`.
    - Performs the specialized task.
    - Writes detailed findings, assumptions, and uncertainties back to `NOTES.md`.
    - Returns a high-level summary report to the caller.

## Example: A "Verification" Specialist
A Layer 2 verification skill doesn't just "test"; it follows a rigorous protocol:

1. **Input Analysis**: Read the AC from the issue and the implementation plan from `NOTES.md`.
2. **Test Generation**: Create a matrix of "Given/When/Then" scenarios for every AC.
3. **Execution**: Run the code and observe behavior (or run tests).
4. **Verdict**: Mark each AC as `PASS` or `FAIL`.
5. **Reporting**:
    - **To `NOTES.md`**: Detailed logs of what was tested, which inputs were used, and exactly why a test failed.
    - **To Caller**: A concise punch-list of passed/failed ACs.

## Key Differences from Layer 1
- **Layer 1 asks "What is next?"** $\rightarrow$ **Layer 2 asks "How do I solve this specific part?"**
- Layer 1 manages the loop; Layer 2 manages the domain logic.
- Layer 1 is a conductor; Layer 2 is the musician.
