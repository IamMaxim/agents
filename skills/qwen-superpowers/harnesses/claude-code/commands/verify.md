---
description: Verify a completion claim with real command output before saying done.
argument-hint: <claim to verify>
---

Apply the Verification Before Completion procedure (canonical: skills/verification-before-completion/SKILL.md).

Before claiming done/fixed/passing, run and PASTE:
1. The tests — real command, real output, this session.
2. Lint / typecheck, if the project has them.
3. The specific requested behavior, demonstrated.

Checklist: ran the exact command on current code? output truly green (not empty/cached)? covers
what was asked? tree in the claimed state? Any unchecked → say "not verified" and what's missing.
Do not commit or open a PR until all pass.

Claim to verify: $ARGUMENTS
