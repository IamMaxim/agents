---
name: finishing-a-development-branch
description: Use when implementation is complete and all checks pass, to decide how to integrate the work — merge, PR, or discard.
---

# Finishing a Development Branch

Goal: integrate finished work cleanly, or throw it away cleanly.

## Steps
1. Verify everything is green (see `/verify`). Don't finish on red.
2. Review your own diff end to end. Remove debug prints, dead code, and stray files.
3. Confirm commits are small and messages say *why*. Squash noise if needed.
4. Choose how to integrate, and confirm with the user:
   - Open a PR (default for shared repos).
   - Merge to the base branch (only if that's the agreed flow).
   - Discard the branch/worktree (a spike that served its purpose).
5. Clean up: delete the branch/worktree once integrated.

## Rules
- Never merge or push unless the user asked for that integration path.
- A finished branch leaves the base branch green and the history readable.
- If anything is unverified, it isn't finished — go back to `/verify`.
