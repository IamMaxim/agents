---
name: executing-plans
description: Use when you have a written plan to execute. Works one step at a time with a check after each, and stops on failure.
---

# Executing Plans

Goal: work a plan to completion without drifting, skipping, or barreling past failures.

## Steps
1. Read the plan. Restate the next single step. Do only that step.
2. Make the change, limited to the one file/concern the step names.
3. Run that step's check. Paste the output.
4. Green → mark the step done and move to the next. Red → fix it now; do not start the next step.
5. Before each step, re-read it fresh. Don't batch steps "to save time".

## Rules
- One step at a time. Never edit ahead of the current step.
- If a step turns out bigger than the plan implied, stop and update the plan first.
- Stuck on a step after 2–3 tries → stop and report. Don't thrash.
- The post-edit hook runs checks automatically; treat any failure it reports as a hard stop.
