# TASK-005: Build, Test, Publish 0.17.0-4.7.2 & Install Editor

## Context Reference
[godot_4_7_2_upgrade.md](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/specs/godot_4_7_2_upgrade.md)

## Recommended Model
`pro`

## Dependencies
- Must be executed after [TASK-002](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/tasks/TASK-002.md), [TASK-003](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/tasks/TASK-003.md), and [TASK-004](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/tasks/TASK-004.md).

## Status
`[COMPLETED]`

## Strict Constraints
In `/Users/jasoncline/workplace/GodotEditor/packages/Godot`:

1. **Verify Kotlin JVM Tests**:
   - In `modules/kotlin_jvm/kt`: Run `./gradlew check` / `./gradlew test`. Verify all test suites pass.
2. **Publish Kotlin JVM Packages to AWS CodeArtifact**:
   - Run `./build.sh publish` from Godot root.
   - Confirm publishing to AWS CodeArtifact (`twofrogs-maven-repository`) completes successfully with exit code 0.
3. **Build Godot Editor C++ Binary**:
   - Run `./build.sh build_godot_editor`.
   - Verify `./bin/godot_macos_editor_jvm_0_17_0.app` is generated.
4. **Install Godot Editor**:
   - Run `./build.sh install`.
   - Verify `/Applications/godot_jvm.app` is replaced and contains the new 4.7.2 editor.
   - Verify running `/Applications/godot_jvm.app/Contents/MacOS/Godot --version` outputs `4.7.2.stable.custom_build`.
5. Update this file's Status to `[COMPLETED]`.
