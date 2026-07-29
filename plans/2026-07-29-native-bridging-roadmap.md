# Luminous 原生桥接路线图

> 创建日期：2026-07-29
> 状态：规划中，尚未开始执行
> 涉及仓库：Luminous（部分需 Lucent 后端配合）
> 完成后删除本文件，将稳定决策更新到 `docs/02-reference/architecture.md` 及相关文档。

---

## 1. 背景与目标

Luminous 当前大部分功能通过纯 Dart + Flutter 插件实现，已有的原生桥接仅限于：

| 已有桥接 | 实现方式 |
|---------|---------|
| 保存图片到相册 (Android) | 自定义 `MethodChannel` (`com.dev.luminous/gallery`) 在 `MainActivity.kt` |
| 微信 OAuth (移动端) | `fluwx` 插件 |
| 本地通知调度 | `flutter_local_notifications` 插件 |
| OCR 文字识别 | `paddle_ocr_native` (PP-OCRv6 / ONNX Runtime) |
| 条码扫描 | `mobile_scanner` (原生相机) |
| 图片压缩 | `flutter_image_compress` (原生 API) |
| 桌面窗口管理 | `window_manager` (原生窗口) |
| 原生 Splash + iOS 通知代理 | `MainActivity.kt` / `AppDelegate.swift` |

随着产品成熟，以下场景在纯 Dart 层无法实现或效果受限，需要引入或增强原生桥接。

---

## 2. 需求清单与优先级

| 优先级 | 需求 | 核心痛点 | 依赖方 |
|--------|------|---------|--------|
| P0 | 后台同步 (Background Sync) | 离线写入的 `pending_sync` 队列在 app 被杀后无法重放 | Luminous 独立 |
| P0 | 推送通知 (Remote Push) | 服务端通知无法触达离线用户 | Luminous + Lucent |
| P1 | 健康数据集成 (HealthKit / Health Connect) | 步数、睡眠、心率等 vital 数据全靠手动录入 | Luminous 独立 |
| P1 | 生物识别认证 (Biometric Auth) | 安全提权仅支持 6 位 PIN | Luminous 独立 |
| P2 | 应用快捷方式 (App Shortcuts) | 快速录入入口需先打开 app | Luminous 独立 |
| P2 | iOS Live Activity / Android Widget | 用药提醒锁屏可见性不足 | Luminous 独立 |
| P3 | 桌面全局热键 | 后台时无法通过快捷键触发 | Luminous 独立 |

---

## 3. 详细方案

### 3.1 后台同步 (Background Sync) — P0

#### 现状

`SyncWorker` (`core/database/sync/worker.dart`) 监听 `connectivity_plus` 的网络变化事件，
在 app 前台时自动重放 `pending_sync` 队列。一旦 app 被系统杀死，队列中的离线写入
（如快速记录的饮水/用药/饮食）将无限期滞留，直到用户下次手动打开 app。

#### 方案

**Android — WorkManager**

使用 `workmanager` 插件（或自定义 MethodChannel 调用原生 WorkManager API）：

- 注册一个 **周期性 Worker**（每 15 分钟），约束 `NetworkType.CONNECTED`
- Worker 启动时在 Dart isolate 中执行 `SyncWorker.flush()`
- 需要处理 isolate 生命周期：Dart isolate 在后台入口点冷启动，需要初始化最小
  依赖（Drift database connection + Dio instance + pending_sync DAO）

关键文件变更：
- `lib/core/database/sync/background_sync_entry.dart` — 新增，后台 isolate 入口点
- `lib/core/database/sync/worker.dart` — 提取 `flush()` 为可独立调用的静态方法
- `android/app/src/main/kotlin/.../MainActivity.kt` — 注册 WorkManager
- `pubspec.yaml` — 添加 `workmanager` 依赖

**iOS — BGProcessingTaskRequest**

通过自定义 MethodChannel 在 `AppDelegate.swift` 中注册后台处理任务：

- `BGTaskScheduler.shared.register` 注册 `BGProcessingTask`
- 在 info.plist 声明 `BGTaskSchedulerPermittedIdentifiers`
- 后台任务触发时通过 MethodChannel 调用 Dart 端的 `flush()`
- iOS 后台执行时间有限（约 30s），需做好超时保护

关键文件变更：
- `ios/Runner/AppDelegate.swift` — 注册 BGTaskScheduler
- `ios/Runner/Info.plist` — 声明后台任务标识符
- `lib/core/database/sync/background_sync_entry.dart` — 共用入口点

**两端共用逻辑**

```
lib/core/database/sync/
├── worker.dart                 ← 现有 SyncWorker（保持不变）
├── background_sync_entry.dart  ← 新增：后台入口点，初始化最小依赖后调用 flush
└── background_sync_coordinator.dart ← 新增：注册/取消后台任务的平台抽象
```

`BackgroundSyncCoordinator` 接口：

```dart
abstract interface class BackgroundSyncCoordinator {
  bool get isSupported;
  Future<void> registerPeriodicSync({Duration interval = const Duration(minutes: 15)});
  Future<void> unregister();
}
```

实现两个版本：`WorkManagerSyncCoordinator` (Android) 和 `BgTaskSyncCoordinator` (iOS)，
在 `core/providers/` 中按 `Platform` 选择注入。

#### 验证

- Android: 关闭 app → 断网写入记录 → 连网 → 等待 15 分钟 → 检查后端是否收到
- iOS: 同上，但需手动触发后台任务（Xcode → Debug → Simulate Background Fetch）
- `flutter test` 覆盖 `flush()` 静态入口点的单元测试

---

### 3.2 推送通知 (Remote Push Notifications) — P0

#### 现状

`notification` feature 的 unread count (`notificationUnreadCountProvider`) 只在 app
前台时拉取。后端 Lucent 有 BullMQ 队列可以生成服务端通知，但无法推送到离线设备。

#### 方案

**Android — FCM**

- 添加 `firebase_messaging` 插件
- 在 `MainActivity.kt` 中获取 FCM token
- 通过 `POST /api/v1/user/devices` 将 token 注册到 Lucent
- Lucent 的通知服务在推送时调用 FCM API

**iOS — APNs**

- 在 `AppDelegate.swift` 中注册远程通知
- 获取 device token 后发送给 Lucent
- Lucent 的通知服务调用 APNs provider

**Lucent 后端需配合**

- 新增 `devices` 模块：`POST /api/v1/user/devices` (register), `DELETE /api/v1/user/devices/:token` (unregister)
- 通知发送服务增加 FCM/APNs 推送逻辑
- `environment.md` 补充 FCM/APNs 配置项

关键文件变更（Luminous 端）：
- `lib/core/network/push/` — 新增目录
  - `push_token_service.dart` — 获取 + 注册 token
  - `push_message_handler.dart` — 处理收到的推送消息（前台/后台/终止态）
- `lib/app/bootstrap.dart` — 在 app 启动时初始化推送
- `ios/Runner/AppDelegate.swift` — 注册远程通知
- `android/app/build.gradle` — 添加 Google Services 依赖
- `pubspec.yaml` — 添加 `firebase_messaging`

#### 验证

- 前台收推送：app 打开时后端发推送 → app 内显示
- 后台收推送：app 在后台 → 通知栏显示系统通知
- 终止态收推送：app 被杀 → 通知栏显示 → 点击打开 app → 跳转到对应页面

---

### 3.3 健康数据集成 (HealthKit / Health Connect) — P1

#### 现状

`record` feature 支持 `water`、`meal`、`vital`、`sleep`、`activity` 等
`DailyRecordKind`，但所有数据靠手动录入或拍照 OCR。用户没有从可穿戴设备
自动采数的通道。

`health_context` 模块管理过敏、状况、当前用药，但缺少从健康平台拉取 vital 的能力。

#### 方案

使用 `health` 插件（pub.dev: `health`，支持 iOS HealthKit + Android Health Connect）。

**数据映射**

| 原生健康数据 | Luminous DailyRecordKind | 说明 |
|-------------|-------------------------|------|
| 步数 (steps) | `activity` | 自动记录每日步数 |
| 睡眠分析 (sleep analysis) | `sleep` | 自动填充睡眠时段 |
| 心率 (heart rate) | `vital` | 自动记录心率 |
| 血压 (blood pressure) | `vital` | 自动记录血压 |
| 体重 (body mass) | `vital` | 自动记录体重 |
| 身高 (height) | `vital` | 更新 health_context profile |
| 水分摄入 (water) | `water` | 自动记录饮水量（如 Apple Health 支持手动录入水） |

**架构设计**

```
lib/features/health_data/          ← 新 feature
├── data/
│   ├── datasources/
│   │   └── health_platform.dart  ← Health 插件封装
│   ├── mappers/
│   │   └── health_record_mapper.dart  ← 原生健康数据 → DailyRecordInput
│   └── repositories/
│       └── health_sync.dart
├── domain/
│   ├── entities/
│   │   ├── health_permission.dart
│   │   └── health_sync_result.dart
│   └── repositories/
│       └── health_data.dart
└── presentation/
    ├── pages/
    │   └── health_sync.dart      ← 同步页面（权限请求 + 数据预览 + 确认导入）
    └── providers/
        └── health_sync.dart
```

**同步流程**

1. 用户在 `mine` 页面点击「从健康 App 导入」
2. 请求 HealthKit/Health Connect 权限（只请求已启用的数据类型）
3. 拉取最近 N 天的健康数据
4. 展示预览页面：显示「步数 8,432 步」「睡眠 7h 12m」等
5. 用户确认后，批量调用 `dailyRecordRepository.create()` 写入
6. 写入完成后 `emitDataChange(DataChangeTopic.dailyRecords)`

**权限策略**

- 不在 app 启动时请求健康数据权限，仅在用户主动触发时请求
- 权限粒度按数据类型分开请求（步数、心率、睡眠各自独立授权）
- 在 `settings` 中增加「健康数据自动同步」开关

#### 验证

- iOS: 模拟器 Health app 手动录入数据 → Luminous 同步 → 验证记录正确
- Android: Health Connect 测试数据 → 同步 → 验证
- 权限拒绝/部分授权场景
- 重复同步不产生重复记录（按 `occurredAt` 去重）

---

### 3.4 生物识别认证 (Biometric Authentication) — P1

#### 现状

`SecurityElevationController` (`core/providers/security_elevation.dart`) 通过
`POST /settings/security-pin/verify` 验证 6 位 PIN，获取提权 token。每次访问
敏感操作（如查看健康档案详情）都需要手动输入 PIN。

#### 方案

使用 `local_auth` 插件（支持 TouchID / FaceID / 指纹）。

**集成点**

在 `SecurityElevationController` 中增加 `tryBiometric()` 分支：

```dart
Future<bool> verify(String pin) async { /* 现有 PIN 路径 */ }

Future<bool> tryBiometric() async {
  final auth = LocalAuthentication();
  final canCheck = await auth.canCheckBiometrics;
  if (!canCheck) return false;
  final success = await auth.authenticate(
    localizedReason: '请验证生物识别以访问健康数据',
    options: const AuthenticationOptions(biometricOnly: true),
  );
  if (success) {
    // 向后端请求 biometric elevation token
    // 后端需新增 POST /settings/security-pin/biometric-verify
    // 请求中携带设备绑定的 challenge token
    ...
  }
  return success;
}
```

**后端配合**

Lucent 需新增 `POST /api/v1/user/settings/security-pin/biometric-verify` 端点：
- 接收设备 challenge token（在用户启用生物识别时生成并绑定）
- 验证通过后返回与 PIN 验证相同的 elevation token
- 用户在 `settings` 中启用生物识别时，后端生成 challenge token 并下发

**Settings 页面变更**

在 `settings/presentation/pages/` 的安全设置 section 中增加：
- 「使用生物识别提权」开关
- 首次启用时需要先验证 PIN，然后注册生物识别 challenge
- 关闭时只需 toggle off

关键文件变更：
- `lib/core/providers/security_elevation.dart` — 增加 `tryBiometric()`
- `lib/features/settings/domain/services/biometric_service.dart` — 新增
- `lib/features/settings/presentation/pages/security.dart` — 新增生物识别设置 UI
- `pubspec.yaml` — 添加 `local_auth`

#### 验证

- 首次启用：输入 PIN → 注册生物识别 → 下次提权可直接用 FaceID/指纹
- 生物识别不可用时的 fallback 路径（回到 PIN）
- 生物识别失败 3 次后 fallback 到 PIN

---

### 3.5 应用快捷方式 (App Shortcuts) — P2

#### 现状

项目已有完整的快速录入流程：
`MealQuickEntryFlow`、`MedicationQuickEntryFlow`、`MoodQuickEntryFlow`、
`WaterQuickEntryFlow`、`SleepQuickEntryFlow`、`SymptomQuickEntryFlow`。
但用户必须先打开 app → 进入对应 tab → 点击快捷入口。

#### 方案

使用 `quick_actions` 插件（pub.dev: `quick_actions`）。

**静态快捷方式 (Android) / Shortcut Items (iOS)**

注册以下快捷方式：

| 快捷方式 | 目标路由 | 图标 |
|---------|---------|------|
| 记录饮水 | `/record?quick=water` | water_drop |
| 记录用药 | `/record?quick=medication` | medication |
| 拍照记录饮食 | `/record?quick=meal&source=camera` | restaurant |
| 记录心情 | `/record?quick=mood` | mood |

**iOS — Static Shortcut Items**

在 `Info.plist` 中声明 `UIApplicationShortcutItems`，或通过
`QuickActions.setShortcutItems()` 动态设置。

**Android — Static Shortcuts**

在 `res/xml/shortcuts.xml` 中声明静态快捷方式，或通过 `ShortcutManager`
动态添加（用户登录后根据 current medicines 动态生成用药快捷方式）。

**路由层变更**

`lib/app/router.dart` 增加深链接处理：`/record?quick=water` →
直接触发 `WaterQuickEntryFlow`，绕过 tab 导航。

关键文件变更：
- `lib/app/router.dart` — 处理快捷方式 deep link
- `lib/core/shortcuts/app_shortcuts.dart` — 增加 `registerAppShortcuts()`
- `ios/Runner/Info.plist` — 声明 shortcut items
- `android/app/src/main/res/xml/shortcuts.xml` — 声明静态快捷方式
- `pubspec.yaml` — 添加 `quick_actions`

#### 验证

- Android: 长按 app 图标 → 显示快捷方式 → 点击 → 直接进入对应流程
- iOS: 3D Touch / 长按 → 显示快捷方式 → 点击 → 直接进入
- 快捷方式 deep link 在 app 冷启动时正确处理
- 未登录用户点击快捷方式 → 跳转到登录页

---

### 3.6 iOS Live Activity / Android 通知 Widget — P2

#### 现状

用药提醒通过 `flutter_local_notifications` 的 `zonedSchedule` 实现普通本地通知。
用户需要解锁手机、找到通知、打开 app 才能看到用药状态。

#### 方案

**iOS — Live Activity (ActivityKit)**

- 创建 `LuminousMedicationReminder` Widget Extension
- 通过 MethodChannel 或 ActivityKit 插件启动/更新/结束 Live Activity
- 锁屏和灵动岛上显示「下一次用药：XX 药，14:00」

**Android — 通知栏小组件**

- 在 `MedicineReminderNotificationCoordinator.resync()` 中使用
  `RemoteViews` 自定义通知布局
- 或在桌面添加 App Widget 显示当日用药进度

**实施范围**

iOS Live Activity 需要单独的 Widget Extension target，增加了项目复杂度。
建议先做 Android 通知小组件（在现有 `flutter_local_notifications` 基础上
扩展自定义布局），Live Activity 作为后续迭代。

关键文件变更（Android 通知小组件）：
- `android/app/src/main/res/layout/` — 通知自定义布局 XML
- `lib/core/notifications/local_notification_gateway.dart` — 增加
  `BigPictureStyle` / `RemoteViews` 支持

#### 验证

- Android: 用药提醒触发 → 通知栏显示自定义布局（药名 + 时间 + 状态）
- iOS: Live Activity 在锁屏显示用药进度（如有实施）

---

### 3.7 桌面全局热键 — P3

#### 现状

`AppShortcuts` (`core/shortcuts/app_shortcuts.dart`) 使用 Flutter 的
`Shortcuts` + `Actions` 机制。这只在 app 窗口聚焦时生效。后台时无法
通过全局快捷键唤起 app 或触发操作。

#### 方案

使用 `hotkey_manager` 插件或自定义 MethodChannel：

- 注册系统级全局热键（如 `Ctrl+Shift+L` 唤起 Luminous 窗口）
- 通过 MethodChannel 在 `MainActivity.kt` / `MainWindow.swift` 中
  调用原生热键 API

关键文件变更：
- `lib/core/shortcuts/global_hotkey.dart` — 新增
- `android/app/src/main/kotlin/.../MainActivity.kt` — 注册热键
- `windows/runner/` — Windows 热键注册

**优先级低**：桌面端用户量少，当前 Flutter 内部快捷键已满足核心场景。

---

## 4. 执行计划

### Phase 1: 后台同步 (P0)

| 步骤 | 内容 | 预计工作量 |
|------|------|-----------|
| 1.1 | 设计 `BackgroundSyncCoordinator` 抽象接口 | 0.5h |
| 1.2 | 提取 `SyncWorker.flush()` 为可独立调用的方法 | 1h |
| 1.3 | 实现 `WorkManagerSyncCoordinator` (Android) | 3h |
| 1.4 | 实现 `BgTaskSyncCoordinator` (iOS) | 3h |
| 1.5 | 后台 isolate 入口点 + 最小依赖初始化 | 3h |
| 1.6 | 单元测试 + 集成测试 | 2h |
| 1.7 | 文档更新 | 0.5h |

**前置条件**：无
**风险**：后台 isolate 的 Drift database 连接可能与前台 isolate 的连接冲突，需验证

### Phase 2: 推送通知 (P0)

| 步骤 | 内容 | 预计工作量 |
|------|------|-----------|
| 2.1 | Lucent 后端新增 devices 模块 + API | 1 天 (后端) |
| 2.2 | Lucent 通知服务集成 FCM/APNs | 1 天 (后端) |
| 2.3 | Luminous `PushTokenService` 实现 | 3h |
| 2.4 | Luminous `PushMessageHandler` 实现 | 3h |
| 2.5 | iOS APNs 注册 (`AppDelegate.swift`) | 2h |
| 2.6 | Android FCM 集成 | 3h |
| 2.7 | 推送消息路由到对应页面 | 2h |
| 2.8 | 测试 + 文档 | 2h |

**前置条件**：需要 Firebase 项目 + APNs 证书
**风险**：Firebase 项目配置可能需要额外审批

### Phase 3: 健康数据集成 (P1)

| 步骤 | 内容 | 预计工作量 |
|------|------|-----------|
| 3.1 | 新建 `health_data` feature 目录结构 | 0.5h |
| 3.2 | `HealthPlatform` 数据源封装 | 3h |
| 3.3 | 健康数据 → `DailyRecordInput` mapper | 2h |
| 3.4 | 同步流程页面 + provider | 4h |
| 3.5 | 权限请求 + 部分授权处理 | 2h |
| 3.6 | 去重逻辑（按 `occurredAt`） | 1h |
| 3.7 | Settings 增加自动同步开关 | 1h |
| 3.8 | 测试 + 文档 | 2h |

**前置条件**：iOS HealthKit entitlement、Android Health Connect 权限声明

### Phase 4: 生物识别认证 (P1)

| 步骤 | 内容 | 预计工作量 |
|------|------|-----------|
| 4.1 | Lucent 后端新增 biometric-verify 端点 | 0.5 天 (后端) |
| 4.2 | `BiometricService` 实现 | 2h |
| 4.3 | `SecurityElevationController` 集成 | 2h |
| 4.4 | Settings 安全页面 UI | 2h |
| 4.5 | 测试 + 文档 | 1h |

**前置条件**：Lucent 后端 biometric challenge token 机制

### Phase 5: 应用快捷方式 (P2)

| 步骤 | 内容 | 预计工作量 |
|------|------|-----------|
| 5.1 | 路由 deep link 处理 | 2h |
| 5.2 | `quick_actions` 集成 | 1h |
| 5.3 | iOS shortcut items 声明 | 1h |
| 5.4 | Android shortcuts.xml | 1h |
| 5.5 | 未登录状态处理 | 1h |
| 5.6 | 测试 + 文档 | 1h |

### Phase 6: 用药提醒增强 (P2)

| 步骤 | 内容 | 预计工作量 |
|------|------|-----------|
| 6.1 | Android 自定义通知布局 | 3h |
| 6.2 | `LocalNotificationGateway` 扩展 | 2h |
| 6.3 | iOS Live Activity（可选，后续迭代） | 1 天+ |
| 6.4 | 测试 + 文档 | 2h |

### Phase 7: 桌面全局热键 (P3)

| 步骤 | 内容 | 预计工作量 |
|------|------|-----------|
| 7.1 | `GlobalHotkey` 抽象 + 实现 | 3h |
| 7.2 | 测试 + 文档 | 1h |

---

## 5. 依赖与前置条件

### 平台账号

| 需求 | 平台 | 用途 |
|------|------|------|
| Firebase 项目 | Android | FCM 推送 |
| APNs 证书 | iOS | 远程推送 |
| Apple Developer entitlement | iOS | HealthKit |
| Android Health Connect | Android | 健康数据 |

### Lucent 后端配合项

| Phase | 后端工作 |
|-------|---------|
| Phase 2 (推送) | `devices` 模块 + FCM/APNs 推送服务 |
| Phase 4 (生物识别) | `POST /settings/security-pin/biometric-verify` + challenge token 机制 |

### 新增 pubspec 依赖

| 依赖 | Phase | 用途 |
|------|-------|------|
| `workmanager` | Phase 1 | Android 后台任务 |
| `firebase_messaging` | Phase 2 | FCM 推送 |
| `health` | Phase 3 | HealthKit / Health Connect |
| `local_auth` | Phase 4 | 生物识别 |
| `quick_actions` | Phase 5 | 应用快捷方式 |

---

## 6. 风险与缓解

| 风险 | 概率 | 缓解 |
|------|------|------|
| 后台 isolate Drift 连接冲突 | 中 | 使用独立 database 文件或 isolate-safe 连接方式 |
| Firebase 项目审批延迟 | 中 | Phase 2 可先做 iOS APNs，Android FCM 后补 |
| HealthKit 权限审核被拒 | 低 | 确保只请求与功能直接相关的数据类型，提供清晰的用户说明 |
| iOS Live Activity 增加 target 复杂度 | 中 | 先做 Android 通知小组件，Live Activity 作为后续迭代 |
| 后台同步导致数据冲突 | 中 | flush() 已有 retry + markFailed 机制，增加 timestamp 冲突检测 |
| `local_auth` 在某些 Android 设备上不可用 | 低 | fallback 到 PIN 路径，已有逻辑 |

---

## 7. 不做的事情

- **不做原生地图集成** — 当前无位置相关功能需求
- **不做 NFC 桥接** — 药品识别已通过条码 + OCR 覆盖
- **不做蓝牙桥接** — 当前无蓝牙设备直连需求
- **不做原生语音识别** — AI 助手已通过 SSE 文本交互
- **不做原生视频/相机高级处理** — `image_picker` + OCR 已满足拍照识别需求
- **不做 Web 端原生桥接** — Web 端不支持 platform channel，现有 web fallback 保持不变

---

## 8. 文档更新清单

每个 Phase 完成后需更新：

| 文档 | 更新内容 |
|------|---------|
| `docs/02-reference/architecture.md` | 新增 `health_data` feature、后台同步模块、推送模块 |
| `docs/00-current/Active_*.md` | 更新各 feature 的当前状态 |
| `docs/03-logs/migration-log/YYYY-MM-DD.md` | 追加迁移日志条目 |
| `pubspec.yaml` | 新增依赖 |
| `AGENTS.md` | 如有新的 feature 目录约定需更新 |
| Lucent `docs/environment.md` | FCM/APNs 配置项（Phase 2） |
| Lucent `README.md` | devices 模块说明（Phase 2） |
