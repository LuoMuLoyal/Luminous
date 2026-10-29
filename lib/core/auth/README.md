# lib/core/auth — UI 会话状态

目录持有 UI 侧会话状态机:`session_provider.dart`(`AuthSessionNotifier` +
`authSessionProvider`)、`session_state.dart`(`@freezed AuthSessionState` + 状态扩展);
`session_state.freezed.dart` 为生成物。

敏感操作密码解析(`resolveSensitiveActionPassword` / `handleSensitiveActionFailure`)已迁到
`../providers/sensitive_action_resolver.dart`——它只读写设置、弹密码框、弹 toast,不碰 I/O,
归属 `core/providers/`(展示层唯一允许依赖的 core 子树)。

## 职责与边界

- 管:会话状态(restore/applySession/applyUser/logout/onSessionExpired)与 restore 超时、
  重连语义。
- 不管:token 的读写与安全存储(在 `../network/client/session_store.dart` 的
  `LucentSessionStore`)、登录/刷新/登出的 HTTP 流与 token 写入(features/auth 的
  data repository)、路由守卫声明(`app/router.dart`)。

## 对外契约

- 导出:`authSessionProvider` / `AuthSessionNotifier`、`AuthSessionState` +
  `AuthSessionStateStatus`(`canAccessProtectedData` / `isRestoring` / `isConfirmedSignedOut`)、
  `AuthRequiredException`、`pendingAuthSessionResolution`、`kSessionRestoreTimeout`。
- 被依赖:`app/router.dart`、`app/bootstrap.dart`(启动 restore)、features/auth、shell、
  notification、mine、health_event、scan,以及 `../widgets/common/feedback/` 的连接横幅与
  页面状态组件。

## 不变量

- restore 有兜底超时,超时 → `isTimeout`(可手动重试,`isReconnecting` 区分重试中),UI 不会
  无限骨架(`test/auth/presentation/providers/session_provider_test.dart` 覆盖
  restore/logout/onSessionExpired 分支)。
- 失败分流:网络连接类失败(`LucentFailure.isNetworkConnectivityError`)保留 token store
  供重试;其余失败在 refresh 这一步统一 `store.clear()`。能继续走 refresh 的只有
  401/403/token 过期/refresh 无效——`isAuthRequired`(`AUTH_REQUIRED`)也在内,它同样可以靠
  refresh token 续期(`../network/client/interceptors/auth_interceptor.dart`)。
- logout 仅在远程注销成功后置 signed-out;失败保留会话,只投影错误信息。
- `onSessionExpired` 回调清 UI 会话但不与 restore 竞态(`state.isLoading` 时跳过)。
- 状态上的 `errorMessage` 是原始失败文本,不是文案来源:`onSessionExpired` 路径置的是
  全新状态(无 message),失败信息只作为「有错」的信号;需要给用户看时按 `../errors`
  的统一入口现算。

## 依赖禁区

- 本目录是 core 内的既有例外:`AuthSessionNotifier` 引用 features/auth 的 repository
  provider 与 session entity。新增引用需保持克制,可收敛时优先收敛为 domain 接口;禁止引用 features 的
  pages/widgets 与其他 feature 的 data 层。

## 陷阱与决策

- token 持久化(`SecureLucentSessionStore`:flutter_secure_storage,web 回退 SharedPreferences)
  在 `../network/client/session_store.dart`,测试 `test/core/network/session_store_test.dart`;
  本目录不重复实现存取。
- OAuth-only 用户无本地密码:密码相关失败命中 `LucentFailure.isPasswordNotSet`
  (线格式码归 `../errors/lucent_failure.dart` 的 `kPasswordNotSetCode` 持有)时走
  Toast + 引导去账号页,而非弹密码框(解析器在 `../providers/sensitive_action_resolver.dart`,
  先等 settings ready,避免加载中 `?? true` 误弹用户永远无法完成的密码框)。
- `pendingAuthSessionResolution()` 返回永不完成的 future,供 authGuarded 工厂挂起恢复中的
  provider(模式见 `../../../docs/reference/adr/0003-riverpod-generator-and-auth-guard.md`)。
