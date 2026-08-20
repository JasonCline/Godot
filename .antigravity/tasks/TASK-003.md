# TASK-003: Port AWS CodeArtifact Publishing in Kotlin/JVM Module

## Context Reference
[godot_4_7_2_upgrade.md](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/specs/godot_4_7_2_upgrade.md)

## Recommended Model
`pro`

## Dependencies
- Must be executed after [TASK-001](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/tasks/TASK-001.md).

## Status
`[COMPLETED]`

## Strict Constraints
In `/Users/jasoncline/workplace/GodotEditor/packages/Godot/modules/kotlin_jvm/kt/build-logic/convention/src/main/kotlin/publish/PublishToMavenCentralPlugin.kt`:

1. **Repository Configuration**:
   - Add `twofrogsCodeArtifact` Maven repository pointing to:
     `https://twofrogs-124355684277.d.codeartifact.us-west-2.amazonaws.com/maven/twofrogs-maven-repository/`
2. **Authentication Token Loading**:
   - Resolve credentials using username `"aws"` and password retrieved from:
     1. File: `~/.aws/codeartifact-token-cache-twofrogs-twofrogs-maven-repository` (trimmed).
     2. Environment variable: `CODEARTIFACT_AUTH_TOKEN`.
     3. Project property: `awsCodeArtifactToken`.
3. **GPG Signing Bypass**:
   - Exempt `publishToTwofrogsCodeArtifactRepository` / `publishAllPublicationsToTwofrogsCodeArtifactRepository` tasks from requiring Maven Central GPG signature checks.
4. **Auto-Delete Package Version on Overwrite**:
   - Add a `doFirst` block to `PublishToMavenRepository` targeting CodeArtifact that calls AWS CLI:
     `aws codeartifact delete-package-versions --domain twofrogs --domain-owner 124355684277 --repository twofrogs-maven-repository --format maven --namespace <namespace> --package <pkg> --versions <ver>`
     (safely ignoring exit code if version does not exist).
5. Verify build configuration compiles with `./gradlew build-logic:classes` in `modules/kotlin_jvm/kt`.
6. Update this file's Status to `[COMPLETED]`.
