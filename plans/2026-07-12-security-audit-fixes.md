# Luminous 安全审查修复计划

来源：2026-07-12 Luminous + Lucent 联合安全性审查。

## P1 — 中危，短期修复

### 1. Web 端 Token 明文存储

- **文件**: `lib/core/network/session_store.dart` 第 92-96 行
- **问题**: `SecureLucentSessionStore` 在 Web 平台回退到 `SharedPreferences`（明文），access token 和 refresh token 可被 XSS 读取。
- **方案**:
  - 方案 A（推荐）：后端新增 cookie-based 认证选项，Web 端使用 `httpOnly` cookie 存储 token，避免 JS 可读。
  - 方案 B（过渡）：Web 端使用 `sessionStorage` + 短 TTL access token，refresh token 仅存内存，页面刷新时重新登录。安全性弱于方案 A 但改动较小。
- **影响范围**: `session_store.dart`、`auth_interceptor.dart`、`dio_client.dart`、后端 `auth` 模块（方案 A）。
- **验证**: Web 端 `document.cookie` 不可读取 token；移动端行为不变。

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

## P2 — 低危，择机修复

### 3. 无证书绑定（Certificate Pinning）

- **文件**: `lib/core/network/dio_client.dart`
- **问题**: 移动端未配置证书绑定，Root/越狱设备上可被中间人截获。
- **方案**:
  1. 使用 `dio_certificate_pinning` 或自定义 `HttpClientAdapter`。
  2. 仅在生产环境启用，开发环境允许自签名证书。
  3. 配置 Lucent 生产域名的公钥 SHA-256 哈希。
- **验证**: 集成测试覆盖「正常证书 → 通过」「篡改证书 → 拒绝连接」。
