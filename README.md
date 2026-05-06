# <img src="https://raw.githubusercontent.com/pipery-dev/pipery-java-ci/main/assets/icon.png" alt="Pipery Java CI" width="28" align="center" /> Pipery Java CI

Reusable GitHub Action for a complete Java CI pipeline with structured logging via [Pipery](https://pipery.dev).

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Pipery%20Java%20CI-blue?logo=github)](https://github.com/marketplace/actions/pipery-java-ci)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Table of Contents

- [Quick Start](#quick-start)
- [Pipeline Overview](#pipeline-overview)
- [Configuration Options](#configuration-options)
- [Usage Examples](#usage-examples)
- [GitLab CI](#gitlab-ci)
- [Bitbucket Pipelines](#bitbucket-pipelines)
- [About Pipery](#about-pipery)
- [Development](#development)

## Quick Start

```yaml
name: CI
on: [push, pull_request]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pipery-dev/pipery-java-ci@v1
        with:
          project_path: .
          java_version: "21"
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Pipeline Overview

| Step | Tool | Skip Input | Description |
| --- | --- | --- | --- |
| SAST | SpotBugs, PMD | `skip_sast` | Detects Java security and quality issues |
| SCA | OWASP Dependency-Check | `skip_sca` | Identifies vulnerable dependencies |
| Lint | Checkstyle | `skip_lint` | Enforces code style |
| Build | Maven/Gradle | `skip_build` | Compiles Java project |
| Test | JUnit | `skip_test` | Runs unit and integration tests |
| Version | Semantic versioning | `skip_versioning` | Bumps version and creates git tag |
| Package | Maven package / Gradle build | `skip_packaging` | Creates JAR/Docker artifact |
| Release | Maven Central / Docker push | `skip_release` | Publishes to registry |
| Reintegrate | Git merge | `skip_reintegration` | Merges back to default branch |

## Configuration Options

| Name | Default | Description |
| --- | --- | --- |
| `project_path` | `.` | Path to the project source tree. |
| `config_file` | `.pipery/config.yaml` | Path to Pipery config file. |
| `java_version` | `21` | Java version to use (e.g., `11`, `17`, `21`). |
| `build_tool` | `auto` | Build tool to use: `auto`, `maven`, `gradle`, or `groovy`. |
| `tests_path` | `` | Test target passed to the build tool (e.g., a test class or pattern). |
| `registry` | `ghcr.io` | Container registry for packaging. |
| `registry_username` | `` | Registry username for authentication. |
| `registry_password` | `` | Registry password for authentication. |
| `version_bump` | `patch` | Version bump type: `patch`, `minor`, or `major`. |
| `target_branch` | `main` | Target branch for reintegration. |
| `github_token` | `` | GitHub token for release and reintegration. |
| `log_file` | `pipery.jsonl` | Path to the JSONL structured log file. |
| `skip_sast` | `false` | Skip the SAST step. |
| `skip_sca` | `false` | Skip the SCA step. |
| `skip_lint` | `false` | Skip the lint step. |
| `skip_build` | `false` | Skip the build step. |
| `skip_test` | `false` | Skip the test step. |
| `skip_versioning` | `false` | Skip the versioning step. |
| `skip_packaging` | `false` | Skip the packaging step. |
| `skip_release` | `false` | Skip the release step. |
| `skip_reintegration` | `false` | Skip the reintegration step. |

## Usage Examples

### Example 1: Maven project with Java 21

```yaml
name: CI
on: [push, pull_request]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pipery-dev/pipery-java-ci@v1
        with:
          project_path: .
          java_version: "21"
          build_tool: maven
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 2: Gradle project with Java 17

```yaml
- uses: pipery-dev/pipery-java-ci@v1
  with:
    project_path: .
    java_version: "17"
    build_tool: gradle
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 3: Run specific test suite

```yaml
- uses: pipery-dev/pipery-java-ci@v1
  with:
    project_path: .
    build_tool: maven
    tests_path: com.example.IntegrationTest
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 4: Docker image packaging and push

```yaml
- uses: pipery-dev/pipery-java-ci@v1
  with:
    project_path: .
    build_tool: gradle
    registry: ghcr.io
    registry_username: ${{ secrets.REGISTRY_USERNAME }}
    registry_password: ${{ secrets.REGISTRY_PASSWORD }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 5: Skip security checks for faster CI

```yaml
- uses: pipery-dev/pipery-java-ci@v1
  with:
    project_path: .
    skip_sast: true
    skip_sca: true
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 6: Major version bump for release

```yaml
- uses: pipery-dev/pipery-java-ci@v1
  with:
    project_path: .
    version_bump: major
    registry_password: ${{ secrets.REGISTRY_PASSWORD }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## GitLab CI

This repository includes a GitLab CI equivalent at `.gitlab-ci.yml`. Copy it into a GitLab project or use it as a reference implementation for running the same Pipery pipeline outside GitHub Actions.

The GitLab pipeline maps action inputs to CI/CD variables, publishes `pipery.jsonl` as an artifact, and maintains the same skip controls. Store credentials as protected GitLab CI/CD variables.

```yaml
include:
  - remote: https://raw.githubusercontent.com/pipery-dev/pipery-java-ci/v1/.gitlab-ci.yml
```

### GitLab CI Variables

Configure these protected variables in **Settings > CI/CD > Variables**:

- `GITHUB_TOKEN` - GitHub API access for release and reintegration
- `REGISTRY_PASSWORD` - Container registry password (if packaging)
- `JAVA_VERSION` - Java version (default: 21)
- `BUILD_TOOL` - maven/gradle/auto (default: auto)
- `VERSION_BUMP` - patch/minor/major (default: patch)

## Bitbucket Pipelines

Bitbucket Cloud pipelines provide an alternative to GitHub Actions. The equivalent pipeline configuration is in `bitbucket-pipelines.yml`.

### Getting Started

1. Copy `bitbucket-pipelines.yml` to your Bitbucket repository root
2. Configure Protected Variables in **Repository Settings > Pipelines > Repository Variables**:
   - `GITHUB_TOKEN` - GitHub API access (for release and reintegration)
   - `REGISTRY_PASSWORD` - Container registry password
   - `JAVA_VERSION` - Java version (default: 21)
3. Commit and push to trigger the pipeline

### Pipeline Stages

The Bitbucket equivalent follows the same structure:

checkout → setup → SAST (SpotBugs, PMD) → SCA (Dependency-Check) → lint (Checkstyle) → build → test → versioning → packaging → release → reintegration → logs

### Skip Flags

Disable any stage using environment variables:

- `SKIP_SAST`, `SKIP_SCA`, `SKIP_LINT`, `SKIP_BUILD`, `SKIP_TEST`, `SKIP_VERSIONING`, `SKIP_PACKAGING`, `SKIP_RELEASE`, `SKIP_REINTEGRATION`

Example: Set `SKIP_LINT=true` to skip code style enforcement.

### Features

- Multiple Java versions (11, 17, 21)
- Maven and Gradle support
- Static analysis (SpotBugs, PMD, Checkstyle)
- Dependency vulnerability checking
- Docker image packaging
- Automatic versioning and tagging
- JSONL-based pipeline logging
- 30-90 day artifact retention

## About Pipery

<img src="https://avatars.githubusercontent.com/u/270923927?s=32" alt="Pipery" width="22" align="center" /> [**Pipery**](https://pipery.dev) is an open-source CI/CD observability platform. Every step script runs under **psh** (Pipery Shell), which intercepts all commands and emits structured JSONL events — giving you full visibility into your pipeline without any manual instrumentation.

- Browse logs in the [Pipery Dashboard](https://github.com/pipery-dev/pipery-dashboard)
- Find all Pipery actions on [GitHub Marketplace](https://github.com/marketplace?q=pipery&type=actions)
- Source code: [pipery-dev](https://github.com/pipery-dev)

## Development

```bash
# Run the action locally against test-project/
pipery-actions test --repo .

# Regenerate docs
pipery-actions docs --repo .

# Dry-run release
pipery-actions release --repo . --dry-run
```
