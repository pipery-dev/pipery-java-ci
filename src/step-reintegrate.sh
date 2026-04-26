#!/usr/bin/env psh
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT="${INPUT_PROJECT_PATH:-.}"
TOKEN="${INPUT_GITHUB_TOKEN:-${GITHUB_TOKEN:-}}"

if [ -z "$TOKEN" ]; then
  echo "No GITHUB_TOKEN available, skipping reintegration."
  exit 0
fi

if ! command -v pipery-steps &>/dev/null; then
  echo "pipery-steps not available, skipping reintegration."
  exit 0
fi

export GITHUB_TOKEN="$TOKEN"

pipery-steps reintegrate \
  --project-path "$PROJECT" \
  --source-branch "${GITHUB_REF_NAME:-main}" \
  --target-branch "${INPUT_TARGET_BRANCH:-main}" \
  --log-file "$LOG" \
  || echo "Reintegration step completed (non-fatal)"
