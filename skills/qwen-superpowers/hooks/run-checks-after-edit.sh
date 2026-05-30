#!/usr/bin/env bash
# PostToolUse hook for qwen-superpowers: after a file edit, run the project's FAST checks and,
# if they fail, feed the output back so the model fixes it instead of proceeding. Heavy/full
# suites belong in /verification-before-completion, not here.
#
# Check command resolution (first match wins):
#   1) $QWEN_SP_CHECK        a shell command string
#   2) ./.qwen/checks.sh     an executable script in the project
# If neither is set, the hook is a no-op, so it never breaks projects without checks.
#
# Tuning: QWEN_SP_CHECK_TIMEOUT (seconds, default 120), QWEN_SP_CHECK_TAIL (lines fed back, default 40).
# Requires: jq.
set -uo pipefail

if [ -n "${QWEN_SP_CHECK:-}" ]; then
  check_cmd="$QWEN_SP_CHECK"
elif [ -x "./.qwen/checks.sh" ]; then
  check_cmd="./.qwen/checks.sh"
else
  exit 0   # no checks configured -> no opinion
fi

# Run with a timeout so a hung test can't wedge the session.
tmo="$(command -v timeout || command -v gtimeout || true)"
if [ -n "$tmo" ]; then
  out="$("$tmo" "${QWEN_SP_CHECK_TIMEOUT:-120}" bash -c "$check_cmd" 2>&1)"; rc=$?
else
  out="$(bash -c "$check_cmd" 2>&1)"; rc=$?
fi

[ "$rc" -eq 0 ] && exit 0   # checks pass -> silent

tail_out="$(printf '%s\n' "$out" | tail -n "${QWEN_SP_CHECK_TAIL:-40}")"
msg="Project checks FAILED (exit $rc) after this edit. Fix this before doing anything else; do not proceed or claim success.

\$ $check_cmd
$tail_out"

jq -nc --arg c "$msg" '{decision:"block",reason:"qwen-superpowers: project checks failed",hookSpecificOutput:{additionalContext:$c}}'
exit 0
