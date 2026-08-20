# TwoFrogs Godot Engine & Kotlin/JVM Patches

This directory contains the patch set applied by TwoFrogs Studio to the Godot Engine and the `godot-kotlin-jvm` submodule to support custom workflows, macOS JNI builds, AWS CodeArtifact publishing, and downstream project compatibility.

## Baseline Versions

- **Godot Engine**: `4.7.2-stable` (Branch: `tf-4.7.2`)
- **Godot Kotlin JVM Submodule**: `0.17.0-4.7.2` (Branch: `tf-0.17.0-4.7.2`)
- **JDK Target**: OpenJDK 21

---

## Active Patch Index

| Patch | Target Component | Summary |
|---|---|---|
| [`0001-fix-wait-for-debugger-cli-argument.patch`](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/twofrogs-patches/0001-fix-wait-for-debugger-cli-argument.patch) | `modules/kotlin_jvm` | Accepts `--jvm-wait-for-debugger` CLI argument on engine startup for JDWP debugging sessions and includes `<algorithm>` in JNI type mappings. |
| [`0002-godot-compiler-memory-and-base-version-assembly.patch`](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/twofrogs-patches/0002-godot-compiler-memory-and-base-version-assembly.patch) | `modules/kotlin_jvm` | Sets Gradle JVM heap to 6GB (`-Xmx6g -XX:+UseG1GC`) and enforces deterministic version resolution (`0.17.0-4.7.2`) when building from custom git branches. |
| [`0003-backward-compatible-extension-aliases.patch`](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/twofrogs-patches/0003-backward-compatible-extension-aliases.patch) | `modules/kotlin_jvm` | Provides backward compatibility helper extensions in `godot.extension` (`Node.getNodeAs`, `ResourceLoader.loadAs`, `Signal0.connect`, `Object.callDeferred`). |
| [`0004-aws-codeartifact-publishing.patch`](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/twofrogs-patches/0004-aws-codeartifact-publishing.patch) | `modules/kotlin_jvm` | Configures publishing to TwoFrogs AWS CodeArtifact repository, automatic authentication via cached token (`~/.aws/codeartifact-token-cache-twofrogs-twofrogs-maven-repository`), and automated package overwrite handling. |
| [`0005-godot-engine-jni-headers.patch`](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/twofrogs-patches/0005-godot-engine-jni-headers.patch) | Godot Engine Root | Appends OpenJDK 21 JNI headers (`include` and `include/darwin`) to `CPPPATH` in `SConstruct` for macOS compilation. |
| [`0006-build-script-subcommands.patch`](file:///Users/jasoncline/workplace/GodotEditor/packages/Godot/twofrogs-patches/0006-build-script-subcommands.patch) | Godot Engine Root | Unified CLI build script `build.sh` supporting `build`, `publish`, `publish_local`, and `install` to `/Applications/godot_jvm.app`. |

---

## Historical Notes (0.14.3 -> 0.17.0 Migration)

During the migration from Godot 4.5.1 / Kotlin JVM 0.14.3 to Godot 4.7.2 / Kotlin JVM 0.17.0:
- Historical patch `0004-detailed-classgraph-symbol-processor-error-logging.patch` and `0007-incremental-classgraph-and-codeartifact-auto-overwrite.patch` were retired because upstream 0.17.0 redesigned entry generation into the `godot-registration` module with built-in Gradle caching and clean task isolation.
- CodeArtifact publication and overwrite logic was consolidated into `0004-aws-codeartifact-publishing.patch`.

---

## How to Apply Patches

To apply these patches onto clean upstream branches:

```bash
# In packages/Godot (Godot root)
git checkout tags/4.7.2-stable -b tf-4.7.2
git apply twofrogs-patches/0005-godot-engine-jni-headers.patch

# In packages/Godot/modules/kotlin_jvm
cd modules/kotlin_jvm
git checkout tags/0.17.0-4.7.2 -b tf-0.17.0-4.7.2
git apply ../../twofrogs-patches/0001-fix-wait-for-debugger-cli-argument.patch
git apply ../../twofrogs-patches/0002-godot-compiler-memory-and-base-version-assembly.patch
git apply ../../twofrogs-patches/0003-backward-compatible-extension-aliases.patch
git apply ../../twofrogs-patches/0004-aws-codeartifact-publishing.patch
```
