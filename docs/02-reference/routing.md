# Routing (GoRouter)

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
├── /medicine/search, /medicine/reminders/new, /medicine/reminders/:id
├── /settings, /settings/*
├── /assistant
├── /notifications, /notifications/:id
├── /login, /register, /forgot-password
└── /login/oauth/wechat, /login/oauth/qq, /login/oauth/apple
```

### Key Conventions

- Use `context.push()` for sub-page navigation (preserves tab state).
- Use `context.go()` for auth redirects and tab switching.
- Shell branches only model the five visible tabs; no hidden branches.
- `AppBackButton` uses `context.pop()` when the route can pop, otherwise falls back to `/today`.

### Why GoRouter

See [ADR-0002: GoRouter Navigation](adr/0002-gorouter-navigation.md).

---

