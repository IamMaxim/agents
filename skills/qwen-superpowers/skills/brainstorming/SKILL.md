---
name: brainstorming
description: Use before building anything new — a feature, component, or behavior change. Turns a vague idea into a small, agreed design before any code.
---

# Brainstorming

Goal: turn an idea into a clear, small design before writing code. Do not write code, scaffold,
or edit files until the user approves a design — this applies even to "simple" tasks.

## Steps
1. Restate the goal in one sentence. Confirm it's right.
2. Check the current code: what already exists, what patterns are used, what constrains the change.
3. Ask the user questions **one at a time** — purpose, constraints, success criteria. Prefer
   multiple-choice. Stop asking once you can describe the solution.
4. Propose 2–3 approaches with one-line trade-offs. Recommend one and say why.
5. Present a short design: what changes, which files, how it's tested. Scale length to
   complexity — a few sentences is often enough.
6. Get explicit approval, then hand off: `/write-plan` for non-trivial work, `/tdd` for small.

## Rules
- One question per message. Don't dump a questionnaire.
- Cut every feature that isn't needed now (YAGNI).
- If the request is really several projects, say so and split it before designing.
- No implementation until the design is approved.
