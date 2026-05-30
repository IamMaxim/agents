---
name: requesting-code-review
description: Use when a change is complete and verified, before merging. Packages the change so a reviewer (human or model) can judge it quickly.
---

# Requesting Code Review

Goal: make the change easy and fast to review.

## Steps
1. Verify first (see `/verification-before-completion`). Don't request review on red or unverified work.
2. Summarize in 2–4 lines: what changed and why. Link the spec/plan if there is one.
3. Show the diff. Keep it scoped — one concern per review.
4. Call out anything risky, uncertain, or deliberately left out of scope.
5. State how you tested it (the commands and their output).

## Rules
- Small diffs get real reviews; huge diffs get rubber stamps. Split if large.
- Don't bundle unrelated refactors into a feature change.
- If you're unsure about a decision, say so explicitly and ask about that specifically.
