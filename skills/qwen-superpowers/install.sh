#!/usr/bin/env bash
# qwen-superpowers installer.
# Links slash commands into ~/.qwen/commands and makes hooks executable.
# Safe and idempotent: pre-existing real files are backed up, never clobbered.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QWEN_HOME="${QWEN_HOME:-$HOME/.qwen}"
CMD_DIR="$QWEN_HOME/commands"

echo "qwen-superpowers: installing from $REPO_DIR"
mkdir -p "$CMD_DIR"

# 1) Link slash commands into ~/.qwen/commands
for f in "$REPO_DIR"/commands/*.toml; do
  [ -e "$f" ] || continue
  name="$(basename "$f")"
  target="$CMD_DIR/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.bak.$(date +%s)"
    echo "  backed up existing $name -> ${name}.bak.*"
  fi
  ln -sfn "$f" "$target"
  echo "  linked command: /$(basename "$name" .toml)"
done

# 2) Make hook + example scripts executable
chmod +x "$REPO_DIR"/hooks/*.sh 2>/dev/null || true
chmod +x "$REPO_DIR"/settings/*.sh 2>/dev/null || true
echo "  marked hook scripts executable"

cat <<EOF

Commands linked. Three manual steps remain (Qwen Code can't do these for you):

1) Always-on discipline (QWEN.md)
   Add this import line to your project's QWEN.md (or ~/.qwen/QWEN.md):

       @${REPO_DIR}/QWEN.md

2) Enforcement hooks + approval mode
   Merge settings/settings.json into your project's .qwen/settings.json and
   set the hook command paths to:

       ${REPO_DIR}/hooks/block-dangerous-bash.sh
       ${REPO_DIR}/hooks/run-checks-after-edit.sh

   See hooks/README.md for what each hook does and how to tune it.

3) Project check command (what the post-edit hook runs)
   Create .qwen/checks.sh in your project (copy settings/checks.example.sh),
   or export a command:

       export QWEN_SP_CHECK="your fast lint + typecheck + targeted tests"

And before you blame the model: hand serving/endpoint-checklist.md to whoever
runs your Qwen endpoint. A wrong tool-call parser or sampling default on the
server looks exactly like "the model is dumb."
EOF
