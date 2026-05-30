# Hooks — the enforcement layer

Two command hooks turn "please be careful" and "please verify" into things the model can't skip.
Wire them into your harness's `settings.json` — per-harness samples live in
[`../harnesses/`](../harnesses/) (`qwen-family/settings.sample.json`, `claude-code/settings.sample.json`),
and `install.sh` prints ready snippets with this pack's real paths filled in.

**Dependency:** `jq` must be on PATH. Both hooks fail *open* (allow / no-op) if it's missing, so a
broken environment never wedges your session.

## `block-dangerous-bash.sh` — `PreToolUse`, shell tool
Inspects each shell command before it runs:
- **Denies** catastrophic commands: `rm -rf`, `sudo rm`, `git reset --hard`, `git clean -f`,
  force-push (unless `--force-with-lease`), `mkfs`, `dd … of=/dev/…`, `chmod …777`, fork bombs,
  `shutdown` / `reboot` / `halt` / `poweroff`.
- **Asks** before recoverable-but-risky ones: `git checkout .`, `git restore .`, `git reset`, `git push`.
- Stays silent (no opinion) otherwise.

It's a guardrail against the model's common mistakes, not a security boundary. Customize by
editing the `deny`/`ask` lines — they're plain `grep -E` patterns over a normalized command string.

## `run-checks-after-edit.sh` — `PostToolUse`, edit tools
After every file edit, runs your project's **fast** checks. On failure it blocks and injects the
output back into the conversation, so the model fixes the breakage instead of moving on.

Configure the check command (first match wins):
1. `export QWEN_SP_CHECK="ruff check . && pytest tests/unit -q"`, or
2. an executable `./.qwen/checks.sh` (copy [`./checks.example.sh`](checks.example.sh)).

No check configured → the hook is a no-op. Keep checks fast (lint, typecheck, targeted unit
tests); put full suites behind `/verification-before-completion`. Tuning: `QWEN_SP_CHECK_TIMEOUT` (seconds, default 120),
`QWEN_SP_CHECK_TAIL` (lines fed back, default 40).

## Matchers
Matchers are per harness. The qwen-family sample uses broad regexes for tool-name variants
(`(Bash|Shell|run_shell_command)`, `(Edit|Write|WriteFile|write_file|replace|edit)`); the
claude-code sample uses `Bash` and `Edit|Write|MultiEdit`. If your version names tools differently,
run it with `--debug` to see the real names and adjust.

## Containment beyond hooks
- **Approval mode:** start with `--approval-mode default` (prompt on edits/shell) while you build
  trust; move to `auto-edit` once the hooks earn it. Avoid `yolo` outside a sandbox.
- **Sandbox:** Qwen Code and Claude Code can both run tools inside a sandbox (Docker, or macOS
  Seatbelt). In a sandbox, even a command the deny-list misses can't touch your host. That's the
  real containment; the hook is the cheap first line.
