# Pipery Java CI

CI pipeline for Java: SAST, SCA, lint, build, test, versioning, packaging, release, reintegration

## Status

- Owner: `pipery-dev`
- Repository: `pipery-java-ci`
- Marketplace category: `continuous-integration`
- Current version: `0.1.0`

## Usage

```yaml
name: Example
on: [push]

jobs:
  run-action:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pipery-dev/pipery-java-ci@v0
        with:
          project_path: .
          java_version: '21'
```

## Inputs

### Core

| Name | Default | Description |
|---|---|---|
| `project_path` | `.` | Path to the project source tree. |
| `config_file` | `.github/pipery/config.yaml` | Path to Pipery config file. |
| `log_file` | `pipery.jsonl` | Path to the JSONL log file written during the run. |
| `java_version` | `21` | Java version to use. |
| `build_tool` | `auto` | Build tool: `auto`, `maven`, `gradle`, or `groovy`. When `auto`, the tool is detected from the project layout. |

### Registry / publish credentials

| Name | Default | Description |
|---|---|---|
| `registry` | `ghcr.io` | Container registry for packaging. |
| `registry_username` | `` | Registry username for authentication. |
| `registry_password` | `` | Registry password for authentication. |
| `github_token` | `` | GitHub token for release and reintegration steps. |

### Pipeline controls (skip flags)

| Name | Default | Description |
|---|---|---|
| `skip_sast` | `false` | Skip SAST step. |
| `skip_sca` | `false` | Skip SCA step. |
| `skip_lint` | `false` | Skip lint step. |
| `skip_build` | `false` | Skip build step. |
| `skip_test` | `false` | Skip test step. |
| `skip_versioning` | `false` | Skip versioning step. |
| `skip_packaging` | `false` | Skip packaging step. |
| `skip_release` | `false` | Skip release step. |
| `skip_reintegration` | `false` | Skip reintegration step. |

### Versioning & release

| Name | Default | Description |
|---|---|---|
| `version_bump` | `patch` | Version bump type: `patch`, `minor`, or `major`. |
| `target_branch` | `main` | Target branch for reintegration merge. |

### Testing

| Name | Default | Description |
|---|---|---|
| `tests_path` | `` | Test target passed to the build tool (e.g. a test class name or pattern). |

## Outputs

| Name | Description |
|---|---|
| `version` | The new version string after the versioning step. |

## Steps

| Step | Skip flag | What it does |
|---|---|---|
| SAST | `skip_sast` | Static analysis via `pipery-steps sast --language java` |
| SCA | `skip_sca` | Dependency vulnerability scan via `pipery-steps sca --language java`; falls back to `mvn dependency:tree` or `gradle dependencies` |
| Lint | `skip_lint` | `mvn checkstyle:check` (Maven), `gradle checkstyleMain` (Gradle), or `npm-groovy-lint` (Groovy) |
| Build | `skip_build` | `mvn package -DskipTests` / `gradle build -x test` / groovy script execution |
| Test | `skip_test` | `mvn test` / `gradle test`, optionally scoped to `tests_path` |
| Versioning | `skip_versioning` | Bump version via `pipery-steps version --language java`, write to `GITHUB_OUTPUT` |
| Packaging | `skip_packaging` | `mvn package` / `gradle assemble`, copies JARs to `dist/` |
| Release | `skip_release` | Publish GitHub release with dist artifacts; title includes `sha-<shortsha>` |
| Reintegration | `skip_reintegration` | Merge source branch back to `target_branch` via `pipery-steps reintegrate` |

## Build Tool Auto-Detection

When `build_tool` is set to `auto` (the default), the action inspects the project directory:

1. Presence of `pom.xml` → **Maven**
2. Presence of `build.gradle` or `build.gradle.kts` → **Gradle**
3. Presence of a `*.groovy` script at the root → **Groovy**

If none of the above match, Maven is assumed.

## Development

This repository is managed with `pipery-tooling`.

```bash
pipery-actions test --repo .
pipery-actions release --repo . --dry-run
```
