# lib/core/database — Drift 本地持久化

cache-first / offline-first 的存储底座:`AppDatabase` 单例 + 8 张缓存表与 8 个 DAO +
离线写队列(`SyncWorker` 重放)+ 按保留期清理(`cacheCleanupProvider`)。选型见
../../../docs/reference/adr/0006-local-persistence-drift.md。

## 职责与边界
- 管:database.dart(schema 迁移链、WAL/外键 PRAGMA、`AppDatabase.forTesting`)、
  tables/ + daos/(daily_record、dose log、current medicine、health_context、
  today_suggestion、review、review_dashboard 缓存 + pending_sync 队列)、
  connection*.dart(io/web 条件导入)、sync/worker.dart、cache_cleanup.dart、
  cache_constants.dart(节流/超时/重试常量)。
- 不管:cache-first 编排与实体映射(各 feature data 层);数据库文件路径由
  connection_io.dart 决定;不做网络请求(重放的 HTTP 由注入的 Dio 完成)。

## 对外契约
- 导出:connection_providers.dart 的 `appDatabaseProvider` 与 8 个 DAO provider;
  `syncWorkerProvider` / `syncFailedCountProvider`(sync/worker.dart);
  `cacheCleanupProvider`;cache_constants.dart 常量;各 DAO 类。
- 被依赖:record / medicine / health_context / review / today 等的 data repositories
  (缓存读写、离线入队与 handler 注册);mine 的同步失败横幅(`syncFailedCountProvider`);
  core/auth(会话恢复超时常量)。

## 不变量
- `PendingSyncItems` 中未同步条目永不被 `cacheCleanup` 删除,只清理已同步的过期行
  (test/core/database/cache_cleanup_test.dart)。
- 重放按 `createdAt` 升序;退避 = `syncBackoffBase * 2^retryCount` 封顶
  `syncBackoffMax`;超 `maxRetry` 永久失败并落 `PendingSyncErrorDetails`
  (test/core/database/sync/worker_test.dart)。
- schema 变更必须走 MigrationStrategy 逐版本步进且可重入(report→review 改名做了
  存在性检查);DAO 行为锁在 test/core/database/dao_test.dart、dao_extended_test.dart。
- Native 开 WAL,Web(WASM)不开(平台差异收敛在 connection 条件导入)。

## 依赖禁区
- 不 import `features/**`;已知例外是 cache_cleanup.dart 读 settings 的保留期 provider,
  新增依赖前优先把设置经 domain/常量下传,不要复制此模式。
- 禁手编 `*.g.dart`;表结构变更只能改 tables/ 后由 build_runner 再生成并补迁移。

## 陷阱与决策
- 无 per-cache TTL:cache-first 立即返回 + 后台刷新,`cachedAt` 仅供清理;
  ADR-0006 初版的 TTL 表已被该策略取代,以 cache_constants.dart 注释为准。
- 后台刷新节流 `backgroundRefreshThrottle` 防止多屏读同一缓存时重复拉取。
- SyncWorker 的 handler 按 entityType 由各 repository 注册,未注册类型跳过并告警,
  不误删队列条目。
- 已知限制:HarmonyOS ArkWeb 可能不暴露 `dart.library.js_interop`,web stub 将抛
  UnsupportedError(database.dart 顶部注释)。
