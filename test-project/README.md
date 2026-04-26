# Test Project

A minimal Maven Java project used as a test fixture for `pipery-java-ci`.

## Contents

- `pom.xml` — Maven project descriptor
- `src/main/java/com/example/Greeter.java` — Simple greeter class
- `src/test/java/com/example/GreeterTest.java` — JUnit 5 unit test

SAST, SCA, versioning, release, and reintegration are skipped during CI testing.
Build and test steps run against this project to verify the action logic.
