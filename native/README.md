# luminous-native

KMP shared module for Luminous. Keep platform-independent logic here; Flutter channel
plumbing stays in `pkgs/luminous_native_bridge`.

## Layout

- `src/commonMain/kotlin/com/devluo/luminous/native/core/` — capability, failure, result.
- `src/commonMain/kotlin/com/devluo/luminous/native/steps/` — request/sample contracts,
  baseline delta, day splitting, clipping, and per-day merging.
- `src/commonTest/kotlin/...` — host tests for normalization and baseline restart.
- `src/androidMain/.../steps/` — `TYPE_STEP_COUNTER`, permission check, persisted baseline.
- `src/iosMain/.../steps/` — HealthKit authorization and daily step statistics.
- `androidLibrary` target — consumed by the Flutter plugin through the composite build
  in `Luminous/android/settings.gradle.kts`.
- `iosArm64` + `iosSimulatorArm64` — exported as a static `LuminousNative.xcframework`.

## Build and test

```bash
./gradlew :luminous-native:testAndroidHostTest
./gradlew :luminous-native:assemble
./gradlew :luminous-native:compileKotlinIosArm64 :luminous-native:compileKotlinIosSimulatorArm64
```

iOS artifacts require macOS:

```bash
scripts/native/build_kmp_ios.sh   # build XCFramework + sync into the plugin
scripts/native/sync_xcframework.sh
```

The XCFramework is written to
`native/luminous-native/build/XCFrameworks/release/LuminousNative.xcframework` and copied
to `pkgs/luminous_native_bridge/ios/Frameworks/`, which is gitignored.

Kotlin iOS compilation works on Windows. Linking the framework/XCFramework and running
iOS/simulator tests still require macOS.

## Adding a module

1. Put shared logic under `src/commonMain/kotlin/com/devluo/luminous/native/<module>/`.
2. Expose a public `object` (not top-level functions) so Swift sees a stable
   `Type.shared.member()` API, and add a `commonTest` for it.
3. Keep platform lifecycle code out of this module; it belongs in the Flutter plugin's
   Android/iOS handlers.
4. Add the channel in `pkgs/luminous_native_bridge`, map it to the Dart API, and cover
   the channel with a mocked `MethodChannel` test.
5. On macOS, rerun `scripts/native/build_kmp_ios.sh` after changing shared code.
