---
name: verification-before-completion
description: Use before claiming work is complete, fixed, or passing — and before committing or opening a PR. Evidence before assertions, always.
---

# Verification Before Completion

Goal: never assert success you haven't observed.

## Before you say "done" / "fixed" / "passing", run and paste:
1. The tests — the real command and real output, this session. Not "they should pass".
2. Lint / typecheck, if the project has them.
3. The specific thing requested, demonstrated. If asked for behavior X, show X happening.

## Checklist
- [ ] Did I run the exact command, this session, on the current code?
- [ ] Is the output actually green — not empty, not a cached or old run?
- [ ] Does it cover what was asked, not a near-miss?
- [ ] Is the tree in the state I'm claiming?

If any box is unchecked, say "not verified" and name what's missing. Do not commit or open a PR
until all are checked.

## Rules
- No success claim without command output in the same message.
- "I didn't run it, but it should work" is a red flag — run it.
- The post-edit hook is a floor, not a ceiling: passing it is not the same as proving the
  feature does what was asked.
