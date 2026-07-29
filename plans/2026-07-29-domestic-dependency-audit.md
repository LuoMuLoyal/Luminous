# Luminous 国内运行时依赖审计报告

> 创建于 2026-07-29。扫描 Luminous 全部依赖，识别在用户手机上运行时是否依赖
> Google Mobile Services (GMS) 或外网服务。完成后删除本文件。

---

## 1. 审计范围与标准

**只看运行时**：用户安装 APK 后，功能是否依赖 GMS 或需访问境外服务器。
编译期的 Maven 下载速度是开发者环境问题，不在本审计范围内。

**扫描对象**：
- `pubspec.yaml` 全部 35 个 dependencies
- 每个插件的 Android `build.gradle` 原生依赖（从 Pub Cache 读取）
- `android/app/build.gradle.kts` 手动声明的原生依赖
- `lib/` 源码中的 import 引用

---

## 2. 结论：当前无运行时 GMS / 外网依赖

`speech_to_text`（唯一依赖 GMS 的插件）已于 2026-07-28 移除。
当前 Luminous 的所有依赖在用户手机上运行时均**不依赖 GMS**，也不需要访问境外服务器（Sentry 空 DSN 时禁用）。

---

## 3. 依赖逐项分析

### 3.1 `google_mlkit_text_recognition` — 不依赖 GMS ✅

**用户问的"是不是需要 GMP"——答案是不需要。**

ML Kit 有两种形态，区别如下：

| 形态 | Maven 坐标 | 需要 GMS | 模型位置 |
|------|-----------|---------|---------|
| Standalone（独立版） | `com.google.mlkit:text-recognition` | ❌ 不需要 | 捆绑在 APK 内 |
| Play Services 版 | `com.google.android.gms:play-services-mlkit-text-recognition` | ✅ 需要 | 运行时从 GMS 动态下载 |

Luminous 用的是 **Standalone 版**。证据来自插件的 `build.gradle`：

```gradle
// google_mlkit_text_recognition-0.15.1/android/build.gradle
implementation("com.google.mlkit:text-recognition:16.0.1")
compileOnly("com.google.mlkit:text-recognition-chinese:16.0.1")
// ...
```

`com.google.mlkit:text-recognition` 是 Google 从 Firebase 拆出来的独立 ML Kit API，
推理引擎和模型文件全部打包在 APK 内，在设备上本地执行，**运行时完全不需要 Google Play Services**。
这是 Google 专门为没有 GMS 的设备（如华为鸿蒙、国内定制 ROM）设计的。

传递依赖 `google_mlkit_commons` 也只依赖 `com.google.mlkit:vision-common:17.3.0`，
同样是 standalone 版本，不拉入 GMS。

**结论**：无需替换。在无 GMS 的国产手机上正常工作。

### 3.2 `mobile_scanner` — 不依赖 GMS ✅

`mobile_scanner` 有两种模式，由 Gradle 属性 `dev.steenbakker.mobile_scanner.useUnbundled` 控制：

```gradle
// mobile_scanner-7.2.0/android/build.gradle
def useUnbundled = project.findProperty('dev.steenbakker.mobile_scanner.useUnbundled') ?: false
if (useUnbundled.toBoolean()) {
    // 需要 GMS，运行时从 Google Play 下载模型
    implementation 'com.google.android.gms:play-services-mlkit-barcode-scanning:18.3.1'
} else {
    // 捆绑模型在 APK 内，不需要 GMS
    implementation 'com.google.mlkit:barcode-scanning:17.3.0'
}
```

Luminous **没有设置** `useUnbundled` 属性，默认值为 `false`，所以用的是**捆绑模式**
（`com.google.mlkit:barcode-scanning:17.3.0`），模型打包在 APK 内，
**运行时不需要 GMS**。

**结论**：无需替换。注意未来不要误设 `useUnbundled=true`。

### 3.3 `sentry_flutter` — 不依赖 GMS，SaaS 端点已禁用 ✅

- 不依赖 GMS
- `main.dart` 中如果 `SENTRY_DSN` 环境变量为空，跳过整个 `SentryFlutter.init()`
- 所有 `Sentry.captureException()` 调用在未初始化时是安全 no-op
- 当前不配置 DSN = 崩溃上报完全禁用，不会尝试访问 `sentry.io`

**结论**：当前不影响用户。如果后续需要线上崩溃上报，参见第 5 节。

### 3.4 其余依赖 — 均不依赖 GMS 或外网 ✅

| 依赖 | 运行时机制 | GMS? | 外网? |
|------|-----------|------|-------|
| `connectivity_plus` | Android `ConnectivityManager` 系统API | ❌ | ❌ |
| `cached_network_image` | HTTP 请求 Lucent 后端（国内服务器） | ❌ | ❌ |
| `sign_in_with_apple` | Apple 系统 API | ❌ | ❌ |
| `fluwx` | 微信 SDK | ❌ | ❌ |
| `share_plus` | 系统分享 | ❌ | ❌ |
| `flutter_local_notifications` | 系统通知 | ❌ | ❌ |
| `image_picker` | 系统相册/相机 | ❌ | ❌ |
| `permission_handler` | 系统权限 API | ❌ | ❌ |
| `flutter_secure_storage` | Android Keystore / iOS Keychain | ❌ | ❌ |
| `path_provider` / `path` | 本地文件系统 | ❌ | ❌ |
| `timezone` | 纯 Dart | ❌ | ❌ |
| `flutter_image_compress` | 本地图像处理 | ❌ | ❌ |
| `url_launcher` | 系统浏览器/拨号 | ❌ | ❌ |
| `package_info_plus` | 系统包信息 | ❌ | ❌ |
| `window_manager` | 桌面窗口管理 | ❌ | ❌ |
| `dio` | HTTP 客户端 → Lucent 后端（国内） | ❌ | ❌ |

---

## 4. 待处理事项

### 4.1 清理 `speech_to_text` 残留权限

`speech_to_text` 已移除，但权限声明还在：

| 文件 | 残留内容 | 动作 |
|------|---------|------|
| `android/app/src/main/AndroidManifest.xml` 第 4 行 | `<uses-permission android:name="android.permission.RECORD_AUDIO" />` | 删除 |
| `ios/Runner/Info.plist` 第 48-49 行 | `<key>NSMicrophoneUsageDescription</key><string>需要麦克风权限以使用语音记录功能。</string>` | 删除 |

保留会导致应用商店审核时被问"为什么需要麦克风权限"，且用户安装时看到不必要的权限请求。

### 4.2 移除未使用的 ML Kit 语言模型

`android/app/build.gradle.kts` 捆绑了 4 个语言模型，但代码只用 2 个：

```kotlin
// 当前（build.gradle.kts 第 88-91 行）
implementation("com.google.mlkit:text-recognition-chinese:16.0.1")     // ✅ 使用中
implementation("com.google.mlkit:text-recognition-devanagari:16.0.1")  // ❌ 未使用
implementation("com.google.mlkit:text-recognition-japanese:16.0.1")    // ❌ 未使用
implementation("com.google.mlkit:text-recognition-korean:16.0.1")       // ❌ 未使用
```

代码中 `ocrScriptForLocale()` 只返回 `chinese` 或 `latin`（`lib/features/scan/domain/services/ocr.dart`），
后 3 个模型是纯浪费 APK 体积（约 15-20MB）。

---

## 5. 可选后续：线上崩溃上报方案

当前 Sentry DSN 为空 = 禁用。如果未来需要线上崩溃上报：

| 方案 | 优点 | 缺点 |
|------|------|------|
| 自建 Sentry 实例 | 不改代码，DSN 指向内网即可 | 需要运维一台服务器 |
| 腾讯 Bugly | 国内 SaaS，稳定快速 | 需替换 `sentry_flutter`，改代码 |

**建议**：如果用户量小，自建 Sentry 即可（社区版免费）。如果用户量大且需快速接入，
Bugly 更省心。

---

## 6. 执行计划

| 步骤 | 文件 | 动作 |
|------|------|------|
| 1 | `android/app/src/main/AndroidManifest.xml` | 删除 `RECORD_AUDIO` 权限 |
| 2 | `ios/Runner/Info.plist` | 删除 `NSMicrophoneUsageDescription` |
| 3 | `android/app/build.gradle.kts` | 删除 3 个未使用的 ML Kit 语言模型依赖 |
| 4 | `android/app/proguard-rules.pro` | 更新注释（移除多余模型引用） |
| 5 | — | 验证 `flutter analyze` + `flutter test` |

---

## 7. 总表

| 依赖 | 运行时需 GMS? | 运行时需外网? | 国内用户可用? | 动作 |
|------|:---:|:---:|:---:|------|
| `google_mlkit_text_recognition` | ❌ | ❌ | ✅ | 无需改动 |
| `mobile_scanner` | ❌ | ❌ | ✅ | 无需改动 |
| `sentry_flutter` | ❌ | ⚠️ (DSN 空时禁用) | ✅ | 无需改动 |
| `connectivity_plus` | ❌ | ❌ | ✅ | 无需改动 |
| `cached_network_image` | ❌ | ❌ | ✅ | 无需改动 |
| `sign_in_with_apple` | ❌ | ❌ | ✅ | 无需改动 |
| `fluwx` | ❌ | ❌ | ✅ | 无需改动 |
| `share_plus` | ❌ | ❌ | ✅ | 无需改动 |
| 其余全部依赖 | ❌ | ❌ | ✅ | 无需改动 |
| `speech_to_text` | — | — | — | ✅ 已移除 |
| `RECORD_AUDIO` 权限残留 | — | — | — | 需清理 |
| 3 个多余 ML Kit 模型 | — | — | — | 需移除 |
