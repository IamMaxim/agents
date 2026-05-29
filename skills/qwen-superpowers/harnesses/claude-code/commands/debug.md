---
description: Debug a failure systematically — reproduce first, one hypothesis at a time.
argument-hint: <symptom>
---

Apply the Systematic Debugging procedure (canonical: skills/systematic-debugging.md).

1. Reproduce: a single command/action that fails reliably (paste output).
2. Read the real error — message, stack, line. Don't guess from the symptom.
3. State ONE hypothesis ("X, because Y").
4. Smallest change to test it. Run. Observe.
5. Wrong → revert, next hypothesis. Don't stack guesses.
6. Right → lock the fix with a test (/tdd).

One variable at a time. After 3 failed hypotheses, stop and report what you've ruled out.

Symptom: $ARGUMENTS
