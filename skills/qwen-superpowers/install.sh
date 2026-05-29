#!/usr/bin/env bash
# qwen-superpowers installer — interactive, multi-harness, and it remembers your choices.
#
# Profiles:
#   qwen-family : TOML slash commands + hooks for Qwen Code / Gemini CLI / forks (dir configurable)
#   claude-code : Markdown slash commands + hooks for Claude Code
#   generic     : AGENTS.md + skills/ only, for harnesses without commands or hooks
#
# Choices are saved to ~/.config/qwen-superpowers/config (override with $QWEN_SP_CONFIG) and reused
# as defaults next run. Precedence: built-in defaults < saved config < QSP_* env vars < your answers.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${QWEN_SP_CONFIG:-$HOME/.config/qwen-superpowers/config}"
VARS="QSP_QWEN_ENABLE QSP_QWEN_DIR QSP_CLAUDE_ENABLE QSP_CLAUDE_DIR QSP_GENERIC_ENABLE QSP_GENERIC_DIR QSP_AGENTS_TARGET"

print_help() {
  sed -n '2,11p' "$0" | sed 's/^#\{1,\} \{0,1\}//'
  echo
  echo "Usage: ./install.sh [--yes] [--print] [--help]"
  echo "  --yes, -y     non-interactive: use saved/default choices without prompting"
  echo "  --print       show the saved configuration and exit"
  echo "  --help, -h    this help"
}

# --- load config with correct precedence ---
for v in $VARS; do eval "_env_$v=\"\${$v:-}\""; done   # capture env-provided values first

QSP_QWEN_ENABLE="yes";   QSP_QWEN_DIR="$HOME/.qwen"
QSP_CLAUDE_ENABLE="no";  QSP_CLAUDE_DIR="$HOME/.claude"
QSP_GENERIC_ENABLE="no"; QSP_GENERIC_DIR=""
QSP_AGENTS_TARGET=""

# shellcheck disable=SC1090
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"
for v in $VARS; do eval "_e=\"\${_env_$v}\""; [ -n "$_e" ] && eval "$v=\"\$_e\""; done

ASSUME_YES=0; DO_PRINT=0
for a in "$@"; do
  case "$a" in
    -y|--yes) ASSUME_YES=1 ;;
    --print|--show) DO_PRINT=1 ;;
    -h|--help) print_help; exit 0 ;;
    *) printf 'unknown argument: %s (try --help)\n' "$a" >&2; exit 2 ;;
  esac
done

INTERACTIVE=0
[ "$ASSUME_YES" = 0 ] && [ -t 0 ] && INTERACTIVE=1

note() { printf '  %s\n' "$*"; }

print_config() {
  echo "qwen-superpowers config ($CONFIG_FILE):"
  for v in $VARS; do eval "val=\"\${$v}\""; printf '  %s=%s\n' "$v" "${val:-<unset>}"; done
  echo "  REPO_DIR=$REPO_DIR"
}
[ "$DO_PRINT" = 1 ] && { print_config; exit 0; }

ask() {  # ask "question" "default" -> echoes answer
  local q="$1" def="$2" ans=""
  if [ "$INTERACTIVE" = 1 ]; then read -r -p "$q [${def:-none}]: " ans </dev/tty || ans=""; fi
  printf '%s' "${ans:-$def}"
}
ask_yn() {  # ask_yn "question" "yes|no" -> echoes yes|no
  local q="$1" def="$2" ans=""
  if [ "$INTERACTIVE" = 1 ]; then read -r -p "$q (y/n) [$def]: " ans </dev/tty || ans=""; fi
  case "${ans:-$def}" in y|Y|yes|YES|Yes) echo yes ;; *) echo no ;; esac
}

safe_link() {  # safe_link <src> <target> ; backs up a pre-existing real file/dir
  local src="$1" tgt="$2"
  if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then mv "$tgt" "$tgt.bak.$(date +%s)"; note "backed up existing $(basename "$tgt")"; fi
  ln -sfn "$src" "$tgt"
}
link_into() {  # link_into <srcdir> <glob> <destdir>
  local src="$1" glob="$2" dest="$3" f
  mkdir -p "$dest"
  for f in "$src"/$glob; do [ -e "$f" ] || continue; safe_link "$f" "$dest/$(basename "$f")"; done
}
hooks_snippet() {  # hooks_snippet <bash_matcher> <edit_matcher> <pre_timeout> <post_timeout>
  cat <<JSON
  "hooks": {
    "PreToolUse": [
      { "matcher": "$1",
        "hooks": [ { "type": "command", "command": "$REPO_DIR/hooks/block-dangerous-bash.sh", "timeout": $3 } ] }
    ],
    "PostToolUse": [
      { "matcher": "$2",
        "hooks": [ { "type": "command", "command": "$REPO_DIR/hooks/run-checks-after-edit.sh", "timeout": $4 } ] }
    ]
  }
JSON
}
save_config() {
  mkdir -p "$(dirname "$CONFIG_FILE")"
  { printf '# qwen-superpowers install config (managed by install.sh) — %s\n' "$(date)"
    for v in $VARS; do eval "val=\"\${$v}\""; printf '%s=%q\n' "$v" "$val"; done
  } > "$CONFIG_FILE"
  note "saved choices to $CONFIG_FILE"
}

echo "qwen-superpowers installer"
echo "repo: $REPO_DIR"
[ "$INTERACTIVE" = 1 ] && echo "(interactive — Enter accepts the [default])" || echo "(non-interactive — using saved/default choices)"
echo

# --- gather choices ---
QSP_QWEN_ENABLE="$(ask_yn "Install qwen-family profile (Qwen Code / Gemini CLI / forks)?" "$QSP_QWEN_ENABLE")"
[ "$QSP_QWEN_ENABLE" = yes ] && QSP_QWEN_DIR="$(ask "  qwen-family config dir" "$QSP_QWEN_DIR")"

QSP_CLAUDE_ENABLE="$(ask_yn "Install claude-code profile?" "$QSP_CLAUDE_ENABLE")"
[ "$QSP_CLAUDE_ENABLE" = yes ] && QSP_CLAUDE_DIR="$(ask "  claude-code config dir" "$QSP_CLAUDE_DIR")"

QSP_GENERIC_ENABLE="$(ask_yn "Install generic profile (AGENTS.md + skills only)?" "$QSP_GENERIC_ENABLE")"
[ "$QSP_GENERIC_ENABLE" = yes ] && QSP_GENERIC_DIR="$(ask "  generic install dir (AGENTS.md + skills land here)" "$QSP_GENERIC_DIR")"

QSP_AGENTS_TARGET="$(ask "Optional: a project dir to symlink AGENTS.md into now (blank = skip)" "$QSP_AGENTS_TARGET")"

echo
echo "== installing =="
chmod +x "$REPO_DIR"/hooks/*.sh 2>/dev/null || true
note "hooks marked executable"

SNIPPETS=""
if [ "$QSP_QWEN_ENABLE" = yes ]; then
  link_into "$REPO_DIR/harnesses/qwen-family/commands" "*.toml" "$QSP_QWEN_DIR/commands"
  note "linked TOML commands -> $QSP_QWEN_DIR/commands"
  SNIPPETS="$SNIPPETS
--- qwen-family: merge into $QSP_QWEN_DIR/settings.json (timeouts in ms; also set context.fileName to \"AGENTS.md\") ---
$(hooks_snippet '(Bash|Shell|run_shell_command)' '(Edit|Write|WriteFile|write_file|replace|edit)' 10000 130000)
"
fi
if [ "$QSP_CLAUDE_ENABLE" = yes ]; then
  link_into "$REPO_DIR/harnesses/claude-code/commands" "*.md" "$QSP_CLAUDE_DIR/commands"
  note "linked Markdown commands -> $QSP_CLAUDE_DIR/commands"
  SNIPPETS="$SNIPPETS
--- claude-code: merge into $QSP_CLAUDE_DIR/settings.json (timeouts in seconds) ---
$(hooks_snippet 'Bash' 'Edit|Write|MultiEdit' 10 130)
"
fi
if [ "$QSP_GENERIC_ENABLE" = yes ] && [ -n "$QSP_GENERIC_DIR" ]; then
  mkdir -p "$QSP_GENERIC_DIR"
  safe_link "$REPO_DIR/AGENTS.md" "$QSP_GENERIC_DIR/AGENTS.md"
  safe_link "$REPO_DIR/skills"    "$QSP_GENERIC_DIR/skills"
  note "linked AGENTS.md + skills/ -> $QSP_GENERIC_DIR"
elif [ "$QSP_GENERIC_ENABLE" = yes ]; then
  note "generic profile enabled but no dir set — skipped (set a dir or QSP_GENERIC_DIR)"
fi
if [ -n "$QSP_AGENTS_TARGET" ]; then
  mkdir -p "$QSP_AGENTS_TARGET"
  safe_link "$REPO_DIR/AGENTS.md" "$QSP_AGENTS_TARGET/AGENTS.md"
  note "linked AGENTS.md -> $QSP_AGENTS_TARGET/AGENTS.md"
fi

save_config

if [ -n "$SNIPPETS" ]; then
  echo
  echo "== hooks: paste these into the matching settings.json (paths are already real) =="
  printf '%s\n' "$SNIPPETS"
fi

cat <<EOF
== remaining manual steps ==
1. AGENTS.md (per project) — unless you set a target above:
     qwen-family : set context.fileName="AGENTS.md", or add '@$REPO_DIR/AGENTS.md' to your QWEN.md
     claude-code : symlink/copy $REPO_DIR/AGENTS.md into your project root (or @import from CLAUDE.md)
     generic     : copy/symlink $REPO_DIR/AGENTS.md into your project root
2. Project checks (post-edit hook) — create .qwen/checks.sh (see hooks/checks.example.sh), or
     export QWEN_SP_CHECK="your fast lint + typecheck + targeted tests"
3. Endpoint — hand serving/endpoint-checklist.md to whoever runs your Qwen endpoint.

Re-run with --print to see saved choices, or --yes to reinstall non-interactively.
EOF
