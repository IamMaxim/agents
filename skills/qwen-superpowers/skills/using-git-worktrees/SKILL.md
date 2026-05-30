---
name: using-git-worktrees
description: Use when starting risky or isolated work, or before executing a plan that touches many files. Keeps mistakes off your main checkout.
---

# Using Git Worktrees

Goal: contain risky work so a bad change is cheap to throw away.

## Steps
1. From a clean repo, create an isolated worktree on a new branch:
   `git worktree add ../<repo>-<task> -b <task>`
2. Work there. Commit after every green step — small, frequent commits are your undo history.
3. If it goes wrong, `git reset` / `git checkout` or just delete the worktree — main is untouched.
4. When done and verified, integrate via `skills/finishing-a-development-branch/SKILL.md`.
5. Remove the worktree when finished: `git worktree remove ../<repo>-<task>`.

## Rules
- Commit per step, not per session. Frequent commits make reverts surgical.
- One task per worktree. Don't mix unrelated work.
- Prefer this whenever a plan touches several files or does anything you're unsure about.
