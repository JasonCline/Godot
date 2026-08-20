# TASK-002: Port Core Kotlin/JVM Submodule Patches

## Context Reference
[godot_4_7_2_upgrade.md](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/specs/godot_4_7_2_upgrade.md)

## Recommended Model
`pro`

## Dependencies
- Must be executed after [TASK-001](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/.antigravity/tasks/TASK-001.md).

## Status
`[COMPLETED]`

## Strict Constraints
Implement the following core patches in `/Users/jasoncline/workplace/GodotEditor/packages/Godot/modules/kotlin_jvm`:

1. **CLI Debugger Identifier**:
   - In `src/lifecycle/jvm_user_configuration.h`:
     - Add `static constexpr const char* JVM_WAIT_FOR_DEBUGGER_CMD_IDENTIFIER {"--jvm-wait-for-debugger"};`.
   - In `src/lifecycle/jvm_user_configuration.cpp`:
     - Update check to: `else if (identifier == WAIT_FOR_DEBUGGER_CMD_IDENTIFIER || identifier == JVM_WAIT_FOR_DEBUGGER_CMD_IDENTIFIER)`.
2. **Gradle Heap Settings**:
   - In `kt/gradle.properties`:
     - Set `org.gradle.jvmargs=-Xmx6g -XX:+UseG1GC`.
3. **Extension Aliases**:
   - Create `kt/godot-library/godot-extension-library/src/main/kotlin/godot/extension/ExtensionAliases.kt`:
     - Implement overloads:
       - `inline fun <reified T : Node> Node.getNodeAs(path: String): T? = getNode(NodePath(path)) as? T`
       - `inline fun <reified T : Resource> ResourceLoader.loadAs(path: String): T? = load(path) as? T`
       - `inline fun <reified T : Any> Signal.connect(noinline target: () -> Unit, flags: Long = 0) = connect(Callable(target), flags)`
       - `fun Object.callDeferred(kFunction: KFunction<*>, vararg args: Any?): Any?`
4. **Deterministic Version Resolution**:
   - In `kt/build-logic/convention/src/main/kotlin/versioninfo/VersionInfoPlugin.kt`:
     - Ensure `godotJvmVersion` returns `0.17.0-4.7.2` cleanly during release and local builds without uncommitted snapshot drift when intended.
5. Verify Kotlin library compiles with `./gradlew :godot-library:compileKotlin` in `modules/kotlin_jvm/kt`.
6. Update this file's Status to `[COMPLETED]`.
