# TASK-007: Upgrade Lotus Dependencies and Verify End-to-End

## Context Reference
[godot_4_7_2_upgrade.md](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/specs/godot_4_7_2_upgrade.md)

## Recommended Model
`pro`

## Dependencies
- Must be executed after [TASK-005](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/tasks/TASK-005.md).

## Status
`[COMPLETED]`

## Strict Constraints
In `/Users/jasoncline/workplace/Lotus`:

1. **Update `gradle/libs.versions.toml`**:
   - `godot = "4.7.2"`
   - `godotKotlinJvm = "0.17.0"`
   - `godotPluginVersion = "0.17.0-4.7.2"`
2. **Clean and Refresh Dependencies**:
   - Run `./gradlew clean --refresh-dependencies` in `Lotus`.
   - Run `./gradlew :lotus-mac-app:build` in `Lotus`.
3. **Execute Full Test Suite**:
   - Run `./gradlew test` across all Lotus packages.
   - Verify all test suites pass with exit code 0.
4. **Runtime Verification**:
   - Launch Godot headless scene check:
     `/Applications/godot_jvm.app/Contents/MacOS/Godot --headless --path packages/lotus-mac-app --quit`
   - Verify no critical registration or engine initialization errors occur.
5. Update this file's Status to `[COMPLETED]`.
