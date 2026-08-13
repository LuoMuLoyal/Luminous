# ADR-0007: 网络层职责分离 — LucentDioClient 拆分与 API 访问简化

- **Status**: accepted
- **Date**: 2026-07-10
- **Deciders**: LuoMuLoyal

## Context

`LucentDioClient`（367 行）是当前网络层的唯一入口，同时承担六种职责：

1. **Dio 实例管理** — 创建、配置、dispose 两个 Dio 实例（主 + refresh）
2. **Token 注入拦截器** — 从 `SessionStore` 读取 access token 并注入 `Authorization` header
3. **401 刷新逻辑** — 检测 token 过期、调用 refresh 端点、重试原请求、刷新去重
4. **错误映射** — 将 `DioException` + envelope 解析为 `LucentApiException`
5. **Session 读写代理** — `writeSession`、`readAccessToken`、`readRefreshToken`、`clearSession`
   直接转发给 `SessionStore`
6. **15+ API getter** — `healthApi`、`accountApi`、`authApi`... 每个只是 `_client.xxx` 的
   一行转发，然后在 `network_providers.dart` 中又包了一层 Provider

此外，`network_providers.dart` 有 15+ 个完全同构的 Provider，每个只是
`ref.watch(lucentDioClientProvider).xxxApi` 的包装，两层间接无意义。

### 核心问题

- **God Class**：单一类混合基础设施关注点（Dio 配置）和业务关注点（token 刷新策略、
  error mapping）。修改错误映射逻辑不应触碰 Dio 实例管理代码。
- **API getter 冗余**：`LucentDioClient` 暴露 15+ getter，`network_providers.dart` 又为
  每个 getter 包一层 Provider。feature 通过 `ref.watch(lucentXxxApiProvider)` 三层间接
  访问到最终 API。
- **无重试策略**：网络超时、5xx 错误没有自动重试。只有 auth 401 有 refresh+retry。
- **SSE 客户端无重连**：`LucentSseClient` 是一次性流，断线后不会自动重连。
- **测试困难**：测试需要 mock 整个 `LucentDioClient` 而非单个拦截器。

## Decision

### 7.1 拆分为单一职责的拦截器和服务

```
lib/core/network/
├── dio_client.dart            # 纯 Dio 实例配置 + dispose（~60 行）
├── interceptors/
│   ├── auth_interceptor.dart  # token 注入 + 401 refresh + retry
│   ├── error_interceptor.dart # DioException → LucentApiException 映射
│   └── retry_interceptor.dart # 5xx / 超时自动重试（指数退避）
├── api_client.dart            # LucentClient 包装，暴露 .client 属性
├── session_store.dart         # 不变
├── sse_client.dart            # 不变（增加 reconnect 选项）
├── envelope.dart              # 不变
├── api_exception.dart         # 不变
├── error_mapper.dart          # 不变
└── network_providers.dart     # 精简：只保留 dioClientProvider + apiClientProvider
```

#### `dio_client.dart`

只负责 Dio 实例创建、BaseOptions 配置、interceptor 注册、dispose。不包含任何业务逻辑。

```dart
class LucentDioClient {
  LucentDioClient({
    required String baseUrl,
    required LucentSessionStore sessionStore,
    String Function()? localeResolver,
    Future<void> Function()? onSessionExpired,
    Dio? dio,
  }) : _dio = dio ?? Dio(_createBaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.addAll([
      AuthInterceptor(
        sessionStore: sessionStore,
        localeResolver: localeResolver,
        onSessionExpired: onSessionExpired,
        refreshDio: Dio(_createBaseOptions(baseUrl: baseUrl)),
      ),
      RetryInterceptor(
        retries: 2,
        retryableStatusCodes: {408, 429, 500, 502, 503, 504},
        backoff: (attempt) => Duration(milliseconds: 500 * (1 << attempt)),
      ),
      ErrorInterceptor(),
    ]);
  }

  final Dio _dio;
  Dio get dio => _dio;
  LucentClient get client => LucentClient(_dio, baseUrl: _baseUrl);
  void dispose() => _dio.close(force: true);
}
```

#### `auth_interceptor.dart`

封装 token 注入、401 检测、refresh token 流程、请求重试。从 `LucentDioClient` 的
`_buildInterceptors()` + `_shouldRefresh()` + `_refreshTokens()` + `_doRefresh()` +
`_retry()` 提取而来（约 150 行 → 独立类）。

#### `error_interceptor.dart`

封装 `DioException` → `LucentApiException` 映射。从 `LucentDioClient._mapToApiException()`
+ `_fallbackMessage()` 提取。`LucentApiException` 保留 `traceId`（来自 `traceresponse`
header），`LucentErrorMapper.toAppError()` 将其透传到 `AppError` 供诊断场景使用。

#### `retry_interceptor.dart`

新增。对 5xx 和超时错误自动重试 1-2 次，带指数退避。可配置重试条件。

### 7.2 简化 API 访问链路

**现状**：`feature → ref.watch(lucentXxxApiProvider) → lucentDioClientProvider.xxxApi → LucentClient.xxx`

**改为**：feature 直接通过 `apiClientProvider` 访问 `LucentClient`：

```dart
// network_providers.dart — 只保留两个根级 provider
@riverpod
LucentDioClient lucentDioClient(LucentDioClientRef ref) { ... }

@riverpod
LucentClient lucentClient(LucentClientRef ref) {
  return ref.watch(lucentDioClientProvider).client;
}
```

Feature 内部：

```dart
// 旧：final api = ref.watch(lucentMedicinesApiProvider);
// 新：final api = ref.watch(lucentClientProvider).medicines;
```

删除 `network_providers.dart` 中的 15+ 个 `lucent*ApiProvider`。

### 7.3 SSE 重连

为 `LucentSseClient` 增加可选的 `reconnect` 参数。当流因网络错误断开时，自动重新发起
请求，最多重试 3 次。对于 AI 助手等长连接场景，增加心跳检测。

## Options Considered

### 保持现状（不拆分）

- Pros: 零迁移成本
- Cons: God Class 持续膨胀，每次新增 API 都要加 getter + provider，测试需 mock 整个类

### 拆分为拦截器（本方案）

- Pros: 单一职责，可独立测试每个拦截器，新 API 零改动（通过 `LucentClient` 直接访问），
  重试策略可全局配置
- Cons: 一次性迁移成本（主要重命名 + import 调整）

### 用 `dio_smart_retry` 替代自实现 retry

- Pros: 社区维护，开箱即用
- Cons: 引入额外依赖，retry 策略不够灵活（无法区分 auth refresh retry 和 network retry）

## Consequences

- `LucentDioClient` 从 367 行降至 ~60 行（纯 Dio 配置 + interceptor 注册）。
- `network_providers.dart` 从 113 行降至 ~20 行（只保留 `dioClientProvider` +
  `clientProvider`）。
- `auth_interceptor.dart` ~150 行，可独立单元测试（mock `SessionStore` + `Dio`）。
- `retry_interceptor.dart` ~60 行，可独立配置重试次数和退避策略。
- Feature 中的 `ref.watch(lucentXxxApiProvider)` 改为
  `ref.watch(lucentClientProvider).xxx`，减少一层间接。
- 存量 `lucent*ApiProvider` 不一次性删除；先标记 `@Deprecated`，新代码使用 `lucentClientProvider`，
  触碰旧文件时迁移。
- `AuthInterceptor` 的 refresh token 逻辑行为不变，只是从内联方法提取为独立类。
- `RetryInterceptor` 默认只重试 GET 请求（写操作幂等性不可保证），可通过 `extra` 配置覆盖。
