# TASK-006: Create Upgrade Runbook & Update Patches Documentation

## Context Reference
[godot_4_7_2_upgrade.md](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/specs/godot_4_7_2_upgrade.md)

## Recommended Model
`flash`

## Dependencies
- Must be executed after [TASK-005](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/tasks/TASK-005.md).

## Status
`[COMPLETED]`

## Strict Constraints
In `/Users/jasoncline/workplace/GodotEditor/packages/Godot`:

1. **Export Patch Files**:
   - Generate refreshed `.patch` files against upstream tags:
     - In Godot root: `git diff tags/4.7.2-stable..HEAD` -> save relevant patches to `twofrogs-patches/`.
     - In `modules/kotlin_jvm`: `git diff tags/0.17.0-4.7.2..HEAD` -> save relevant patches to `twofrogs-patches/`.
2. **Update `twofrogs-patches/README.md`**:
   - Update baseline versions to Godot `4.7.2-stable` and Kotlin JVM `0.17.0-4.7.2`.
   - Update patch index and descriptions.
3. **Create `twofrogs-patches/UPGRADE_RUNBOOK.md`**:
   - Document step-by-step procedure for future upgrades:
     1. Checking upstream tags and creating `tf-[version]` branches.
     2. Evaluating diffs of old patches vs new upstream release.
     3. Porting patches in `modules/kotlin_jvm` and `Godot`.
     4. Running `./build.sh publish` and `./build.sh build install`.
     5. Downstream project consumption in `libs.versions.toml`.
4. Update this file's Status to `[COMPLETED]`.
