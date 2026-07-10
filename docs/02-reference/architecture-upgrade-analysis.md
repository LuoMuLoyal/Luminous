# Luminous 架构升级分析

Last updated: 2026-07-10

本文档记录对 Luminous 前端架构的审查结果和升级建议，按优先级分类。跨项目升级项见文末。

---

## 1. 离线同步冲突解决策略缺失 — 高优先级

### 现状

ADR-0009 实现了 Drift 本地持久化 + SyncWorker + 乐观写入。
`insertOptimistic` → `confirmSync` / `markPendingSync` 流程完整。
但 `SyncWorker` 重放操作时没有处理服务端状态已变化的 409 Conflict 场景。

当前策略隐含的是 "last-write-wins"——如果两个设备同时编辑同一天的记录，
后写入的会覆盖先写入的，用户不会收到任何提示。

### 升级方向

- 在 `SyncWorker` 的 replay handler 中区分 409 Conflict 响应
- 实现三种策略：
  - `lastWriteWins`（默认，直接覆盖）
  - `serverWins`（丢弃本地版本）
  - `promptUser`（标记为冲突，在 UI 中展示 diff 让用户选择）
- 在 `pending_sync_queue` 表中增加 `conflictData` 字段，存储服务端返回的当前版本
- 在 Today / Record 页面增加冲突指示器 UI

---

## 2. Release 模式错误报告缺位 — 高优先级（Roadmap v1.1.0）

### 现状

- `debugPrint` 已全量迁移到 `talker_flutter`，但 `talker` 是 dev-only 工具
- Release 构建中没有任何 crash analytics 或错误上报机制
- `AppError` 类型系统（ADR-0008）结构化得很好，但在 release 模式下这些错误信息无处可去

### 升级方向

- 集成 Sentry（或国内替代如 Bugly）
- 在 `runGuarded` 的 catch 分支中自动上报 `AppError`
- 配置 release 版本的 source maps
- 与 Lucent 的 `X-Request-Id` 关联，使客户端错误可以和服务端日志对齐

---

## 3. `Result<T>` 使用一致性 — 中优先级

### 现状

ADR-0008 引入了 `Result<T>` + `AppError` + `runGuarded`，但目前只有 5 个 UI 文件的
12 处 try-catch 迁移到了 `runGuarded`。大量 provider 仍然直接 `throw` 异常，
由 Riverpod 的 `AsyncValue.error` 捕获。

UI 层需要同时处理 `AsyncValue.error` 和 `Result.Failure` 两种错误模式。

### 升级方向

统一错误处理策略——要么全部 provider 返回 `Result<T>`（UI 层只处理 `Result`），
要么全部 `throw`（UI 层只处理 `AsyncValue.error`）。

推荐后者：`AsyncValue` 已经是 Riverpod 的原生错误传播机制，`Result` 在异步上下文中
增加了不必要的嵌套。`runGuarded` 可以保留用于 imperative action（按钮点击等非
provider 场景）。

---

## 4. Feature 模块分层一致性 — 低优先级

### 现状

9 个 feature 有完整 Clean Architecture（data + domain + presentation），
4 个是轻量级：

| Feature | 现状 | 问题 |
|---------|------|------|
| `notification` | 仅 presentation | 没有 domain 层，API DTO 直接泄露到 UI |
| `scan` | minimal | 数据层直接在 `data/` 根目录 |
| `settings` | data + presentation | 没有 domain 层 |
| `support` | 仅 data | 无 domain / presentation |

### 升级方向

为 `notification` 和 `settings` 补充 domain entities 层，隔离 API DTO 和 UI 模型。
`scan` 和 `support` 因功能简单可以保持现状。

---

## 5. Forui 迁移收尾 — 低优先级

### 现状

- Forui 迁移已覆盖大部分 UI，但仍处于 "intentional compatibility phase"
- 共享脚手架中 Forui widget 和未迁移的 Material descendant 共存
- 部分 settings 子页面仍通过 `AppSettings*` wrapper 间接使用 Material 组件
- Forui 0.23.0 `FToaster` 的 `_entranceDismissController` LateInitializationError
  导致 toast 测试被跳过

### 升级方向

- 完成剩余 settings 子页面的 Forui 原生迁移
- 移除 `lib/core/widgets/settings/` 中的 Material 兼容桥接
- 升级到 Forui 0.24+ 后恢复 `FToaster` 的 toast 测试

---

## 跨项目升级项

以下升级项涉及 Lucent 和 Luminous 双方，完整描述见
`../Lucent/docs/01-reference/architecture-upgrade-analysis.md`。

### A. API 合同同步自动化 — 高优先级

当前 OpenAPI 合同同步是手动步骤（`pnpm export:openapi` →
`dart run tool/bootstrap_generated_sources.dart` →
`dart run tool/verify_lucent_openapi_sync.dart`），Lucent API 变更可以在不被检测的
情况下破坏 Luminous。需要在 CI 层面建立自动检测机制。

### B. 推送通知基础设施 — 中优先级（两个 Roadmap 都已列入）

Lucent 有 `UserDevice` 模型和 `NotificationsModule`，但仅支持 in-app 通知。
Luminous 有 `core/notifications/` 本地通知网关。两端都没有 FCM/APNs 集成。
Lucent 需要集成 `firebase-admin` + `apn` + BullMQ 异步发送；
Luminous 需要增加 remote push 权限请求和 token 注册流程。

### C. Feature Flag 系统 — 低优先级

`genUiEnabled` flag 已在 Luminous 提及，但没有系统化基础设施。Lucent 端存储 flag
配置（per-user / global），通过 `/api/v1/user/settings/feature-flags` 端点暴露；
Luminous 端通过 Riverpod provider 注入，支持运行时远程控制。

---

## 优先级总结

| 优先级 | 升级项 | 关联 Roadmap |
|--------|--------|-------------|
| 🔴 高 | 离线同步冲突解决策略 | v1.1.0 |
| 🔴 高 | Release 错误上报 | v1.1.0 |
| 🟡 中 | `Result<T>` 使用一致性 | — |
| 🟢 低 | Feature 分层一致性 | — |
| 🟢 低 | Forui 迁移收尾 | — |
| 🔴 高 | [跨项目] API 合同同步自动化 | — |
| 🟡 中 | [跨项目] 推送通知基础设施 | v1.1.0 |
| 🟢 低 | [跨项目] Feature Flag 系统 | — |
