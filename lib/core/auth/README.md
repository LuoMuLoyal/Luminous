# lib/core/auth — UI 会话状态与敏感操作密码

目录持有 UI 侧会话状态机与敏感操作辅助:`session_provider.dart`(`AuthSessionNotifier` +
`authSessionProvider`)、`session_state.dart`(`@freezed AuthSessionState` + 状态扩展)、
`sensitive_action_password_resolver.dart`(`session_state.freezed.dart` 为生成物)。

## 职责与边界

- 管:会话状态(restore/applySession/applyUser/logout/onSessionExpired)、restore 超时与
  重连语义、敏感操作密码解析(`resolveSensitiveActionPassword`)与失败处理
  (`handleSensitiveActionFailure`)。
- 不管:token 的读写与安全存储(在 `../network/client/session_store.dart` 的
  `LucentSessionStore`)、登录/刷新/登出的 HTTP 流与 token 写入(features/auth 的
  data repository)、路由守卫声明(`app/router.dart`)。

## 对外契约

- 导出:`authSessionProvider` / `AuthSessionNotifier`、`AuthSessionState` +
  `AuthSessionStateStatus`(`canAccessProtectedData` / `isRestoring` / `isConfirmedSignedOut`)、
  `AuthRequiredException`、`pendingAuthSessionResolution`、`kSessionRestoreTimeout`、
  `resolveSensitiveActionPassword` / `handleSensitiveActionFailure`。
- 被依赖:`app/router.dart`、`app/bootstrap.dart`(启动 restore)、features/auth、shell、
  notification、mine、health_event、scan,以及 `../widgets/common/feedback/` 的连接横幅与
  页面状态组件。

## 不变量

- restore 有兜底超时,超时 → `isTimeout`(可手动重试,`isReconnecting` 区分重试中),UI 不会
  无限骨架(`test/auth/presentation/providers/session_provider_test.dart` 覆盖
  restore/logout/onSessionExpired 分支)。
- 失败分流:网络连接类失败(`LucentFailure.isNetworkConnectivityError`)保留 token store
  供重试;仅鉴权失败(401/403/token 过期/refresh 无效)才 `store.clear()`。
- logout 仅在远程注销成功后置 signed-out;失败保留会话,只投影错误信息。
- `onSessionExpired` 回调清 UI 会话但不与 restore 竞态(`state.isLoading` 时跳过)。

## 依赖禁区

- 本目录是 core 内的既有例外:`AuthSessionNotifier` 引用 features/auth 的 repository
  provider 与 session entity,`sensitive_action_password_resolver.dart` 引用 features/settings
  的 provider。新增引用需保持克制,可收敛时优先收敛为 domain 接口;禁止引用 features 的
  pages/widgets 与其他 feature 的 data 层。

## 陷阱与决策

- token 持久化(`SecureLucentSessionStore`:flutter_secure_storage,web 回退 SharedPreferences)
  在 `../network/client/session_store.dart`,测试 `test/core/network/session_store_test.dart`;
  本目录不重复实现存取。
- OAuth-only 用户无本地密码:密码相关失败带 `AUTH_PASSWORD_NOT_SET` 时走 Toast + 引导去账号页,
  而非弹密码框;`resolveSensitiveActionPassword` 先等 settings ready,避免加载中 `?? true`
  误弹用户永远无法完成的密码框。
- `pendingAuthSessionResolution()` 返回永不完成的 future,供 authGuarded 工厂挂起恢复中的
  provider(模式见 `../../../docs/reference/adr/0003-riverpod-generator-and-auth-guard.md`)。
