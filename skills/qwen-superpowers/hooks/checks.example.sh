#!/usr/bin/env bash
# Example check command for qwen-superpowers' post-edit hook.
# Copy to .qwen/checks.sh in your project and edit for your stack. Keep it FAST -- this runs
# after every edit. Put slow/full suites behind /verification-before-completion instead.
#
# Exit non-zero on any failure (set -e does this for you). The hook feeds stdout+stderr back
# to the model when this exits non-zero.
set -euo pipefail

# --- Python ---
# ruff check . && mypy app/ && pytest tests/unit -q

# --- Node / TypeScript ---
# npm run lint --silent && npx tsc --noEmit && npm run test:unit --silent

# --- Go ---
# test -z "$(gofmt -l .)" && go vet ./... && go test ./... -run Unit -count=1

echo "qwen-superpowers: edit .qwen/checks.sh to run your project's fast checks." >&2
exit 0
