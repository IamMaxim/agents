# Qwen-family harness — Qwen Code, Gemini CLI, and forks

These share Gemini-CLI internals: a `context.fileName` setting and the same hook JSON convention.
**Qwen Code** additionally has a native **Agent Skills** system, which this profile uses to deliver
the procedures. Only the config directory differs — Qwen Code `~/.qwen`, Gemini CLI `~/.gemini`,
other forks their own. Pick the base dir; everything else is identical.

> Skills require a harness with the Agent Skills system (Qwen Code). Gemini CLI / forks without it
> still benefit from `AGENTS.md` + hooks, and can read the `skills/<name>/SKILL.md` files directly.

## Install (recommended)
Run `../../install.sh` and choose the **qwen-family** profile. It symlinks each skill directory into
`<base>/skills/`, removes any stale TOML command links this pack created previously, and prints a
ready-to-merge hooks block with this pack's real script paths.

## Manual wiring
1. **Skills** — symlink each `../../skills/<name>/` directory into `<base>/skills/<name>` (e.g.
   `~/.qwen/skills/brainstorming` → this pack's `skills/brainstorming`). Each holds a `SKILL.md`.
   Invoke one as `/<name>` (e.g. `/brainstorming`) or browse with `/skills`; the model can also
   auto-invoke from the description.
2. **AGENTS.md** — set `context.fileName` to `AGENTS.md` in `<base>/settings.json` (see
   `settings.sample.json`), or add `@/abs/path/AGENTS.md` to your project's `QWEN.md`.
3. **Hooks** — merge the `hooks` block from `settings.sample.json` into `<base>/settings.json`,
   replacing the placeholder paths with this pack's `hooks/*.sh`. `timeout` is in **milliseconds**.
4. **Tool names** — the matchers are broad regexes (`Bash|Shell|run_shell_command`, etc.); run with
   `--debug` to confirm your fork's actual tool names and tighten if you like.

> **Migrating from a previous install?** Earlier versions linked TOML slash commands into
> `<base>/commands/`. TOML commands are deprecated in Qwen Code; the installer removes the stale
> links automatically. Skills now provide the same entry points as `/<name>`.

See [`settings.sample.json`](settings.sample.json) and [`../../hooks/README.md`](../../hooks/README.md).
