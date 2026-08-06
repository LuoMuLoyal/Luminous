# 极光推送客户端集成实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 Luminous 接入极光推送（JPush），按极光推荐的最佳实践：登录后 `setAlias(userId)` 绑定用户、退出 `deleteAlias()`，接收通知消息并路由到站内通知页，覆盖前台/后台/终止三种状态。

**Architecture:** 新增 `lib/core/push/` 目录，三个职责单一的文件（**文件名不重复目录已表明的 `push` 前缀**）：`jpush_gateway.dart`（封装 jpush_flutter：setup/事件流/alias 绑定/权限）、`message_handler.dart`（通知点击路由 `/notifications`、到达刷新未读数）、`lifecycle.dart`（推送生命周期编排：启动初始化、登录态变化时绑定/解绑 alias）。SDK 初始化放在 `main()`（`runApp` 之前）以捕获冷启动点击；`jpushGatewaySingleton` 由 `main()` 初始化、Riverpod provider 复用同一实例。现有 `flutter_local_notifications` 本地提醒链路不动。仅 Android/iOS 生效，其他平台静默跳过。

**Tech Stack:** Flutter, Riverpod, GoRouter, `jpush_flutter ^3.4.5`, 生成 API 客户端 `generated/lucent_api`。

---

## 与后端的契约

- 客户端登录后 `jpush.setAlias(userId)`、退出 `jpush.deleteAlias()`；alias = Lucent 用户 id（UUID）。极光维护 alias→设备映射，同一用户多设备共享一个 alias。
- 后端按 `audience: { alias: [userId] }` 推送，**不再提供设备注册 API**；旧 `POST/GET/DELETE /api/v1/user/user-devices` 已删除。
- 通知 `extras`（后端 `data`）携带 `action` 等路由信息；v1 统一跳转 `/notifications`，后续按 `action` 细化。

## 现状

- `lib/core/notifications/local_notification_gateway.dart`：本地定时通知（用药提醒等），与远程推送互不干扰。
- `lib/features/settings/domain/services/notification_permission.dart` + `lib/features/settings/data/providers/notification_permission.dart`：系统通知权限统一管理（permission_handler + flutter_local_notifications），**推送授权复用该流程，不额外弹窗**。
- `generated/lucent_api` 含旧的 `UserDevicesApi`（本次随后端删除契约后重生成移除）。
- 路由：`lib/app/router.dart` 的 `Routes.notifications = '/notifications'`；`appRouterProvider` 为 GoRouter provider。
- 未读角标：`notificationUnreadCountProvider`（`lib/features/notification/data/providers/unread_count.dart`）。

---

### Task 1: 依赖与原生平台配置

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle`
- Modify: `ios/Runner/AppDelegate.swift`（仅当收不到 device token 时兜底，见 Step 4）

- [ ] **Step 1: 添加依赖**

Run: `flutter pub add jpush_flutter`
Expected: `pubspec.yaml` 的 `dependencies` 出现 `jpush_flutter: ^3.4.5`，`flutter pub get` 成功。

- [ ] **Step 2: Android 配置 manifestPlaceholders**

在 `android/app/build.gradle` 的 `defaultConfig` 块内追加（`JPUSH_APPKEY` 替换为极光控制台该包名对应的 AppKey，AppKey 为公开应用标识，可入库）：

```groovy
        manifestPlaceholders = [
            JPUSH_PKGNAME: applicationId,
            JPUSH_APPKEY : "在这里填极光控制台 AppKey",
            JPUSH_CHANNEL: "developer-default",
        ]
```

> 若构建报 minSdk 不足，按报错提升 `android/app/build.gradle` 中 `minSdk`（jpush_flutter 3.x 要求 Android 5.0+）。

- [ ] **Step 3: iOS 开启推送能力（手动 Xcode 步骤）**

1. Xcode 打开 `ios/Runner.xcworkspace`
2. `Runner` target → `Signing & Capabilities` → `+ Capability` → `Push Notifications`
3. 确认开发/发布 provisioning profile 已勾选 Push Notifications entitlement（需在 Apple Developer 后台为 App ID 开启 Push 能力）

- [ ] **Step 4: 验证 iOS device token 兜底（仅在收不到 token 时执行）**

`jpush_flutter` 插件默认自动处理 APNs 注册；若真机收不到推送，在 `AppDelegate.swift` 的 `didFinishLaunchingWithOptions` 中追加转发：

```swift
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // jpush_flutter 插件要求转发 deviceToken 给 JPUSHService
    NotificationCenter.default.post(
      name: Notification.Name("didRegisterForRemoteNotificationsWithDeviceToken"),
      object: deviceToken
    )
  }
```

- [ ] **Step 5: 验证构建**

Run: `flutter build apk --debug`
Expected: 构建成功（iOS 在后续任务统一用 `flutter analyze` 验证 Dart 层）。

- [ ] **Step 6: Commit**

```bash
git -C Luminous add pubspec.yaml pubspec.lock android/app/build.gradle
git -C Luminous commit -m "feat(push): 接入 jpush_flutter 依赖与原生平台配置"
```

---

### Task 2: JPush 网关封装

**Files:**
- Create: `lib/core/push/jpush_gateway.dart`

> 命名说明：目录 `push/` 已表明域，文件名只保留业务词 + 限定词。`jpush` 是实现限定词（区别于未来可能的厂商直连实现），故 `jpush_gateway.dart` 保留。

- [ ] **Step 1: 新建 `lib/core/push/jpush_gateway.dart`**

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

/// 极光 AppKey。iOS 由 Dart 侧传入（--dart-define），Android 由 manifestPlaceholders 提供；
/// 两处值必须一致。未配置时推送功能整体禁用。
const jpushAppKey = String.fromEnvironment('JPUSH_APP_KEY');

/// 归一化的推送事件（与平台无关）。
class PushNotificationEvent {
  const PushNotificationEvent({
    required this.title,
    required this.body,
    this.extras,
  });

  final String title;
  final String body;

  /// 后端 `data` 的映射；JPush 可能以 JSON 字符串或 Map 形式返回。
  final Map<String, dynamic>? extras;
}

/// 推送点击事件消费者（路由与未读刷新）。定义在网关文件中以复用
/// [PushNotificationEvent]，避免 lifecycle / message_handler 循环依赖。
abstract interface class PushEventSink {
  void handleOpen(PushNotificationEvent event);
}

/// 封装 jpush_flutter：setup、alias 绑定、通知事件流、APNs 注册。
/// 仅 Android/iOS 可用；web/桌面平台静默禁用。
class JpushGateway {
  JpushGateway({JPushFlutterInterface? jpush}) : _jpush = jpush ?? JPush.newJPush();

  final JPushFlutterInterface _jpush;
  bool _initialized = false;
  bool _available = false;

  /// 通知到达（前台）事件流。
  final _onReceive = StreamController<PushNotificationEvent>.broadcast();
  /// 通知点击事件流（含冷启动后缓存的点击）。
  final _onOpen = StreamController<PushNotificationEvent>.broadcast();

  Stream<PushNotificationEvent> get onReceiveNotification => _onReceive.stream;
  Stream<PushNotificationEvent> get onOpenNotification => _onOpen.stream;

  bool get isAvailable => _available;

  /// 必须最先调用：注册事件回调（在 setup 之前）→ setup → 标记可用。
  Future<void> init() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _available = _supportsPushOnThisPlatform;

    if (!_available) {
      return;
    }

    _jpush.addEventHandler(
      onReceiveNotification: (message) {
        _onReceive.add(_parseEvent(message));
      },
      onOpenNotification: (message) {
        _onOpen.add(_parseEvent(message));
      },
    );

    if (jpushAppKey.isEmpty) {
      return; // 未配置 AppKey：保持禁用，不调用 setup
    }

    await _jpush.setup(
      appKey: jpushAppKey,
      channel: 'developer-default',
      production: const bool.fromEnvironment('dart.vm.product'),
      debug: kDebugMode,
    );
  }

  /// 登录后绑定用户别名（alias = Lucent userId）。极光自动建立
  /// alias → 设备映射，同一用户多设备共享一个 alias。
  /// 失败仅记录日志，下次登录会再次绑定。
  Future<void> setAlias(String userId) async {
    if (!_available || jpushAppKey.isEmpty) {
      return;
    }
    final result = await _jpush.setAlias(userId);
    final code = result is Map ? result['code'] : null;
    if (code is int && code != 0) {
      debugPrint('JPush setAlias failed: code=$code, msg=${result?['msg']}');
    }
  }

  /// 退出登录解绑别名。
  Future<void> deleteAlias() async {
    if (!_available || jpushAppKey.isEmpty) {
      return;
    }
    await _jpush.deleteAlias();
  }

  /// iOS：注册 APNs（若系统权限已授予则静默注册，不重复弹窗）。
  /// Android：通知权限由现有 permission_handler 流程统一管理，无需额外调用。
  Future<void> ensureApnsRegistered() async {
    if (!_available || jpushAppKey.isEmpty) {
      return;
    }
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return; // 仅 iOS 需要
    }
    await _jpush.applyPushAuthority(
      const NotificationSettingsIOS(sound: true, alert: true, badge: true),
    );
  }

  /// iOS：获取点击通知冷启动应用的那条通知；Android 由缓存事件流覆盖。
  Future<PushNotificationEvent?> launchNotification() async {
    if (!_available || defaultTargetPlatform != TargetPlatform.iOS) {
      return null;
    }
    final raw = await _jpush.getLaunchAppNotification();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return _parseEvent(raw);
  }

  void dispose() {
    _onReceive.close();
    _onOpen.close();
  }

  bool get _supportsPushOnThisPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// 归一化 JPush 消息 Map；extras 兼容「JSON 字符串」与「Map」两种形态。
  static PushNotificationEvent _parseEvent(Map<dynamic, dynamic> raw) {
    var extras = raw['extras'];
    if (extras is String && extras.isNotEmpty) {
      try {
        final decoded = jsonDecode(extras);
        if (decoded is Map<String, dynamic>) {
          extras = decoded;
        }
      } catch (_) {
        extras = null;
      }
    }
    return PushNotificationEvent(
      title: raw['title']?.toString() ?? '',
      body: raw['content']?.toString() ?? '',
      extras: extras is Map<String, dynamic> ? extras : null,
    );
  }
}

/// `main()` 中提前初始化的全局单例；provider 复用同一实例，保证
/// 冷启动时 `runApp` 之前注册的事件回调与 app 内订阅的是同一对象。
final jpushGatewaySingleton = JpushGateway();

final jpushGatewayProvider = Provider<JpushGateway>((ref) {
  ref.onDispose(jpushGatewaySingleton.dispose);
  return jpushGatewaySingleton;
});
```

- [ ] **Step 2: 运行 analyze**

Run: `flutter analyze lib/core/push/`
Expected: 无错误（`NotificationSettingsIOS`、`addEventHandler`、`setAlias`、`deleteAlias`、`getLaunchAppNotification` 等 API 以 `jpush_flutter` 3.4.5 文档为准，若个别签名不同按实际修正并保持语义一致）。

- [ ] **Step 3: Commit**

```bash
git -C Luminous add lib/core/push/jpush_gateway.dart
git -C Luminous commit -m "feat(push): 封装极光推送网关（alias 绑定）"
```

---

### Task 3: 推送消息处理与路由

**Files:**
- Create: `lib/core/push/message_handler.dart`

> 命名说明：目录 `push/` 已表明域，文件名 `message_handler` 表明职责，不重复 `push_` 前缀。

- [ ] **Step 1: 新建 `lib/core/push/message_handler.dart`**

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/push/jpush_gateway.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';

/// 通知点击的默认落地路由。后续可按 `event.extras['action']` 细化为具体页面。
String routeForPushEvent(PushNotificationEvent event) {
  final action = event.extras?['action'];
  return switch (action) {
    // 用药提醒等业务动作 v1 统一进站内通知列表，后续逐类细化。
    _ => Routes.notifications,
  };
}

/// 订阅极光事件流：点击 → 路由；到达 → 刷新未读数。
class PushMessageHandler implements PushEventSink {
  PushMessageHandler(
    this._ref, {
    required JpushGateway gateway,
  }) {
    _subs.add(gateway.onOpenNotification.listen(handleOpen));
    _subs.add(gateway.onReceiveNotification.listen(handleReceive));
  }

  final Ref _ref;
  final List<StreamSubscription<PushNotificationEvent>> _subs = [];

  void handleOpen(PushNotificationEvent event) {
    _ref.invalidate(notificationUnreadCountProvider);
    _ref.read(appRouterProvider).go(routeForPushEvent(event));
  }

  void handleReceive(PushNotificationEvent event) {
    _ref.invalidate(notificationUnreadCountProvider);
  }

  void dispose() {
    for (final sub in _subs) {
      unawaited(sub.cancel());
    }
  }
}

final pushMessageHandlerProvider = Provider<PushMessageHandler>((ref) {
  final handler = PushMessageHandler(
    ref,
    gateway: ref.watch(jpushGatewayProvider),
  );
  ref.onDispose(handler.dispose);
  return handler;
});
```

- [ ] **Step 2: 运行 analyze**

Run: `flutter analyze lib/core/push/message_handler.dart`
Expected: 无错误（`notificationUnreadCountProvider` 所在文件路径以实际为准，若在 `providers/unread_count.dart` 而非 `data/providers/`，按实际 import 修正）。

- [ ] **Step 3: Commit**

```bash
git -C Luminous add lib/core/push/message_handler.dart
git -C Luminous commit -m "feat(push): 推送点击路由与未读刷新处理"
```

---

### Task 4: 生命周期编排与启动接线

**Files:**
- Create: `lib/core/push/lifecycle.dart`
- Modify: `lib/main.dart`
- Modify: `lib/app/bootstrap.dart`

> 命名说明：目录 `push/` 已表明域，文件名 `lifecycle` 表明职责（推送生命周期编排），不重复 `push_` 前缀；类名保持 `PushCoordinator`（命名规则只约束文件名）。

- [ ] **Step 1: 新建 `lib/core/push/lifecycle.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/push/jpush_gateway.dart';
import 'package:luminous/core/push/message_handler.dart';

/// 推送生命周期编排：启动初始化、登录态变化时绑定/解绑 alias。
class PushCoordinator {
  PushCoordinator({
    required JpushGateway gateway,
    required PushEventSink eventSink,
  })  : _gateway = gateway,
        _eventSink = eventSink;

  final JpushGateway _gateway;
  final PushEventSink _eventSink;

  bool _started = false;

  /// 启动时调用（app 首帧后）：处理 iOS 冷启动点击。
  /// 事件流订阅由 [pushMessageHandlerProvider] 在 provider 图中创建时完成。
  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;

    final launch = await _gateway.launchNotification();
    if (launch != null) {
      _eventSink.handleOpen(launch);
    }
  }

  /// 登录态变化：登录绑定 alias（并注册 iOS APNs），退出解绑 alias。
  Future<void> onAuthChanged({
    required bool authenticated,
    required String userId,
  }) async {
    if (!_gateway.isAvailable) {
      return;
    }
    if (authenticated) {
      // iOS 注册 APNs（权限已授予时静默注册）；Android 不额外弹窗。
      await _gateway.ensureApnsRegistered();
      await _gateway.setAlias(userId);
    } else {
      await _gateway.deleteAlias();
    }
  }
}

final pushCoordinatorProvider = Provider<PushCoordinator>((ref) {
  return PushCoordinator(
    gateway: ref.watch(jpushGatewayProvider),
    eventSink: ref.watch(pushMessageHandlerProvider),
  );
});
```

- [ ] **Step 2: 在 `main.dart` 的 `main()` 中提前初始化网关**（`runApp` 之前，`WidgetsFlutterBinding.ensureInitialized()` 之后）

```dart
  // 极光推送：SDK 初始化须在 runApp 之前，以捕获冷启动点击事件。
  await _initPush();
```

在文件内新增：

```dart
/// 初始化极光推送网关（无 AppKey 时静默禁用）。
Future<void> _initPush() async {
  try {
    await jpushGatewaySingleton.init();
  } catch (e, st) {
    debugPrint('⚠️ JPush init failed: $e\n$st');
  }
}
```

并在 import 区加入 `package:luminous/core/push/jpush_gateway.dart`。

> 说明：`jpushGatewaySingleton` 已在 Task 2 的网关文件中定义，`main()` 初始化与 app 内 provider 引用的是同一实例；`init()` 幂等，重复调用安全。

- [ ] **Step 3: 在 `bootstrap.dart` 的认证监听中接入 alias 绑定/解绑**

在 `_LuminousAppState.initState` 的 `addPostFrameCallback` 内、`authSessionProvider.restore()` 之后追加：

```dart
      unawaited(ref.read(pushCoordinatorProvider).start());
```

在 `ref.listen<AuthSessionState>(authSessionProvider, ...)` 中：退出分支（`previous?.isAuthenticated == true && !next.isAuthenticated`）内追加：

```dart
        unawaited(
          ref
              .read(pushCoordinatorProvider)
              .onAuthChanged(authenticated: false, userId: previous.user!.id),
        );
```

在 `becameAuthenticated` / `switchedUser` 分支（`_restoreLocaleFromProfile()` 调用处）追加：

```dart
      unawaited(
        ref
            .read(pushCoordinatorProvider)
            .onAuthChanged(authenticated: true, userId: next.user!.id),
      );
```

并在 import 区加入 `package:luminous/core/push/lifecycle.dart`。

- [ ] **Step 4: 重新生成 API 客户端**（后端已删除 user-devices 契约）

Run: `dart run scripts/bootstrap_generated_sources.dart`
Expected: `generated/lucent_api` 中 `UserDevicesApi`、`RegisterDeviceDto`、`UserDevicePlatform` 等不再生成（`UserDevicePlatform` 若因 session 相关 DTO 残留则保留，无需处理）；`flutter analyze` 无因删除引发的未使用引用报错。

- [ ] **Step 5: 运行 analyze 与全量检查**

Run: `flutter analyze`
Expected: 无错误。

- [ ] **Step 6: Commit**

```bash
git -C Luminous add lib/core/push/lifecycle.dart lib/main.dart lib/app/bootstrap.dart lib/core/push/jpush_gateway.dart lib/core/push/message_handler.dart generated/lucent_api
git -C Luminous commit -m "feat(push): 启动初始化与登录态 alias 绑定接线"
```

---

### Task 5: 测试与文档

**Files:**
- Create: `test/core/push/message_handler_test.dart`
- Create: `test/core/push/lifecycle_test.dart`
- Modify: `docs/03-logs/migration-log/2026-08-03.md`（追加）
- Modify: `docs/00-current/Current_State.md`（如含推送状态描述则同步）

- [ ] **Step 1: 新建 `test/core/push/message_handler_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/push/jpush_gateway.dart';
import 'package:luminous/core/push/message_handler.dart';

void main() {
  group('routeForPushEvent', () {
    test('默认跳转站内通知列表', () {
      const event = PushNotificationEvent(title: 't', body: 'b');
      expect(routeForPushEvent(event), '/notifications');
    });

    test('带 action 的提醒类消息 v1 也进通知列表', () {
      const event = PushNotificationEvent(
        title: 't',
        body: 'b',
        extras: <String, dynamic>{'action': 'medicine_reminder'},
      );
      expect(routeForPushEvent(event), '/notifications');
    });
  });
}
```

- [ ] **Step 2: 新建 `test/core/push/lifecycle_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/push/jpush_gateway.dart';
import 'package:luminous/core/push/lifecycle.dart';

class FakeGateway extends JpushGateway {
  FakeGateway({this.available = true});

  final bool available;
  final aliases = <String>[];
  bool deleted = false;
  bool apnsRegistered = false;

  @override
  bool get isAvailable => available;

  @override
  Future<void> setAlias(String userId) async {
    aliases.add(userId);
  }

  @override
  Future<void> deleteAlias() async {
    deleted = true;
  }

  @override
  Future<void> ensureApnsRegistered() async {
    apnsRegistered = true;
  }
}

class FakeSink implements PushEventSink {
  final opened = <PushNotificationEvent>[];

  @override
  void handleOpen(PushNotificationEvent event) {
    opened.add(event);
  }
}

void main() {
  group('PushCoordinator.onAuthChanged', () {
    test('登录时注册 APNs 并绑定 alias=userId', () async {
      final gateway = FakeGateway();
      final coordinator = PushCoordinator(
        gateway: gateway,
        eventSink: FakeSink(),
      );

      await coordinator.onAuthChanged(authenticated: true, userId: 'user-1');

      expect(gateway.apnsRegistered, isTrue);
      expect(gateway.aliases, ['user-1']);
      expect(gateway.deleted, isFalse);
    });

    test('退出时解绑 alias', () async {
      final gateway = FakeGateway();
      final coordinator = PushCoordinator(
        gateway: gateway,
        eventSink: FakeSink(),
      );

      await coordinator.onAuthChanged(authenticated: false, userId: 'user-1');

      expect(gateway.deleted, isTrue);
      expect(gateway.aliases, isEmpty);
    });

    test('推送不可用时不做任何操作', () async {
      final gateway = FakeGateway(available: false);
      final coordinator = PushCoordinator(
        gateway: gateway,
        eventSink: FakeSink(),
      );

      await coordinator.onAuthChanged(authenticated: true, userId: 'user-1');

      expect(gateway.aliases, isEmpty);
      expect(gateway.apnsRegistered, isFalse);
    });
  });
}
```

- [ ] **Step 3: 运行测试**

Run: `flutter test test/core/push/`
Expected: PASS（两个测试文件全绿）

- [ ] **Step 4: 运行文档检查工具确认要更新的文档**

Run: `dart run scripts/check_doc_coverage.dart --warning-only`
Expected: 输出 per-rule 报告；按报告更新（至少包括 migration log）。

- [ ] **Step 5: 追加迁移日志** `docs/03-logs/migration-log/2026-08-03.md`

```markdown
## 极光推送客户端集成

- 新增 `lib/core/push/`：`jpush_gateway`、`message_handler`、`lifecycle`。
- `main()` 提前初始化 JPush SDK；登录 `setAlias(userId)`、退出 `deleteAlias()`（极光推荐最佳实践）。
- 通知点击统一路由到 `/notifications`，到达刷新未读数；本地提醒链路不变。
- 随后端删除 user-devices 契约，重新生成 `generated/lucent_api`。
- 未新增可见文案，无需更新 Localization。
```

- [ ] **Step 6: 更新当前状态文档**（如 `docs/00-current/Current_State.md` 或对应子文件描述了消息推送现状，删除“仅离线/未接推送”相关旧描述）

- [ ] **Step 7: 全量验证**

Run: `flutter analyze` 和 `flutter test`
Expected: 全部通过。

- [ ] **Step 8: Commit**

```bash
git -C Luminous add test/core/push/ docs/03-logs/migration-log/2026-08-03.md docs/00-current/Current_State.md
git -C Luminous commit -m "test(push): alias 绑定与消息路由单测及文档同步"
```

---

## 验证清单（全部通过后计划文件可删除）

- [ ] `flutter analyze` 无错误
- [ ] `flutter test` 全绿（含新增 `test/core/push/`）
- [ ] 真机验证 Android：登录 → 极光后台看到 userId 对应的 alias 绑定 → 后端 `sendToUser` 触发 → 前台 toast/后台通知栏/终止态点击均正确跳转 `/notifications`
- [ ] 真机验证 iOS：首次登录调用 `applyPushAuthority` 注册 APNs → 收到推送（注意生产/沙箱证书与后端 `JPUSH_APNS_PRODUCTION` 匹配）
- [ ] 退出登录 → 极光后台该 alias 解除绑定；同账号其他设备不受影响
- [ ] 未配置 AppKey（`--dart-define` 缺失）时 app 正常启动、无异常日志
- [ ] `generated/lucent_api` 无 `UserDevicesApi` 残留

## 后续迭代（不在本次范围）

- 按 `extras.action` 细化路由（用药提醒直达提醒详情等）
- Android 厂商通道（华为/小米/OPPO/vivo）接入 `fl_jpush-android` 插件 + 各厂商开发者账号配置
- 用户级推送开关（原设备级 `notificationsEnabled` 语义迁移为用户设置，推送前由后端检查）
