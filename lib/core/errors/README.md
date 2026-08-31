# lib/core/errors — 失败类型与用户消息归一

目录持有三件事:`LucentFailure`(repository 边界的失败类型)、`NetworkErrorL10n`(网络错误码
→ 本地化文案)、`userMessageFromError`(任意 error → 可展示文本)。

## 职责与边界

- 管:`LucentFailure` + `LucentFailureKind`(network/authentication/business/server/unknown)
  的归类、`AUTH_*` code 谓词、网络错误码的 l10n 映射、错误对象到用户消息的统一入口。
- 不管:fpdart `Either`/`TaskEither` 在 repository 的用法(ADR-0005)、HTTP 线格式
  `ProblemDetails`(在 `../network/contract/problem_details.dart`)、页面错误视图
  (`../widgets/common/feedback/page_state.dart`)。

## 对外契约

- 导出:`lucent_failure.dart` 的 `LucentFailure` / `LucentFailureKind` / `kPasswordNotSetCode`;
  `network_error_l10n.dart` 的 `NetworkErrorL10n.map`;`user_message.dart` 的
  `userMessageFromError`。
- 被依赖:`core/network`(error_mapper/sse/retry_policy/auth_interceptor 等)、`core/auth`、
  `core/database`、`core/logger`,以及 auth/assistant/health_*/legal 等 feature 的
  repository 与 provider — 全仓失败语义的枢纽。

## 不变量

- kind 只能经工厂归类:`fromProblemDetails` / `fromSseProblemDetails` 按 status 与 SSE code
  判定(401/403→authentication、5xx→server、4xx→business),不散落手写判断
  (`test/core/errors/lucent_failure_test.dart`)。
- `ProblemDetails` 仍是 wire 表示,`LucentFailure` 只归一化不替代(类注释明示)。
- 面向用户:任何 error 上屏前必须过 `userMessageFromError` / `LucentErrorMapper.fromObject`,
  禁止 `error.toString()`;有 `networkErrorCode` 且能取 l10n 时映射优先。
- `NetworkErrorL10n.map` 对 `NetworkErrorCode` 穷举 switch,新增错误码编译期强制补映射。

## 依赖禁区

- 仅依赖 `../network/contract/`(error_code/problem_details)与 `l10n` 生成物;不依赖
  network 客户端实现,不依赖 features。
- domain 层拿不到 `AppLocalizations`,l10n 映射只能在 presentation 边界调用。

## 陷阱与决策

- `isNetworkConnectivityError` 的错误码清单在此收敛:连接类失败不得清 session store
  (重试语义在 `../auth/session_provider.dart`),鉴权失败才清 — 两处必须联动维护。
- 敏感动作密码相关判定(`AUTH_PASSWORD_NOT_SET`)集中于此,消费方见
  `../auth/sensitive_action_password_resolver.dart`。
- 决策背景:`../../../docs/reference/adr/0005-result-type-and-error-handling.md`。
