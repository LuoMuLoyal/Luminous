# 极光推送客户端集成实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Luminous 在 Android/iOS 接入 JPush：初始化 SDK，登录后绑定 Lucent 用户 UUID 为 alias，退出时解绑，处理前台到达与后台/终止态点击，并统一路由到站内通知页。

**Architecture:** `lib/core/push/` 分为 SDK 网关、消息处理、生命周期协调三个职责。网关只处理插件 API 与跨平台事件归一化；消息处理只负责未读数失效和路由；协调器只负责启动冷启动通知处理及认证状态到 alias 的映射。现有 `flutter_local_notifications` 本地提醒链路保持不变。JPush 未配置或运行在非 Android/iOS 平台时静默禁用。

**Tech Stack:** Flutter, Riverpod 3, GoRouter 17, `jpush_flutter`（按 pub resolver 解析的当前兼容版本）, generated `lucent_api`。

---

## 审核结论与执行约束

- 原计划使用了不存在的 `android/app/build.gradle`；本仓库实际文件是 `android/app/build.gradle.kts`。
- 原计划漏掉 `lib/core/network/dio_client.dart` 的 `userDevices` getter；OpenAPI 客户端删除后必须同步移除该 getter。
- `jpush_flutter` 的 `JPushFlutterInterface` 位于 `package:jpush_flutter/jpush_interface.dart`；`setup()` 和 `applyPushAuthority()` 返回 `void`，不能 `await`；`setAlias()`/`deleteAlias()` 返回 `Future<Map>`；事件回调签名是返回 `Future` 的异步回调。实现和测试按实际 SDK 类型编译，不按旧示例猜测。
- 不把真实 AppKey 写进 Gradle、Dart 或 plist。Android placeholder 从 `-PJPUSH_APP_KEY` 或环境变量读取，缺失时为空；Dart 侧从 `--dart-define=JPUSH_APP_KEY=...` 读取。真实推送构建必须同时提供两者。
- iOS 推送能力通过 `Runner.entitlements` + `project.pbxproj` 配置，Debug/Profile 使用 development，Release 使用 production；不把手动 Xcode 点击步骤当成已完成的自动化验证。真实 provisioning、APNs 证书和真机消息链路属于外部验收。
- 现有通知权限流程不能被登录时的 JPush API 额外弹窗绕过。协调器只在现有 `NotificationPermissionService` 返回 `granted` 时调用 `applyPushAuthority`；未授权时只绑定 alias，不主动申请权限。
- 当前日期为 2026-08-06，迁移日志统一追加到 `docs/03-logs/migration-log/2026-08-06.md`。Luminous 已有 `l10n.yaml` 工作区修改必须原样保留，不得纳入本任务提交。

## 验收标准

- Android Gradle Kotlin DSL 和 iOS entitlements 已配置，缺少 AppKey 时构建/启动不因 JPush 崩溃。
- 网关能在 Android/iOS 注册事件、解析 title/content/extras、绑定/解绑 alias、读取 iOS 冷启动通知；非移动平台静默返回。
- 点击通知使未读数失效并路由到已存在的 `/notifications`；前台到达只刷新未读数，不改变本地提醒行为。
- 登录、切换用户、退出登录分别绑定正确 alias 或删除当前 alias；现有通知权限服务负责权限状态。
- OpenAPI 客户端重新生成后无 `UserDevicesApi`/`RegisterDeviceDto`/`DeviceResponseDto` 残留；`dio_client.dart` 无旧 getter。
- `flutter analyze`、`flutter test`、文档覆盖检查在环境允许时通过；Windows 环境不能执行的 iOS/真机验证明确记录为未验证。

---

### Task 0: 固化审核后的客户端计划

**Files:**
- Modify: `plans/2026-08-03-jpush-integration.md`

- [ ] **Step 1: 检查仓库状态**

```powershell
git status --short --branch
```

Expected: 既有 `l10n.yaml` 修改保持未暂存；不覆盖其他用户文件。

- [ ] **Step 2: Commit**

```powershell
git add plans/2026-08-03-jpush-integration.md
git commit -m "docs(push): 审核并完善极光客户端实施计划"
```

---

### Task 1: 依赖、Android placeholder 与 iOS Push entitlement

**Files:**
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Modify: `android/app/build.gradle.kts`
- Create: `ios/Runner/Runner.entitlements`
- Modify: `ios/Runner.xcodeproj/project.pbxproj`
- Modify: `docs/03-logs/migration-log/2026-08-06.md`

- [ ] **Step 1: 添加 SDK 依赖并记录解析版本**

```powershell
flutter pub add jpush_flutter
flutter pub get
```

Expected: `pubspec.yaml` 增加 `jpush_flutter`，`pubspec.lock` 固定实际解析版本；不手工把旧计划中的 `^3.4.5` 当作 API 事实。

- [ ] **Step 2: 修改实际 Kotlin DSL 的 manifest placeholders**

在 `android/app/build.gradle.kts` 中增加从 Gradle property/env 读取 AppKey 的 provider，`defaultConfig` 设置：`JPUSH_PKGNAME=applicationId`、`JPUSH_APPKEY=读取值或空字符串`、`JPUSH_CHANNEL=developer-default`。仓库文件中不得出现真实 AppKey 或“在这里填”的占位文字；无值时保留空字符串，让 Dart 层也保持禁用。

- [ ] **Step 3: 配置 iOS entitlements**

创建 `ios/Runner/Runner.entitlements`，内容使用 `$(APS_ENVIRONMENT)` 作为 `aps-environment`；在 Runner target 的 Debug/Profile/Release build settings 中加入 `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements`，并分别设置 `APS_ENVIRONMENT=development/development/production`。不修改 `AppDelegate.swift`，除非真实设备验证证明插件需要额外转发 token。

- [ ] **Step 4: 运行静态配置检查和 Android debug 构建**

```powershell
rg -n "在这里填|真实 AppKey|JPUSH_APPKEY|APS_ENVIRONMENT|CODE_SIGN_ENTITLEMENTS" android ios
flutter build apk --debug
```

Expected: 不出现真实凭据；Android debug 构建成功。若 Android 构建因 SDK/Gradle 版本失败，先按实际报错修正，不盲目升级 minSdk/生产依赖。

- [ ] **Step 5: 文档检查并 Commit**

```powershell
dart run scripts/check_doc_coverage.dart --warning-only
git add pubspec.yaml pubspec.lock android/app/build.gradle.kts ios/Runner/Runner.entitlements ios/Runner.xcodeproj/project.pbxproj docs/03-logs/migration-log/2026-08-06.md
git commit -m "feat(push): 接入 JPush 依赖与移动端原生配置"
```

---

### Task 2: JPush 网关

**Files:**
- Create: `lib/core/push/jpush_gateway.dart`
- Create: `test/core/push/jpush_gateway_test.dart`
- Modify: `docs/03-logs/migration-log/2026-08-06.md`

- [ ] **Step 1: 先写可测试的网关行为**

测试覆盖：非 Android/iOS 或 AppKey 为空时 `init()` 不调用 `setup`；移动平台配置存在时先注册异步事件回调再调用同步 `setup`；`setAlias`/`deleteAlias` 只在 configured 时调用；`getLaunchAppNotification()` 空 Map 返回 null；extras 同时兼容 Map 与 JSON 字符串；没有订阅者时先到达的点击事件在第一个订阅者建立后仍可消费。

- [ ] **Step 2: 实现网关并匹配当前 SDK 签名**

导入：

```dart
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';
```

`JpushGateway` 接受可选 `JPushFlutterInterface` 以便测试；`addEventHandler` 的两个 handler 声明为 `Future<void> Function(Map<String, dynamic>)`；`setup()`、`applyPushAuthority()` 不使用 `await`；`setAlias()`、`deleteAlias()` 使用 `await`；冷启动读取 `Future<Map>` 并以 `isEmpty` 判断。使用 `StreamController.broadcast` + pending-open 队列避免 `main()` 早于 Riverpod provider 初始化时丢失点击事件。`jpushGatewaySingleton` 只初始化一次，provider 不在短生命周期 dispose 时关闭进程级单例。

- [ ] **Step 3: 运行网关测试和 analyzer**

```powershell
flutter test test/core/push/jpush_gateway_test.dart
flutter analyze lib/core/push/jpush_gateway.dart test/core/push/jpush_gateway_test.dart
dart run scripts/check_doc_coverage.dart --warning-only
```

- [ ] **Step 4: Commit**

```powershell
git add lib/core/push/jpush_gateway.dart test/core/push/jpush_gateway_test.dart docs/03-logs/migration-log/2026-08-06.md
git commit -m "feat(push): 封装 JPush SDK 与 alias 网关"
```

---

### Task 3: 消息处理与站内路由

**Files:**
- Create: `lib/core/push/message_handler.dart`
- Create: `test/core/push/message_handler_test.dart`
- Modify: `docs/03-logs/migration-log/2026-08-06.md`

- [ ] **Step 1: 实现消息处理**

`routeForPushEvent()` 默认返回现有 `Routes.notifications`；`PushMessageHandler` 订阅网关 open/receive 流，点击和前台到达都 `invalidate(notificationUnreadCountProvider)`，点击额外 `go(Routes.notifications)`。provider 使用 `ref.keepAlive()` 或由应用根持续 watch，确保 `ref.read()` 后不会在首帧结束时销毁订阅。

- [ ] **Step 2: 编写消息路由测试**

测试默认消息和带 `extras.action=medicine_reminder` 的消息都返回 `/notifications`；不引入新的可见文案，不改 `lib/l10n/src/`。

- [ ] **Step 3: 运行验证和 Commit**

```powershell
flutter test test/core/push/message_handler_test.dart
flutter analyze lib/core/push/message_handler.dart test/core/push/message_handler_test.dart
dart run scripts/check_doc_coverage.dart --warning-only
git add lib/core/push/message_handler.dart test/core/push/message_handler_test.dart docs/03-logs/migration-log/2026-08-06.md
git commit -m "feat(push): 处理通知点击与站内路由"
```

---

### Task 4: 生命周期、认证接线与通知权限协作

**Files:**
- Create: `lib/core/push/lifecycle.dart`
- Create: `test/core/push/lifecycle_test.dart`
- Modify: `lib/main.dart`
- Modify: `lib/app/bootstrap.dart`
- Modify: `docs/00-current/Runtime_Snapshot.md`
- Modify: `docs/03-logs/migration-log/2026-08-06.md`

- [ ] **Step 1: 实现 `PushCoordinator`**

构造函数注入 `JpushGateway`、`PushEventSink`、`NotificationPermissionService`。`onAuthChanged` 的 `userId` 对登出为可选；登录时先检查现有通知权限，权限为 `granted` 才调用无额外弹窗的 APNs 注册，再 `setAlias(userId)`；登出只 `deleteAlias()`；JPush 不可用或用户 ID 为空时返回。`start()` 只执行一次，在 iOS 读取冷启动通知并交给 sink。

- [ ] **Step 2: 修正启动顺序和 provider 生命周期**

在 `main()` 的 `WidgetsFlutterBinding.ensureInitialized()` 后、`runApp()` 前调用 `jpushGatewaySingleton.init()`，捕获并记录初始化失败但不阻断应用启动。`bootstrap.dart` 首帧中先 `await authSessionProvider.notifier.restore()`，再启动 coordinator，确保冷启动点击不会先被未恢复的 auth redirect 丢失；在 auth listener 中处理登出、首次登录和切换用户。根 widget 持续 `ref.watch(pushCoordinatorProvider)`，保证消息 handler 订阅整个 app 生命周期。

- [ ] **Step 3: 编写生命周期测试**

使用 fake gateway 与 fake permission service 覆盖：已授权登录执行 APNs 注册+alias；未授权登录只 alias 不申请权限；登出删除 alias；不可用时无操作；`start()` 把冷启动事件传给 sink 且只处理一次。

- [ ] **Step 4: 运行定向验证和文档检查**

```powershell
flutter test test/core/push/
flutter analyze lib/main.dart lib/app/bootstrap.dart lib/core/push/ test/core/push/
dart run scripts/check_doc_coverage.dart --warning-only
```

- [ ] **Step 5: Commit**

```powershell
git add lib/core/push/lifecycle.dart test/core/push/lifecycle_test.dart lib/main.dart lib/app/bootstrap.dart docs/00-current/Runtime_Snapshot.md docs/03-logs/migration-log/2026-08-06.md
git commit -m "feat(push): 接入启动生命周期与登录 alias 绑定"
```

---

### Task 5: 后端合同删除后的客户端同步

**Files:**
- Modify: `lib/core/network/dio_client.dart`
- Modify: `generated/lucent_api/**`（仅生成器产物）
- Modify: `docs/00-current/Lucent_Contract_Snapshot.md`
- Modify: `docs/02-reference/OpenApi_Client.md`
- Modify: `docs/03-logs/migration-log/2026-08-06.md`

- [ ] **Step 1: 先删除旧客户端 accessor**

删除 `DioClient.userDevices` getter；先运行 analyzer，确认唯一编译引用来自生成客户端本身，业务代码没有实际调用旧 API。

- [ ] **Step 2: 从 Lucent 最新 OpenAPI 重新生成**

```powershell
dart run scripts/bootstrap_generated_sources.dart
```

该脚本会执行 `flutter pub get`、生成客户端 `build_runner`、`flutter gen-l10n` 和应用 `build_runner`；保留与本任务无关的既有 `l10n.yaml` 工作区修改，不把它加入 stage。

- [ ] **Step 3: 检查生成范围**

```powershell
rg -n "UserDevicesApi|RegisterDeviceDto|DeviceResponseDto|user-devices|user_devices" generated lib
git diff --stat
```

Expected: 旧设备 API/DTO 无残留；`UserDevicePlatform` 只有在仍被 UserSession 合同使用时才保留；生成器没有删除或改写无关 API。

- [ ] **Step 4: 运行合同和文档验证**

```powershell
flutter analyze lib/core/network/dio_client.dart generated/lucent_api
dart run scripts/check_doc_coverage.dart --warning-only
```

- [ ] **Step 5: Commit**

```powershell
git add lib/core/network/dio_client.dart generated/lucent_api docs/00-current/Lucent_Contract_Snapshot.md docs/02-reference/OpenApi_Client.md docs/03-logs/migration-log/2026-08-06.md
git commit -m "chore(api): 同步移除设备注册接口的生成客户端"
```

---

### Task 6: 全量验证、真实设备边界与计划收尾

- [ ] **Step 1: 运行全量检查**

```powershell
flutter analyze
flutter test
dart run scripts/check_doc_coverage.dart --warning-only
dart run scripts/check_doc_coverage.dart --staged
```

- [ ] **Step 2: 检查敏感信息和工作区边界**

```powershell
rg -n "JPUSH_APP_KEY|JPUSH_APPKEY|JPUSH_MASTER_SECRET|Master Secret" --glob '!pubspec.lock' --glob '!plans/**' .
git status --short
```

Expected: 只有空配置、构建参数名和文档说明；不出现真实 AppKey/Master Secret；`l10n.yaml` 仍是原有未暂存改动。

- [ ] **Step 3: 记录无法在当前环境验证的项目**

Windows 环境不执行 iOS build、Apple entitlement/provisioning 验证；没有 JPush 凭据和 Android/iOS 真机时，不声称前台/后台/终止态真实推送已通过。交付时列出这些未验证项和所需命令/设备。

- [ ] **Step 4: 删除已完成计划文件**

在迁移日志追加“本计划实施完毕，计划文件已删（实施完毕文件已删）”，删除 `plans/2026-08-03-jpush-integration.md`；不要留下 `✅`/`DONE` 标记。

- [ ] **Step 5: Commit**

```powershell
git add plans/2026-08-03-jpush-integration.md docs/03-logs/migration-log/2026-08-06.md
git commit -m "chore(plans): 完成极光客户端计划并清理计划文件"
```

---

## 与 Lucent 的交接

只有在 Lucent 的 OpenAPI 已移除设备注册路径后执行 Task 5。真实推送联调需要服务端 `JPUSH_APP_KEY`/`JPUSH_MASTER_SECRET`、客户端 Dart define/Android Gradle property、正确的包名/Bundle ID 以及匹配的 APNs provisioning；所有凭据只注入本地或部署环境。
