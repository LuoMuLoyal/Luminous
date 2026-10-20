# lib/core/router — 路由辅助(常量 / 动作映射 / 外链 / 深链)

core 层的路由小工具:与 typed routes 保持同步的路径常量、后端动作 token → GoRouter
location 的映射、外部 URL 启动器、原生深链接收。路由表与 redirect guard 本体在
lib/app/router.dart。

## 职责与边界
- 管:routes.dart(`CoreRoutes` 常量 + `loginRouteLocation`)、action_route_mapper.dart
  (`mapActionToRoute`)、external_url_launcher.dart(`ExternalUrlLauncher` + provider)、
  deep_link*.dart(深链域名/自定义 scheme 的验收规则 + `deepLinkStreamProvider`;
  `deep_link_source*.dart` 是 io/stub 条件导出的平台接收层)。
- 不管:路由声明、redirect、typed route 生成(全部在 lib/app/router.dart 与各 feature
  的 routes 定义);页面内导航 UI;未知 location 的兜底页
  (`../widgets/common/feedback/route_not_found.dart`,由 `app/router.dart` 的 `errorBuilder`
  接上);OAuth 回调的消费逻辑(features/auth 的 `oauth_callback_hook.dart`)。

## 对外契约
- 导出:`CoreRoutes.login` / `CoreRoutes.home` / `CoreRoutes.loginOauthWechat` /
  `loginOauthQq` / `loginOauthGoogle`、`loginRouteLocation(returnTo)`、
  `mapActionToRoute(action)`、`externalUrlLauncherProvider`(`ExternalUrlLauncher.open`)、
  `deepLinkHostValue` / `deepLinkSchemeValue` / `isAcceptedDeepLink`、
  `deepLinkHostProvider` / `deepLinkSchemeProvider` / `deepLinkSourceProvider` /
  `deepLinkStreamProvider`(`Stream<Uri>`),以及 `DeepLinkSource` / `NoopDeepLinkSource` /
  `NativeDeepLinkSource` / `FakeDeepLinkSource`。
- 被依赖:core/widgets/auth/required_dialog.dart;auth(登录回跳、OAuth 回调 URI 拼装与
  回调消费)、assistant / settings / notification / review 等页面的跳转与外链;后端 action
  字符串解析。

## 不变量
- `CoreRoutes` 常量与 typed routes 逐字一致:core 不 import feature 代码,靠
  test/core/router/routes_test.dart 锁同步,漂移即测试失败。
- `mapActionToRoute` 只认白名单 token 或以 `/` 开头的绝对路径,其余返回 null,由调用方
  决定兜底(test/core/router/action_route_mapper_test.dart)。
- 外链统一走 `ExternalUrlLauncher.open`(`LaunchMode.externalApplication`),不散调
  url_launcher。
- `deepLinkStreamProvider` 是深链的唯一入口:冷启动链接作为首个事件重放一次,热启动链接
  并入同一 broadcast 流;每个订阅各自向 source 取一次,source 由 `deepLinkSourceProvider`
  注入(`FakeDeepLinkSource` 即测试替身),生产路径不直接触碰 `app_links`。
- `isAcceptedDeepLink` 先认配置的**自定义 scheme**(含 scheme 的链接一律接受),再按
  `LUMINOUS_DEEP_LINK_HOST` 大小写不敏感比对 host;host 未配置时放行,避免整条链路静默失效
  (test/core/router/deep_link_test.dart)。

## 依赖禁区
- 不 import `features/**`:用字符串常量镜像 typed routes 正是为避免反向依赖;新增镜像
  路由需同步更新 routes.dart 并补同步测试。
- 不承载路由表逻辑,不做鉴权判断。接受一条深链 ≠ 可以进受保护页面:登录守卫在
  `app/router.dart`,深链消费在 features/auth。
- `deep_link.dart` 在本层直接 import `dart:io` 的 `Platform` 判平台(非 web 且非
  Android/iOS/macOS 一律 `NoopDeepLinkSource`);新建 web 目标前先确认这层不会被打包。

## 陷阱与决策
- 自定义 scheme 的 path 会被 URI 解析吃进 host:`com.devluo.luminous://login/oauth/qq` 的
  `host` 是 `login`,所以只按 host 校验会把平台声明注册的兜底链接自己拒掉——scheme 规则
  必须排在 host 规则之前(deep_link.dart 的 `isAcceptedDeepLink`)。
- 动作 token `report` 映射到 `Routes.review`(旧名兼容,与 shell 的 `shell-tab-report`
  同源问题)。
- `loginRouteLocation` 的 return-to 编码:go_router 同时解码 `+` 与 `%20`,字面量可能与
  `LoginRoute(returnTo:).location` 不同(routes.dart 注释已说明)。
- GoRouter 选型与 typed routes 决策见 ../../../docs/reference/adr/0002-gorouter-navigation.md。
