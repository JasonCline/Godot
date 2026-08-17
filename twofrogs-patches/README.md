# TwoFrogs Studio Godot Engine & Kotlin/JVM Patches

This directory tracks all custom modifications made to the Godot Engine and the `godot-kotlin-jvm` submodule for TwoFrogs Studio development. Use this documentation to review, maintain, and re-apply patches when upgrading engine and JVM module versions (e.g., upgrading from 4.5.1 to 4.7).

---

## Baseline Upstream Versions

| Component | Baseline Tag / Branch | Commit Reference | Repository Location |
| :--- | :--- | :--- | :--- |
| **Godot Engine Core** | `4.5.1-stable` | `77a25f93ac` (base: `f62fdbde15`) | `/Users/jasoncline/workplace/GodotEditor/packages/Godot` |
| **Kotlin JVM Module** | `master` (Godot 4.5.1 JVM) | `92ac75f0` | `modules/kotlin_jvm` |

---

## Patch Index & Descriptions

### 1. Fix `--jvm-wait-for-debugger` CLI Argument & Flag Mapping
- **Patch File**: [`0001-fix-wait-for-debugger-cli-argument.patch`](./0001-fix-wait-for-debugger-cli-argument.patch)
- **Target Files**:
  - `modules/kotlin_jvm/src/lifecycle/jvm_user_configuration.h`
  - `modules/kotlin_jvm/src/lifecycle/jvm_user_configuration.cpp`
- **What it does**:
  - Adds `JVM_WAIT_FOR_DEBUGGER_CMD_IDENTIFIER` (`"--jvm-wait-for-debugger"`) alongside `"--wait-for-debugger"`.
  - Fixes a variable mapping bug on line 305 where `json_config.use_debug` was incorrectly reading from `DEBUG_PORT_CMD_IDENTIFIER` instead of `USE_DEBUG_CMD_IDENTIFIER`.
- **How to reach file**: `cd modules/kotlin_jvm/src/lifecycle`

### 2. Compiler Heap Bump & Clean Base Version Assembly
- **Patch File**: [`0002-godot-compiler-memory-and-base-version-assembly.patch`](./0002-godot-compiler-memory-and-base-version-assembly.patch)
- **Target Files**:
  - `modules/kotlin_jvm/kt/gradle.properties`
  - `modules/kotlin_jvm/kt/build-logic/convention/src/main/kotlin/versioninfo/godotKotlinJvmVersion.kt`
- **What it does**:
  - Bumps Gradle daemon memory to `-Xmx6g -XX:+UseG1GC` to prevent GC Overhead Limit `OutOfMemoryError` during definition generation.
  - Fixes `provideAssembledVersion()` so local builds publish to `0.14.3-4.5.1` (or controlled SNAPSHOTs) rather than appending untagged random commit hashes (`0.14.3-4.5.1-92ac75f-SNAPSHOT`), ensuring consistent dependency resolution in consumer projects.
- **How to reach file**: `cd modules/kotlin_jvm/kt`

### 3. Backward-Compatible Extension Aliases & Signal Connections
- **Patch File**: [`0003-backward-compatible-extension-aliases.patch`](./0003-backward-compatible-extension-aliases.patch)
- **Target Files**:
  - `modules/kotlin_jvm/kt/godot-library/godot-extension-library/src/main/kotlin/godot/extension/ExtensionAliases.kt`
- **What it does**:
  - Provides backward-compatible extension overloads in `godot.extension` for `Node.getNodeAs`, `ResourceLoader.loadAs`, `Signal.connect` (bridging lambda to `connectLambda`), and `callDeferred(KFunction, ...)` so gameplay code compiles seamlessly across Godot JVM API changes.
- **How to reach file**: `cd modules/kotlin_jvm/kt/godot-library/godot-extension-library/src/main/kotlin/godot/extension`

### 4. Detailed ClassGraph Symbol Processor Error Logging
- **Patch File**: [`0004-detailed-classgraph-symbol-processor-error-logging.patch`](./0004-detailed-classgraph-symbol-processor-error-logging.patch)
- **Target Files**:
  - `modules/kotlin_jvm/kt/entry-generation/godot-class-graph-symbol-processor/src/main/kotlin/godot/annotation/processor/classgraph/logging/LoggerWrapper.kt`
- **What it does**:
  - Formats error logs to include `sourceElement?.fqName` (or property name). When property registration checks (e.g., mutability or Variant type checks) fail, Gradle reports the exact file, class, and property name rather than an anonymous failure string.
- **How to reach file**: `cd modules/kotlin_jvm/kt/entry-generation/godot-class-graph-symbol-processor/src/main/kotlin/godot/annotation/processor/classgraph/logging`

### 5. AWS CodeArtifact Publishing & Build Script Automation
- **Patch File**: [`0005-aws-codeartifact-publishing-and-build-script.patch`](./0005-aws-codeartifact-publishing-and-build-script.patch)
- **Target Files**:
  - `modules/kotlin_jvm/kt/build-logic/convention/src/main/kotlin/publish/PublishToMavenCentralPlugin.kt`
  - `build.sh`
- **What it does**:
  - Adds AWS CodeArtifact repository support to `PublishToMavenCentralPlugin.kt`, automatically retrieving cached authorization tokens from `~/.aws/codeartifact-token-cache-twofrogs-twofrogs-maven-repository` (falling back to `CODEARTIFACT_AUTH_TOKEN`).
  - Bypasses Sonatype/Maven Central GPG signing requirements when publishing to internal repositories.
  - Updates `build.sh` with `./build.sh publish` (uploads to AWS CodeArtifact) and `./build.sh publish_local` (uploads to `mavenLocal`).
- **How to reach file**: Root of `Godot` package and `modules/kotlin_jvm/kt/build-logic/convention`

### 6. Incremental ClassGraph Symbol Processing & Automatic CodeArtifact Overwrite
- **Patch File**: [`0007-incremental-classgraph-and-codeartifact-auto-overwrite.patch`](./0007-incremental-classgraph-and-codeartifact-auto-overwrite.patch)
- **Target Files**:
  - `modules/kotlin_jvm/kt/plugins/godot-gradle-plugin/src/main/kotlin/godot/gradle/tasks/DeleteClassGraphGenerated.kt`
  - `modules/kotlin_jvm/kt/plugins/godot-gradle-plugin/src/main/kotlin/godot/gradle/tasks/classGraphSymbolsProcess.kt`
  - `modules/kotlin_jvm/kt/build-logic/convention/src/main/kotlin/publish/PublishToMavenCentralPlugin.kt`
- **What it does**:
  - Moves `directory.deleteRecursively()` in `DeleteClassGraphGenerated.kt` inside a `doLast` action so it no longer executes at Gradle configuration time on every invocation.
  - Declares compile dependency files, compile output files, and extension properties as `@Input`s and generated source directory as `@Output` on `classGraphSymbolsProcess`, making it a fully incremental Gradle task that is skipped (`UP-TO-DATE`) when Kotlin bytecode is unchanged.
  - Automatically invokes AWS CLI `delete-package-versions` on `PublishToMavenRepository` tasks when targeting `twofrogsCodeArtifact`, allowing seamless package overwrite/re-publishing.
- **How to reach file**: `cd modules/kotlin_jvm/kt`

---

## Instructions for Re-Applying During Upgrade (e.g. Godot 4.7)

1. **Check out the target upstream Godot version**:
   ```bash
   git fetch upstream
   git checkout tags/4.7-stable -b tf-4.7
   git submodule update --init --recursive
   ```
2. **Review and apply patches sequentially**:
   ```bash
   # Apply C++ and build script patches to Godot root
   git apply twofrogs-patches/0001-fix-wait-for-debugger-cli-argument.patch
   git apply twofrogs-patches/0005-aws-codeartifact-publishing-and-build-script.patch

   # Apply Kotlin/JVM module patches
   cd modules/kotlin_jvm
   git apply ../../twofrogs-patches/0002-godot-compiler-memory-and-base-version-assembly.patch
   git apply ../../twofrogs-patches/0003-backward-compatible-extension-aliases.patch
   git apply ../../twofrogs-patches/0004-detailed-classgraph-symbol-processor-error-logging.patch
   git apply ../../twofrogs-patches/0007-incremental-classgraph-and-codeartifact-auto-overwrite.patch
   cd ../..
   ```
3. **Verify Build and Publish**:
   ```bash
   ./build.sh publish
   ./build.sh build install
   ```
4. **Update Baseline References**:
   Update the commit IDs and baseline tags in this `README.md` after verifying the upgraded build.
