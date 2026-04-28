# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.1.0] - Initial scaffold

- Initial Java CI action scaffold
- Supports Maven, Gradle, and Groovy build tools with auto-detection
- Steps: SAST, SCA, lint, build, test, versioning, packaging, release, reintegration
- All step scripts use `#!/usr/bin/env psh` as the shebang
- `setup-psh.sh` detects runner architecture dynamically (amd64 and arm64)
- `tests_path` input: passes test scope to the build tool
- Short git hash (`sha-<7chars>`) included in release title
- `target_branch` input for reintegration step
