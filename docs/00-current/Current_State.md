# Luminous Current State

Last updated: 2026-07-11

本文件只保留简介和按区域链接。具体实现细节见 `00-current/` 下各子文件。
历史 completed baselines 已归档至 [[04-archive/current-state-archive]]。

## 当前区域

- [[00-current/Project_Governance]] — 项目治理、文档映射、AI 开发工作流
- [[00-current/Repository_Split]] — 仓库划分与生成物边界
- [[00-current/Product_Surface]] — 产品表面
- [[00-current/Work_Phase_Guide]] — 阶段总纲
- [[00-current/Lucent_Contract_Snapshot]] — Lucent 合同快照
- [[00-current/Runtime_Snapshot]] — Luminous 运行时快照（Forui 主题、状态管理、网络层）
- [[00-current/Active_Mobile_UI]] — 活跃移动 UI 总览
- [[00-current/Active_UI_Today]] — Today 页面详细状态
- [[00-current/Active_UI_Record]] — Record 页面详细状态
- [[00-current/Active_UI_Medicine]] — Medicine 页面详细状态
- [[00-current/Active_UI_Report]] — Report 页面详细状态
- [[00-current/Active_UI_Mine_Settings]] — Mine / Settings 页面详细状态
- [[00-current/Mock_Or_Deferred]] — Mock 与延后能力
- [[00-current/Removed_From_Active_Scope]] — 已移出活跃范围的功能

## 当前基线摘要

- 五 Tab 根页（Today / Record / Medicine / Report / Mine）均已接入 `PageViewState` 统一状态机，
  未登录态使用 `SignInHintBanner` 轻量提示条而非全屏门控。
  **审查修复（2026-07-11）**：Mine 页面补齐 `SignInHintBanner`（连续三次审查未修复问题）；Medicine `_stateColor` 为 `taken`/`skipped`/`pending` 分别使用 `success`/`neutral`/`warning` 语义颜色区分；`updatedAt` 移除不必要的 `createdAt` fallback；SearchBar 从 `SizedBox(height:56)` 改为 `ConstrainedBox(minHeight:56)` 支持大字体场景。
- Today 根页已收口为 `主建议卡 → 次建议区 → 今日摘要 → 观察项 → 轻动作` 结构。建议引擎前端接入 Phase 1-9 全部完成：API 客户端生成、Domain 实体层、Remote Data Source 就绪；`todaySuggestionProvider` 升级为 `AsyncNotifier`（含 submitFeedback/dismiss/refresh），主卡/次卡区从 provider 直接取数据；反馈按钮接入 `POST /today/suggestions/:id/feedback`，AI 解释按需加载 `POST /today/suggestions/:id/explain`；主卡证据区改为结构化逐条展示（`_EvidenceList` + `_EvidenceItemRow`），`subtype == 'water'` 建议卡显示 `FDeterminateProgress` 饮水进度条；观察项区从旧 `todayRecommendationsProvider` 切换到 `todaySuggestionProvider.observations`，置信度 tag 从后端 `confidence` 映射，fallback 睡眠提示保留；页面刷新同时 invalidate dashboard + suggestions；废弃的 `priorityItems` / `TodayPriorityItem` / `TodayPriorityItemType` 已彻底删除，旧 `todayRecommendationsProvider` / `recommendations_remote_data_source.dart` 标记 `@Deprecated`；Forui API 规范化（`FProgress` → `FCircularProgress.loader`），硬编码文案消除，56 个 today + shell 测试全部通过。**审查修复（2026-07-10）**：次级建议 error 状态显示重试 UI（`_SecondarySuggestionErrorState`）；图标映射提取为独立 `SuggestionIconMapping` 类（`shared/suggestion_icon_mapping.dart`）；反馈提交后切换为只读「已反馈」指示器；AI 解释重试上限 3 次（`_AiExplainUnavailable`）；Dashboard 超时支持 `--dart-define=DASHBOARD_TIMEOUT_SECONDS` 编译时配置。
- Medicine 根页已接入 Lucent Phase 2 slot-aware dose-log 合同。
- Forui-first 编码统一性优化完成：Material 组件全面迁移、颜色/排版 token 化。语义颜色系统增量清理已全部完成：`colors.X.withValues(alpha: Y)` 直接 `FColors` 访问和 `.resolve(colors)` 桥接方法已迁移到 `SemanticColor` palette 预计算色调（`subtle`/`muted`/`border`/`solid`），范围外 alpha 值改为基于 `palette.solid(context).withValues(alpha:)`。业务代码中 `.resolve(colors)` 残留清零，仅剩基础设施定义（`resolveAll` 实现 + 文档注释）。残留 `withValues(alpha:)` 仅为无 SemanticColor 等价物的 `colors.background`/`colors.card`/`colors.foreground` 访问和 raw `Color` 参数。
- `lib/core/design/` 目录架构升级完成：全部 token 类名移除 `App` 前缀，统一为 `Spacing` / `RadiusTokens` / `TypographyToken` / `DurationTokens` / `Breakpoints` / `ResponsiveSizing` / `LayoutScale` + `LayoutScaleResolver`，通过 barrel `design.dart` 统一导出。
- Mine 账号与安全区已包含退出登录 tile（`ConsumerWidget` + `authSessionProvider`）；Report 趋势区已替换为 `fl_chart` 多线折线图，日期标签从 `dashboard.startDate` 动态生成。
- `debugPrint` 已全量迁移到 `talker_flutter` 日志基础设施（922 tests passed）。
- 文档治理使用 `docs/doc-map.yaml` + `tool/check_doc_coverage.dart`：默认阻断模式——有代码变更但无 `docs/` 文件时 `exit(1)`；`--warning-only` 用于日常检查（per-rule 报告缺少的具体文档但不阻断）；`SKIP_DOC_CHECK=1` 可旁路。
- Auth 模块架构重构完成：`LoginFormState` 从 18 字段降至 11（移除全部 OAuth 字段），`LoginFormNotifier` 从 393 行降至 ~170 行（移除 7 个 OAuth 方法）；新增 `OAuthLoginController` + `OAuthLoginState` 统管 WeChat/QQ/Apple 三方登录；新增 `WechatOAuthService` 封装 mobile→desktop→web 三路平台检测，同时服务登录和身份绑定；新增 `AuthActionRunner`（`runAuthAction<T>()`）统一 try-catch+LucentErrorMapper 模式；新增 `OAuthCallbackParser` 提取回调 URL 解析；`AuthRemoteDataSource` 5 处 `writeSession` 重复提取为 `_persistSession`；`LoginPage` 从 700 行降至 ~370 行，OAuth 面板提取为独立 widget；45 个 auth 测试 + 8 个 mine 测试全部通过。
- ADR-0006 实施第一批：`riverpod_generator` 引入完成。`riverpod_annotation 4.0.3` + `riverpod_generator 4.0.4` 加入依赖；`network_providers.dart` 全部 20 个 provider 迁移为 `@riverpod` / `@Riverpod(keepAlive: true)` 注解形式；新增 `authGuarded` helper 函数（`lib/core/providers/auth_guarded.dart`）封装 auth session 检查模式；947 tests passed。
- ADR-0006 实施第二批：Feature 数据 provider 全部接入 `authGuarded`。14 处重复 auth guard 模式消除，覆盖 mine/record/today/medicine/health_context/notification/report 7 个 feature。`authGuarded` 修正为非 `async` 以保持同步 error 传播。`todaySuggestionProvider` 在 session restoring 期间行为改进（pending 代替 null）。947 tests passed。
- ADR-0006 实施第三批：Feature datasource/repository provider 全部迁移为 `@riverpod` 注解。覆盖 auth/settings/scan/today/record/medicine/health_context/report/assistant/search/mine 共 11 个 feature 模块 + core 层（logger/notifications/router/ai），约 40 个手写 `Provider<T>` 声明改为 `@riverpod` 函数注解。947 tests passed。
- ADR-0007 实施完成：网络层职责分离。`LucentDioClient` God Class（~367 行）拆分为 `AuthInterceptor`（token 注入 + 401 刷新 + session 清理）、`ErrorInterceptor`（DioException → LucentApiException 映射）、`RetryInterceptor`（5xx/超时指数退避重试）三个独立拦截器；`LucentDioClient` 精简至 ~100 行纯配置 + interceptor 注册；新增 `lucentClientProvider` 统一 API 访问入口，17 个旧 `lucent*ApiProvider` 标记 `@Deprecated`；`LucentSseClient` 新增 `reconnect` 自动重连；19 个 feature 文件迁移到新 provider；`AuthRemoteDataSource` 从依赖 `LucentDioClient` 改为 `LucentClient` + `LucentSessionStore`；940 tests passed。
- ADR-0008 实施完成：Result 类型与统一错误处理。新增 `lib/core/errors/` 三文件——`AppError`（统一错误类型 + `AppErrorKind` 五分类：network/auth/server/business/unknown）、`Result<T>`（sealed class + `Success`/`Failure` + `fold`/`valueOrNull`/`errorOrNull`/`isSuccess`/`isFailure`）、`runGuarded<T>()`（泛化错误处理 helper，支持 `Ref` 和 `WidgetRef` 双入口）；`LucentErrorMapper` 新增 `toAppError(Object) → AppError` 方法，基于 HTTP status + Lucent envelope code + Dio error type 推导 `AppErrorKind`（auth code 优先于 HTTP status，`wrongPassword(401005)` 正确归类为 business 而非 auth）；`runAuthAction` 标记 `@Deprecated` 并委托到 `runGuarded`；5 个 UI 文件的 12 处 try-catch 迁移到 `runGuarded`（assistant 5 处、report 2 处、settings 5 处）；29 个新增测试全部通过，总计 969 tests passed。
- ADR-0009 实施第一步：Drift 本地持久化基础设施。移除 `sqflite`，新增 `drift` + `sqlite3_flutter_libs` + `connectivity_plus` + `drift_dev`；新建 `lib/core/database/` 目录——`AppDatabase`（WAL 模式 + 外键约束 + LazyDatabase）、6 张表（daily_records / medicine_dose_logs / current_medicines / health_context / today_suggestions / pending_sync_queue）、6 个 DAO（fetchByDate / replaceByDate / insertOptimistic / confirmSync / cleanup / watchByDate 等）、`SyncWorker`（connectivity_plus 监听 + 指数退避重放 + maxRetry 上限 + handler 注册机制）、`database_providers.dart`（keepAlive `appDatabaseProvider` + 6 个 DAO provider）；`LucentDailyRecordRepository` 迁移为 cache-first 模式（读：先缓存 + 后台刷新节流 30s → 网络回填；写：乐观本地副本 → 远程确认/失败入队 pending sync）；新增 `DailyRecordJsonCodec` 手动序列化；DAO 单元测试已编写（因网络受限无法下载 SQLite DLL 待执行）。`flutter analyze` 零问题。
- ADR-0009 实施第二步：全 Repository cache-first 迁移 + SyncWorker handler + 数据保留期清理。DAO 单元测试 22/22 通过；`HealthContextRepository` 迁移为 cache-first（读：缓存 + 后台刷新 30s 节流；写：远程成功后替换缓存快照）+ 手动 JSON 序列化；`TodaySuggestionNotifier._fetch()` 接入缓存（网络成功持久化，网络失败 stale-while-error 兜底）+ `TodaySuggestionJsonCodec` 序列化；新增 `CachedDoseLogDataSource` 包装 `DoseLogRemoteDataSource`（cache-first fetchForDate/create/mark + 60s 节流），3 个消费方迁移；`dailyRecordRepositoryProvider` 注册 `daily_record` SyncWorker replay handler（create/delete/update 三路回放）；新增 `cacheCleanupProvider` 读取 `DataRetentionPeriod` 设置，应用启动时调用 `dao.cleanup(cutoff)` 清理过期缓存（forever 跳过，pending 行保留）；测试适配 in-memory `AppDatabase`。991 tests passed。
- ADR-0010 实施完成：类型安全路由 — go_router_builder 全量迁移。`go_router_builder ^4.3.0` 加入 dev_dependencies；8 个 feature 各自 `presentation/routes.dart` 中使用 `@TypedGoRoute` 注解声明路由类（共 42 条路由），生成 `.g.dart` 提供 `$appRoutes` 聚合 + `.go()` / `.push()` / `.location` 类型安全导航 API；9 个旧手写路由文件删除，`router.dart` 通过 `...feature_routes.$appRoutes` spread 聚合；10 处字符串插值导航调用迁移为类型安全 API；`loginRouteForReturnTo` 从手动 `Uri` 构造改为 `LoginRoute(returnTo:).location`；5 个 shell tab 路由保持手写（`StatefulShellRoute.indexedStack`），`AppRoutes` 常量保留用于 tab 切换；嵌套路由通过 `@TypedGoRoute(routes: [...])` 声明（settings 三层嵌套 15 条、notifications 嵌套 2 条）；OAuth `state` 字段 shadowing 通过重命名 `buildPage` 参数为 `goState` 解决；camelCase → kebab-case 自动转换（`returnTo` → `return-to`）已在 6 个 test 文件同步；新增 12 个 `.location` URL 生成测试。1002 tests passed。
- 测试覆盖缺口补测（2026-07-11）：基于 `plans/2026-07-10-test-coverage-gap-analysis.md` 优先级清单，分五批补测 43 个测试文件共 ~652 个测试用例。第一批（84 个）：text_matcher（28）、auth_interceptor（15）、sync_worker（14）、suggestion_json_codec（11）、daily_record_json_codec（16），同时修复 enum 序列化不匹配 bug。第二批（116 个）：lucent_repository（28）、app_error（10）、result（10）、run_guarded（10）、retry_interceptor（21）、error_interceptor（13）、reminder_form_fields（20）、reminder_delete_dialog（4）。第三批高优先级（173 个）：dao_extended（31）、auth_remote_data_source_extended（53）、search_lucent_repository（17）、today_lucent_ai_repository（16）、risk_check_repository（15）、cached_dose_log_data_source（21）、auth_guarded（20）。第四批中优先级（~191 个）：oauth_callback_parser（15）、auth_action_runner（10）、oauth_panels（13）、assistant_remote_data_source（5）、health_context_lucent_repository（19）、today_ai_remote_data_source（13）、today_suggestion_remote_data_source（10）、dashboard_entity（8）、quick_actions（6）、week_strip（8）、ocr_entry_dialog（10）、status_overview（7）、range_picker_dialog（10）、settings_subpages（26）、reminder_form_body（15）。第五批低优先级（89 个）：scan_repository（11）、shell/branch（9）、shell/deferred_content（3）、shell/tab（8）、quick_entry_preferences（13）、voice_recording_service（22）、notification_permission_service（15）、reminder_rows（11）。覆盖扫描仓库 search/uploadImage/recognizeMedicine、Shell 分支/Tab 枚举逻辑、延迟内容加载、快捷录入偏好+频率裁剪、语音录制归一化+服务封装、通知权限 Android/iOS/macOS 全路径、提醒行组件渲染与交互。
- 集成测试统一迁移至 Patrol（2026-07-11）：`integration_test/` 下所有测试从 `IntegrationTestWidgetsFlutterBinding` + `testWidgets` 迁移到 `patrolTest`，项目中只保留一种 E2E 写法。删除 3 个失效测试（Today 页重构导致 Key 全部失效）；support helpers 参数从 `WidgetTester` 改为 `PatrolTester`；`pubspec.yaml` 移除 `integration_test` 显式依赖；`CONTRIBUTING.md` 合并两个章节为 "Integration Tests (Patrol)"。统一运行命令：`dart pub global run patrol_cli:main test --target integration_test/ --device emulator-5554`。

## 相关文档

- 产品方向：[[01-product/Product_Vision]]
- 阶段总纲：[[00-current/Work_Phase_Guide]]
- 下一步工作：[[00-current/Next_Plan]]
- 避错清单：[[02-reference/Project_Guardrails]]
- 操作指南：[[02-reference/how-to/README]]
- 延后项：[[00-current/TODO]]
- 变更日志：[[03-logs/MigrationLog]]
- 历史归档：[[04-archive/current-state-archive]]
