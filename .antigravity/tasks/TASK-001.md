# TASK-001: Branch Creation and Submodule Version Alignment

## Context Reference
[godot_4_7_2_upgrade.md](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/specs/godot_4_7_2_upgrade.md)

## Recommended Model
`flash`

## Status
`[COMPLETED]`

## Strict Constraints
1. In `/Users/jasoncline/workplace/GodotEditor/packages/Godot`:
   - Fetch upstream tags: `git fetch upstream --tags`.
   - Checkout new branch `tf-4.7.2` from tag `4.7.2-stable`: `git checkout -b tf-4.7.2 tags/4.7.2-stable`.
2. In `/Users/jasoncline/workplace/GodotEditor/packages/Godot/modules/kotlin_jvm`:
   - Fetch upstream tags: `git fetch upstream --tags`.
   - Checkout new branch `tf-0.17.0-4.7.2` from tag `0.17.0-4.7.2`: `git checkout -b tf-0.17.0-4.7.2 tags/0.17.0-4.7.2`.
3. In `/Users/jasoncline/workplace/GodotEditor/packages/Godot/.gitmodules`:
   - Configure submodule branch:
     ```ini
     [submodule "modules/kotlin_jvm"]
         path = modules/kotlin_jvm
         url = ssh://git@github.com/JasonCline/godot-kotlin-jvm.git
         branch = tf-0.17.0-4.7.2
     ```
4. Verify both repositories are cleanly checked out on their respective branches with clean working trees.
5. Update this file's Status to `[COMPLETED]`.
