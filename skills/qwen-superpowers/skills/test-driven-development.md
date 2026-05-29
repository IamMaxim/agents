---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code. Red-green-refactor, one behavior at a time.
---

# Test-Driven Development

Goal: drive every change with a test. No production code without a failing test that demands it.

## Steps
1. Pick the smallest behavior to add or fix.
2. Write one test for it. Run it. Confirm it fails, and fails for the **right reason** (paste the
   output). A test that passes immediately is testing the wrong thing.
3. Write the minimum code to make it pass. Run the test. Paste the green output.
4. Refactor if useful, then re-run. Keep it green.
5. Repeat for the next behavior.

## Rules
- One behavior per cycle. Don't write five tests and then five implementations.
- Never edit more than one source file before running the tests.
- For a bug: first write the test that reproduces it (red), then fix it (green). That test is
  both your proof and your regression guard.
- "It should pass" is not passing — run it. The post-edit hook runs checks too; fix red before
  continuing.
- If you can't make a test fail (or then pass) within 2 tries, stop and report what you tried.
