#!/usr/bin/env bash
# PreToolUse hook for qwen-superpowers: blocks catastrophic shell commands, asks before
# recoverable-but-risky ones, stays silent otherwise. This is a guardrail against the model's
# common destructive mistakes -- NOT a security boundary. For real isolation, run Qwen Code in
# its sandbox (see hooks/README.md).
#
# Wire under hooks.PreToolUse with a matcher for your shell tool name
# ("Bash" / "Shell" / "run_shell_command", depending on your Qwen Code version).
#
# Requires: jq. If jq is missing, the hook fails open (allows) rather than blocking your session.
set -uo pipefail

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // .tool_input.cmd // .tool_input // empty' 2>/dev/null)"
[ -z "${cmd:-}" ] && exit 0   # nothing to inspect -> no opinion

# Normalize: lowercase, collapse newlines/tabs and shell separators to spaces, pad with spaces
# so word-boundary matching is simple and portable across BSD/GNU grep.
norm=" $(printf '%s' "$cmd" | tr 'A-Z' 'a-z' | tr '\n\t' '  ' | sed 's/[;&|()<>]/ /g') "

m()    { printf '%s' "$norm" | grep -Eq "$1"; }
deny() { jq -nc --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'; exit 2; }
ask()  { jq -nc --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:$r}}'; exit 0; }

# --- Catastrophic -> deny ---
if m ' rm ' && m '(-[a-z]*r|--recursive)' && m '(-[a-z]*f|--force)'; then
  deny "rm -rf is blocked. Remove specific paths without -rf, or ask the user to run it."
fi
m ' sudo +rm '                        && deny "sudo rm is blocked."
m ' git +reset +.*--hard'             && deny "git reset --hard discards work; ask the user to run it."
m ' git +clean +.*-[a-z]*f'           && deny "git clean -f deletes untracked files; ask the user to run it."
m ' mkfs'                             && deny "mkfs (format) is blocked."
m ' dd +.*of=/dev/'                   && deny "dd to a device is blocked."
m ' chmod +.*777'                     && deny "chmod 777 is blocked; use least privilege."
m ' (shutdown|reboot|halt|poweroff) ' && deny "power/shutdown commands are blocked."
printf '%s' "$cmd" | grep -Fq ':(){'  && deny "fork bomb pattern blocked."
if m ' git +push ' && m '( --force | -f )' && ! m 'force-with-lease'; then
  deny "force-push is blocked. Use --force-with-lease, or ask the user to run it."
fi

# --- Recoverable but risky -> ask the user first ---
m ' git +checkout +(-- +)?\. '        && ask "'$cmd' discards local changes. Confirm before running."
m ' git +restore +(-- +)?\. '         && ask "'$cmd' discards local changes. Confirm before running."
m ' git +reset '                      && ask "git reset can lose staged work or commits. Confirm before running."
m ' git +push '                       && ask "Pushing is outward-facing. Confirm before running."

exit 0   # no opinion
