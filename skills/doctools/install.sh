#!/usr/bin/env bash
# doctools installer — symlink each skill directory into your harness's skills/ dir.
# Usage: ./install.sh [skills-dir]
#   default skills-dir: ${QSP_QWEN_DIR:-$HOME/.qwen}/skills
# A pre-existing real directory at the target is backed up before linking.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${1:-${QSP_QWEN_DIR:-$HOME/.qwen}/skills}"

mkdir -p "$DEST"
linked=0
for d in "$REPO_DIR"/*/; do
  [ -f "$d/SKILL.md" ] || continue
  name="$(basename "$d")"
  tgt="$DEST/$name"
  if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then
    mv "$tgt" "$tgt.bak.$(date +%s)"
    echo "  backed up existing $name"
  fi
  ln -sfn "${d%/}" "$tgt"
  echo "  linked $name -> $tgt"
  linked=$((linked + 1))
done

echo "done ($linked skills). Restart your harness, then run /skills to confirm."
