# Design — qwen-superpowers

The problem, the approach, the structure, and what's deliberately out of scope. Written 2026-05-29.

## Problem
[Superpowers] is tuned for Claude. Driven with Qwen3.5-397B-A17B under Qwen Code, the model
drifts, skips steps, claims unverified success, and occasionally runs destructive commands —
needing constant babysitting. We want the *methodology* to survive the model swap and yield a
tool that actually speeds up work instead of a toy.

## Key insight: containment vs. capability
Two separable problems:
- **Capability** — the model makes mistakes. Mitigable, with a hard ceiling.
- **Containment** — its mistakes are expensive. Cheaply solvable.

Most "babysitting" is containment wearing a capability costume. So this pack spends first on
making mistakes cheap and unhideable, then on guiding the model.

## Three layers (lowest trust first)
1. **Enforcement** (`hooks/`) — block destructive shell; run checks after edits and feed
   failures back. Requires no trust in the model.
2. **Always-on discipline** (`QWEN.md`) — the non-negotiables, every turn. Low trust.
3. **On-demand procedure** (`commands/` + `skills/`) — TDD, debugging, planning, review; invoked
   explicitly, because Qwen won't self-select skills reliably.

## Why not port the skills verbatim?
Model facts that break the originals (full list + sources in [`model-notes.md`](model-notes.md)):
- Thinks by default, no soft switch, must strip thinking from history → can't lean on an
  invisible scratchpad; must suppress verbosity.
- Tool calls go through the `qwen3_coder` parser and a "not guaranteed" protocol → enforce,
  don't trust.
- Attention degrades with context faster than Claude → short, numbered prose beats long
  ALL-CAPS/flowchart skills, and only essentials stay always-on.
- fp8 serving can degrade structured output → enforcement matters more.

## Mapping Superpowers → Qwen Code
Qwen Code has no Claude-style Skill tool or auto-invocation. We map:
- Skill auto-invocation → explicit slash commands + always-on `QWEN.md` pointers.
- "Please verify / be careful" → `PreToolUse` + `PostToolUse` hooks (deterministic).
- Progressive disclosure → commands carry condensed procedures inline (robust across versions);
  `skills/` holds the fuller canonical text.

## Scope (v1)
Core methodology, 10 skills: brainstorming, writing-plans, executing-plans, test-driven-development,
systematic-debugging, verification-before-completion, requesting-code-review,
receiving-code-review, using-git-worktrees, finishing-a-development-branch.

## Non-goals
- **No model change.** Qwen3.5-397B-A17B is deployed company-wide and fixed; this pack targets it
  exclusively. (Coding-specialized siblings benchmark higher on agentic coding, but switching is
  out of the user's control and therefore out of scope.)
- Not a security sandbox — that's Qwen Code's sandbox; the hooks are a guardrail.
- Not the subagent / parallel-dispatch skills — they tend to compound a weaker model's errors;
  deferred to a later version.

## To revisit after real-world testing
- Slash-command arg placeholder is `{{args}}` (Gemini-CLI style). Confirm on the target Qwen Code
  version; switch commands to file-injection (`@{skills/…}`) if those paths resolve reliably.
- Shell/edit tool-name matchers are broad regexes; tighten once real tool names are confirmed via
  `--debug`.
- Post-edit checks run after every edit; if too slow, scope the matcher to specific paths.

## Credits
Methodology adapted from Superpowers by Jesse Vincent (obra), MIT-licensed. Independent and
unaffiliated.

[Superpowers]: https://github.com/obra/superpowers
