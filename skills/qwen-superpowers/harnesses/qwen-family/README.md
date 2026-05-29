# Qwen-family harness — Qwen Code, Gemini CLI, and forks

These share Gemini-CLI internals: TOML slash commands, a `context.fileName` setting, and the same
hook JSON convention. Only the config directory differs — Qwen Code `~/.qwen`, Gemini CLI
`~/.gemini`, other forks their own. Pick the base dir; everything else is identical.

## Install (recommended)
Run `../../install.sh` and choose the **qwen-family** profile. It links the TOML commands into
`<base>/commands` and prints a ready-to-merge hooks block with this pack's real script paths.

## Manual wiring
1. **Commands** — symlink `commands/*.toml` into `<base>/commands/` (e.g. `~/.qwen/commands`).
2. **AGENTS.md** — set `context.fileName` to `AGENTS.md` in `<base>/settings.json` (see
   `settings.sample.json`), or add `@/abs/path/AGENTS.md` to your project's `QWEN.md`.
3. **Hooks** — merge the `hooks` block from `settings.sample.json` into `<base>/settings.json`,
   replacing the placeholder paths with this pack's `hooks/*.sh`. `timeout` is in **milliseconds**.
4. **Tool names** — the matchers are broad regexes (`Bash|Shell|run_shell_command`, etc.); run with
   `--debug` to confirm your fork's actual tool names and tighten if you like.

See [`settings.sample.json`](settings.sample.json) and [`../../hooks/README.md`](../../hooks/README.md).
