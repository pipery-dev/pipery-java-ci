#!/usr/bin/env psh
set -euo pipefail

PROJECT="${INPUT_PROJECT_PATH:-.}"
LOG="${INPUT_LOG_FILE:-pipery.jsonl}"

if ! command -v pipery-steps &>/dev/null; then
  echo "pipery-steps not available, skipping versioning."
  exit 0
fi

NEW_VERSION=$(pipery-steps version \
  --language java \
  --project-path "$PROJECT" \
  --bump "${INPUT_VERSION_BUMP:-patch}")

echo "New version: $NEW_VERSION"
[ -n "${GITHUB_OUTPUT:-}" ] && echo "version=$NEW_VERSION" >> "$GITHUB_OUTPUT"
printf '{"event":"version","status":"success","version":"%s"}\n' "$NEW_VERSION" >> "$LOG"
