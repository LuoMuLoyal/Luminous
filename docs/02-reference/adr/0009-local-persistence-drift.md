# ADR-0009: 本地持久化与离线策略 — Drift

- **Status**: accepted
- **Date**: 2026-07-10
- **Deciders**: LuoMuLoyal

## Context

### 当前阶段

Forui 大重构已完成，当前进入架构优化期。ADR-0006（riverpod_generator）、ADR-0007
（网络层职责分离）、ADR-0008（Result 类型与统一错误处理）均已落地，Repository 层的
错误处理基础设施已就位。本地持久化是架构优化期的核心结构性补全。

### 当前缺失

`pubspec.yaml` 声明了 `sqflite: ^2.4.2`，但代码库中未使用。设置页面已有"数据保留期"
（30 天 / 90 天 / 永久）、"图片质量"（标准 / 省流）、"仅 Wi-Fi 同步"等 UI 选项
（`DataStorageSettingsController`），但仅持久化到 `SharedPreferences`，无实际业务消费方。

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
  sqlite3_flutter_libs: ^0.5.0      # 原生 SQLite3 动态库
  path_provider: ^2.1.5              # 已有
  path: ^1.9.1                       # 已有
  connectivity_plus: ^6.1.0          # 网络状态监听（SyncWorker 依赖）

dev_dependencies:
  drift_dev: ^2.20.0
  build_runner: ^2.15.0              # 已有
```

**后端选择说明 — `sqlite3_flutter_libs` vs `drift_sqflite`**：

drift 支持两种底层后端：

- `sqlite3_flutter_libs`（本方案）：基于 `sqlite3` 包，直接绑定 C 库。drift 官方推荐，
  性能更好，支持 WAL 模式和更多 SQLite 高级特性。不依赖 `sqflite`。
- `drift_sqflite`：复用已有 `sqflite` 依赖。但 `sqflite` 在桌面平台支持有限，且
  `sqlite3_flutter_libs` 是 drift 文档的首选后端。

选择 `sqlite3_flutter_libs` 后，`sqflite` 依赖可从 `pubspec.yaml` 移除（当前未使用）。

`workmanager` 作为可选后台保活同步依赖，初期不引入，待评估后台同步需求后再决定。

### 9.2 数据库结构

```
lib/core/database/
├── app_database.dart           # Database 定义、migration 策略
├── tables/
│   ├── daily_records.dart      # 日常记录（症状、饮水、睡眠、用药、笔记）
│   ├── medicine_dose_logs.dart # 用药日志
│   ├── current_medicines.dart  # 当前用药列表缓存
│   ├── health_context.dart     # 健康档案缓存（过敏、状况、用药档案）
│   ├── today_suggestions.dart  # 今日建议缓存（不含 AI 分析）
│   └── pending_sync_queue.dart # 离线写入队列
├── daos/
│   ├── daily_record_dao.dart
│   ├── medicine_dao.dart
│   ├── health_context_dao.dart
│   ├── today_suggestion_dao.dart
│   └── pending_sync_dao.dart
├── sync/
│   └── sync_worker.dart        # 网络恢复后重放 pending queue
└── database_providers.dart     # Riverpod providers
```

### 9.3 Cache-First Repository 模式

> **前置依赖**：本节的 `Result<T>` 类型和 `LucentErrorMapper.toAppError()` 方法由
> ADR-0008 定义。ADR-0008 已 accepted 并落地 `lib/core/errors/`，但当前 Repository
> 签名仍为 `Future<T>` 而非 `Future<Result<T>>`（ADR-0008 约定"存量方法在触碰时迁移"）。
> 实施 ADR-0009 时，被触碰的 Repository 方法需**同步迁移到 `Result<T>` 签名**。
>
> 以下代码为示意伪代码，`RecordFilter` 等类型名称为简化表达，实际实施时以当前接口
> 签名为准（如 `DailyRecordRepository.fetchRecords(String date, {String? kind, ...})`）。

Repository 层从纯远程调用改为 cache-first 模式：

```dart
class LucentDailyRecordRepository implements DailyRecordRepository {
  LucentDailyRecordRepository({
    required this.remoteDataSource,
    required this.dao,
  });

  final DailyRecordRemoteDataSource remoteDataSource;
  final DailyRecordDao dao;

  DateTime? _lastRefreshAttemptAt;

  @override
  Future<Result<List<DailyRecordItem>>> fetchList(RecordFilter filter) async {
    // 1. 先读本地缓存
    final cached = await dao.fetchByFilter(filter);
    if (cached.isNotEmpty) {
      // 后台刷新（不阻塞 UI），带节流
      _refreshInBackground(filter);
      return Result.success(cached);
    }

    // 2. 缓存为空 → 从网络获取
    try {
      final remote = await remoteDataSource.fetchList(filter);
      // 按 filter 范围局部替换，不清空全表
      await dao.replaceByScope(filter, remote);
      return Result.success(remote);
    } on DioException catch (e) {
      return Result.failure(LucentErrorMapper.toAppError(e));
    }
  }

  Future<void> _refreshInBackground(RecordFilter filter) async {
    // 节流：30 秒内不重复刷新同一 filter
    final now = DateTime.now();
    if (_lastRefreshAttemptAt != null &&
        now.difference(_lastRefreshAttemptAt!) < const Duration(seconds: 30)) {
      return;
    }
    _lastRefreshAttemptAt = now;

    try {
      final remote = await remoteDataSource.fetchList(filter);
      await dao.replaceByScope(filter, remote);
    } catch (e) {
      // 后台刷新失败不阻塞 UI；记录日志，下次 fetch 会重试
      appTalker.warning('background refresh failed: $e');
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

**关键设计决策**：

- **`replaceByScope` 而非 `replaceAll`**：按 filter 范围做局部替换。例如查询某天记录
  时，只替换该日期范围的数据，不清除其他日期的缓存。避免用户查看历史记录时后台刷新
  当天数据导致历史数据被清空。
- **后台刷新节流**：同一 filter 30 秒内不重复触发后台刷新，避免网络不稳定时频繁发
  起失败请求、浪费电量。
- **后台刷新失败记录日志**：使用 `appTalker.warning` 而非静默吞没，便于排障。

### 9.4 离线写入队列

对写操作（创建记录、用药日志、反馈提交）引入 pending sync 队列：

```dart
// lib/core/database/tables/pending_sync_queue.dart
class PendingSyncItems extends Table {
  TextColumn get id => text()();              // UUID
  TextColumn get entityType => text()();      // 'daily_record' | 'dose_log' | ...
  TextColumn get payload => text()();         // JSON 序列化的请求体
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();  // 上次尝试时间
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetry => integer().withDefault(const Constant(5))();
  BoolColumn get isSyncing => boolean().withDefault(const Constant(false))();
  TextColumn get lastError => text().nullable()();  // 上次失败原因
}
```

**重放策略**：

- `SyncWorker` 使用 `connectivity_plus` 监听网络恢复事件。
- 网络恢复后，按 `createdAt` 升序重放 `isSyncing == false && retryCount < maxRetry` 的项。
- 指数退避：`lastAttemptAt` 距当前时间不足 `30s * 2^retryCount` 时不重试。
- 同步成功 → 删除该 pending item，确认本地乐观副本。
- 同步失败 → `retryCount++`，记录 `lastError`，更新 `lastAttemptAt`。
- `retryCount >= maxRetry` → 标记为永久失败，通过 talker 上报，UI 提示用户手动处理。

**冲突处理 — last-write-wins 基于 `updatedAt`**：

对于编辑操作（如 `update`），冲突解决策略为 last-write-wins：

1. 同步时携带本地 `updatedAt` 到后端。
2. 后端比较本地 `updatedAt` 与服务端 `updatedAt`：
   - 服务端更新 → 返回服务端版本，客户端用服务端版本覆盖本地（server-wins）。
   - 本地更新 → 接受本地更新，返回确认。
3. 对于删除冲突（本地编辑了一条已被另一端删除的记录），后端返回 404，客户端将本地
   记录标记为 `conflict_deleted`，UI 提示用户该记录已被删除。

### 9.5 缓存失效策略

| 实体 | 缓存 TTL | 失效触发 | TTL 检查位置 |
|------|---------|---------|-------------|
| daily_records | 24h | pull-to-refresh、创建/编辑/删除后 | DAO 查询时检查 `cachedAt` |
| medicine_dose_logs | 1h | 用药日志变更后 | DAO 查询时检查 `cachedAt` |
| current_medicines | 7d | 用药列表变更后 | DAO 查询时检查 `cachedAt` |
| health_context | 7d | 档案变更后 | DAO 查询时检查 `cachedAt` |
| today_suggestions | 1h | 用户反馈/dismiss 后 | DAO 查询时检查 `cachedAt` |

**TTL 实现**：每个缓存表包含 `cachedAt` 列。DAO 查询时先检查 `cachedAt` 是否在 TTL
内，过期则返回空结果触发 Repository 走网络路径。失效触发（如创建/编辑/删除）直接调用
`dao.invalidateScope(filter)` 标记对应范围为 stale。

**AI 内容缓存边界**：

- `today_suggestions`（建议卡片）：**可缓存**。建议卡片是结构化数据（类型、优先级、证据），
  离线展示上次缓存内容对用户有参考价值。
- `today_analysis`（AI 每日分析文本）：**不缓存**。AI 分析文本时效性强且基于当天数据动态
  生成，缓存过期内容可能误导用户。
- `assistant` 回复：**不缓存**。对话上下文依赖服务端会话状态，本地缓存无意义。

设置页面已有的"数据保留期"选项（30 天 / 90 天 / 永久）映射为 `dao.cleanup(olderThan)`
的自动清理策略，在应用启动时执行一次。

### 9.6 Riverpod 集成

```dart
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

// 响应式查询：DAO 返回 Stream，Provider 暴露为 StreamProvider
@riverpod
Stream<List<DailyRecordItem>> watchDailyRecords(
  Ref ref,
  RecordFilter filter,
) {
  return ref.watch(dailyRecordDaoProvider).watchByFilter(filter);
}
```

### 9.7 Migration 策略

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) => m.createAll(),

  onUpgrade: (m, from, to) async {
    // 逐版本迁移，不支持跨版本跳级
    if (from < 2) {
      await m.addColumn(pendingSyncItems, pendingSyncItems.lastError);
    }
    // 后续版本迁移在此追加
  },

  beforeOpen: (details) async {
    // 开启 WAL 模式，提升并发读写性能
    await customStatement('PRAGMA journal_mode = WAL');
    // 开启外键约束
    await customStatement('PRAGMA foreign_keys = ON');
  },
);
```

- 初始 schema 版本为 1，包含所有 9.2 中定义的表。
- `onUpgrade` 采用逐版本迁移，不使用 `if (from < N)` 跳级。
- `beforeOpen` 开启 WAL 模式和外键约束，确保数据完整性和并发性能。
- migration 失败时 drift 会抛出异常，应用应捕获并引导用户重启；不自动回滚（健康数据
  不可丢，宁可启动失败也不默默清库）。

### 9.8 安全与加密

**当前阶段不引入 SQLCipher 加密**，原因：

- SQLCipher 增加约 2-5MB 包体积，且需要平台特定配置。
- 当前 MVP 数据均为用户个人健康记录，不涉及第三方数据。
- 设备级加密（iOS Keychain / Android Keystore + 文件系统加密）已提供基础保护。
- Token 存储已使用 `flutter_secure_storage`。

**后续如果引入敏感第三方数据（如家庭档案），重新评估 SQLCipher 集成。**

数据库文件存储在 `getApplicationDocumentsDirectory()` 返回的路径下，受操作系统应用沙箱
保护。

### 9.9 测试策略

**DAO 单元测试**：

```dart
// 使用 in-memory SQLite，无需平台通道
AppDatabase createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}
```

测试矩阵：
- CRUD 正确性（insert / update / delete / query）
- `replaceByScope` 局部替换不越界
- TTL 过期判断
- `cleanup(olderThan)` 数据保留期清理

**Cache-First Repository 测试**：

| 场景 | 缓存状态 | 网络状态 | 预期结果 |
|------|---------|---------|---------|
| 缓存命中 | 有数据 | 任意 | 返回缓存，后台刷新 |
| 缓存空+网络成功 | 空 | 成功 | 返回远程数据，写入缓存 |
| 缓存空+网络失败 | 空 | 失败 | 返回 `Result.failure(AppError)` |
| 缓存过期 | 过期 | 成功 | 返回远程数据，更新缓存 |
| 缓存过期+网络失败 | 过期 | 失败 | 返回过期缓存（stale-while-error） |
| 离线写入 | 任意 | 失败 | 本地乐观写入，标记 pending sync |
| 离线写入恢复 | 任意 | 恢复 | SyncWorker 重放，确认乐观副本 |

**SyncWorker 集成测试**：

- Mock `connectivity_plus` 网络状态变化
- 验证重放顺序、退避间隔、maxRetry 后标记永久失败

### 9.10 平台兼容性

- **Android / iOS**：`sqlite3_flutter_libs` 原生支持，无额外配置。
- **Web**：`sqlite3_flutter_libs` 需要 wasm 编译，配置较复杂。当前 Luminous 以移动端
  为主，Web 平台不在 MVP 范围。如后续需要 Web 支持，使用 `drift` 的 Web 后端
 （`sql.js` + `flutter.js`），或降级为纯远程模式（不做本地缓存）。
- **桌面（macOS / Windows / Linux）**：`sqlite3_flutter_libs` 支持，需确保打包时包含
  SQLite 动态库。

## Options Considered

| 方案 | Pros | Cons |
|------|------|------|
| **`drift`（本方案）** | 类型安全 SQL，响应式 stream 与 Riverpod `StreamProvider` 天然契合，migration 支持，文档完善，官方推荐 `sqlite3_flutter_libs` 后端 | codegen 步骤（项目已有 build_runner），学习曲线 |
| **`isar`** | 性能最优（非 SQLite），NoSQL 灵活，响应式查询 | v4 仍在 alpha，API 不稳定；与 SQLite 生态不兼容；社区规模小于 drift；不基于 SQL，与后端数据模型对齐需额外映射 |
| **裸 `sqflite` + 手写 SQL** | 已在 `pubspec.yaml` 中，零新依赖 | 无类型安全，无响应式查询，手写 migration 容易出错，DAO 样板代码量大 |
| **`hive` / `shared_preferences` 做 KV 缓存** | 极简，适合少量数据 | 不支持复杂查询（按日期范围、按类型过滤），无关系约束，不适合结构化健康数据 |
| **`realm`** | 高性能，自动同步 | MongoDB 生态绑定，非 Flutter 原生，社区较小 |

## Consequences

- 新增 `drift` + `sqlite3_flutter_libs` + `drift_dev` + `connectivity_plus` 依赖。
- 移除 `sqflite` 依赖（当前未使用，被 `sqlite3_flutter_libs` 替代）。
- 新增 `lib/core/database/` 目录（tables、daos、sync、database 定义、providers）。
- Repository 层从纯远程调用改为 cache-first，增加 `dao` 依赖注入。被触碰的 Repository
  方法同步迁移到 `Future<Result<T>>` 签名（ADR-0008 约定）。
- `main.dart` 中的 `kDebugMode` mock override 可逐步替换为真实 repository + 缓存降级。
  离线时自动回退到本地缓存，不再需要 mock。
- 设置页面"数据保留期"选项接入 `dao.cleanup(olderThan)` 实现，在应用启动时执行。
- 写操作引入 optimistic UI 模式：先展示本地副本，后台同步后更新。
- `SyncWorker` 使用 `connectivity_plus` 监听网络状态变化，恢复后自动重放 pending queue，
  带指数退避和 maxRetry 上限。`workmanager` 后台保活同步待后续评估。
- 测试：DAO 使用 `NativeDatabase.memory()` in-memory SQLite 单元测试，覆盖 CRUD、
  局部替换、TTL、cleanup、cache-first 矩阵、SyncWorker 重放。
- **不缓存 AI 生成内容**（today analysis 文本、assistant 回复）——这些内容时效性强
  且不可重建，缓存反而误导用户。`today_suggestions` 建议卡片作为结构化数据可缓存，
  与 AI 文本分析有明确边界。
- 初期只缓存 5 个核心实体（daily_records、medicine_dose_logs、current_medicines、
  health_context、today_suggestions），其他 feature 按需扩展。
- 当前阶段不引入 SQLCipher 加密，依赖操作系统应用沙箱保护。后续如引入敏感第三方数据
  重新评估。
