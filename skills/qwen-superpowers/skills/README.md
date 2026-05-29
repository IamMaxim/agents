# Skills

Adapted from [Superpowers](https://github.com/obra/superpowers) for Qwen3.5-397B-A17B. Each file
is a short, imperative procedure — no flowcharts, no ALL-CAPS pressure, no reliance on hidden
chain-of-thought.

## How these are used
- The non-negotiable parts live in [`../QWEN.md`](../QWEN.md) (loaded every turn).
- The full procedures here are the canonical, editable source.
- Most are invoked through slash commands in [`../commands/`](../commands/), which carry a
  condensed copy of the steps inline so they work even if file-injection paths differ across
  Qwen Code versions.

## Index
| Skill | Command | Use when |
|-------|---------|----------|
| [brainstorming](brainstorming.md) | `/brainstorm` | before building something new |
| [writing-plans](writing-plans.md) | `/write-plan` | turning a spec into checkable steps |
| [executing-plans](executing-plans.md) | `/execute-plan` | working a plan step by step |
| [test-driven-development](test-driven-development.md) | `/tdd` | implementing any feature or fix |
| [systematic-debugging](systematic-debugging.md) | `/debug` | any bug or unexpected behavior |
| [verification-before-completion](verification-before-completion.md) | `/verify` | before claiming done |
| [requesting-code-review](requesting-code-review.md) | `/review` | preparing a change for review |
| [receiving-code-review](receiving-code-review.md) | — | acting on review feedback |
| [using-git-worktrees](using-git-worktrees.md) | — | isolating risky work |
| [finishing-a-development-branch](finishing-a-development-branch.md) | — | wrapping up a finished branch |

## What changed vs. the Claude originals
- **Smaller steps**, with explicit "stop and report" points — a weaker model shouldn't barrel ahead.
- **Verification tied to enforcement:** procedures assume the post-edit hook runs checks and that
  red is a hard stop, rather than trusting the model to verify on its own.
- **Verbosity suppressed:** the originals' emphatic ALL-CAPS and flowcharts are replaced with
  plain numbered steps, which Qwen follows more reliably and which cost far fewer tokens in a
  context window where Qwen's attention degrades faster than Claude's.
