# TASK-004: Port Godot Base SConstruct, build.sh, and Submodule Config

## Context Reference
[godot_4_7_2_upgrade.md](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/specs/godot_4_7_2_upgrade.md)

## Recommended Model
`flash`

## Dependencies
- Must be executed after [TASK-001](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/tasks/TASK-001.md).

## Status
`[COMPLETED]`

## Strict Constraints
In `/Users/jasoncline/workplace/GodotEditor/packages/Godot`:

1. **JNI Header Inclusion**:
   - In `SConstruct`:
     - Append JDK 21 include paths to `CPPPATH`:
       ```python
       env.AppendUnique(CPPPATH=[
           '/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home/include',
           '/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home/include/darwin'
       ])
       ```
2. **Java Version**:
   - Create/verify `.java-version` contains `21`.
3. **Build Automation Script**:
   - Update `build.sh`:
     - Set `build_artifact=./bin/godot_macos_editor_jvm_0_17_0.app`.
     - Set `install_location=/Applications/godot_jvm.app`.
     - Ensure all subcommands (`build`, `publish`, `publish_local`, `install`, `build_godot_kotlin`, `build_godot_editor`) function properly.
     - Make `build.sh` executable (`chmod +x build.sh`).
4. **Git Submodule Configuration**:
   - Verify `.gitmodules` points to submodule `modules/kotlin_jvm` on branch `tf-0.17.0-4.7.2`.
5. Update this file's Status to `[COMPLETED]`.
