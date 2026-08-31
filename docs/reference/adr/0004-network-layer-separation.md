# ADR-0004: 网络层职责分离 — LucentDioClient 拆分与 API 访问简化

- **Status**: accepted
- **Date**: 2026-07-10
- **Deciders**: LuoMuLoyal

## Context

`LucentDioClient`（367 行）是当前网络层的唯一入口，同时承担六种职责：Dio 实例管理、Token 注入拦截器、401 刷新逻辑、错误映射、Session 读写代理、15+ API getter。此外，`network_providers.dart` 有 15+ 个完全同构的 Provider，每个只是 `ref.watch(lucentDioClientProvider).xxxApi` 的包装，两层间接无意义。

核心问题：

- **God Class**：单一类混合基础设施关注点（Dio 配置）和业务关注点（token 刷新策略、error mapping）。修改错误映射逻辑不应触碰 Dio 实例管理代码。
- **API getter 冗余**：`LucentDioClient` 暴露 15+ getter，`network_providers.dart` 又为每个 getter 包一层 Provider。feature 通过 `ref.watch(lucentXxxApiProvider)` 三层间接访问到最终 API。
- **无重试策略**：网络超时、5xx 错误没有自动重试。只有 auth 401 有 refresh+retry。
- **SSE 客户端无重连**：`LucentSseClient` 是一次性流，断线后不会自动重连。
- **测试困难**：测试需要 mock 整个 `LucentDioClient` 而非单个拦截器。

## Decision

### 1. 拆分为单一职责的拦截器和服务

将 `LucentDioClient` 拆解为：

- `dio_client.dart` — 纯 Dio 实例配置 + dispose（~60 行）
- `interceptors/auth_interceptor.dart` — token 注入 + 401 refresh + retry（~150 行）
- `interceptors/error_interceptor.dart` — DioException → LucentFailure 映射
- `interceptors/retry_interceptor.dart` — 5xx / 超时自动重试，指数退避（~60 行）
- `api_client.dart` — LucentClient 包装，暴露 `.client` 属性
- `error_mapper.dart` — 解析 Problem Details

### 2. 简化 API 访问链路

**现状**：`feature → ref.watch(lucentXxxApiProvider) → lucentDioClientProvider.xxxApi → LucentClient.xxx`

**改为**：feature 直接通过 `apiClientProvider` 访问 `LucentClient`：

```dart
// 旧：final api = ref.watch(lucentMedicinesApiProvider);
// 新：final api = ref.watch(lucentClientProvider).medicines;
```

删除 `network_providers.dart` 中的 15+ 个 `lucent*ApiProvider`。

### 3. SSE 重连

为 `LucentSseClient` 增加可选的 `reconnect` 参数。当流因网络错误断开时，自动重新发起请求，最多重试 3 次。对于 AI 助手等长连接场景，增加心跳检测。

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| 保持现状（不拆分） | 零迁移成本 | God Class 持续膨胀，每次新增 API 都要加 getter + provider，测试需 mock 整个类 |
| **拆分为拦截器（本方案）** | 单一职责，可独立测试每个拦截器，新 API 零改动，重试策略可全局配置 | 一次性迁移成本（主要重命名 + import 调整） |
| 用 `dio_smart_retry` 替代自实现 retry | 社区维护，开箱即用 | 引入额外依赖，retry 策略不够灵活（无法区分 auth refresh retry 和 network retry） |

## Consequences

- `LucentDioClient` 从 367 行降至 ~60 行（纯 Dio 配置 + interceptor 注册）。
- `network_providers.dart` 从 113 行降至 ~20 行（只保留 `dioClientProvider` + `clientProvider`）。
- 每个拦截器可独立单元测试。
- Feature 中的 `ref.watch(lucentXxxApiProvider)` 改为 `ref.watch(lucentClientProvider).xxx`，减少一层间接。
- 存量 `lucent*ApiProvider` 不一次性删除；先标记 `@Deprecated`，新代码使用 `lucentClientProvider`，触碰旧文件时迁移。
- `RetryInterceptor` 默认只重试 GET 请求（写操作幂等性不可保证），可通过 `extra` 配置覆盖。
- 错误映射与 ADR-0005（Result 类型与统一错误处理）对齐：HTTP 错误使用 `application/problem+json` Problem Details，`LucentErrorMapper` 解析后映射为 `LucentFailure`。
