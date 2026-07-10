# ADR-0006: riverpod_generator 与 Auth-Guarded Provider 工厂

- **Status**: accepted
- **Date**: 2026-07-10
- **Deciders**: LuoMuLoyal

## Context

ADR-0001 确立了 Riverpod 作为唯一状态管理方案。经过两个月的快速迭代，provider 层暴露出三个结构性问题：

### 1. Provider 声明样板过多

每个 feature 重复 datasource → repository → provider 三层管道，且 `network_providers.dart`
中有 15+ 个完全同构的 API provider，每个只是 `ref.watch(lucentDioClientProvider).xxxApi`
的一行包装：

```dart
// 这段模式在 7 个 feature 中重复出现
final xxxRemoteDataSourceProvider = Provider<XxxRemoteDataSource>((ref) {
  final api = ref.watch(lucentXxxApiProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;
  return XxxRemoteDataSource(api: api, dio: dio);
});
final xxxRepositoryProvider = Provider<XxxRepository>((ref) {
  final dataSource = ref.watch(xxxRemoteDataSourceProvider);
  return LucentXxxRepository(dataSource: dataSource);
});

// network_providers.dart 中 15+ 个完全同构的 provider
final lucentAuthApiProvider = Provider<AuthApi>((ref) {
  return ref.watch(lucentDioClientProvider).authApi;
});
final lucentHealthApiProvider = Provider<HealthApi>((ref) {
  return ref.watch(lucentDioClientProvider).healthApi;
});
// ... 重复 15 次
```

### 2. Provider 类型选型不统一

TODO 明确记录 `FutureProvider`（7 个）和 `AsyncNotifierProvider`（5 个）未统一。缺乏
明确的选型标准：何时用 `FutureProvider`、何时用 `AsyncNotifierProvider`、何时加
`autoDispose`、何时用 `family`。

### 3. Auth session 检查散落

多个数据 provider 重复相同的 auth guard 模式：

```dart
// 在 mine、report、today、health_context 等至少 5 处重复
final session = ref.watch(authSessionProvider);
if (session.isLoading) return pendingAuthSessionResolution();
if (!session.canAccessProtectedData) return ...;
```

## Decision

### 6.1 引入 `riverpod_generator`

使用 `@riverpod` 注解替代手写 provider 声明。所有新 provider 必须使用注解形式；存量
provider 在触碰时迁移。

```dart
@riverpod
LucentDioClient lucentDioClient(LucentDioClientRef ref) { ... }

@riverpod
AuthApi authApi(AuthApiRef ref) {
  return ref.watch(lucentDioClientProvider).authApi;
}

@Riverpod(keepAlive: true)
TodaySuggestionNotifier todaySuggestionNotifier(TodaySuggestionNotifierRef ref) { ... }
```

代码生成会自动：
- 推导 provider 名称（函数名 → camelCase + `Provider` 后缀）
- 默认添加 `autoDispose`（通过 `@Riverpod(keepAlive: true)` 显式保留）
- 支持 family 参数类型推断
- 生成类型安全的 `Ref` 子类（如 `AuthApiRef`）

### 6.2 统一 Provider 选型标准

| 场景 | Provider 类型 | autoDispose | 示例 |
|------|-------------|-------------|------|
| 纯 DI / 无状态服务 | `@riverpod` | 默认 autoDispose | `authApiProvider`、`dioClientProvider` |
| 只读异步数据（无 mutation） | `@riverpod` 返回 `Future<T>` | 默认 autoDispose | `mineDashboardProvider` |
| 带 mutation 的异步状态 | `@Riverpod(keepAlive: true)` AsyncNotifier | keepAlive | `todaySuggestionProvider` |
| 跨 feature 共享的根级服务 | `@Riverpod(keepAlive: true)` | keepAlive | `dioClientProvider`、`sessionStoreProvider` |
| 参数化只读 | `@riverpod` 带 family 参数 | 默认 autoDispose | `dailyRecordDetailProvider(id)` |

### 6.3 提取 `authGuardedFutureProvider` 工厂

```dart
/// 创建一个受 auth session 保护的 FutureProvider。
///
/// - session 正在恢复 → 返回 pending future（不触发 error/loading）
/// - session 确认未登录 → 返回 signedOutFallback（如有）
/// - session 已登录 → 执行 fetch
@riverpod
Future<T> authGuarded<T>(
  AuthGuardedRef<T> ref, {
  required Future<T> Function() fetch,
  Future<T> Function()? signedOutFallback,
}) async {
  final session = ref.watch(authSessionProvider);
  if (session.isRestoring) return pendingAuthSessionResolution();
  if (!session.canAccessProtectedData) {
    if (signedOutFallback != null) return signedOutFallback();
    throw const AuthRequiredException();
  }
  return fetch();
}
```

各 feature 的数据 provider 改为：

```dart
@riverpod
Future<MineDashboard> mineDashboard(MineDashboardRef ref) {
  return ref.watch(authGuardedProvider(
    fetch: () => ref.watch(mineRepositoryProvider).fetchDashboard(),
    signedOutFallback: () => ref.watch(mineRepositoryProvider).signedOutDashboard,
  ).future);
}
```

## Options Considered

### 保持手写 Provider 声明

- Pros: 零新依赖，无 codegen 步骤
- Cons: 样板持续增长，autoDispose 遗漏风险，无编译时 provider 名称检查

### 引入 `riverpod_generator`（本方案）

- Pros: 编译时安全，减少 ~30% provider 样板，自动 autoDispose，IDE 跳转支持更好
- Cons: 增加 `build_runner` 运行（项目已有 freezed/json_serializable 依赖，无额外基础设施成本）

### 迁移到 Bloc

- Pros: 事件/状态分离更明确
- Cons: 推翻 ADR-0001，全量重写，学习成本高，与 hooks_riverpod 集成断裂

## Consequences

- 新增 `riverpod_generator` + `riverpod_annotation` 到 `dev_dependencies`。
- `build_runner` 已存在于项目 dev_dependencies，无新增基础设施。
- `bootstrap_generated_sources.dart` 需增加 riverpod codegen 步骤（已有 freezed/json_serializable
  的 build_runner 流程，新增 `*.g.dart` 产物）。
- 存量 provider 不强制一次性迁移；新代码必须使用注解形式，触碰旧文件时逐步迁移。
- `network_providers.dart` 中的 15+ API provider 可通过注解简化，但不优先（它们已经能工作）。
- `authGuardedFutureProvider` 消除至少 5 处重复 auth guard 逻辑。
- Provider 选型标准写入本文档作为 ADR 引用，不再在 TODO 中追踪。
