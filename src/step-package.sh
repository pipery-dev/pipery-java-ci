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
  elif compgen -G "./*.groovy" > /dev/null 2>&1; then
    BUILD_TOOL="groovy"
  else
    BUILD_TOOL="maven"
  fi
fi

echo "Packaging with build tool: $BUILD_TOOL"

mkdir -p dist

case "$BUILD_TOOL" in
  maven)
    mvn package --batch-mode
    # Copy JARs to dist/
    find target -maxdepth 1 -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" \
      -exec cp {} dist/ \; 2>/dev/null || true
    ;;
  gradle)
    GRADLE_CMD="gradle"
    [ -f "gradlew" ] && GRADLE_CMD="./gradlew"
    "$GRADLE_CMD" assemble
    # Copy JARs/WARs to dist/
    find build/libs \( -name "*.jar" -o -name "*.war" \) -print0 2>/dev/null | xargs -r -0 -I{} cp {} dist/ || true
    ;;
  groovy)
    GROOVY_SCRIPT=$(find . -maxdepth 1 -name "*.groovy" 2>/dev/null | head -1)
    if [ -n "$GROOVY_SCRIPT" ]; then
      cp "$GROOVY_SCRIPT" dist/
    else
      echo "No .groovy script found; skipping packaging."
    fi
    ;;
  *)
    echo "Unknown build tool: $BUILD_TOOL" >&2
    exit 1
    ;;
esac

echo "Packaging complete. Contents of dist/:"
ls -la dist/ 2>/dev/null || echo "(dist/ is empty)"
