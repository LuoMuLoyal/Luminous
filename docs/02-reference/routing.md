# Routing (GoRouter)

Last updated: 2026-07-10

本文件是 [[architecture]] 拆分后的子文档。

相关子文档：
- [[state-management]]
- [[data-layer]]

## 3. Routing (GoRouter)

Navigation uses `go_router` with a `StatefulShellRoute` for the five main tabs:

```
StatefulShellRoute (preserves tab state)
├── ShellBranch 0: /          → Today dashboard
├── ShellBranch 1: /record    → Record list
├── ShellBranch 2: /medicine  → Medicine workspace
├── ShellBranch 3: /report    → Report dashboard
└── ShellBranch 4: /mine      → Mine/profile
```

All create/detail/edit sub-pages are **top-level full-screen routes** (outside the shell), which
hides the bottom navigation bar and desktop sidebar:

```
GoRoute (top-level, no shell)
├── /record/create, /record/:id, /record/:id/edit
├── /medicine/search, /medicine/risk-check, /medicine/reminders/*
├── /settings, /settings/*
├── /assistant
├── /notifications, /notifications/:id
├── /login, /login/oauth/*, /register, /forgot-password
├── /account, /account/oauth/wechat, /account/change-email
└── /scan/barcode
```

### File Structure

Routes are split by feature into `lib/app/router/`:

```
lib/app/
├── router.dart                         # Main entry: shell branches + feature route spread
└── router/
    ├── router_helpers.dart             # fadePage / slidePage transitions
    ├── router_settings.dart            # /settings + 8 sub-routes
    ├── router_auth.dart                # /login ×3 + /forgot-password + /register
    ├── router_account.dart             # /account ×3
    ├── router_record.dart              # /record/create + /record/:id + /record/:id/edit
    ├── router_medicine.dart            # /medicine/search + risk-check + reminders ×3
    ├── router_mine.dart                # /mine/profile + allergy ×2 + condition ×2 + medicine ×2
    ├── router_notifications.dart       # /notifications + /notifications/:id
    ├── router_assistant.dart           # /assistant
    └── router_scan.dart                # /scan/barcode
```

Each feature file exports a list constant (`settingsRoutes`, `authRoutes`, ...) or a single route
(`assistantRoute`, `scanRoute`). The main `router.dart` uses `...spread` to assemble them.

### Route Constants

Route path strings are centralized in `AppRoutes` (defined in `lib/app/router.dart`) to avoid
hardcoded strings across the codebase:

```dart
class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const register = '/register';
  static const account = '/account';
}
```

### Key Conventions

- Use `context.push()` for sub-page navigation (preserves tab state).
- Use `context.go()` for auth redirects and tab switching.
- Shell branches only model the five visible tabs; no hidden branches.
- `AppBackButton` uses `context.pop()` when the route can pop, otherwise falls back to
  `AppRoutes.home`.
- Dead routes must be removed from `AppRoutes` immediately — there is no "placeholder"
  route constant. `medicineReminders` was removed because it had no corresponding page.

### Public Preview Routes

The following routes are accessible without signing in so the app can be opened in preview mode:

- `/`, `/record`, `/medicine`, `/report`, `/mine` — the five shell tabs.
- `/settings`, `/assistant` — standalone pages that render their own sign-in prompts when needed.
- `/legal`, `/report/clinic-summary` — shared/legal content.

All other routes require an authenticated session. The redirect guard sends unauthenticated users to `/login` only when they reach a non-public, non-auth route, and it redirects authenticated users away from `/login`, `/register`, `/forgot-password`.

### Why GoRouter

See [ADR-0002: GoRouter Navigation](adr/0002-gorouter-navigation.md).

> **ADR-0009 审查备注:** `lib/app/bootstrap.dart` 在 `initState` postFrame 回调中新增了 `ref.read(cacheCleanupProvider)` 调用，用于触发数据保留期缓存清理。此变更不影响路由结构、路由守卫或导航行为。

---

