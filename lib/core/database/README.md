# lib/core/database — Drift 本地持久化

cache-first / offline-first 的存储底座：`AppDatabase` 单例 + 缓存表与 DAO +
离线写队列（`SyncWorker` 重放）+ 供保留期清理使用的 DAO 接缝。
**原生平台数据库由 SQLCipher 加密**。选型与加密决定见
`../../../docs/reference/adr/0006-local-persistence-drift.md`。

## 职责与边界

- 管：`database.dart`（schema 定义、WAL/外键 PRAGMA、`AppDatabase.forTesting`）、
  `key.dart`（SQLCipher 密钥的生成与保管）、
  `tables/` + `daos/`（记录 / 汇总 / 剂次 / 当前用药 / 健康档案 / 今日建议 /
  回顾 / 通知分页 / 我的仪表盘 / 用药工作台 / 搜索结果 / 用户设置 的缓存，
  加 `pending_sync` 离线队列）、`connection*.dart`（io/web 条件导入）、
  `sync/worker.dart`、`cache_constants.dart`（节流/超时/重试常量）。
- 不管：cache-first 编排与实体映射（各 feature data 层）；按保留期清理的触发与策略
  （归 `features/settings/data/providers/cache_cleanup.dart`——保留期是用户设置，
  放在 core 会让 core 依赖 feature，本层只提供 DAO 的 `cleanup(cutoff)`）；
  数据库文件路径由 `connection_io.dart` 决定；不做网络请求（重放的 HTTP 由注入的 Dio 完成）。

## 对外契约

- 导出：`connection_providers.dart` 的 `appDatabaseProvider` 与各 DAO provider；
  `syncWorkerProvider` / `syncFailedCountProvider`（`sync/worker.dart`）；
  `cache_constants.dart` 常量；各 DAO 类（`DailyRecordDao.cleanup` /
  `PendingSyncDao.fetchReady` / `resetForRetry` 等）。
- 被依赖：各 feature 的 data repositories（缓存读写、离线入队与 handler 注册）；
  mine 的同步失败列表；core/auth（会话恢复超时常量）；core/analytics（pending-sync 入队）；
  features/settings（保留期清理）。

## 加密（原生平台）

- **加密引擎由 `pubspec.yaml` 的 native-assets hook 选择**：
  `hooks.user_defines.sqlite3.source: sqlite3mc`（SQLite3MultipleCiphers）。
  `sqlite3` v3 默认装配的是**普通** SQLite——没有加密、也不认 `PRAGMA key`，
  症状是 `SqliteException(1): near "x'…'": syntax error`。
  `sqlcipher_flutter_libs` 自 0.7.0 起是空壳包（README 原话：no longer does
  anything），它存在与否都不影响是否加密。
- 选 SQLite3MultipleCiphers 而非 SQLCipher 构建：`PRAGMA key` 语法与原始密钥
  （`x'<hex>'`）形式两边一致，而 SQLCipher 构建会在 Windows/Linux/Android 链接
  OpenSSL 并牵进 Zetetic 许可证。
- **打开数据库前先校验引擎**：`requireCipherEngine` 读 `PRAGMA cipher`——它只存在于
  加密构建里。校验失败返回 `LucentFailure`（不抛异常），`connection_io` 据此让打开
  失败，而不是拿普通 SQLite 继续写明文。上游 drift 文档推荐的正是这条探针。
- 密钥为 **32 字节原始随机量**（256-bit key），由 `Random.secure()`
  生成——底层是平台 CSPRNG，不是 `Random()`。
- 密钥存平台安全存储（iOS Keychain / Android Keystore / Windows DPAPI /
  Linux Secret Service），**不落库、不落 KV、不进日志**。
- 打开数据库时经 `PRAGMA key = x'<hex>'` 以原始字节形式注入；`x'...'` 形态让
  引擎直接把字节当密钥，而引号字符串会走 KDF 得到不同密钥材料。
- **密钥取不到时直接失败，绝不降级为明文**——静默明文落盘比打不开更糟。
- **明文库不迁移**：检测到「没有密钥但文件存在」即删除重建。本地库只是可丢弃的缓存，
  重建安全，且避免明文残留。
- **Web 不加密**：`connection_web.dart` 走 `WasmDatabase`，加密引擎不适用，
  该平台由浏览器 origin 隔离保护。ADR-0006 §5 明确把加密范围限定在原生平台。

## 不变量

- 保留期清理只删 `syncStatus = 'synced'` 且早于 cutoff 的行：未同步条目永不被
  `cleanup` 带走（`DailyRecordDao.cleanup` / `MedicineDoseLogDao.cleanup`）。
- 重放按 `createdAt` 升序；退避 = `syncBackoffBase * 2^retryCount` 封顶
  `syncBackoffMax`；超 `maxRetry` 永久失败并落 `PendingSyncErrorDetails`
  （`test/core/database/sync/worker_test.dart`）。服务端声明的不可重试失败直接跳到上限，
  不白耗剩余次数——同一条 payload 每次重放都会得到同一个语义拒绝（`sync/worker.dart`）。
- 永久失败的行仍留在队列里，由 mine 的同步失败页 `resetForRetry` 清重试计数后重新进入
  `fetchReady`，不是靠时间自愈（`fetchReady` 过滤 `retryCount < maxRetry`）。
- **schema 无迁移链**：本地库只有可丢弃的缓存，`schemaVersion` 恒为 1，
  `onUpgrade` 不含兼容分支；结构变更按全新安装处理。
- Native 开 WAL，Web（WASM）不开（平台差异收敛在 connection 条件导入）。
- 密钥管理由 `test/core/database/key_test.dart` 锁定：32 字节、同安装内稳定、
  跨安装互异、存储不可用时抛错。

## 依赖禁区

- 不 import `features/**`。新增「要读用户设置才能决定」的行为时，把策略放在 feature
  侧、本层只留接缝（保留期清理即此形态），不要反过来让 core 读 feature 的 provider。
- 禁手编 `*.g.dart`；表结构变更只能改 `tables/` 后由 build_runner 再生成。
- 加密引擎只能有一个来源：`sqlite3` 的 hook 选源（当前 `sqlite3mc`）。
  不要再引入 `sqlite3_flutter_libs` / `sqlcipher_flutter_libs`——
  前者会换回普通 SQLite（`PRAGMA key` 直接语法错），后者的 0.7.0 起已是空壳。

## 陷阱与决策

- 无 per-cache TTL：cache-first 立即返回 + 后台刷新，`cachedAt` 仅供清理；
  ADR-0006 初版的 TTL 表已被该策略取代，以 `cache_constants.dart` 注释为准。
- 后台刷新节流 `backgroundRefreshThrottle` 防止多屏读同一缓存时重复拉取。
- SyncWorker 的 handler 按 entityType 由各 repository 注册，未注册类型跳过并告警，
  不误删队列条目。
- 已知限制：HarmonyOS ArkWeb 可能不暴露 `dart.library.js_interop`，web stub 将抛
  UnsupportedError（`database.dart` 顶部注释）。
