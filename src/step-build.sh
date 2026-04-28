#!/usr/bin/env psh
set -euo pipefail

PROJECT="${INPUT_PROJECT_PATH:-.}"
BUILD_TOOL="${INPUT_BUILD_TOOL:-auto}"

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

echo "Build tool detected/selected: $BUILD_TOOL"

case "$BUILD_TOOL" in
  maven)
    mvn package -DskipTests --batch-mode
    ;;
  gradle)
    GRADLE_CMD="gradle"
    [ -f "gradlew" ] && GRADLE_CMD="./gradlew"
    "$GRADLE_CMD" build -x test
    ;;
  groovy)
    GROOVY_SCRIPT=$(ls ./*.groovy 2>/dev/null | head -1)
    if [ -n "$GROOVY_SCRIPT" ]; then
      groovy "$GROOVY_SCRIPT"
    else
      echo "No .groovy script found in $PROJECT; skipping build."
    fi
    ;;
  *)
    echo "Unknown build tool: $BUILD_TOOL" >&2
    exit 1
    ;;
esac

echo "Build complete."
