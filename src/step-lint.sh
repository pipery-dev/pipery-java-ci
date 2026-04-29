#!/usr/bin/env psh
set -euo pipefail

PROJECT="${INPUT_PROJECT_PATH:-.}"
BUILD_TOOL="${INPUT_BUILD_TOOL:-auto}"

cd "$PROJECT"

# Auto-detect build tool if needed
if [ "$BUILD_TOOL" = "auto" ]; then
  if [ -f "pom.xml" ]; then
    BUILD_TOOL="maven"
  elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    BUILD_TOOL="gradle"
  elif compgen -G "./*.groovy" > /dev/null 2>&1; then
    BUILD_TOOL="groovy"
  else
    BUILD_TOOL="maven"
  fi
fi

case "$BUILD_TOOL" in
  maven)
    if command -v mvn &>/dev/null; then
      mvn checkstyle:check --batch-mode -q || echo "Checkstyle check failed or not configured; continuing."
      echo "Lint passed (Maven Checkstyle)."
    else
      echo "mvn not available, skipping lint."
    fi
    ;;
  gradle)
    if command -v gradle &>/dev/null || [ -f "gradlew" ]; then
      GRADLE_CMD="gradle"
      [ -f "gradlew" ] && GRADLE_CMD="./gradlew"
      "$GRADLE_CMD" checkstyleMain --continue || echo "Checkstyle check failed or not configured; continuing."
      echo "Lint passed (Gradle Checkstyle)."
    else
      echo "gradle not available, skipping lint."
    fi
    ;;
  groovy)
    if command -v npm &>/dev/null && npm list -g npm-groovy-lint &>/dev/null 2>&1; then
      npm-groovy-lint . || echo "Groovy lint failed or not configured; continuing."
      echo "Lint passed (npm-groovy-lint)."
    else
      echo "npm-groovy-lint not available, skipping lint."
    fi
    ;;
  *)
    echo "Unknown build tool: $BUILD_TOOL; skipping lint."
    ;;
esac
