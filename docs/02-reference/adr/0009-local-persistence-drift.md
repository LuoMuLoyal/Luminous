# ADR-0009: 本地持久化与离线策略 — Drift

- **Status**: proposed
- **Date**: 2026-07-10
- **Deciders**: LuoMuLoyal

## Context

### 当前缺失

这是目前架构中最大的结构性缺口。`pubspec.yaml` 声明了 `sqflite: ^2.4.2`，但代码库中
几乎未使用。设置页面已有"数据保留期"（30 天 / 90 天 / 永久）、"图片质量"（标准 / 省流）、
"仅 Wi-Fi 同步"等 UI 选项，但后端没有实现。

**影响**：

1. **无本地缓存层** — 所有数据从网络获取。网络断开时页面直接 error state，用户看到
   "请求失败"而非 stale data。这对于健康助手应用是不可接受的：用户需要随时查看用药
   记录、今日建议、健康档案。
2. **无离线写入队列** — 用户在离线时创建的记录（症状、饮水、睡眠、用药日志）无法暂存，
   恢复网络后不会自动同步。数据丢失风险。
3. **Mock 数据用 `kDebugMode` 覆盖** — `main.dart` 中 5 个 `overrideWith(MockXxxRepository)`
   是开发工具，不是离线降级策略。Release 构建中离线即全盘不可用。
4. **启动体验差** — 每次冷启动都要等网络请求完成才能显示数据。无本地缓存意味着无
   skeleton → content 过渡。

### 产品需求驱动

- **MVP 路径**：`record → summarize → bounded medicine safety check → export`。记录创建
  是核心路径，不能因网络问题阻塞。
- **用药安全**：当前用药列表和过敏档案在离线时必须可查（紧急场景）。
- **今日建议**：建议卡片在离线时应展示上次缓存的内容，而非空白 error state。

## Decision

### 9.1 引入 `drift` 作为本地数据库

`drift` 是 Flutter 生态最成熟的 SQLite ORM，提供类型安全查询、响应式 stream、自动
migration、compile-time SQL 验证。

```yaml
# pubspec.yaml
dependencies:
  drift: ^2.20.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.5   # 已有
  path: ^1.9.1            # 已有

dev_dependencies:
  drift_dev: ^2.20.0
  build_runner: ^2.15.0   # 已有
```

### 9.2 数据库结构

```
lib/core/database/
├── app_database.dart           # Database 定义、migration 策略
├── tables/
│   ├── daily_records.dart      # 日常记录（症状、饮水、睡眠、用药、笔记）
│   ├── medicine_dose_logs.dart # 用药日志
│   ├── current_medicines.dart  # 当前用药列表缓存
│   ├── health_context.dart     # 健康档案缓存（过敏、状况、用药档案）
│   └── today_suggestions.dart  # 今日建议缓存
├── daos/
│   ├── daily_record_dao.dart
│   ├── medicine_dao.dart
│   ├── health_context_dao.dart
│   └── today_suggestion_dao.dart
└── database_providers.dart     # Riverpod providers
```

### 9.3 Cache-First Repository 模式

Repository 层从纯远程调用改为 cache-first 模式：

```dart
class LucentDailyRecordRepository implements DailyRecordRepository {
  LucentDailyRecordRepository({
    required this.remoteDataSource,
    required this.dao,
  });

  final DailyRecordRemoteDataSource remoteDataSource;
  final DailyRecordDao dao;

  @override
  Future<Result<List<DailyRecordItem>>> fetchList(RecordFilter filter) async {
    // 1. 先读本地缓存
    final cached = await dao.fetchByFilter(filter);
    if (cached.isNotEmpty) {
      // 后台刷新（不阻塞 UI）
      _refreshInBackground(filter);
      return Result.success(cached);
    }

    // 2. 缓存为空 → 从网络获取
    try {
      final remote = await remoteDataSource.fetchList(filter);
      await dao.replaceAll(remote);  // 写入缓存
      return Result.success(remote);
    } on DioException catch (e) {
      return Result.failure(LucentErrorMapper.toAppError(e));
    }
  }

  Future<void> _refreshInBackground(RecordFilter filter) async {
    try {
      final remote = await remoteDataSource.fetchList(filter);
      await dao.replaceAll(remote);
    } catch (_) {
      // 后台刷新失败不阻塞 UI；下次 fetch 会重试
    }
  }

  @override
  Future<Result<DailyRecordItem>> create(DailyRecordInput input) async {
    // 写入：先写本地（optimistic），再同步远程
    final localCopy = await dao.insertOptimistic(input);
    try {
      final remote = await remoteDataSource.create(input);
      await dao.confirmSync(localCopy.id, remote);  // 用远程结果替换乐观副本
      return Result.success(remote);
    } on DioException catch (e) {
      // 离线写入：标记为 pending sync
      await dao.markPendingSync(localCopy.id);
      return Result.success(localCopy);  // 返回本地副本，UI 正常展示
    }
  }
}
```

### 9.4 离线写入队列

对写操作（创建记录、用药日志、反馈提交）引入 pending sync 队列：

```dart
// lib/core/database/tables/pending_sync_queue.dart
class PendingSyncItems extends Table {
  TextColumn get id => text()();              // UUID
  TextColumn get entityType => text()();      // 'daily_record' | 'dose_log' | ...
  TextColumn get payload => text()();         // JSON 序列化的请求体
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  BoolColumn get isSyncing => boolean().withDefault(const Constant(false))();
}
```

网络恢复后，`SyncWorker` 按创建时间顺序重放队列，处理冲突（server-wins 策略）。

### 9.5 缓存失效策略

| 实体 | 缓存 TTL | 失效触发 |
|------|---------|---------|
| daily_records | 24h | 用户 pull-to-refresh、创建/编辑/删除后 |
| medicine_dose_logs | 1h | 用药日志变更后 |
| current_medicines | 7d | 用药列表变更后 |
| health_context | 7d | 档案变更后 |
| today_suggestions | 1h | 用户反馈/dismiss 后 |

设置页面已有的"数据保留期"选项（30 天 / 90 天 / 永久）映射为 `dao.cleanup(olderThan)`
的自动清理策略。

### 9.6 Riverpod 集成

```dart
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

// 响应式查询：DAO 返回 Stream，Provider 暴露为 StreamProvider
@riverpod
Stream<List<DailyRecordItem>> watchDailyRecords(
  WatchDailyRecordsRef ref,
  RecordFilter filter,
) {
  return ref.watch(dailyRecordDaoProvider).watchByFilter(filter);
}
```

## Options Considered

### `drift`（本方案）

- Pros: 类型安全 SQL，响应式 stream 与 Riverpod `StreamProvider` 天然契合，migration 支持，
  与已有 `sqflite` 底层兼容，文档完善
- Cons: codegen 步骤（项目已有 build_runner），学习曲线

### `isar`

- Pros: 性能最优（非 SQLite），NoSQL 灵活，响应式查询
- Cons: v4 仍在 alpha，API 不稳定；与 SQLite 生态不兼容；社区规模小于 drift；不基于 SQL，
  与后端数据模型对齐需额外映射

### 裸 `sqflite` + 手写 SQL

- Pros: 已在 pubspec.yaml 中，零新依赖
- Cons: 无类型安全，无响应式查询，手写 migration 容易出错，DAO 样板代码量大

### `hive` / `shared_preferences` 做 KV 缓存

- Pros: 极简，适合少量数据
- Cons: 不支持复杂查询（按日期范围、按类型过滤），无关系约束，不适合结构化健康数据

### `realm`

- Pros: 高性能，自动同步
- Cons: MongoDB 生态绑定，非 Flutter 原生，社区较小

## Consequences

- 新增 `drift` + `sqlite3_flutter_libs` + `drift_dev` 依赖。
- 新增 `lib/core/database/` 目录（tables、daos、database 定义、providers）。
- Repository 层从纯远程调用改为 cache-first，增加 `dao` 依赖注入。
- `main.dart` 中的 `kDebugMode` mock override 可逐步替换为真实 repository + 缓存降级。
  离线时自动回退到本地缓存，不再需要 mock。
- 设置页面"数据保留期"选项接入 `dao.cleanup()` 实现。
- 需要定义 migration 策略（drift 的 `MigrationStrategy`）。
- 写操作引入 optimistic UI 模式：先展示本地副本，后台同步后更新。
- `SyncWorker` 使用 `connectivity_plus` 监听网络状态变化，恢复后自动重放 pending queue。
  可选 `workmanager` 做后台保活同步。
- 测试：DAO 可用 in-memory SQLite（` NativeDatabase.memory()`）进行单元测试。
- **不缓存 AI 生成内容**（today analysis、assistant 回复）——这些内容时效性强且不可
  重建，缓存反而误导用户。
- 初期只缓存 5 个核心实体（daily_records、medicine_dose_logs、current_medicines、
  health_context、today_suggestions），其他 feature 按需扩展。
