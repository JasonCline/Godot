# Godot Engine & Kotlin/JVM Upgrade Runbook

This document describes the standard operating procedure for upgrading the Godot Engine and `godot-kotlin-jvm` submodule across TwoFrogs Studio projects.

---

## 1. Overview & Architecture

TwoFrogs builds custom Godot Engine editor binaries with embedded Kotlin/JVM support:
- **Godot Root (`packages/Godot`)**: Godot Engine core with custom macOS JNI include configurations and automation scripts.
- **Kotlin/JVM Submodule (`modules/kotlin_jvm`)**: The `godot-kotlin-jvm` bindings modified to support AWS CodeArtifact publishing, CLI debugger synchronization, and backward-compatible helper extensions.
- **Downstream Consumer Projects (e.g. `Lotus`)**: Multi-module Gradle projects depending on published TwoFrogs Kotlin/JVM artifacts and the local `/Applications/godot_jvm.app` editor executable.

### Branching Convention
- Engine root: `tf-[godot_version]` (e.g. `tf-4.7.2` from upstream tag `4.7.2-stable`)
- Submodule: `tf-[jvm_version]-[godot_version]` (e.g. `tf-0.17.0-4.7.2` from upstream tag `0.17.0-4.7.2`)

---

## 2. Step-by-Step Upgrade Procedure

### Step 1: Upstream Tag Inspection & Branch Creation

1. **Godot Engine Root**:
   ```bash
   cd packages/Godot
   git fetch origin --tags
   # Create new version branch from upstream tag
   git checkout -b tf-<new_godot_version> tags/<new_godot_version>-stable
   ```

2. **Kotlin/JVM Submodule**:
   ```bash
   cd modules/kotlin_jvm
   git fetch origin --tags
   # Create new version branch from matching upstream submodule tag
   git checkout -b tf-<new_jvm_version>-<new_godot_version> tags/<new_jvm_version>-<new_godot_version>
   ```

3. **Submodule Tracking in Root**:
   In `packages/Godot/.gitmodules`, update the branch field:
   ```ini
   [submodule "modules/kotlin_jvm"]
       path = modules/kotlin_jvm
       url = ssh://git@github.com/JasonCline/godot-kotlin-jvm.git
       branch = tf-<new_jvm_version>-<new_godot_version>
   ```

---

### Step 2: Evaluate Existing Patches

Review the active patches in `twofrogs-patches/` and evaluate changes in upstream code:

1. **CLI Debugger (`0001`)**:
   Check `src/lifecycle/jvm_user_configuration.h` and `.cpp` to verify if `--jvm-wait-for-debugger` argument handling needs porting. Verify `src/jni/types.cpp` includes `<algorithm>`.
2. **Memory & Version Resolution (`0002`)**:
   Check `kt/gradle.properties` (ensure 6GB heap) and `kt/build-logic/convention/src/main/kotlin/versioninfo/VersionInfoPlugin.kt` (ensure `godotJvmVersion` without dirty snapshot hashing).
3. **Extension Aliases (`0003`)**:
   Check `kt/godot-library/godot-extension-library/src/main/kotlin/godot/extension/ExtensionAliases.kt`. Ensure helper overloads for `Node.getNodeAs`, `ResourceLoader.loadAs`, `Signal0.connect`, and `Object.callDeferred` compile against new API bindings.
4. **AWS CodeArtifact Publishing (`0004`)**:
   Check `kt/build-logic/convention/src/main/kotlin/publish/PublishToMavenCentralPlugin.kt`. Ensure the `twofrogsCodeArtifact` Maven repository block, cached token loader (`~/.aws/codeartifact-token-cache-twofrogs-twofrogs-maven-repository`), and signing bypass rules are intact.
5. **JNI Header Inclusion (`0005`)**:
   Check `SConstruct`. Ensure OpenJDK 21 include paths are appended to `CPPPATH` for macOS.
6. **Build Script (`0006`)**:
   Check `build.sh`. Verify `build_artifact` path matches new version (e.g. `./bin/godot_macos_editor_jvm_<version>.app`).

---

### Step 3: Apply & Port Patches

Apply patches sequentially using `git apply`:

```bash
# In modules/kotlin_jvm
cd packages/Godot/modules/kotlin_jvm
git apply ../../twofrogs-patches/0001-fix-wait-for-debugger-cli-argument.patch
git apply ../../twofrogs-patches/0002-godot-compiler-memory-and-base-version-assembly.patch
git apply ../../twofrogs-patches/0003-backward-compatible-extension-aliases.patch
git apply ../../twofrogs-patches/0004-aws-codeartifact-publishing.patch

# In packages/Godot root
cd ../..
git apply twofrogs-patches/0005-godot-engine-jni-headers.patch
```

If any patch fails to apply due to upstream code movement, resolve conflicts manually, ensuring all functionality from the spec is preserved.

---

### Step 4: Build, Publish & Install

1. **Verify AWS CodeArtifact Authentication**:
   Ensure your CodeArtifact token cache is refreshed or `CODEARTIFACT_AUTH_TOKEN` is set:
   ```bash
   aws codeartifact get-authorization-token \
     --domain twofrogs \
     --domain-owner 124355684277 \
     --region us-west-2 \
     --query authorizationToken \
     --output text > ~/.aws/codeartifact-token-cache-twofrogs-twofrogs-maven-repository
   ```

2. **Publish Kotlin/JVM Libraries to CodeArtifact**:
   ```bash
   ./build.sh publish
   ```
   This compiles all Kotlin modules, jars, Gradle plugins, and publishes `godot-core-library`, `godot-extension-library`, `godot-gradle-plugin`, and `godot-entry-generator` to the TwoFrogs repository.

3. **Build Godot Editor C++ App**:
   ```bash
   ./build.sh build_godot_editor
   ```
   This invokes SCons to produce the native macOS editor bundle in `./bin/`.

4. **Install Editor to Applications**:
   ```bash
   ./build.sh install
   ```
   This deploys the editor bundle to `/Applications/godot_jvm.app`.

---

### Step 5: Downstream Project Integration (e.g. Lotus)

1. **Update `gradle/libs.versions.toml`**:
   ```toml
   [versions]
   godot = "<new_godot_version>"
   godotKotlinJvm = "<new_jvm_version>"
   godotPluginVersion = "<new_jvm_version>-<new_godot_version>"
   ```

2. **Refresh Dependencies & Rebuild**:
   ```bash
   cd /Users/jasoncline/workplace/Lotus
   ./gradlew clean build --refresh-dependencies
   ./gradlew test
   ```

3. **Verify Runtime & Scene Loading**:
   Launch a scene via the Godot editor or debug runner:
   ```bash
   /Applications/godot_jvm.app/Contents/MacOS/Godot --path /Users/jasoncline/workplace/Lotus/packages/lotus-core-game res://game/screens/gameplay_screen.tscn
   ```

---

### Step 6: Refresh Patches & Documentation

Once the upgrade is verified:
1. Export refreshed patches from working tree / commit diffs into `twofrogs-patches/`:
   ```bash
   # In packages/Godot root
   git --no-pager diff --no-ext-diff tags/<godot_version>-stable SConstruct > twofrogs-patches/0005-godot-engine-jni-headers.patch

   # In modules/kotlin_jvm
   cd modules/kotlin_jvm
   git --no-pager diff --no-ext-diff tags/<jvm_version>-<godot_version> > ../../twofrogs-patches/<patch_name>.patch
   ```
2. Update `twofrogs-patches/README.md` with new baseline version numbers and patch descriptions.
3. Commit and push the `tf-*` branches to TwoFrogs remotes.
