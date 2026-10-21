# luminous_native_bridge

Luminous 原生桥接通道层：Dart 只通过本包访问原生能力，不直接接触 Pigeon、KMP 或平台类型。

## 构建

- Android：`android/build.gradle.kts` 通过复合构建依赖 `com.devluo.luminous:luminous-native`，
  由 `android/settings.gradle.kts` 的 `includeBuild("../native")` 提供。
- iOS：在 macOS 上运行 `scripts/native/build_kmp_ios.sh`（或 `.ps1`）生成并同步
  `Frameworks/LuminousNative.xcframework`，podspec 通过 `vendored_frameworks` 链接。
  该目录已 gitignore，修改 KMP 共享代码后需重新执行。
  项目当前使用 CocoaPods；若启用 Flutter SPM，需在 `Package.swift` 增加指向同一
  XCFramework 的 binary target。
- Dart 单测：`flutter test`（在 `pkgs/luminous_native_bridge` 目录执行）。

## 生成 Pigeon 代码

修改 `pigeon/*.dart` 后，在包目录执行：

```bash
dart run pigeon --input pigeon/steps.dart \
  --dart_out lib/src/generated/steps.g.dart \
  --kotlin_out android/src/main/kotlin/com/devluo/luminous/bridge/steps/Steps.g.kt \
  --kotlin_package com.devluo.luminous.bridge.steps \
  --swift_out ios/luminous_native_bridge/Sources/luminous_native_bridge/Steps/Steps.g.swift
```

生成文件不手改；公开 API 只暴露 `lib/src/steps/model.dart` 中的类型。

## 新增 bridge module

1. 在 `pigeon/` 增加 schema，生成 `lib/src/generated/`，不手改生成文件。
2. 在 `lib/src/<module>/` 增加 Dart bridge，并在 `lib/luminous_native_bridge.dart` 暴露。
3. Android 在 `android/src/main/kotlin/com/devluo/luminous/bridge/<module>/handler.kt`
   实现通道；iOS 在 `ios/luminous_native_bridge/Sources/luminous_native_bridge/<Module>/Handler.swift`
   实现通道。
4. 若模块有跨端共享逻辑，放到 `native/luminous-native` 并按平台放入 `commonMain` /
   `androidMain` / `iosMain`；仅平台生命周期相关的模块留在插件内。
5. 在 `test/` 增加 Dart 通道测试，真机能力用 fake 注入，不在单测中启动。
