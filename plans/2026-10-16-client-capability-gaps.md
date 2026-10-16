---
status: active
owner: frontend
updated: 2026-10-16
---

# 客户端能力补齐：深链 / 许可清单 / 图片查看 / 日历回写 / OAuth 内嵌 WebView

Created: 2026-10-16
Revised: 2026-10-16（首版）

定位：引入 5 个包，修掉 5 个**用户可感知的断点**。除「开源许可」是合规项外，
其余都是当前产品的真实硬伤：OAuth 回调用户要手工粘 URL、报告与扫描单无法缩放、
用药提醒进不了系统日历。

> 本计划只做「怎么做」。剩余项的唯一台账是 `docs/TODO.md`；跨仓事项（Lucent 侧
> 契约）在 Lucent `plans/2026-10-16-backend-engineering-capabilities.md` 与双仓迁移
> 日志登记。落地后本文件按 `plans/README.md` 生命周期第 4 条删除。

---

## 〇、引入清单与一句话理由

| 包 | 版本 | 修的断点 | 排期 |
| --- | --- | --- | --- |
| `app_links` | ^6.4.0 | OAuth 回调、推送跳转、分享链接 | P0 |
| `webview_flutter` | ^4.10.0 | QQ/Google 授权内嵌完成，免手工粘 URL | P0 |
| `photo_view` | ^1.1.0 | 报告/扫描单/头像大图缩放 | P1 |
| `add_2_calendar` | ^3.0.1 | 用药提醒写入系统日历 | P1 |
| `flutter_oss_licenses` | ^1.1.0 | About「开源许可」真正列 pub 依赖 | P1 |
| `local_auth` | ^3.0.0 | 指纹/Face ID 应用锁 | **不在本批**（按你给的清单） |

`P0/P1` 只是**排期建议**，不是范围裁剪。

`local_auth` 按你给的清单**不在本批范围**，此处仅登记占位。它需要「应用锁 + 后台化
超时 + 设置项」一条完整产品线，建议单独立项，但**是否落地、何时落地由你定**。

---

## 一、现状锚点（代码事实，2026-10-16 核实）

- `pubspec.yaml` 已声明 `url_launcher`（外部浏览器）、`fluwx`、`sign_in_with_apple`；
  无深链接收、无内嵌 WebView、无系统日历写入。
- OAuth 回调三条链（`presentation/pages/oauth_handlers.dart`）：
  `startXLogin` → `externalUrlLauncherProvider.open()` → 用户在外部队浏览器授权
  → **手工复制地址栏 URL** → `completeXLoginFromInput` 粘进 `TextField`
  → `OAuthCallbackParser.parse()` 取 code/state。
  已存在的自动路径 `useOAuthCallbackHandler`（`oauth_callback_hook.dart`）只认
  **GoRouter query 参数**（`?code=&state=`），即「web 端同页跳回」才触发，
  原生端深链回来时**不会**命中。
- `lib/app/router.dart:206` `initialLocation: Routes.home` 写死；
  `redirect` 守卫（:211）无深链参与。
- `about.dart:206` 走 Flutter 内置 `showLicensePage`，只含框架自身 license。
- 无 `photo_view`：报告 PDF 详情、扫描单预览、头像均不可缩放。
- `docs/TODO.md` 已登记两条相关延后项：
  「微信 Universal Link 的 Associated Domains 未配置」与「iOS 系统权限文案未本地化」，
  本计划的 iOS 步骤**不重复登记**，只在完成后更新这两条的状态描述。

## 实施取向与待确认决策点（2026-10-16）

第 1/2/6 条是实施取向，直接执行；**第 3/4/5 条是收窄范围的选择，默认按「默认」列，
需你确认**——若你要全量形态，我按「全量形态」列改写步骤。

1. **深链用 `app_links`，不用 `uni_links`**：`app_links` 支持 Android 15+
   `verifyAndroidLinks`/`intent.autoVerified`，与 `uni_links` 的 Web 深链能力等价，
   原生侧维护更跟 Flutter 版本。**不引入 DeepLink 路由表 DSL**
   （`go_router_deeplink` 之类）——本项目路由已用 `@TypedGoRoute` 静态生成，
   再套一层 DSL 会与 `tool/luminous_lints` 的 `no_direct_navigator` 规则打架。
2. **深链入口收敛到 `lib/core/router/deep_link.dart`**：一个 `deepLinkProvider`
   暴露 `Stream<Uri>`，由 `lib/app/` 在 bootstrap 期订阅。auth feature 只订阅
   自己关心的 path（`/login/oauth/*`），不各自持有 stream（避免
   presentation→presentation 之外再出现新的跨层监听）。

| # | 决策点 | 默认 | 全量形态 | 差异代价 |
| --- | --- | --- | --- | --- |
| 3 | WebView 职责边界 | 用 `webview_flutter`，只做 OAuth 授权页（加载 + 命中 callback URI 即拦截返回） | 用 `flutter_inappwebview`，做通用内嵌浏览器（JS 注入 / Cookie 管理 / 文件上传） | 若以后要把 Legal 页、帮助页也内嵌，现在选型决定后续返工量 |
| 4 | `add_2_calendar` 是否单向 | 「提醒 → 系统日历」单向导出（drift 仍是唯一事实源，日历只是用户生态里的一个视图） | 双向同步（用户在系统日历改时间，app 跟着改） | 双向需要冲突解决设计，属独立议题 |
| 5 | 许可页是否替换内置 | `flutter_oss_licenses` 与 Flutter 内置 `showLicensePage` **并存**（两者数据源不同：内置只含框架自身 license） | 单一入口只保留 `flutter_oss_licenses` | 需处理「框架条目归属」，否则丢信息 |

6. **`photo_view` 只做交互式查看容器**，不做图片加载器：图片仍走既有
   `cached_network_image`，`PhotoView` 只包一层手势/缩放，避免引入第二套缓存策略。

## 平台侧最小改动（不引入新配置体系）

| 平台 | 动作 | 依据 |
| --- | --- | --- |
| Android | `AndroidManifest.xml` 加 `intent-filter`（`VIEW` + `BROWSABLE` + `DEFAULT`，`android:autoVerify="true"`，scheme 用 `https` + 既有 `applinks:<域名>` 声明） | `app_links` 官方要求；`autoVerify` 需服务端 `/.well-known/assetlinks.json` |
| iOS | `Runner.entitlements` 加 `com.apple.developer.associated-domains` = `applinks:<域名>`；`Info.plist` 加 `CFBundleURLTypes`（自定义 scheme 兜底） | `docs/TODO.md` 已登记 associated-domains 缺项，本计划落地后更新该条 |

> **`autoVerify` 与 `assetlinks.json` 是强依赖**：没有服务端文件时 Android 会
> 拒绝 App Link，只能退回自定义 scheme（仍可用但体验差）。服务端文件属域名/
> 部署侧事项——**它是 Lucent 侧的部署动作，登记到 `docs/TODO.md` 而非本计划**；
> 落地时以自定义 scheme 打通链路，`autoVerify` 置 `true` 但验收只断言
> 「深链能进 app」。

---

## 二、P0 — 深链 + OAuth 内嵌（已完成，2026-10-16）

P0-1 依赖与平台骨架、P0-2 auth 消费深链、P0-3 WebView 内嵌授权、P0-4 收尾与 l10n
均已落地，见 `docs/logs/migration-log/2026-10-16.md`。剩余为 P1 三项与验收 A6（真机）。

---

## 三、P1 — 三个用户可见增强

### P1-1 `photo_view` 报告/扫描单缩放

- 接入点优先序：报告详情页大图 → 扫描单预览 → 头像查看。
- 统一封装 `lib/core/widgets/photo_viewer.dart`（`PhotoView` + `Hero` 可选 +
  `AppStateErrorView` 兜底），页面只传 URL。
- **测试**：`test/core/widgets/photo_viewer_test.dart` 断言缩放手势可达、
  加载失败走 `AppStateErrorView` 而非空白。

### P1-2 `add_2_calendar` 用药提醒导出

- 入口：medicine reminder 详情页「加入系统日历」。
- 数据来源：既有 reminder 实体（`scheduledHour/Minute` + `daysOfWeek` +
  `startDate/endDate`）→ 转成 `Event`；**时区用 `timezone` 包取用户本地**
  （`userTimezone` 已存在于健康上下文快照，勿新取一路）。
- 写库失败/权限拒绝 → `AppToast`，不静默。
- **测试**：`test/medicine/reminder_calendar_test.dart` 用 fake `Add2Calendar`
  断言 (a) 事件字段映射正确；(b) 结束日期为空时不给 `Event(endDate)`；
  (c) 异常映射为 toast。
- 文案进 `lib/l10n/src/medicine_{zh,en}.arb`。

### P1-3 `flutter_oss_licenses` About 页

- `about.dart` 现有「开源许可」行改为**两个入口**：Flutter 框架许可（保留
  `showLicensePage`）+ pub 依赖许可（`flutter_oss_licenses`）。
  （若决策点 5 选全量形态，则改为单一入口。）
- **软著相关**：`flutter_oss_licenses` 产物是一份可导出的依赖清单，与工作区
  `软件著作权申请资料/` 的材料生成直接相关；验收时导出一次并存档到
  `软件著作权申请资料/`（是否进 git 由维护者定）。
- **测试**：widget 测试断言入口渲染；不依赖真实 pubspec 解析。

---

## 四、验收（每项独立可过）

| # | 验收 | 命令/依据 |
| --- | --- | --- |
| A1 | `flutter analyze` 0 新增违规 | `flutter analyze` |
| A2 | 新增/改动的单测全绿 | `flutter test test/core/router/deep_link_test.dart test/auth/oauth_deep_link_test.dart test/auth/oauth_webview_test.dart test/core/widgets/photo_viewer_test.dart test/medicine/reminder_calendar_test.dart` |
| A3 | 八条自定义规则 warn 模式无新增命中 | `Push-Location tool/luminous_lints; dart run bin/luminous_lints.dart; Pop-Location` |
| A4 | l10n 无硬编码（新增文案全走 ARB） | 分片改完跑 `dart scripts/l10n/arb_tools.dart merge` + `flutter gen-l10n`，再 `dart run scripts/docs/generate.dart --check` |
| A5 | 文档新鲜度与链接完整 | `dart run scripts/workflows/daily.dart` |
| A6 | 深链实机验证（维护者手动）：Android/iOS 各一次，`https://<域名>/login/oauth/qq?code=&state=` 能进登录页并完成登录 | 真机记录，写进迁移日志 |

> A6 需要服务端 `assetlinks.json` / `apple-app-site-association` 才能走
> `autoVerify`；未就绪时用自定义 scheme 验证，验收标准降为「深链能进 app」。

## 风险与已知限制

- **`webview_flutter` 与 SwiftPM 冲突**：`pubspec.yaml` 当前
  `enable-swift-package-manager: false`（iOS 依赖全走 CocoaPods）。
  `webview_flutter` 4.x 有 SwiftPM 支持，但项目级关闭状态下不受影响；
  SwiftPM 迁移时（`docs/TODO.md` 已登记）需复核其 `Package.swift`。
- **`app_links` 的 Android 15 `verifyAndroidLinks`**：需要 `queries` 权限与
  `autoVerify`，低版本系统静默降级。验收只测可达，不测验证态。
- **深链与 redirect 守卫的竞态**：深链落在 `/login` 时，若会话尚未恢复，
  守卫可能先把用户带去 home。P0-2 的实现必须「等 `authSessionProvider`
  `isLoading == false` 再消费深链」，否则会出现「深链被吞」。
- **`add_2_calendar` 权限模型**：Android 走 `WRITE_CALENDAR`（已在
  `permission_handler` 覆盖范围），iOS 走 `NSCalendarsUsageDescription`——
  **该 Info.plist 文案未本地化是 `docs/TODO.md` 已知项**，本计划顺手补
  `en.lproj/InfoPlist.strings` 中该键，不扩大为全量 Info.plist 本地化。
