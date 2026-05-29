---
description: Implement a change test-first (red-green-refactor), one behavior at a time.
argument-hint: <change to implement>
---

Apply the Test-Driven Development procedure (canonical: skills/test-driven-development.md).

1. Pick the smallest behavior.
2. Write ONE test. Run it. Confirm it fails for the RIGHT reason (paste output).
3. Write the minimum code to pass. Run it. Paste green output.
4. Refactor if useful; re-run; keep green.
5. Repeat for the next behavior.

One behavior per cycle. Never edit more than one source file before running tests. For a bug,
first write the failing test that reproduces it. "Should pass" is not passing — run it.

Change to implement: $ARGUMENTS
