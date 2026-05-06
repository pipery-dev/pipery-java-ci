# <img src="https://raw.githubusercontent.com/pipery-dev/pipery-java-ci/main/assets/icon.png" width="28" align="center" /> Pipery Java CI

Reusable GitHub Action for a complete Java CI pipeline with structured logging via [Pipery](https://pipery.dev). Supports Maven, Gradle, and Groovy — auto-detected or configurable.

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Pipery%20Java%20CI-blue?logo=github)](https://github.com/marketplace/actions/pipery-java-ci)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Usage

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
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

## GitLab CI

This repository also includes a GitLab CI equivalent at `.gitlab-ci.yml`. Copy it into a GitLab project or use it as the reference implementation when you want to run the same Pipery pipeline outside GitHub Actions.

The GitLab pipeline maps the action inputs to CI/CD variables, publishes `pipery.jsonl` as an artifact, and keeps the same skip controls where the GitHub Action exposes them. Store credentials such as deploy tokens, registry passwords, and cloud provider keys as protected GitLab CI/CD variables.

```yaml
include:
  - remote: https://raw.githubusercontent.com/pipery-dev/pipery-java-ci/v1/.gitlab-ci.yml
```

## Pipeline steps

| Step | Tool | Skip input |
|---|---|---|
| SAST | SpotBugs / Semgrep | `skip_sast` |
| SCA | OWASP Dependency-Check | `skip_sca` |
| Lint | Checkstyle (Maven/Gradle) | `skip_lint` |
| Build | `mvn package` / `gradle build` | `skip_build` |
| Test | `mvn test` / `gradle test` | `skip_test` |
| Version | Semantic version bump | `skip_versioning` |
| Package | JAR / Docker image | `skip_packaging` |
| Release | GitHub Release + SHA tag | `skip_release` |
| Reintegrate | Merge back to default branch | `skip_reintegration` |

## Inputs

| Name | Default | Description |
|---|---|---|
| `project_path` | `.` | Path to the project source tree. |
| `config_file` | `.pipery/config.yaml` | Path to Pipery config file. |
| `java_version` | `21` | Java version to use. |
| `build_tool` | `auto` | Build tool: `auto`, `maven`, `gradle`, or `groovy`. |
| `tests_path` | `` | Test target passed to the build tool (class name or pattern). |
| `registry` | `ghcr.io` | Container registry for packaging. |
| `registry_username` | `` | Registry login username. |
| `registry_password` | `` | Registry login password or token. |
| `version_bump` | `patch` | Version bump type: `patch`, `minor`, or `major`. |
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

## Bitbucket Pipelines

Bitbucket Cloud pipelines provide an alternative to GitHub Actions for this CI workflow. The equivalent pipeline configuration is provided in `bitbucket-pipelines.yml`.

### Quick Start

1. Copy `bitbucket-pipelines.yml` to your Bitbucket repository root
2. Configure Protected Variables in Bitbucket (Repository Settings > Pipelines > Repository Variables):
   - `REGISTRY_PASSWORD` - Docker registry authentication (if packaging as image)
   - `GITHUB_TOKEN` - GitHub API access (for reintegration)
3. Commit and push to trigger the pipeline

### Pipeline Stages

The Bitbucket Pipelines equivalent follows the same structure as the GitHub Actions:
- checkout → setup → SAST (SpotBugs, Semgrep) → SCA (OWASP Dependency-Check) → lint (Checkstyle) → build → test → versioning → packaging → release → reintegration → logs

### Skip Flags

Disable any stage using environment variables:
- SKIP_SAST, SKIP_SCA, SKIP_LINT, SKIP_BUILD, SKIP_TEST, SKIP_VERSIONING, SKIP_PACKAGING, SKIP_RELEASE, SKIP_REINTEGRATION

Example: Set `SKIP_SAST=true` in pipeline variables to skip security scanning.

### Features

- Same security scanning tools as GitHub Actions (SpotBugs, Semgrep, Checkstyle, OWASP Dependency-Check)
- Parallel SAST and SCA stages
- Auto-detects Maven, Gradle, or Groovy build systems
- Automatic versioning and tagging
- JAR and Docker image packaging
- GitHub Release publishing
- JSONL-based pipeline logging
- 30-90 day artifact retention

### Documentation

- See `bitbucket-pipelines.yml` for complete customization options
- Refer to [Bitbucket Pipelines Documentation](https://support.atlassian.com/bitbucket-cloud/docs/get-started-with-bitbucket-pipelines/) for detailed reference

## About Pipery

<img src="https://avatars.githubusercontent.com/u/270923927?s=32" width="22" align="center" /> [**Pipery**](https://pipery.dev) is an open-source CI/CD observability platform. Every step script runs under **psh** (Pipery Shell), which intercepts all commands and emits structured JSONL events — giving you full visibility into your pipeline without any manual instrumentation.

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
