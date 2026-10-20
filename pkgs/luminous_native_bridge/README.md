# luminous_native_bridge

Luminous 原生桥接通道层：Dart 只通过本包访问原生能力，不直接接触 Pigeon、KMP 或平台类型。

## 构建

- Android：`android/build.gradle.kts` 通过复合构建依赖 `com.devluo.luminous:luminous-native`，
  由 `android/settings.gradle.kts` 的 `includeBuild("../native")` 提供。
- iOS：当前 `ping` 由 Swift 直接返回；KMP XCFramework 在 macOS 上构建后再由 podspec
  的 `vendored_frameworks` 接入。
- Dart 单测：`flutter test`（在 `pkgs/luminous_native_bridge` 目录执行）。

## 新增 bridge module

1. 在 `pigeon/` 增加 schema，生成 `lib/src/generated/`，不手改生成文件。
2. 在 `lib/src/<module>/` 增加 Dart bridge，并在 `lib/luminous_native_bridge.dart` 暴露。
3. Android 在 `android/src/main/kotlin/com/devluo/luminous/bridge/<module>/handler.kt`
   实现通道；iOS 在 `ios/luminous_native_bridge/Sources/luminous_native_bridge/<Module>/Handler.swift`
   实现通道。
4. 若模块有跨端共享逻辑，放到 `native/luminous-native` 并按平台放入 `commonMain` /
   `androidMain` / `iosMain`；仅平台生命周期相关的模块留在插件内。
5. 在 `test/` 增加 Dart 通道测试，真机能力用 fake 注入，不在单测中启动。
