---
status: active
owner: frontend
updated: 2026-08-31
---

# Routing (GoRouter)

本文件是 [[architecture]] 拆分后的子文档。

相关子文档：
- [[state-management]]
- [[data-layer]]

## Routing (GoRouter)

Navigation uses `go_router` with a `StatefulShellRoute` for the five main tabs:

```
StatefulShellRoute (preserves tab state)
├── ShellBranch 0: /          → Today dashboard
├── ShellBranch 1: /record    → Record list
├── ShellBranch 2: /medicine  → Medicine workspace
├── ShellBranch 3: /review    → Review (回顾)
└── ShellBranch 4: /mine      → Mine/profile
```

All create/detail/edit sub-pages are **top-level full-screen routes** (outside the shell), which
hides the bottom navigation bar and desktop sidebar. 全量路由清单由 `lib/app/router.g.dart` 与
生成索引承接，本文件不复述逐路由清单。

### File Structure

Router entry lives in `lib/app/`; typed routes are declared per feature:

```
lib/app/
├── router.dart          # Routes 常量、公开路由前缀、redirect 守卫、shell branches + routes spread
├── router_helpers.dart  # fadePage / tabFadePage / slidePage / sidePanelPage 页面过渡
└── router.g.dart        # go_router_builder 生成的 typed routes（router.dart 的 part 文件）
```

各 feature 在 `presentation/routes.dart` 用 `@TypedGoRoute` 声明 typed routes，生成 `$appRoutes`
列表常量，由 `router.dart` 以 `...spread` 汇入（auth、record、medicine、mine、settings、
notification、assistant、scan、health_data、legal）。另有三条手写 `GoRoute`：
`/review/clinic-summary/:token`、`/review/legacy`、`/review/review/:eventId`。

### Route Constants

Route path strings are centralized in `Routes` (defined in `lib/app/router.dart`) to avoid
hardcoded strings across the codebase:

```dart
class Routes {
  static const home = '/';
  static const login = '/login';
  static const review = '/review';  // Fifth tab
  static const reviewClinicSummaryShared = '/review/clinic-summary/:token';
  static const reviewLegacyDashboard = '/review/legacy';
  static const reviewDetail = '/review/review/:eventId';
  // ... other routes
}
```

### Key Conventions

- Use `context.push()` for sub-page navigation (preserves tab state).
- Use `context.go()` for auth redirects and tab switching.
- Shell branches only model the five visible tabs; no hidden branches.
- 带路径参数的路由使用 `go_router_builder` 生成的 typed route class（如
  `XxxRoute(id: id).push(context)`），不手拼路径字符串。
- `AppBackButton` uses `context.pop()` when the route can pop, otherwise falls back to
  `Routes.home`.
- Dead routes must be removed from `Routes` immediately — there is no "placeholder" route
  constant.

### Public Preview Routes

The following routes are accessible without signing in so the app can be opened in preview mode:

- `/`, `/record`, `/medicine`, `/review`, `/mine` — the five shell tabs.
- `/settings`, `/assistant` — standalone pages that render their own sign-in prompts when needed.
- `/legal`, `/review/clinic-summary` — shared/legal content（列入 `_publicRoutePrefixes`）。
- `/review/legacy` — legacy dashboard 兼容页：从回顾页 More sheet 的「历史报告」入口 push 进入，
  沿用 `/review` 的公开预览语义（未登录显示 preview + 登录引导，不重定向到 /login）。
- `/medicine/detail/:source/:id` — 药品详情页（列入 `_publicRoutePrefixes`）：后端
  `GET /medicines/:id?source=` 为 `@Public`、页面仅对「加入药箱」做 auth 门控，未登录可浏览
  说明书；「加入药箱」未登录时走 `showAuthRequiredDialog`。

All other routes require an authenticated session. The redirect guard sends unauthenticated users
to `/login` only when they reach a non-public, non-auth route, and it redirects authenticated users
away from `/login`, `/register`, `/forgot-password`, `/reset-password`.

### Push Notification Navigation

JPush notification receive/open events are normalized by `lib/core/push/message_handler.dart`.
Both the default action and `extras.action = medicine_reminder` navigate to `/notifications`;
click events invalidate the notification unread-count provider before navigation. The root app
keeps `pushCoordinatorProvider` alive, and `bootstrap.dart` starts cold-start event handling only
after the auth session restore has completed so the protected notification route is evaluated with
the final session state.

`extras.action = ai_today_summary` routes to `/` (Today dashboard / home). Foreground receive
events of this type are exposed by `aiTodaySummaryPushEventsProvider`
(`lib/core/push/message_handler.dart`); `bootstrap.dart` listens and shows a tappable
`Toast.showWithAction`. Tapping the toast navigates to `/`.

### Record Quick-Entry Settings

- `/record/quick-entry-settings` hosts the dedicated quick-entry settings page.
- `/record/quick-entry-settings/reorder` hosts the focused manual ordering surface.
- Both are top-level Record feature routes generated from
  `lib/features/record/presentation/routes.dart`, so they hide shell chrome like other Record
  sub-pages and use the desktop side-panel transition on wide screens.

### Why GoRouter

See [ADR-0002: GoRouter Navigation](adr/0002-gorouter-navigation.md).

> [ADR-0006](adr/0006-local-persistence-drift.md) 审查备注：`lib/app/bootstrap.dart` 在
> `initState` postFrame 回调中调用 `ref.read(cacheCleanupProvider)`，触发数据保留期缓存清理。
> 此变更不影响路由结构、路由守卫或导航行为。

---
