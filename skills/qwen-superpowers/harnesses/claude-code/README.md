# Claude Code harness

Use this when you drive the Qwen model through **Claude Code** — e.g. Claude Code pointed at a
local or internal Qwen endpoint via `ANTHROPIC_BASE_URL`. Claude Code uses Markdown slash commands
and the same hook JSON convention as the Qwen family, so the hook scripts are shared.

## Install (recommended)
Run `../../install.sh` and choose the **claude-code** profile. It links the Markdown commands into
`~/.claude/commands` and prints a ready-to-merge hooks block.

## Manual wiring
1. **Commands** — symlink `commands/*.md` into `~/.claude/commands/` (personal) or your project's
   `.claude/commands/`.
2. **AGENTS.md** — Claude Code reads `AGENTS.md` / `CLAUDE.md` from the project root; symlink or
   copy this pack's `AGENTS.md` there, or `@import` it from your `CLAUDE.md`.
3. **Hooks** — merge the `hooks` block from `settings.sample.json` into `~/.claude/settings.json`
   (or project `.claude/settings.json`), replacing placeholder paths with this pack's `hooks/*.sh`.
   Claude Code `timeout` is in **seconds** (not milliseconds).
4. **Tool names** — Claude Code uses `Bash`, `Edit`, `Write`, `MultiEdit`; already in the sample.

Note: the post-edit hook reports check failures via `decision: "block"` + `reason`, which Claude
Code surfaces back to the model. See [`../../hooks/README.md`](../../hooks/README.md).
