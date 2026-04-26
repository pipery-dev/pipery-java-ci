#!/usr/bin/env psh
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT="${INPUT_PROJECT_PATH:-.}"
BUILD_TOOL="${INPUT_BUILD_TOOL:-auto}"

if command -v pipery-steps &>/dev/null; then
  pipery-steps sca \
    --language java \
    --project-path "$PROJECT" \
    --log-file "$LOG" \
    || echo "SCA step completed (non-fatal)"
  exit 0
fi

echo "pipery-steps not available, falling back to native dependency listing."

cd "$PROJECT"

# Auto-detect build tool if needed
if [ "$BUILD_TOOL" = "auto" ]; then
  if [ -f "pom.xml" ]; then
    BUILD_TOOL="maven"
  elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    BUILD_TOOL="gradle"
  else
    BUILD_TOOL="maven"
  fi
fi

case "$BUILD_TOOL" in
  maven)
    if command -v mvn &>/dev/null; then
      mvn dependency:tree --batch-mode -q || echo "mvn dependency:tree failed; continuing."
    else
      echo "mvn not available, skipping SCA fallback."
    fi
    ;;
  gradle)
    if command -v gradle &>/dev/null || [ -f "gradlew" ]; then
      GRADLE_CMD="gradle"
      [ -f "gradlew" ] && GRADLE_CMD="./gradlew"
      "$GRADLE_CMD" dependencies || echo "gradle dependencies failed; continuing."
    else
      echo "gradle not available, skipping SCA fallback."
    fi
    ;;
  *)
    echo "Unknown build tool: $BUILD_TOOL; skipping SCA fallback."
    ;;
esac
