#!/usr/bin/env psh
set -euo pipefail

TOKEN="${INPUT_GITHUB_TOKEN:-${GITHUB_TOKEN:-}}"
SHORT_SHA="${GITHUB_SHA:-}"
SHORT_SHA="${SHORT_SHA:0:7}"

if [ -z "$TOKEN" ] || [ -z "${GITHUB_REF_NAME:-}" ]; then
  echo "No GITHUB_TOKEN or not on a tag, skipping release."
  exit 0
fi

export GITHUB_TOKEN="$TOKEN"

RELEASE_TITLE="${GITHUB_REF_NAME}${SHORT_SHA:+ (sha-${SHORT_SHA})}"

gh release create "${GITHUB_REF_NAME}" dist/**/* --generate-notes --title "$RELEASE_TITLE" \
  || echo "Release create failed (may already exist)"
