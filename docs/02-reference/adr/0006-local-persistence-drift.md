# ADR-0006: 本地持久化与离线策略 — Drift

- **Status**: accepted
- **Date**: 2026-07-10
- **Deciders**: LuoMuLoyal

## Context

Luminous 无本地缓存层：所有数据从网络获取，网络断开时页面直接 error state。无离线写入队列，用户在离线时创建的记录无法暂存。`pubspec.yaml` 声明了 `sqflite` 但未使用。设置页面已有"数据保留期"等 UI 选项但仅持久化到 `SharedPreferences`，无实际业务消费方。

对于健康助手应用，用户需要随时查看用药记录、今日建议、健康档案（含用药安全信息），离线不可用是不可接受的。

## Decision

### 1. 引入 `drift` 作为本地数据库

`drift` 是 Flutter 生态最成熟的 SQLite ORM，提供类型安全查询、响应式 stream、自动 migration、compile-time SQL 验证。使用 `sqlite3_flutter_libs` 作为底层后端（drift 官方推荐，性能更好，不依赖 `sqflite`）。`workmanager` 后台保活同步初期不引入。

### 2. Cache-First Repository 模式

Repository 层从纯远程调用改为 cache-first：

- **读操作**：先读本地缓存，缓存命中则返回并触发后台刷新（节流 30s）；缓存为空则从网络获取并写入缓存。
- **写操作**：先写本地（optimistic），再同步远程；网络失败则标记为 pending sync，返回本地副本使 UI 正常展示。
- **局部替换**：按 filter 范围做局部替换（`replaceByScope`），不清空全表，避免后台刷新当天数据导致历史数据被清空。

### 3. 离线写入队列

引入 pending sync 队列表（`PendingSyncItems`），写操作在离线时暂存。`SyncWorker` 使用 `connectivity_plus` 监听网络恢复事件，按 `createdAt` 升序重放，带指数退避和 maxRetry 上限。冲突处理采用 last-write-wins 基于 `updatedAt`。

### 4. 缓存失效策略

每个缓存表包含 `cachedAt` 列，DAO 查询时检查 TTL。失效触发（创建/编辑/删除后）直接标记对应范围为 stale。

| 实体 | 缓存 TTL | 失效触发 |
|------|---------|---------|
| daily_records | 24h | pull-to-refresh、CRUD 后 |
| medicine_dose_logs | 1h | 日志变更后 |
| current_medicines | 7d | 用药列表变更后 |
| health_context | 7d | 档案变更后 |
| today_suggestions | 1h | 用户反馈/dismiss 后 |

**不缓存 AI 生成内容**：`today_analysis`（AI 每日分析文本）和 `assistant` 回复时效性强且不可重建，缓存反而误导用户。`today_suggestions` 建议卡片作为结构化数据可缓存。

### 5. 不引入 SQLCipher 加密

当前阶段数据均为用户个人健康记录，设备级加密（iOS Keychain / Android Keystore + 文件系统加密）已提供基础保护。后续如引入敏感第三方数据重新评估。

## Options Considered

| 方案 | Pros | Cons |
|------|------|------|
| **`drift`（本方案）** | 类型安全 SQL，响应式 stream 与 Riverpod `StreamProvider` 天然契合，migration 支持，官方推荐 `sqlite3_flutter_libs` | codegen 步骤（项目已有 build_runner），学习曲线 |
| `isar` | 性能最优（非 SQLite），NoSQL 灵活，响应式查询 | v4 仍在 alpha，API 不稳定；与 SQLite 生态不兼容；社区规模小于 drift |
| 裸 `sqflite` + 手写 SQL | 已在 `pubspec.yaml` 中，零新依赖 | 无类型安全，无响应式查询，手写 migration 容易出错 |
| `hive` / `shared_preferences` 做 KV 缓存 | 极简，适合少量数据 | 不支持复杂查询，无关系约束，不适合结构化健康数据 |

## Consequences

- 新增 `drift` + `sqlite3_flutter_libs` + `drift_dev` + `connectivity_plus` 依赖，移除未使用的 `sqflite`。
- 新增 `lib/core/database/` 目录（tables、daos、sync、database 定义、providers）。
- Repository 层从纯远程调用改为 cache-first，增加 `dao` 依赖注入。
- 写操作引入 optimistic UI 模式：先展示本地副本，后台同步后更新。
- `main.dart` 中的 `kDebugMode` mock override 可逐步替换为真实 repository + 缓存降级。
- 设置页面"数据保留期"选项接入 `dao.cleanup(olderThan)` 实现。
- DAO 使用 `NativeDatabase.memory()` in-memory SQLite 单元测试，覆盖 CRUD、局部替换、TTL、cleanup、cache-first 矩阵、SyncWorker 重放。
- 初期只缓存 5 个核心实体，其他 feature 按需扩展。
- 详细设计（表结构、DAO 接口、SyncWorker 重放策略、migration 代码、测试矩阵）见 `02-reference/local-persistence-design.md`。
