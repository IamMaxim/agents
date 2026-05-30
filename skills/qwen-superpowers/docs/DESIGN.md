# Design — qwen-superpowers

The problem, the approach, the structure, and what's deliberately out of scope. Written 2026-05-29.

## Problem
[Superpowers] is tuned for Claude. Driven with Qwen3.5-397B-A17B, the model drifts, skips steps,
claims unverified success, and occasionally runs destructive commands — needing constant
babysitting. We want the *methodology* to survive the model swap (and run under whatever harness
the user has) and yield a tool that actually speeds up work instead of a toy.

## Key insight: containment vs. capability
Two separable problems:
- **Capability** — the model makes mistakes. Mitigable, with a hard ceiling.
- **Containment** — its mistakes are expensive. Cheaply solvable.

Most "babysitting" is containment wearing a capability costume. So this pack spends first on making
mistakes cheap and unhideable, then on guiding the model.

## Three layers (lowest trust first)
1. **Enforcement** (`hooks/`) — block destructive shell; run checks after edits and feed failures
   back. Requires no trust in the model.
2. **Always-on discipline** (`AGENTS.md`) — the non-negotiables, every turn. Low trust.
3. **On-demand procedure** (`skills/`, delivered as native skills where supported) — TDD, debugging,
   planning, review; invokable explicitly as `/<name>` (the reliable path) and auto-invokable by the
   model where the harness supports it.

## Why not port the skills verbatim?
Model facts that break the originals (full list + sources in [`model-notes.md`](model-notes.md)):
- Thinks by default, no soft switch, must strip thinking from history → can't lean on an invisible
  scratchpad; must suppress verbosity.
- Tool calls go through the `qwen3_coder` parser and a "not guaranteed" protocol → enforce, don't trust.
- Attention degrades with context faster than Claude → short, numbered prose beats long
  ALL-CAPS/flowchart skills, and only essentials stay always-on.
- fp8 serving can degrade structured output → enforcement matters more.

## Mapping Superpowers → a harness
Claude Code has a Skill tool with auto-invocation. Among non-Claude harnesses this is now uneven:
Qwen Code (v0.15.7+) added a native Agent Skills system (model-invoked *and* user-invokable as
`/<name>`); Gemini CLI and other forks may not. We map:
- Skill auto-invocation → on Qwen Code, **native Agent Skills** (the `skills/` files installed to
  `~/.qwen/skills/`), auto-invokable by the model and runnable by the user as `/<name>`; on harnesses
  without a skill system, always-on `AGENTS.md` pointers plus explicit invocation.
- "Please verify / be careful" → `PreToolUse` + `PostToolUse` hooks (deterministic).
- Progressive disclosure → `AGENTS.md` carries the always-on essentials; `skills/<name>/SKILL.md`
  holds the fuller canonical procedure, loaded on invocation.

## Multi-harness delivery
The methodology is harness-agnostic; only delivery differs, so the harness-specific parts live under
`harnesses/<profile>/` and the universal parts (`AGENTS.md`, `skills/`, `hooks/`) are shared.
- **qwen-family** (Qwen Code, Gemini CLI, forks) — native Agent Skills (`<base>/skills/<name>/SKILL.md`),
  Gemini-fork settings schema, configurable base dir (`~/.qwen`, `~/.gemini`, …). Skills require a
  harness with the Agent Skills system (Qwen Code); forks without it still get `AGENTS.md` + hooks.
- **claude-code** — Markdown commands, Claude settings schema, `~/.claude`. `$ARGUMENTS` placeholder.
- **generic** — `AGENTS.md` + `skills/` only, for harnesses without commands/hooks.

The hook scripts are reusable across qwen-family and claude-code because both use the same hook JSON
convention (`hookSpecificOutput.permissionDecision`, `decision: "block"`); only matchers/tool names
and timeout units (ms vs seconds) differ, which the installer handles.

`install.sh` is interactive and profile-aware, remembers choices in
`~/.config/qwen-superpowers/config`, and supports `--yes` / `--print` / `QSP_*` env overrides.

## Scope
Core methodology, 10 skills: brainstorming, writing-plans, executing-plans, test-driven-development,
systematic-debugging, verification-before-completion, requesting-code-review, receiving-code-review,
using-git-worktrees, finishing-a-development-branch.

## Non-goals
- **No model change.** Qwen3.5-397B-A17B is deployed company-wide and fixed; this pack targets it
  exclusively. (Coding-specialized siblings benchmark higher on agentic coding, but switching is out
  of the user's control and therefore out of scope.)
- Not a security sandbox — that's the harness's sandbox; the hooks are a guardrail.
- Not the subagent / parallel-dispatch skills — they tend to compound a weaker model's errors;
  deferred to a later version.

## To revisit after real-world testing
- Tool-name matchers in the hook settings are best-effort; confirm against the actual harness
  versions via `--debug` and adjust.
- claude-code still uses Markdown slash commands (`$ARGUMENTS`); it could move to Claude Code's
  native skills later for parity with qwen-family.
- Post-edit checks run after every edit; if too slow, scope the matcher to specific paths.

## Credits
Methodology adapted from Superpowers by Jesse Vincent (obra), MIT-licensed. Independent and unaffiliated.

[Superpowers]: https://github.com/obra/superpowers
