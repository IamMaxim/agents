# Generic harness — Codex, Cursor, aider, opencode, …

For harnesses without TOML/Markdown slash commands or a hook system. You still get the two pieces
that carry most of the value: the always-on **`AGENTS.md`** discipline and the **`skills/`**
procedures.

## Install (recommended)
Run `../../install.sh` and choose the **generic** profile. It links `AGENTS.md` and `skills/` into
a directory you choose.

## Manual wiring
1. **AGENTS.md** — most modern agents read `AGENTS.md` from the working directory; copy or symlink
   this pack's `AGENTS.md` into your project root (Codex, Cursor, and others honor it).
2. **Skills** — keep `skills/` reachable and point to the right one in-prompt when you need a
   procedure (e.g. "follow `skills/test-driven-development/SKILL.md`"). Without slash commands, you
   trigger them by asking.
3. **Safety** — no hook enforcement here, so lean harder on running in a sandbox and on VCS
   checkpoints, plus the verify-before-claiming discipline (run checks, paste output) from `AGENTS.md`.
