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

- 导出:`lucent_failure.dart` 的 `LucentFailure` / `LucentFailureKind` / `kPasswordNotSetCode`
  与 `LucentFailure.client` 工厂;`client_error_code.dart` 的 `ClientErrorCode`;
  `client_error_l10n.dart` 的 `ClientErrorL10n.map`;`network_error_l10n.dart` 的
  `NetworkErrorL10n.map`;`user_message.dart` 的 `userMessageFromError` /
  `userMessageOrNull`。
- 被依赖:`core/network`(error_mapper/sse/retry_policy/auth_interceptor 等)、`core/auth`、
  `core/database`、`core/logger`,以及 auth/assistant/health_*/legal 等 feature 的
  repository 与 provider — 全仓失败语义的枢纽。

## 不变量

- kind 只能经工厂归类:`fromProblemDetails` / `fromSseProblemDetails` 按 status 与 SSE code
  判定(401/403→authentication、5xx→server、4xx→business),不散落手写判断
  (`test/core/errors/lucent_failure_test.dart`)。
- 客户端本地校验(不满足格式/大小/类型等)用 `LucentFailure.client`(kind 默认 business)归类,
  不用 `network` ——把「用户输入不合要求」记成网络或服务端故障会污染错误率与告警
  (例:`features/auth/data/services/avatar_uploader.dart`、
  `features/medicine/presentation/services/reminder_calendar.dart` 的日历导出)。
  该工厂的 `message` 只是开发者诊断(日志/测试),用户文案一律由 `clientErrorCode` 决定。
- `ProblemDetails` 仍是 wire 表示,`LucentFailure` 只归一化不替代(类注释明示)。
- 面向用户:任何 error 上屏前必须过 `userMessageFromError` / `LucentErrorMapper.fromObject`,
  禁止 `error.toString()`;能取 l10n 时映射优先,顺序是
  `clientErrorCode`(客户端自己判定,最具体)→ `networkErrorCode`(传输层)→ 服务端下发的
  `message`(此时 `l10n` 为 null 或两个码都缺省;函数只透这个兜底,不另造文案)。
  `clientErrorCode` 是**客户端自判**的失败码(微信 SDK、未登录、头像预检、缺
  refresh token、日历导出),与线格式 `code`(服务端 Problem Details)分开:两者来源不同,
  混用会让「服务端返回了什么」无从判断。`ClientErrorCode` 是封闭 enum,
  `ClientErrorL10n.map` 对它穷举 switch,新增变体编译期强制补映射。
- 传输态失败(无 l10n 可用的 provider 里)不进 state 的字符串字段:state 存 error 对象,
  文案在页面用 `userMessageFromError` / `userMessageOrNull` 现算——否则 state 里那句英文
  会跟着 App 语言一起错。
- 兜底文本不是文案:`LucentFailure.unknown` 回落的英文串是开发者诊断,没有 l10n 句柄时
  才会上屏。`LucentErrorMapper` 已经把传输失败统一标成 `NetworkErrorCode.unknown`
  (含 `networkErrorUnknown` 文案),展示点应在无 l10n 时也传 `l10n`,而不是接受诊断串。
- `NetworkErrorL10n.map` 同样对 `NetworkErrorCode` 穷举 switch,新增错误码编译期强制补映射。
- 同一个 `ClientErrorCode` 可以映射到同一句文案:三种「当前环境不支持微信登录」
  (`wechatSdkNotConfigured` / `wechatMobileUnsupported` / `wechatDesktopUnsupported`)与
  注册失败/启动失败共享条目。码分开是为了运维侧区分原因,不是因为用户需要看到区别。

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
