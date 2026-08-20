# Specification: Godot Engine & Kotlin/JVM Upgrade to 0.17.0-4.7.2

## 1. Goal & Objectives
Upgrade the Godot Engine core and the `godot-kotlin-jvm` submodule from Godot 4.5.1 / Kotlin JVM 0.14.3 to **Godot 4.7.2-stable / Kotlin JVM 0.17.0**.
Consolidate repository branch structure onto clean, tag-derived version branches, port necessary TwoFrogs patches, publish updated JVM libraries to AWS CodeArtifact, install the updated editor to `/Applications/godot_jvm.app`, document an Upgrade Runbook, and upgrade the downstream `Lotus` project.

---

## 2. Repository & Branch Architecture

### 2.1 Branching Convention
- **Godot Engine**: `tf-4.7.2` branched from upstream tag `4.7.2-stable`.
- **Kotlin/JVM Module**: `tf-0.17.0-4.7.2` branched from upstream tag `0.17.0-4.7.2`.
- Submodule reference in `.gitmodules`:
  ```ini
  [submodule "modules/kotlin_jvm"]
      path = modules/kotlin_jvm
      url = ssh://git@github.com/JasonCline/godot-kotlin-jvm.git
      branch = tf-0.17.0-4.7.2
  ```

---

## 3. Patch Porting & Compatibility Contract

### 3.1 Kotlin/JVM Submodule Patches
1. **CLI Debugger Identification**:
   - `modules/kotlin_jvm/src/lifecycle/jvm_user_configuration.h`: Define `JVM_WAIT_FOR_DEBUGGER_CMD_IDENTIFIER {"--jvm-wait-for-debugger"}`.
   - `modules/kotlin_jvm/src/lifecycle/jvm_user_configuration.cpp`: Accept `identifier == WAIT_FOR_DEBUGGER_CMD_IDENTIFIER || identifier == JVM_WAIT_FOR_DEBUGGER_CMD_IDENTIFIER`.
2. **Gradle Heap Settings**:
   - `modules/kotlin_jvm/kt/gradle.properties`: `org.gradle.jvmargs=-Xmx6g -XX:+UseG1GC`.
3. **AWS CodeArtifact Publishing & Auto-Delete Overwrite**:
   - `modules/kotlin_jvm/kt/build-logic/convention/src/main/kotlin/publish/PublishToMavenCentralPlugin.kt`:
     - Configure repository `twofrogsCodeArtifact` targeting AWS CodeArtifact endpoint `https://twofrogs-124355684277.d.codeartifact.us-west-2.amazonaws.com/maven/twofrogs-maven-repository/`.
     - Read cached token from `~/.aws/codeartifact-token-cache-twofrogs-twofrogs-maven-repository`, falling back to env `CODEARTIFACT_AUTH_TOKEN`.
     - Disable GPG signing requirement when publishing to `twofrogsCodeArtifact`.
     - Add `doFirst` task action to delete existing package versions via AWS CLI if re-publishing.
4. **Deterministic Version Resolution**:
   - `modules/kotlin_jvm/kt/build-logic/convention/src/main/kotlin/versioninfo/VersionInfoPlugin.kt`:
     - Allow publishing `0.17.0-4.7.2` cleanly when building custom branch.
5. **Extension Aliases**:
   - Create `modules/kotlin_jvm/kt/godot-library/godot-extension-library/src/main/kotlin/godot/extension/ExtensionAliases.kt` providing backward compatibility overloads for `Node.getNodeAs`, `ResourceLoader.loadAs`, `Signal.connect`, and `callDeferred`.

### 3.2 Godot Base Engine Patches
1. **JNI Header Inclusion**:
   - `SConstruct`: Append JDK 21 include paths to `CPPPATH`:
     ```python
     env.AppendUnique(CPPPATH=[
         '/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home/include',
         '/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home/include/darwin'
     ])
     ```
2. **Java Version**:
   - `.java-version`: `21`.
3. **Build Automation**:
   - `build.sh`: Target `build_artifact=./bin/godot_macos_editor_jvm_0_17_0.app` and `install_location=/Applications/godot_jvm.app`.

---

## 4. Upgrade Runbook Specification
Document `twofrogs-patches/UPGRADE_RUNBOOK.md` in `GodotEditor/packages/Godot` detailing:
1. Upstream Tag Checkout & Version Branch Creation.
2. Submodule Tag Checkout & Branch Configuration.
3. Patch Evaluation & Porting Procedure.
4. JVM Library Build, Test & CodeArtifact Publishing.
5. Godot Engine C++ SCons Compilation & Installation.
6. Downstream Project Dependency Version Bumping.

---

## 5. Downstream Integration (Lotus)
Update `Lotus/gradle/libs.versions.toml`:
- `godot = "4.7.2"`
- `godotKotlinJvm = "0.17.0"`
- `godotPluginVersion = "0.17.0-4.7.2"`
Verify with `./gradlew clean build --refresh-dependencies` and `./gradlew test`.
