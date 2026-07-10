# ADR-0010: 类型安全路由 — go_router_builder

- **Status**: proposed
- **Date**: 2026-07-10
- **Deciders**: LuoMuLoyal

## Context

ADR-0002 确立了 GoRouter 作为导航方案。当前路由存在三个问题：

### 1. 路径参数无类型安全

路由跳转依赖手动拼接字符串：

```dart
// 现状：手动拼接，无编译时检查
context.push('/record/$id');
context.push('/medicine/reminders/$medicineId');
context.push('/mine/allergy/$allergyId/edit');
```

`GoRoute(path: '/record/:id')` 中的 `:id` 是字符串，但实际期望是 UUID 或特定格式。
参数名拼写错误、参数遗漏、类型不匹配都无法在编译时发现。

### 2. 路由常量分散且不完整

`AppRoutes` 定义了路径常量，但：

- 带参数的路由只能定义 base path（如 `recordDetail = '/record'`），实际使用时仍需拼接
- 15 个路由文件各自导出 `List<RouteBase>` 常量，`router.dart` 用 spread 合并
  （去前缀化后文件名为 `auth.dart`、`record.dart` 等，不带 `router_` 前缀）
- 查询参数（如 `?kind=sleep`）完全没有类型安全
- `GoRoute` 的 `pageBuilder` 与路由定义绑定，无法复用页面构建逻辑

### 3. 路由守卫与重定向逻辑内联

auth 重定向逻辑在 `GoRouter` 的 `redirect` 回调中手写，无法基于路由类型做差异化守卫。

## Decision

### 10.1 引入 `go_router_builder`

使用官方 `go_router_builder` 包，通过 `@TypedGoRoute` 注解声明路由，代码生成器自动
注册路由并生成类型安全的跳转方法。

```yaml
# pubspec.yaml dev_dependencies
go_router_builder: ^2.7.0
```

### 10.2 路由声明方式

每个路由定义为一个继承 `GoRouteData` 的类：

```dart
// lib/features/record/presentation/routes.dart
@TypedGoRoute<RecordDetailRoute>(path: '/record/:id')
class RecordDetailRoute extends GoRouteData {
  const RecordDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RecordDetailPage(id: id);
  }
}

@TypedGoRoute<RecordCreateRoute>(path: '/record/create')
class RecordCreateRoute extends GoRouteData {
  const RecordCreateRoute({this.kind});

  final RecordEntryKind? kind;  // 查询参数，自动从 URL 解析

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RecordCreatePage(initialKind: kind);
  }
}
```

### 10.3 类型安全的导航

```dart
// 旧：context.push('/record/$id');
// 新：
RecordDetailRoute(id: recordId).push(context);

// 旧：context.go('/record/create?kind=sleep');
// 新：
const RecordCreateRoute(kind: RecordEntryKind.sleep).go(context);
```

- 参数类型在编译时检查（`id` 必须是 `String`，`kind` 必须是 `RecordEntryKind?`）
- 参数遗漏会编译报错（必填参数未提供）
- 查询参数自动序列化/反序列化
- 路径参数自动 URL 编码

### 10.4 Shell 路由保持不变

`StatefulShellRoute.indexedStack` 的五个 tab 根路由保持手写声明（`go_router_builder`
对 shell route 的支持有限）。只有 shell 外的 top-level routes 使用 `@TypedGoRoute`。

### 10.5 路由注册自动化

`router.dart` 从手写 spread 合并改为自动收集生成的路由：

```dart
final router = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(...),  // 五个 tab，保持手写
    ...$appRoutes,  // go_router_builder 生成的所有 @TypedGoRoute
  ],
);
```

### 10.6 `AppRoutes` 常量保留

`AppRoutes` 常量类保留用于：
- shell tab 路径（`/`、`/record`、`/medicine`、`/report`、`/mine`）
- 需要在非导航场景下引用路径字符串的地方（如 deep link 校验）

子页面路径不再需要手写常量，由 `@TypedGoRoute` 的 `path` 属性自动管理。

## Options Considered

### `go_router_builder`（本方案）

- Pros: 官方维护，与 `go_router` 天然集成，类型安全参数，查询参数自动序列化，路由
  自动注册
- Cons: codegen 步骤（项目已有 build_runner），`@TypedGoRoute` 注解有一定样板

### `auto_route`

- Pros: 功能最全（嵌套路由、守卫、tab 管理），社区活跃
- Cons: 推翻 ADR-0002 的 GoRouter 选择，全量路由重写，与 `StatefulShellRoute` 集成
  需要适配，迁移成本最高

### 保持手写路由 + `AppRoutes` 常量（现状）

- Pros: 零迁移成本
- Cons: 路径拼接错误只能运行时发现，查询参数无类型安全，路由注册分散在 15 个文件

### 自实现 `RouteData` 基类

- Pros: 无新依赖，可定制
- Cons: 重复造轮子，`go_router_builder` 已解决相同问题且官方维护

## Consequences

- 新增 `go_router_builder` 到 `dev_dependencies`（`build_runner` 已存在）。
- `lib/app/router/` 下的 10 个路由文件（`auth.dart`、`record.dart`、`medicine.dart`
  等，去前缀化前为 `router_auth.dart`、`router_record.dart`）逐步改为
  `@TypedGoRoute` 注解形式。每个 feature 在自己的 `presentation/routes.dart`
  中声明路由类，不再集中到 `lib/app/router/`。
- `router.dart` 简化：`routes: [StatefulShellRoute(...), ...$appRoutes]`。
- `AppRoutes` 常量精简为 5 个 tab 路径 + 非导航用途的路径引用。
- 所有 `context.push('/xxx/$id')` 调用改为 `XxxRoute(id: id).push(context)`。
- 路由参数类型安全：`id` 类型、查询参数枚举值在编译时检查。
- 深度链接：`go_router_builder` 自动从 URL 解析参数到类型化字段，包括查询参数。
- 存量路由不一次性迁移；新路由使用注解形式，触碰旧路由文件时迁移。
- 测试：`router_test.dart` 需更新，验证生成的路由注册与手写 shell route 共存。
- **限制**：`go_router_builder` 对 `StatefulShellRoute` 内的子路由支持有限，五个 tab
  根路由保持手写 `GoRoute` 声明，不使用注解。
