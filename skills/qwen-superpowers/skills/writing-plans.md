---
name: writing-plans
description: Use when you have a spec or approved design for a multi-step task, before touching code. Produces a numbered plan of small, independently verifiable steps.
---

# Writing Plans

Goal: break an approved design into the smallest steps that can each be built and checked on
their own.

## Steps
1. List the steps in order. Each step changes one file or one concern.
2. For each step, write its **check**: the exact command or observation that proves it works
   (a test, a build, a run). No check → the step isn't finished.
3. Order the steps so every one leaves the tree green and the app runnable.
4. Save the plan to a file (e.g. `docs/plans/<topic>.md`) so `/execute-plan` can follow it.

## Rules
- Smaller steps than feel necessary. A weaker model is far more reliable per small step.
- No step should require holding more than one file in mind at once.
- Each step must be independently revertable. If a step needs three files at once, split it.
- Flag risky steps and put them behind a worktree (`skills/using-git-worktrees.md`).
