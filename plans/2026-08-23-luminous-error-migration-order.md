# Luminous 错误处理并行迁移顺序（临时执行指引）

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans (recommended). Steps use checkbox syntax for tracking.

**Goal:** 在 Lucent 执行 neverthrow 错误边界迁移期间，独立完成 Luminous 的 RFC 9457 Problem Details 消费、LucentFailure 控制流、网络认证边界、repository/provider TaskEither 迁移和旧错误类型清理。

**Architecture:** Lucent 是 Problem Details、错误码、SSE error schema 和 OpenAPI 的唯一事实来源；Luminous 只消费这些契约，不自行增加或重定义服务端错误语义。Luminous datasource 保留 Dio Future/Stream 传输职责，repository 将预期失败转换为 fpdart TaskEither<LucentFailure, T>，provider 消费 Left 并投影到 Riverpod AsyncValue 或 action state，widget 不处理网络 try/catch。

**Tech Stack:** Flutter、Dart 3.12、Riverpod 3、fpdart 1.2、Dio 5、OpenAPI 生成客户端、Vitest 对应的 Lucent contract、Flutter test、flutter analyze。

---

## 0. 并行边界与当前基线

本文件是 Luminous 2026-08-17-error-handling-reform-plan.md 的并行执行顺序。它不修改 Lucent 的错误码和 OpenAPI，也不替代跨仓同步阶段。

当前已具备的基础：

- lib/core/network/problem_details.dart 已解析 HTTP Problem Details 和 SSE Problem Details。
- lib/core/errors/lucent_failure.dart 已把 Problem Details 转换为 LucentFailure。
- lib/core/network/error_mapper.dart 已以 Problem Details 为目标格式，不再解析旧成功 envelope。
- lib/core/network/retry_policy.dart、error_interceptor.dart、retry_interceptor.dart 已有目标态基础和对应测试。
- test/core/network/target_error_contract_test.dart、test/core/errors/lucent_failure_test.dart、test/core/network/retry_policy_test.dart 已覆盖核心目标态的一部分。

并行规则：

- 可以与 Lucent 的内部 ResultAsync 迁移并行；不能与 Lucent 同时修改共享 ProblemCode、Problem Details 字段、SSE status 枚举或 Retry-After 语义。
- 不运行 bootstrap_generated_sources.dart，直到 Lucent 导出新的 docs/openapi.json；未同步前只使用当前已锁定的契约 fixtures 和现有生成客户端。
- 不建立旧错误响应与新 Problem Details 的运行时兼容期。error_mapper.toAppError、core/errors/Result、runGuarded 只能作为待删除旧实现，不能继续扩展新调用方。
- 每个 feature 单独迁移、单独验证、单独提交；不把多个 feature 的 provider/repository 改动合成一个大提交。
- 每次代码提交前运行 dart run scripts/check_doc_coverage.dart --warning-only，并追加当天 docs/03-logs/migration-log/2026-08-23.md；跨日执行时追加实际日期文件。
- 不直接修改 lib/l10n/app_zh.arb 或 app_en.arb。只有用户可见文案变化时，修改 lib/l10n/src/ 片段，再运行 arb merge 和 flutter gen-l10n。

## 1. 顺序总览

| 顺序 | 波次 | 主要范围 | 可否与 Lucent 并行 | 退出条件 |
| --- | --- | --- | --- | --- |
| 0 | 基线重跑 | 旧 Result、AppError、runGuarded、Dio catch、repository Future 清单 | 可以 | 有分类清单和当前验证基线 |
| 1 | 网络核心收口 | error/auth/retry interceptor、API exception、Problem Details fixtures | 可以 | 只有 LucentFailure 进入网络错误边界，401 refresh 规则固定 |
| 2 | Auth/session repository | auth datasource、sessions repository、登录/注册/刷新 provider | 可以 | token 失效、refresh 失效和普通 401 分支明确 |
| 3 | health_context + today | 健康上下文、今日分析、今日建议 repository/provider | 可以 | TaskEither 边界稳定，UI 不再读旧 Result |
| 4 | record + assistant + medicine | 记录、助手、用药、扫描/搜索相关 repository/provider | 可以 | 流式取消和普通失败边界分离 |
| 5 | 其余业务 repository | health_event、report、notification、settings、mine、legal、support | 可以 | 所有可恢复 repository 统一 TaskEither |
| 6 | provider/UI 编排清理 | 删除 runGuarded、旧 Result、AppError fallback 和 widget 网络 catch | 可以 | 生产代码没有旧错误类型引用 |
| 7 | SSE 与流式错误 | assistant/today/report SSE 消费和取消语义 | 可以，契约锁定后 | event:error 正确映射，断流不伪装成业务失败 |
| 8 | OpenAPI/生成客户端同步 | Lucent 导出后生成客户端和跨仓合同测试 | 不可提前并行 | 生成客户端与 Lucent 新 OpenAPI 一致 |
| 9 | 全量门禁 | analyze、test、文档、静态清理、删除临时计划 | 串行 | 双仓库完成最终验收 |

## 2. Task 0：重跑 Luminous 错误边界清单

**Files:**

- Inspect: plans/2026-08-17-error-handling-reform-plan.md
- Inspect: lib/core/errors/
- Inspect: lib/core/network/
- Inspect: lib/features/*/data/repositories/
- Inspect: lib/features/*/presentation/
- Record: 本计划的勾选状态和每个 feature 的提交 SHA

- [x] Step 1: 固定分支和工作区

运行：

~~~powershell
git rev-parse HEAD
git status --short --untracked-files=all
~~~

预期：记录当前 Luminous 分支和 SHA；不切换分支，不修改 Lucent 文件，不运行生成客户端。

记录（2026-08-23）：

- 分支：`refactor`；HEAD：`5edf883e8e459cb8921cfca90c1bbfaa52627b58`（fix(error): Today AI 数据源空响应使用 LucentFailure）
- 工作区：仅 `plans/README.md`（本计划登记条目）与未跟踪的本计划文件；Lucent 正在执行 neverthrow 迁移且未导出新 openapi.json（Task 8 保持等待，不提前运行 bootstrap）

- [x] Step 2: 分类旧错误边界

运行：

~~~powershell
rg -n --glob '*.dart' 'runGuarded|Result<|Success<|Failure<|AppError|toAppError|DioException|catch \(' lib test
rg -n --glob '*.dart' 'LucentFailure|ProblemDetails|TaskEither|Either' lib test
~~~

将命中项分为四类：repository 可恢复失败、provider action 失败、编程/协议不变量、取消/SSE 断流。不得用搜索数量代替分类判断。

分类清单（2026-08-23，按任务归属）：

**R — repository/datasource 可恢复失败（迁移到 TaskEither<LucentFailure, T>）**

- `health_context/data/repositories/lucent.dart`（L69-208 全部写操作：catch DioException → enqueue 离线 → throw toAppError）→ Task 3
- `today/data/repositories/lucent.dart`（L85-526 多处 catch + talker + degraded 降级：明确降级需保留并记录观测）→ Task 3
- `today/data/repositories/lucent_ai.dart`（read/refresh/generate；L50 流结束无结果 StateError 属协议不变量）→ Task 3
- `record/data/repositories/lucent_daily.dart`（L96-321：toAppError throw + `fetchRecordsResult` 返回 Result）→ Task 4
- `medicine/data/datasources/dose_log_cached.dart`（L73-121 toAppError throw）→ Task 4
- `medicine/data/datasources/{dose_log_remote,medicine_detail_remote,safety_tips_remote,risk_check_remote,reminder_remote}.dart`（LucentApiException throw）→ Task 4
- `auth/data/datasources/auth.dart`（LucentAuthRepository，生成客户端调用 + _requireBody StateError + 注销 finally 清 session）→ Task 2
- `auth/data/repositories/sessions.dart`（StateError 协议不变量 + Dio 直调）→ Task 2
- `core/database/sync/worker.dart` + `core/database/models/pending_sync_error_details.dart`（toAppError → 离线队列持久化，AppErrorKind 字段）→ Task 5/6
- `search/data/datasources/medicine_search.dart`、`record/data/datasources/record.dart`、`report/data/datasources/report.dart`、`settings/data/datasources/profile_remote.dart`、`health_context/data/datasources/snapshot.dart`、`assistant/data/datasources/assistant.dart`、`today/data/datasources/{suggestion_remote,ai_remote}.dart`、`report/data/datasources/ai_summary_remote.dart`（datasource 保持 Future/Stream 传输职责，确认不抛旧类型）→ 对应任务

**P — provider action 失败（迁移到 TaskEither.run() + action state）**

- `auth/presentation/providers/forms/{login,register,password_reset}.dart`（runGuarded ×6）→ Task 2
- `assistant/presentation/pages/page.dart`（runGuarded ×6）→ Task 4
- `report/presentation/pages/clinic_summary_shared.dart`、`report/presentation/widgets/sheets/share_management.dart`、`report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart`、`report/presentation/utils/export_actions.dart`（runGuarded/toAppError）→ Task 5
- `settings/presentation/providers/user_settings.dart`、`settings/presentation/pages/{ai,data_export,language,security_pin}.dart`（runGuarded）→ Task 5
- `mine/presentation/mappers/sync_error_user_message.dart`（AppErrorKind 分派）→ Task 5/6

**I — 编程/协议不变量（保持 throw/FormatException，不转 LucentFailure）**

- `core/errors/{error,result,run_guarded}.dart`、`core/network/error_mapper.dart`（toAppError 旧投影）、`core/errors/user_message.dart`（toAppError 委托）→ Task 6 删除/重写
- `core/network/api_exception.dart`（旧类型，sse/wechat/medicine 仍有构造点，保留定位）→ Task 1 不新增依赖，Task 4/7 迁移后 Task 6 清理
- `core/network/map_utils.dart` requireMap（LucentApiException SSE payload）→ Task 7
- `core/network/sse.dart`（L97 空流 LucentApiException）→ Task 7
- `auth/data/datasources/wechat/mobile_auth_client_fluwx.dart`（LucentApiException 本地 SDK 失败，非网络）→ Task 2 判断保留异常
- `today/data/repositories/lucent_ai.dart` L50（流结束无结果 StateError）→ Task 3 保持
- 各 repository 的 StateError（空 body、列表结构不符）= 协议不变量，保持

**C — 取消/SSE 断流（保持 Stream 错误/取消语义）**

- `core/network/sse.dart`（postJson + reconnect 策略）→ Task 7
- `assistant/data/datasources/assistant.dart`、`today/data/datasources/ai_remote.dart`、`report/data/datasources/ai_summary_remote.dart` 的 Stream 路径 → Task 7
- 现有测试：`test/assistant/remote_data_source_stream_test.dart`、`test/today/ai_remote_data_source_test.dart`、`test/report/ai_summary_remote_data_source_test.dart`、`test/core/network/{sse_test,problem_details_test}.dart`

**测试归属**

- 旧类型测试（Task 6 处理）：`test/core/errors/{app_error_test,result_test,run_guarded_test,error_mapper_to_app_error_test}.dart`
- 目标态保留：`test/core/errors/lucent_failure_test.dart`、`test/core/network/{target_error_contract_test,target_auth_interceptor_test,retry_policy_test,problem_details_test,sse_test}.dart`
- Task 1：`test/core/network/{dio_client_test,auth_interceptor_test,retry_interceptor_test,target_error_contract_test,target_auth_interceptor_test}.dart`
- Task 2：`test/auth/**`、`test/core/providers/security_elevation_test.dart`、`test/core/network/interceptors/auth_interceptor_test.dart`
- Task 3：`test/health_context/**`、`test/today/**`
- Task 4：`test/{record,assistant,medicine,scan,search}/**`
- Task 5：`test/{health_event,report,notification,settings,mine,legal,support}/**`
- Task 7：`test/assistant/remote_data_source_stream_test.dart`、`test/today/ai_remote_data_source_test.dart`、`test/report/ai_summary_remote_data_source_test.dart`、`test/core/network/problem_details_test.dart`

**各 feature 最近提交 SHA（盘点时点）**

auth `8912d278` / today `5edf883e` / record `d40071c9` / medicine `557b32ff` / report `9666115d` / mine `80103bb2` / settings `f55426a2` / health_context `0b288145` / health_event `feba6c0b` / notification `4433d3ad` / assistant `7faa9dec` / scan `c75f3f06` / search `498e7806` / legal `33077e6f` / support `dcd3cdb3` / health_data `ed9594c4` / more `6ef8d6ad` / shell `0d65d94b` / core-network `255bb33f` / core-errors `255bb33f`

**补充边界事实（盘点确认）**

- `record/data/repositories/lucent_daily.dart:304` 的 `fetchRecordsResult` 是全库唯一 `Future<Result<T>>` 业务签名且**无调用方** → Task 4 可直接删除
- pending sync 模型 `core/database/models/pending_sync_error_details.dart`（+ .g/.freezed）把 `AppErrorKind` 序列化落库，worker/dao/mine banner 三方引用 → 删除旧类型（Task 6）前需同步迁移该模型
- 明确吞错降级点（Task 5 清理/记录）：`search/repositories/lucent.dart:58`（fetchDetail→null）、`notification/repositories/lucent.dart:65`（unread→0）、`medicine/lucent_workspace.dart`（3 处→空集）、`record/repositories/lucent.dart`（→空列表）、`today/repositories/lucent.dart`（9 处 degraded dashboard）、`health_data/health_platform.dart`（4 处→降级值）
- StateError 协议不变量保持点：`scan/repositories/scan.dart:59,91`、`record/datasources/record.dart:203`、`health_event/repositories/lucent.dart:105,150,165,181`、`auth/repositories/sessions.dart:16,22`、`core/network/response_body.dart:8`（requireData）、`today/repositories/lucent_ai.dart:50`
- 隐式 R 类（无 catch、走 requireData/拦截器）：medicine/assistant/support/search/report/settings 多数 datasource；`today/datasources/ai_remote.dart` 已抛 LucentFailure（目标样例）
- `auth/data/datasources/auth.dart` 中的 `LucentAuthRepository` 是计划所称 "auth datasource"（生成客户端直调 + _requireBody + 注销 finally 清 session）
- `lib/core/auth/session_provider.dart` 是 auth 会话 provider 实际位置（`lib/features/auth/presentation/providers/session.dart` 仅为 re-export）

- [x] Step 3: 运行基线验证

运行：

~~~powershell
flutter analyze
flutter test test/core/errors test/core/network
dart run scripts/check_doc_coverage.dart --warning-only
~~~

预期：记录已有失败；后续每个波次只比较本波次引入的变化。

基线结果（2026-08-23）：

- `flutter analyze`：0 问题
- `flutter test test/core/errors test/core/network`：全部通过
- `dart run scripts/check_doc_coverage.dart --warning-only`：通过（无映射代码变更）
- 后续波次只与本基线比较新增变化

## 3. Task 1：收口网络错误和认证拦截器

**Files:**

- Modify: lib/core/network/error_mapper.dart
- Modify: lib/core/network/interceptors/error_interceptor.dart
- Modify: lib/core/network/interceptors/retry_interceptor.dart
- Modify: lib/core/network/interceptors/auth_interceptor.dart
- Modify: lib/core/network/api_exception.dart
- Modify: lib/core/network/retry_policy.dart
- Test: test/core/network/target_error_contract_test.dart
- Test: test/core/network/dio_client_test.dart
- Test: test/core/network/interceptors/target_auth_interceptor_test.dart
- Test: test/core/network/target_error_contract_test.dart
- Test: test/core/network/interceptors/retry_interceptor_test.dart
- Test: test/core/network/interceptors/auth_interceptor_test.dart

- [ ] Step 1: 固定 Dio 到 LucentFailure 的唯一映射

Dio 的 HTTP response 必须先校验 Content-Type 为 application/problem+json，再解析 ProblemDetails；缺少 body、错误媒体类型、字段类型不符和服务端协议不变量保持 FormatException，不转换为业务 LucentFailure。网络连接、timeout、证书和明确的 HTTP Problem Details 转换为 LucentFailure。

- [ ] Step 2: 固定重试边界

RetryPolicy 只允许 GET 等幂等请求按状态和网络错误重试；写请求必须显式 retryEnabled=true 且带非空 Idempotency-Key。Problem Details 中 retryable=false 只能禁止重试，服务端的 retryable=true 不得扩大客户端允许的状态集合。Retry-After 只接受当前契约约定的非负整数秒。

- [ ] Step 3: 固定 token refresh 触发条件

AuthInterceptor 只对 AUTH_TOKEN_EXPIRED 或已锁定的明确 token-expired 语义触发 refresh；AUTH_REFRESH_TOKEN_INVALID、AUTH_REQUIRED、AUTH_WRONG_PASSWORD 和普通 403 不得触发 refresh。并发请求只允许一次 refresh，refresh 失败必须清理 session 并把原始 LucentFailure 传回调用方。

- [ ] Step 4: 删除新增代码对 LucentApiException 的依赖

保留旧类型只用于定位剩余引用，不增加新的 toAppError 调用。网络层向上抛出的 DioException.error 必须是 LucentFailure；无法分类的错误保留 cause 和原始异常供日志使用，但不得把内部异常文本作为用户文案。

- [ ] Step 5: 验证并提交网络核心

运行：

~~~powershell
flutter test test/core/network
flutter analyze
dart run scripts/check_doc_coverage.dart --warning-only
~~~

提交：

~~~powershell
git add lib/core/network test/core/network docs/03-logs/migration-log/2026-08-23.md
git diff --cached --name-status
git commit -m 'refactor(error): 收口 Luminous 网络失败边界'
~~~

## 4. Task 2：迁移 Auth/session repository 和 provider

**Files:**

- Modify: lib/features/auth/data/datasources/auth.dart
- Modify: lib/features/auth/data/repositories/sessions.dart
- Inspect/Modify: lib/features/auth/presentation/providers/
- Inspect/Modify: lib/features/auth/presentation/providers/forms/
- Modify: lib/core/network/session_store.dart
- Modify: lib/core/network/security_elevation_token_holder.dart
- Test: test/core/network/interceptors/auth_interceptor_test.dart
- Test: test/auth/
- Test: test/core/providers/security_elevation_test.dart

- [ ] Step 1: 固定 repository 返回类型

认证 repository 的预期网络失败统一返回 TaskEither<LucentFailure, T>；datasource 保持 Future/Stream 并继续抛出 DioException。不要让 datasource 直接返回 Result，也不要在 widget 层捕获 DioException。

目标形态：

~~~dart
TaskEither<LucentFailure, AuthSession> login({
  required String email,
  String? password,
  String? code,
}) {
  return TaskEither.tryCatch(
    () => datasource.login(email: email, password: password, code: code),
    (error, stackTrace) => LucentErrorMapper.fromObject(error),
  );
}
~~~

- [ ] Step 2: 迁移登录、注册、验证、刷新和注销

分别覆盖成功、AUTH_TOKEN_EXPIRED、AUTH_REFRESH_TOKEN_INVALID、AUTH_WRONG_PASSWORD、验证码错误、网络 timeout、Problem Details 4xx 和未知协议异常。refresh 失败不能被转成普通网络错误，注销失败不能清空尚未确认的本地 session。

- [ ] Step 3: 迁移 provider action state

provider 调用 TaskEither.run() 并将 Left 转换为现有 action state 或 AsyncValue.error；widget 不导入 fpdart，不读取 DioException.response，不自行解析 code/status。token expired 的导航和 refresh invalid 的登出行为只在 auth provider/interceptor 处理。

- [ ] Step 4: 保留 Security Elevation token 语义

elevation token 无效、过期、拒绝和网络故障分别保持 LucentFailure 的 code/kind；不把 elevation 失败吞成普通未登录，也不在失败时错误写入本地 token holder。

- [ ] Step 5: 验证并提交 auth/session

运行：

~~~powershell
flutter test test/auth test/core/network/interceptors/auth_interceptor_test.dart test/core/providers/security_elevation_test.dart
flutter analyze
dart run scripts/check_doc_coverage.dart --warning-only
~~~

提交：

~~~powershell
git add lib/features/auth lib/core/network/session_store.dart lib/core/network/security_elevation_token_holder.dart test/auth test/core/network/interceptors/auth_interceptor_test.dart test/core/providers/security_elevation_test.dart docs/03-logs/migration-log/2026-08-23.md
git diff --cached --name-status
git commit -m 'refactor(auth): 迁移 Luminous 认证 repository Result'
~~~

## 5. Task 3：迁移 health_context 和 today

**Files:**

- Modify: lib/features/health_context/data/repositories/lucent.dart
- Modify: lib/features/today/data/repositories/lucent.dart
- Modify: lib/features/today/data/repositories/lucent_ai.dart
- Modify: lib/features/today/data/datasources/ai_remote.dart
- Modify: lib/features/today/data/datasources/suggestion_remote.dart
- Modify: lib/features/today/presentation/providers/
- Test: test/health_context/
- Test: test/today/
- Test: test/core/errors/
- Test: test/core/network/

- [ ] Step 1: 迁移 health_context repository

将读取、创建、更新、删除、profile/allergy/condition/medicine 写操作改成 TaskEither；资源不存在使用服务端 Problem Details 的 code，不用本地猜测 HTTP status。离线缓存或本地 snapshot 的明确降级保持成功/旧数据结果，但必须记录失败次数和可观测事件。

- [ ] Step 2: 迁移 today repository/provider

今日建议、分析、刷新、反馈和生成请求的服务端业务失败进入 Left；空建议、没有分析结果和用户取消不转换成 server failure。provider 只消费 Left/Right，widget 只消费 provider state。

- [ ] Step 3: 处理缓存写失败

缓存写失败只有在现有业务合同允许 best-effort 时才记录并继续；若缓存是请求成功的必要条件，返回 Left。为这两种路径分别写 repository 测试，不保留 catch 后无条件成功。

- [ ] Step 4: 验证并提交两个独立领域

分别运行：

~~~powershell
flutter test test/health_context
flutter analyze
dart run scripts/check_doc_coverage.dart --warning-only

flutter test test/today
flutter analyze
dart run scripts/check_doc_coverage.dart --warning-only
~~~

分别提交：

~~~powershell
git add lib/features/health_context test/health_context docs/03-logs/migration-log/2026-08-23.md
git diff --cached --name-status
git commit -m 'refactor(health-context): 迁移 repository Failure 边界'

git add lib/features/today test/today docs/03-logs/migration-log/2026-08-23.md
git diff --cached --name-status
git commit -m 'refactor(today): 迁移 repository Failure 边界'
~~~

## 6. Task 4：迁移 record、assistant 和 medicine

**Files:**

- Modify: lib/features/record/data/repositories/lucent.dart
- Modify: lib/features/record/data/repositories/lucent_daily.dart
- Modify: lib/features/assistant/data/repositories/lucent.dart
- Modify: lib/features/assistant/data/datasources/assistant.dart
- Modify: lib/features/medicine/data/repositories/lucent_workspace.dart
- Modify: lib/features/medicine/data/repositories/risk_check.dart
- Modify: lib/features/medicine/data/datasources/
- Modify: lib/features/scan/data/repositories/scan.dart
- Modify: lib/features/search/data/repositories/lucent.dart
- Modify: lib/features/search/data/datasources/
- Test: test/record/
- Test: test/assistant/
- Test: test/medicine/
- Test: test/scan/
- Test: test/search/

- [ ] Step 1: 迁移 record repository

日记录、附件、meal analysis 和 daily refresh 的可恢复 API 失败统一进入 TaskEither。分页空页是 Right；服务端资源不存在、冲突、校验失败进入 Left；本地缓存和离线队列失败按既有离线合同记录并可诊断。

- [ ] Step 2: 迁移 assistant repository

普通会话读取、写入、重命名、删除和 regenerate 的 HTTP 失败进入 TaskEither；assistant Stream 的 chunk、done、error、cancelled 保持 Stream 事件/错误语义，不把断流强行转换为 TaskEither。

- [ ] Step 3: 迁移 medicine、scan、search

药品查询、风险检查、剂量日志、提醒和识别请求按服务端 code 进入 LucentFailure；识别候选为空是合法 Right，不是错误；上游解析不符合生成客户端结构时保持协议异常并记录。

- [ ] Step 4: 分领域验证和提交

每个 feature 必须单独运行 flutter test、flutter analyze、文档覆盖检查，并分别提交。不得将 record、assistant、medicine、scan、search 合并成一个提交。

## 7. Task 5：迁移其余业务 repository/provider

**Files:**

- Modify: lib/features/health_event/data/repositories/lucent.dart
- Modify: lib/features/report/data/repositories/lucent.dart
- Modify: lib/features/report/data/repositories/lucent_ai_summary.dart
- Modify: lib/features/report/data/repositories/lucent_review.dart
- Modify: lib/features/notification/data/repositories/lucent.dart
- Modify: lib/features/settings/data/repositories/lucent.dart
- Modify: lib/features/settings/data/repositories/notification_preferences.dart
- Modify: lib/features/mine/data/repositories/lucent.dart
- Modify: lib/features/legal/data/repositories/lucent.dart
- Modify: lib/features/support/data/repositories/lucent.dart
- Test: 对应 feature 下的 repository/provider/controller tests

- [ ] Step 1: 迁移同步 CRUD

health_event、settings、notification、legal、support 的读写 repository 改为 TaskEither；合法空列表、未配置可选数据和本地缺省值保持 Right，HTTP 4xx/5xx 和解析异常不能被默认值吞掉。

- [ ] Step 2: 迁移 report 与 mine

报告生成、分享管理、导出、账户设置和同步状态分别处理业务失败、依赖失败、权限失败和取消；重试决策只由 LucentFailure、HTTP status、幂等性和 Retry-After 共同决定。

- [ ] Step 3: 清理 provider 中的网络 try/catch

provider 只在需要释放本地资源或记录明确 action state 时 catch；网络失败直接消费 TaskEither Left。删除只为继续流程而存在的空 catch 和默认成功状态。

- [ ] Step 4: 单 feature 验证和提交

每个 feature 运行对应测试、flutter analyze、文档覆盖检查并独立提交；可见文案变化必须同步 lib/l10n/src/ 和 Localization.md。

## 8. Task 6：删除旧 Result、AppError 和 runGuarded

**Files:**

- Modify: lib/core/errors/user_message.dart
- Delete after reference removal: lib/core/errors/result.dart
- Delete after reference removal: lib/core/errors/run_guarded.dart
- Delete after reference removal: lib/core/errors/error.dart
- Modify/Delete: lib/core/network/error_mapper.dart
- Modify: lib/core/logger/sentry_talker_observer.dart
- Inspect: lib/features/**/presentation/
- Test: test/core/errors/
- Test: test/core/logger/

- [ ] Step 1: 建立旧类型零引用检查

运行：

~~~powershell
rg -n --glob '*.dart' 'Result<|Success<|Failure<|runGuarded|AppError|AppErrorKind|toAppError' lib test
~~~

预期：只有待删除文件自身和迁移计划文档命中；业务代码不再依赖旧类型。

- [ ] Step 2: 删除旧应用错误投影

删除 error_mapper.toAppError 和仅服务旧 AppError 的分支；user_message.dart、Sentry observer、provider action state 直接支持 LucentFailure。保留 cause 只供日志，不把原始 DioException 文本展示给用户。

- [ ] Step 3: 删除自建 Result 和 runGuarded

确认所有 repository/provider 已使用 fpdart Either/TaskEither 后删除 core/errors/result.dart 和 run_guarded.dart。不要用新的项目类型别名替换它们，直接使用 fpdart 的 Either 和 TaskEither。

- [ ] Step 4: 验证并提交清理

运行：

~~~powershell
flutter test test/core/errors test/core/logger
flutter analyze
dart run scripts/check_doc_coverage.dart --warning-only
~~~

提交：

~~~powershell
git add lib/core/errors lib/core/network/error_mapper.dart lib/core/logger test/core/errors test/core/logger docs/03-logs/migration-log/2026-08-23.md
git diff --cached --name-status
git commit -m 'refactor(error): 删除 Luminous 旧错误类型'
~~~

## 9. Task 7：统一 SSE error 事件消费

**Files:**

- Modify: lib/core/network/sse.dart
- Modify: lib/features/assistant/data/datasources/assistant.dart
- Modify: lib/features/today/data/datasources/ai_remote.dart
- Modify: lib/features/report/data/datasources/ai_summary_remote.dart
- Test: test/assistant/remote_data_source_stream_test.dart
- Test: test/today/ai_remote_data_source_test.dart
- Test: test/report/ai_summary_remote_data_source_test.dart
- Test: test/core/network/problem_details_test.dart

- [ ] Step 1: 解析 event: error

SSE data 按 SseProblemDetails.fromJson 解析，构造 LucentFailure.fromSseProblemDetails；不读取旧 type/message/data envelope，不把 status 字段当作 HTTP status code。

- [ ] Step 2: 区分服务端 error event 和连接终止

服务端明确发送 event: error 时向上游发出 LucentFailure；客户端取消、连接断开、server shutdown 和 premature close 保持 Stream error/取消语义，并按现有重连策略处理。不得把连接断裂伪装成业务 Problem Details。

- [ ] Step 3: 补齐四类流测试

覆盖 result→done、error→终止、malformed error payload→协议异常、cancelled/断流→既定 stream error。确认 error event 不发送堆栈、requestId、statusCode 或原始服务端敏感数据。

- [ ] Step 4: 验证并提交 SSE 领域

运行：

~~~powershell
flutter test test/assistant/remote_data_source_stream_test.dart test/today/ai_remote_data_source_test.dart test/report/ai_summary_remote_data_source_test.dart test/core/network/problem_details_test.dart
flutter analyze
dart run scripts/check_doc_coverage.dart --warning-only
~~~

提交：

~~~powershell
git add lib/core/network/sse.dart lib/features/assistant/data/datasources/assistant.dart lib/features/today/data/datasources/ai_remote.dart lib/features/report/data/datasources/ai_summary_remote.dart test/assistant test/today test/report test/core/network/problem_details_test.dart docs/03-logs/migration-log/2026-08-23.md
git diff --cached --name-status
git commit -m 'refactor(error): 统一 Luminous SSE failure 消费'
~~~

## 10. Task 8：等待 Lucent OpenAPI 后同步生成客户端

**Files:**

- Input: Lucent/docs/openapi.json
- Generate: generated/lucent_api/
- Modify: 受生成客户端类型变化影响的 repository/datasource
- Test: test/core/network/target_error_contract_test.dart、对应 API contract tests
- Docs: docs/03-logs/migration-log/实际执行日期.md

- [ ] Step 1: 确认 Lucent 已完成对应后端波次

确认 Lucent 已导出新的 docs/openapi.json，并明确列出新增/删除的 ProblemCode、Problem Details schema、SSE schema 和 endpoint response 变化。Luminous 不自行猜测这些变化。

- [ ] Step 2: 运行官方生成流程

从 Luminous 执行：

~~~powershell
dart run scripts/bootstrap_generated_sources.dart
~~~

不得手工修改 generated/lucent_api/；生成结果只在 OpenAPI 已锁定后进入提交。

- [ ] Step 3: 修复生成客户端适配点

只修复因为生成客户端真实变化导致的类型、字段或 endpoint 调用错误；repository 的失败统一继续映射为 LucentFailure，widget 不直接依赖生成客户端的 DioException。

- [ ] Step 4: 运行跨仓合同验证

运行：

~~~powershell
flutter analyze
flutter test test/core/network test/auth
dart run scripts/check_doc_coverage.dart --warning-only
~~~

此任务必须与 Lucent 的 OpenAPI 导出串行完成，不能在 Lucent 修改契约期间提前提交。

## 11. Task 9：全量门禁和临时计划清理

**Files:**

- Inspect: lib/core/errors/
- Inspect: lib/core/network/
- Inspect: lib/features/**/data/repositories/
- Inspect: lib/features/**/presentation/
- Modify: docs/02-reference/Localization.md only when visible copy changed
- Modify: docs/00-current/ relevant state file
- Append: docs/03-logs/migration-log/2026-08-23.md
- Delete: plans/2026-08-23-luminous-error-migration-order.md
- Modify: plans/README.md

- [ ] Step 1: 清理静态残留

运行：

~~~powershell
rg -n --glob '*.dart' 'Result<|Success<|Failure<|runGuarded|AppError|toAppError|DioException.*catch' lib
rg -n --glob '*.dart' 'application/json|message.*data|statusCode|requestId' lib/core lib/features
~~~

逐项确认命中是生成客户端、协议不变量、日志展示或 transport metadata；旧错误 fallback 和 widget 网络解析不能保留。

- [ ] Step 2: 运行 Luminous 全量门禁

运行：

~~~powershell
flutter analyze
flutter test
dart run scripts/check_doc_coverage.dart --verify
~~~

预期：三条命令退出码为 0；不能用放宽 analyzer、跳过测试或忽略文档检查结束迁移。

- [ ] Step 3: 更新状态和日志

把稳定的客户端错误边界、重试规则、SSE 消费规则和删除旧类型的结果写入相关 current state、ADR/参考文档和当天迁移日志。完成后删除本临时计划并从 plans/README.md 的 Current Plans 删除条目。

## 12. 提交和并行同步规则

每个 Luminous 领域提交前运行：

~~~powershell
git status --short
git diff --name-only
git diff --cached --name-status
flutter analyze
dart run scripts/check_doc_coverage.dart --warning-only
~~~

提交内容只能包含当前领域的 Dart 代码、对应测试和必要文档。不要把 generated/lucent_api、OpenAPI 同步和业务 repository 迁移放在一个提交中。

与 Lucent 的同步点只有两个：

- 契约锁定点：Problem Details 字段、ProblemCode、SSE error payload、Retry-After 语义发生变化时，停止当前 Luminous 波次，等待 Lucent 更新并确认。
- 生成同步点：Lucent 导出 openapi.json 后，单独执行 Task 8；生成客户端同步完成前，不进行最终跨仓库 e2e 验收。

## 13. 计划完成判据

- 所有预期网络/业务失败在 Luminous repository 边界是 TaskEither<LucentFailure, T>；datasource 仍只负责 Future/Stream 传输。
- provider 不再依赖旧 Result、AppError 或 runGuarded；widget 不解析 DioException 或 Problem Details。
- auth refresh、普通 HTTP retry、SSE error/cancel、离线 best-effort 各自有独立且可测试的语义。
- LucentFailure 保留稳定 code、status、retryable、retryAfter、traceId 和安全 detail；不展示原始异常文本。
- generated client 只在 Lucent OpenAPI 导出后同步，最终 contract/e2e 测试与双仓库文档检查通过。
- 旧错误类型、旧成功 envelope fallback、无语义 catch 和临时计划均已删除。
