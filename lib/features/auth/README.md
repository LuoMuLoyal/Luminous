# lib/features/auth — 认证与账号

一句话:登录/注册/找回密码/账号设置/设备会话管理,并经 core 桥接提供全 app 的会话事实来源。

公共规则(l10n、TaskEither 仓库边界、跨 feature import 禁令)见仓库根 AGENTS.md,本文件只写本目录特有约定。

## 职责与边界
- 管:邮箱密码/验证码登录注册、OAuth(微信/Apple/QQ/微博/Google;微信分移动 SDK 与桌面 loopback 双通道)、会话恢复/刷新、设备会话查看与吊销、改邮箱/改密码/注销账号。
- 不管:路由 redirect 守卫(lib/app/router.dart)、token 持久化(`lucentSessionStoreProvider` 属 lib/core/network)、`authGuarded` 工厂(lib/core/providers/)。

## 对外契约
- 路由(presentation/routes.dart):`Routes.login` / `loginOauthWechat|Qq|Weibo|Google` / `register` / `forgotPassword` / `resetPassword` / `account` / `accountOauthWechat` / `accountChangeEmail` / `accountSessions`。
- 导出:domain/entities/session.dart(`AuthUser`/`AuthSession`/`AuthLinkedIdentity`,core/auth 消费)、data/providers/auth.dart(`authRepositoryProvider`)、presentation/services/wechat_oauth.dart(平台感知微信 OAuth,登录与身份绑定共用)。
- 被依赖:core/auth/session_provider.dart 与 session_state.dart(`authSessionProvider` 建在其上)、app/router.dart redirect、mine/settings 的账号入口(pushAuthRequiredRoute 进 `/account`)。

## 不变量
- 会话状态只在 core/auth/session_provider.dart 的 `authSessionProvider` 上变更;presentation/providers/session.dart 仅为兼容 re-export,不得再 import。
- 网络连通性错误不清 session store(`isNetworkConnectivityError` 分支);远程 logout 失败不得把用户置为登出。
- 仓库方法一律 `TaskEither<LucentFailure, T>`;会话恢复有超时地板(isTimeout),防冷启动挂死骨架屏。

## 依赖禁区
- 不 import 其他 feature;微信平台通道经条件导出(io/stub),非支持平台不得直接依赖 fluwx。

## 陷阱与决策
- OAuth 回调以深链携带 code/state 进入 LoginPage/AccountSettingsPage;`LoginRoute.returnTo` 控制登录后回跳。
- 登录与账号绑定共用 WechatOAuthService 的平台探测(移动 SDK → 桌面 loopback → 浏览器回退),勿在页面层重写。
- 决策:会话守卫与 authGuarded 工厂见 ../../../docs/reference/adr/0003-riverpod-generator-and-auth-guard.md;TaskEither 边界见 0005-result-type-and-error-handling.md。
