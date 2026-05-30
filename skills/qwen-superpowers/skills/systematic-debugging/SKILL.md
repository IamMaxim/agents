---
name: systematic-debugging
description: Use for any bug, test failure, or unexpected behavior, before proposing a fix. One hypothesis at a time, reproduce first.
---

# Systematic Debugging

Goal: find the actual cause before changing code. No shotgun fixes.

## Steps
1. Reproduce. Get a single command or action that fails reliably. Paste the output.
2. Read the real error — the message, the stack, the line. Don't guess from the symptom.
3. State one hypothesis: "I think X, because Y."
4. Make the smallest change that tests that hypothesis. Run it. Observe.
5. Wrong → revert that change, then form the next hypothesis. Don't stack guesses.
6. Right → write or keep a test that locks in the fix (see `/tdd`).

## Rules
- Reproduce before you fix. A bug you can't reproduce, you can't verify fixed.
- One variable at a time. Never change three things and re-run.
- Revert failed attempts immediately so the tree stays clean.
- After 3 failed hypotheses, stop and report what you've ruled out — don't thrash.
- "Probably fixed" is not fixed. Reproduce again and show it's gone.
