# Luminous 安全审查修复计划

来源：2026-07-12 Luminous + Lucent 联合安全性审查。



### 2. GoRouter 缺少全局重定向守卫

- **文件**: `lib/app/router.dart`
- **问题**: 未认证用户可短暂访问受保护路由的 UI 框架（provider 完成认证检查前页面已渲染骨架）。
- **方案**: 在 `GoRouter` 中添加 `redirect` 回调。
  ```dart
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final session = authSessionProvider.read();
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password');
      if (session.isRestoring) return null; // 恢复中不跳转
      if (!session.isAuthenticated && !isAuthRoute) return AppRoutes.login;
      if (session.isAuthenticated && isAuthRoute) return AppRoutes.home;
      return null;
    },
    routes: [ ... ],
  );
  ```
- **注意**: 需要将 `authSessionProvider` 传入 router 的 refreshListener 以便认证状态变化时自动重定向。
- **验证**: Widget 测试覆盖「未登录 → /login」「已登录访问 /login → /」「恢复中 → 不跳转」。
