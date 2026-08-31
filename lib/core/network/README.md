# lib/core/network — Lucent HTTP / SSE 网络层

所有 Lucent 后端请求的唯一出口:`generated/lucent_api` 生成客户端 + Dio 装配与拦截器链
(token 注入/401 刷新、重试、错误映射、trace)+ SSE 流式客户端 + Problem Details
错误契约。

## 职责与边界
- 管:`client/`(Dio 实例、auth/retry/error/trace 拦截器、会话 token 存储、SSE)、
  `contract/`(路径常量、错误码、Problem Details → `LucentFailure` 映射)、根 barrel
  `api.dart`。
- 不管:业务 repository(各 feature data 层);`LucentFailure` 类型定义在
  core/errors/lucent_failure.dart;生成客户端由 Lucent OpenAPI 导出后经
  `dart run scripts/bootstrap_generated_sources.dart` 再生成。

## 对外契约
- 导出:barrel `api.dart` 一站式 re-export `lucent_api` 与本层符号(`LucentClient`、
  `LucentDioClient`、`LucentSseClient`、`LucentApiPaths`、`LucentErrorMapper`、
  `ProblemDetails`、`lucentClientProvider` 等),消费方 import `api.dart` 即可。
- 被依赖:几乎所有 feature 的 data 层(经 `lucentClientProvider` 取 `LucentClient`)、
  core/database/sync/worker.dart(重放用主 Dio)、core/auth(会话/trace 上报)。

## 不变量
- 全部请求走本层装配的同一 Dio;拦截器顺序 trace → 自定义 → auth → retry → error
  (test/core/network/dio_client_test.dart 与 interceptors/ 各测试锁定)。
- `generated/lucent_api/**` 禁手编,只能由 OpenAPI 导出后再生成(仓库 AGENTS.md 契约)。
- 错误映射只解析 RFC 9457 Problem Details(`application/problem+json`),旧 success
  envelope 不再解析(test/core/network/problem_details_test.dart、
  target_error_contract_test.dart)。
- SSE 请求 `receiveTimeout = 0`(AI 首 chunk 可超 10s),仅连接类错误按指数退避重连
  (test/core/network/sse_test.dart)。

## 依赖禁区
- 不 import 任何 `features/**`(core 禁反向依赖 feature);不依赖 UI widget。
- 业务代码不得绕过本层自建 Dio / HTTP 客户端。

## 陷阱与决策
- token 刷新走独立 `refreshDio`,避免刷新请求再次触发拦截器递归;它的 trace 拦截器
  不写 `lastTraceId`,防止污染用户可见 trace(见 dio_client.dart 注释)。
- 写请求默认不重试:需 `extra['retryEnabled'] = true` 且带 `Idempotency-Key` 头
  (client/retry_policy.dart,test/core/network/retry_policy_test.dart)。
- `api.dart` re-export `lucent_api` 是有意的 barrel 例外,移除会强迫每个 data 文件追加
  第二个 import(文件头注释已说明)。
- 拦截器单一职责拆分的决策见 ../../../docs/reference/adr/0004-network-layer-separation.md。
