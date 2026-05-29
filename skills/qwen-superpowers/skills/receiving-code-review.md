---
name: receiving-code-review
description: Use when acting on review feedback, before implementing suggestions — especially if a comment seems unclear or wrong. Verify, don't perform agreement.
---

# Receiving Code Review

Goal: apply feedback with technical rigor, not reflexive agreement.

## Steps
1. Read each comment for what it's actually asking. Restate it if unsure.
2. Decide if it's correct — check the code, docs, or tests. Don't assume the reviewer is right
   or wrong by default.
3. Agree → make the change, then re-run checks.
4. Disagree → say so with evidence (a test, a doc, a counter-example), not opinion. Ask if it's
   still unclear.
5. Don't silently skip comments. Each one gets a change or a reasoned reply.

## Rules
- "You're absolutely right" is not a response. Verify, then act.
- A suggestion that breaks a test is wrong until proven otherwise — show the test.
- Re-verify after applying feedback; a fix for one comment can break something else.
