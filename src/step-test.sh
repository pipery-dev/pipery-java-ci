#!/usr/bin/env psh
set -euo pipefail

PROJECT="${INPUT_PROJECT_PATH:-.}"
BUILD_TOOL="${INPUT_BUILD_TOOL:-auto}"
TESTS_PATH="${INPUT_TESTS_PATH:-}"

cd "$PROJECT"

# Auto-detect build tool
if [ "$BUILD_TOOL" = "auto" ]; then
  if [ -f "pom.xml" ]; then
    BUILD_TOOL="maven"
  elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    BUILD_TOOL="gradle"
  elif ls ./*.groovy 2>/dev/null | grep -q .; then
    BUILD_TOOL="groovy"
  else
    BUILD_TOOL="maven"
  fi
fi

echo "Running tests with build tool: $BUILD_TOOL"

case "$BUILD_TOOL" in
  maven)
    if [ -n "$TESTS_PATH" ]; then
      mvn test -Dtest="$TESTS_PATH" --batch-mode
    else
      mvn test --batch-mode
    fi
    ;;
  gradle)
    GRADLE_CMD="gradle"
    [ -f "gradlew" ] && GRADLE_CMD="./gradlew"
    if [ -n "$TESTS_PATH" ]; then
      "$GRADLE_CMD" test --tests "$TESTS_PATH"
    else
      "$GRADLE_CMD" test
    fi
    ;;
  groovy)
    GROOVY_SCRIPT=$(ls ./*.groovy 2>/dev/null | head -1)
    if [ -n "$GROOVY_SCRIPT" ]; then
      groovy "$GROOVY_SCRIPT"
    else
      echo "No .groovy script found; skipping test."
    fi
    ;;
  *)
    echo "Unknown build tool: $BUILD_TOOL" >&2
    exit 1
    ;;
esac

echo "Tests complete."
