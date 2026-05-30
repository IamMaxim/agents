# Skills

Adapted from [Superpowers](https://github.com/obra/superpowers) for Qwen3.5-397B-A17B. Each file
is a short, imperative procedure — no flowcharts, no ALL-CAPS pressure, no reliance on hidden
chain-of-thought.

## How these are used
- The non-negotiable parts live in [`../AGENTS.md`](../AGENTS.md) (loaded every turn).
- Each procedure is a native **`<name>/SKILL.md`** — the canonical, editable source.
- On Qwen Code (`qwen-family`) they install to `~/.qwen/skills/` and are invokable as `/<name>` or
  via `/skills`, and the model can auto-invoke them. On Claude Code they're delivered as Markdown
  slash commands under [`../harnesses/claude-code/`](../harnesses/claude-code/).

## Index
| Skill | Invoke | Use when |
|-------|--------|----------|
| [brainstorming](brainstorming/SKILL.md) | `/brainstorming` | before building something new |
| [writing-plans](writing-plans/SKILL.md) | `/writing-plans` | turning a spec into checkable steps |
| [executing-plans](executing-plans/SKILL.md) | `/executing-plans` | working a plan step by step |
| [test-driven-development](test-driven-development/SKILL.md) | `/test-driven-development` | implementing any feature or fix |
| [systematic-debugging](systematic-debugging/SKILL.md) | `/systematic-debugging` | any bug or unexpected behavior |
| [verification-before-completion](verification-before-completion/SKILL.md) | `/verification-before-completion` | before claiming done |
| [requesting-code-review](requesting-code-review/SKILL.md) | `/requesting-code-review` | preparing a change for review |
| [receiving-code-review](receiving-code-review/SKILL.md) | `/receiving-code-review` | acting on review feedback |
| [using-git-worktrees](using-git-worktrees/SKILL.md) | `/using-git-worktrees` | isolating risky work |
| [finishing-a-development-branch](finishing-a-development-branch/SKILL.md) | `/finishing-a-development-branch` | wrapping up a finished branch |

## What changed vs. the Claude originals
- **Smaller steps**, with explicit "stop and report" points — a weaker model shouldn't barrel ahead.
- **Verification tied to enforcement:** procedures assume the post-edit hook runs checks and that
  red is a hard stop, rather than trusting the model to verify on its own.
- **Verbosity suppressed:** the originals' emphatic ALL-CAPS and flowcharts are replaced with
  plain numbered steps, which Qwen follows more reliably and which cost far fewer tokens in a
  context window where Qwen's attention degrades faster than Claude's.
