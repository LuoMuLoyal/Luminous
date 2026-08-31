# lib/core/router — 路由辅助(常量 / 动作映射 / 外链)

core 层的路由小工具:与 typed routes 保持同步的路径常量、后端动作 token → GoRouter
location 的映射、外部 URL 启动器。路由表与 redirect guard 本体在 lib/app/router.dart。

## 职责与边界
- 管:routes.dart(`CoreRoutes` 常量 + `loginRouteLocation`)、action_route_mapper.dart
  (`mapActionToRoute`)、external_url_launcher.dart(`ExternalUrlLauncher` + provider)。
- 不管:路由声明、redirect、typed route 生成(全部在 lib/app/router.dart 与各 feature
  的 routes 定义);页面内导航 UI。

## 对外契约
- 导出:`CoreRoutes.login` / `CoreRoutes.home`、`loginRouteLocation(returnTo)`、
  `mapActionToRoute(action)`、`externalUrlLauncherProvider`(`ExternalUrlLauncher.open`)。
- 被依赖:core/widgets/auth/required_dialog.dart;auth(登录回跳、微信 OAuth 回调)、
  assistant / settings / notification / review 等页面的跳转与外链;后端 action 字符串解析。

## 不变量
- `CoreRoutes` 常量与 typed routes 逐字一致:core 不 import feature 代码,靠
  test/core/router/routes_test.dart 锁同步,漂移即测试失败。
- `mapActionToRoute` 只认白名单 token 或以 `/` 开头的绝对路径,其余返回 null,由调用方
  决定兜底(test/core/router/action_route_mapper_test.dart)。
- 外链统一走 `ExternalUrlLauncher.open`(`LaunchMode.externalApplication`),不散调
  url_launcher。

## 依赖禁区
- 不 import `features/**`:用字符串常量镜像 typed routes 正是为避免反向依赖;新增镜像
  路由需同步更新 routes.dart 并补同步测试。
- 不承载路由表逻辑,不做鉴权判断。

## 陷阱与决策
- 动作 token `report` 映射到 `Routes.review`(旧名兼容,与 shell 的 `shell-tab-report`
  同源问题)。
- `loginRouteLocation` 的 return-to 编码:go_router 同时解码 `+` 与 `%20`,字面量可能与
  `LoginRoute(returnTo:).location` 不同(routes.dart 注释已说明)。
- GoRouter 选型与 typed routes 决策见 ../../../docs/reference/adr/0002-gorouter-navigation.md。
