# ADR-0010: 类型安全路由 — go_router_builder

- **Status**: accepted
- **Date**: 2026-07-10
- **Deciders**: LuoMuLoyal

## Context

ADR-0002 确立了 GoRouter 作为导航方案。当前路由存在两个核心问题：

### 1. 路径参数无类型安全

路由跳转依赖手动拼接字符串：

```dart
// 现状：手动拼接，无编译时检查
context.push('/record/$id');
context.push('/medicine/reminders/$medicineId');
context.push('/mine/allergy/$allergyId/edit');
context.push(
  '/medicine/reminders/${Uri.encodeComponent(currentMedicineId)}',
);
```

`GoRoute(path: '/record/:id')` 中的 `:id` 是字符串，但实际期望是 UUID 或特定格式。
参数名拼写错误、参数遗漏、类型不匹配都无法在编译时发现。调用方还需手动
`Uri.encodeComponent`，遗漏即产生 bug。

### 2. 路由常量分散且不完整

`AppRoutes` 定义了路径常量，但：

- 带参数的路由只能定义 base path（如 `recordDetail = '/record'`），实际使用时仍需拼接
- 9 个路由文件（`auth.dart`、`record.dart`、`medicine.dart`、`mine.dart`、
  `settings.dart`、`account.dart`、`notifications.dart`、`assistant.dart`、
  `scan.dart`）各自导出 `List<RouteBase>` 常量，`router.dart` 用 spread 合并
- 查询参数（如 `?kind=sleep`、`?returnTo=/record`）完全没有类型安全
- 自定义查询参数解析（`dailyRecordKindFromName()`、`parseRecordDate()`）散落在
  `pageBuilder` 中，无法复用
- `GoRoute` 的 `pageBuilder` 与路由定义绑定，无法复用页面构建逻辑

> **注**：auth 守卫逻辑不在 `GoRouter.redirect` 中，而是由调用方通过
> `pushAuthRequiredRoute()` 和 `showAuthRequiredDialog()`（`required_dialog.dart`）
> 实现。这一模式在迁移后仍需保留——`go_router_builder` 不改变 auth 守卫的架构。

## Decision

### 10.1 引入 `go_router_builder`

使用官方 `go_router_builder` 包，通过 `@TypedGoRoute` 注解声明路由，代码生成器自动
注册路由并生成类型安全的跳转方法。

```yaml
# pubspec.yaml dev_dependencies
go_router_builder: ^4.3.0  # 兼容 go_router ^17.x；2.x/3.x API 不兼容
```

> **版本说明**：`go_router_builder` 3.0.0 引入破坏性变更——Route 类必须
> `with _$RouteName` mixin。4.0.0+ 是与 `go_router` 17.x 兼容的版本。项目中
> `go_router: ^17.2.3`，`build_runner: ^2.15.0` 已存在，无需额外添加。

### 10.2 路由声明方式

每个路由定义为一个继承 `GoRouteData` 并 `with _$RouteName` 的类：

```dart
// lib/features/record/presentation/routes.dart
@TypedGoRoute<RecordDetailRoute>(path: '/record/:id')
class RecordDetailRoute extends GoRouteData with _$RouteName {
  const RecordDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RecordDetailPage(recordId: id);
  }
}

@TypedGoRoute<RecordCreateRoute>(path: '/record/create')
class RecordCreateRoute extends GoRouteData with _$RouteName {
  const RecordCreateRoute({this.kind, this.date, this.time});

  final DailyRecordKind? kind;  // 查询参数，自动从 URL 解析
  final DateTime? date;          // 通过 @TypedQueryParameter 自定义解码
  final String? time;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RecordCreatePage(
      initialKind: kind,
      initialDate: date,
      initialTime: time,
    );
  }
}
```

### 10.3 页面过渡动画

`GoRouteData.build()` 返回 `Widget` 时，`go_router` 使用默认 `MaterialPage`，会丢失
当前 `helpers.dart` 中的自定义过渡动画。因此 **所有路由类应覆写 `buildPage()`**
（或 `buildPageWithState()`）而非 `build()`，复用现有的 `fadePage` / `slidePage`：

```dart
@TypedGoRoute<RecordDetailRoute>(path: '/record/:id')
class RecordDetailRoute extends GoRouteData with _$RouteName {
  const RecordDetailRoute({required this.id});

  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    // 复用 helpers.dart 中的 slidePage
    return slidePage(key: state.pageKey, child: RecordDetailPage(recordId: id));
  }
}
```

过渡动画映射策略：

| 路由类别 | 过渡 | 当前 helper | 对应路由 |
|----------|------|-------------|----------|
| Auth 路由 | fade | `fadePage()` | login, register, forgot-password, oauth 回调 |
| CRUD 子页面 | slide | `slidePage()` | record create/detail/edit, mine edit, medicine reminder, settings, assistant, scan, notifications |
| Shell tab | 无过渡 | `NoTransitionPage` | today, record, medicine, report, mine（保持手写，不迁移） |

`helpers.dart` 中的 `fadePage` / `slidePage` 保持不变，被生成的路由类引用。

### 10.4 自定义查询参数反序列化

当前 `record.dart` 路由通过自定义函数解析查询参数：

```dart
// 现状：手动解析
RecordCreatePage(
  initialKind: dailyRecordKindFromName(state.uri.queryParameters['kind']),
  initialDate: parseRecordDate(state.uri.queryParameters['date']),
  initialTime: state.uri.queryParameters['time'],
)
```

`go_router_builder` 4.1.0+ 原生支持 `fromJson`/`toJson` 类型（包括枚举），4.3.0 新增
`@TypedQueryParameter` 注解，允许指定自定义 encoder/decoder：

```dart
@TypedGoRoute<RecordCreateRoute>(path: '/record/create')
class RecordCreateRoute extends GoRouteData with _$RouteName {
  const RecordCreateRoute({this.kind, this.date, this.time});

  // 枚举：go_router_builder 自动使用 .name 序列化/反序列化
  final DailyRecordKind? kind;

  // DateTime：通过 @TypedQueryParameter 指定自定义编解码
  @TypedQueryParameter(
    encoder: encodeRecordDate,
    decoder: decodeRecordDate,
  )
  final DateTime? date;

  final String? time;

  // ...buildPage...
}

String encodeRecordDate(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

DateTime? decodeRecordDate(String? value) =>
    value == null ? null : parseRecordDate(value);
```

> `dailyRecordKindFromName()` 的逻辑若与 `DailyRecordKind` 的 `.name` 一致，则直接
> 使用枚举自动解析；若映射关系不一致（如大小写、别名），也用 `@TypedQueryParameter`
> 指定自定义编解码。

### 10.5 嵌套路由

当前 `settings.dart` 使用多层嵌套 `GoRoute`（`/settings` → `/notifications` →
`/sleep`、`/dnd` 等，共 12 个子路由），`notifications.dart` 也有嵌套
（`/notifications` → `/:id`）。

`go_router_builder` 通过 `@TypedGoRoute` 的 `routes` 参数声明嵌套：

```dart
@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with _$RouteName {
  const SettingsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      slidePage(key: state.pageKey, child: const SettingsPage());

  // 嵌套子路由——每个子路由需单独声明为 GoRouteData 子类
  static const routes = <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<SettingsLanguageRoute>(path: 'language'),
    TypedGoRoute<SettingsThemeRoute>(path: 'theme'),
    TypedGoRoute<SettingsMoreRoute>(
      path: 'more',
      routes: [
        TypedGoRoute<SettingsFeatureFlagsRoute>(path: 'feature-flags'),
      ],
    ),
    TypedGoRoute<SettingsNotificationsRoute>(
      path: 'notifications',
      routes: [
        TypedGoRoute<SettingsNotificationsSleepRoute>(path: 'sleep'),
        TypedGoRoute<SettingsNotificationsDndRoute>(path: 'dnd'),
      ],
    ),
    // ...其余子路由
  ];
}

@TypedGoRoute<SettingsLanguageRoute>(path: 'language')
class SettingsLanguageRoute extends GoRouteData with _$RouteName {
  const SettingsLanguageRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      slidePage(key: state.pageKey, child: const LanguageSettingsPage());
}
```

> **迁移策略**：settings 的 12 个嵌套子路由是迁移工作量最大的一块。建议作为最后一个
> 迁移目标，先迁移无嵌套的 top-level 路由（record、mine、medicine、auth、account、
> assistant、scan），验证模式后再处理嵌套结构。

### 10.6 多文件路由聚合

路由类分散到各 feature 的 `presentation/routes.dart` 后，`router.dart` 需要显式 import
并合并。每个 `routes.dart` 文件经 `build_runner` 生成后，会导出对应的
`$routeNames` 和路由常量。聚合方式：

```dart
// lib/app/router.dart
import 'package:go_router/go_router.dart';
// ...shell imports...

import '../features/auth/presentation/routes.dart' as auth_routes;
import '../features/record/presentation/routes.dart' as record_routes;
import '../features/medicine/presentation/routes.dart' as medicine_routes;
import '../features/mine/presentation/routes.dart' as mine_routes;
import '../features/settings/presentation/routes.dart' as settings_routes;
import '../features/account/presentation/routes.dart' as account_routes;
import '../features/notification/presentation/routes.dart' as notification_routes;
import '../features/assistant/presentation/routes.dart' as assistant_routes;
import '../features/scan/presentation/routes.dart' as scan_routes;

final router = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(...),  // 五个 tab，保持手写
    // 逐文件导入生成的路由
    ...auth_routes.$routes,
    ...record_routes.$routes,
    ...medicine_routes.$routes,
    ...mine_routes.$routes,
    ...settings_routes.$routes,
    ...account_routes.$routes,
    ...notification_routes.$routes,
    ...assistant_routes.$routes,
    ...scan_routes.$routes,
  ],
);
```

> **不使用**全局 `$appRoutes` 自动收集——多个独立 library 无法合并为单个生成变量。
> 逐文件 import 更显式、可审计，且与当前 `...authRoutes` spread 模式一致。

### 10.7 类型安全的导航

```dart
// 旧：context.push('/record/$id');
// 新：
RecordDetailRoute(id: recordId).push(context);

// 旧：context.go('/record/create?kind=sleep');
// 新：
const RecordCreateRoute(kind: DailyRecordKind.sleep).go(context);

// 旧：context.push('/medicine/reminders/${Uri.encodeComponent(id)}');
// 新：
MedicineReminderDetailRoute(medicineId: id).push(context);
// 路径参数自动 URL 编码，无需手动 Uri.encodeComponent
```

- 参数类型在编译时检查（`id` 必须是 `String`，`kind` 必须是 `DailyRecordKind?`）
- 参数遗漏会编译报错（必填参数未提供）
- 查询参数自动序列化/反序列化
- 路径参数自动 URL 编码

### 10.8 Shell 路由保持不变

`StatefulShellRoute.indexedStack` 的五个 tab 根路由保持手写声明（`go_router_builder`
对 shell route 的支持有限，且当前 shell 不需要类型安全导航——tab 切换用
`context.go(AppRoutes.home)` 等常量即可）。只有 shell 外的 top-level routes 使用
`@TypedGoRoute`。

### 10.9 `AppRoutes` 常量保留

`AppRoutes` 常量类保留用于：
- shell tab 路径（`/`、`/record`、`/medicine`、`/report`、`/mine`）
- 需要在非导航场景下引用路径字符串的地方（如 deep link 校验、
  `action_route_mapper.dart` 的后端 action → 路由映射、OAuth 回调 URI 构建）

子页面路径不再需要手写常量，由 `@TypedGoRoute` 的 `path` 属性自动管理。

## Options Considered

### `go_router_builder`（本方案）

- Pros: 官方维护，与 `go_router` 天然集成，类型安全参数，查询参数自动序列化（4.3.0
  支持 `@TypedQueryParameter` 自定义编解码），路由自动注册
- Cons: codegen 步骤（项目已有 build_runner），`@TypedGoRoute` 注解有一定样板，
  嵌套路由声明较冗长，3.0.0 引入 `_$RouteName` mixin 要求

### `auto_route`

- Pros: 功能最全（嵌套路由、守卫、tab 管理），社区活跃
- Cons: 推翻 ADR-0002 的 GoRouter 选择，全量路由重写，与 `StatefulShellRoute` 集成
  需要适配，迁移成本最高

### 保持手写路由 + `AppRoutes` 常量（现状）

- Pros: 零迁移成本
- Cons: 路径拼接错误只能运行时发现，查询参数无类型安全，路由注册分散在 9 个文件

### 自实现 `RouteData` 基类

- Pros: 无新依赖，可定制
- Cons: 重复造轮子，`go_router_builder` 已解决相同问题且官方维护

## Consequences

### 新增与变更

- 新增 `go_router_builder: ^4.3.0` 到 `dev_dependencies`（`build_runner` 已存在）。
- `lib/app/router/` 下的 9 个路由文件逐步改为 `@TypedGoRoute` 注解形式。每个 feature
  在自己的 `presentation/routes.dart` 中声明路由类，不再集中到 `lib/app/router/`。
- `router.dart` 简化：`routes: [StatefulShellRoute(...), ...auth_routes.$routes, ...]`。
- `AppRoutes` 常量精简为 5 个 tab 路径 + 非导航用途的路径引用。
- 所有 `context.push('/xxx/$id')` 调用改为 `XxxRoute(id: id).push(context)`。
- 路由参数类型安全：`id` 类型、查询参数枚举值在编译时检查。
- 深度链接：`go_router_builder` 自动从 URL 解析参数到类型化字段，包括查询参数。
- 存量路由不一次性迁移；新路由使用注解形式，触碰旧路由文件时迁移。
- `helpers.dart` 的 `fadePage` / `slidePage` 保留，被生成的路由类的 `buildPage()` 引用。

### 受影响的辅助函数与模式

以下代码在迁移中需要适配，**不可忽略**：

| 文件 / 函数 | 当前行为 | 迁移后 |
|-------------|----------|--------|
| `required_dialog.dart` — `loginRouteForReturnTo(String returnTo)` | `Uri(path: AppRoutes.login, queryParameters: {'returnTo': returnTo}).toString()` | `LoginRoute(returnTo: returnTo).location` |
| `required_dialog.dart` — `loginRouteForCurrentLocation(context)` | 同上，returnTo 来自 `GoRouterState.of(context).uri` | 同上 |
| `required_dialog.dart` — `pushAuthRequiredRoute(context, String route)` | 接收 `String route` 参数 | 签名改为接收 `GoRouteData` 或保留 `String` 用于动态路由 |
| `action_route_mapper.dart` — `mapActionToRoute(String? action)` | 返回 `String?` 给 `context.go()` | 保留返回 `String?`——后端 action token 是动态的，无法类型化 |
| `suggestion_section.dart` / `observation_section.dart` — `_openRoute(context, String route)` | 接收后端下发的动态路由字符串 | **保留 String 签名**——后端动态路由无法类型化 |
| `mock_repository.dart` (mine) — `route: '/mine/allergy/new'` | 数据层硬编码路径 | 保留——数据层需可序列化路径，不能引用路由类 |

> **动态路由 fallback 策略**：后端下发的路由字符串（today suggestion 的 `action.route`、
> observation 的 `route` 字段）无法在编译时类型化。这些场景保留 `String` 路径 +
> `context.push(String)` / `context.go(String)` 的调用方式。`go_router` 仍能正常匹配
> `@TypedGoRoute` 注册的路由路径，只是调用方放弃编译时检查。这是可接受的折中——动态路由
> 的参数来自后端，类型安全本就无法保证。

### 路径字符串插值调用点迁移清单

以下 `context.push` / `context.go` 调用使用了字符串插值或硬编码路径，需要逐个迁移：

| 调用点 | 当前写法 | 迁移后 |
|--------|----------|--------|
| `barcode_scanner_page.dart:76,119` | `'${AppRoutes.medicineReminders}/${item.id}'` | `MedicineReminderDetailRoute(medicineId: item.id).push(context)` |
| `recognize_dialog.dart:219` | `'${AppRoutes.medicineReminders}/$id'` | 同上 |
| `report/page.dart:405` | `'/notifications/${item.id}'` | `NotificationDetailRoute(id: item.id).push(context)` |
| `record/detail.dart:95` | `'/record/$recordId/edit'` | `RecordEditRoute(id: recordId).push(context)` |
| `medicine/page.dart:193,197-199` | `'/medicine/reminders/${Uri.encodeComponent(...)}'` | `MedicineReminderDetailRoute(medicineId: ...).push(context)` |
| `reminder_detail_page.dart:103-104` | `'/medicine/reminders/${Uri.encodeComponent(...)}/edit'` | `MedicineReminderEditRoute(medicineId: ...).push(context)` |
| `advanced_settings_page.dart:178` | `'/settings/more/feature-flags'` | `SettingsFeatureFlagsRoute().push(context)` |

> 使用 `AppRoutes.xxx` 常量的无参调用（如 `context.push(AppRoutes.settings)`）可
> 同步迁移为 `SettingsRoute().push(context)`，也可暂不迁移——不影响编译，仅影响一致性。

### 测试

`router_test.dart` 需更新：
- 当前测试直接遍历 `router.configuration.routes` 做路径匹配验证。
- 生成路由的结构与手写 `GoRoute` 不同（`GoRouteData` 生成的路由内部结构由
  `go_router_builder` 控制），`_isInsideStatefulShell()` 递归逻辑可能需要适配。
- 验证生成的路由注册与手写 shell route 共存：shell tab 路径仍在
  `StatefulShellRoute` 内，子页面路径仍在 top-level。
- 建议新增测试验证类型安全导航：`RecordDetailRoute(id: '123').location` 应等于
  `/record/123`，`RecordCreateRoute(kind: DailyRecordKind.sleep).location` 应等于
  `/record/create?kind=sleep`。

### 限制

- `go_router_builder` 对 `StatefulShellRoute` 内的子路由支持有限，五个 tab 根路由
  保持手写 `GoRoute` 声明，不使用注解。
- 后端动态下发的路由字符串无法类型化，保留 `String` + `context.push(String)` fallback。
- 嵌套路由（settings 12 个子路由）迁移工作量较大，建议最后处理。
