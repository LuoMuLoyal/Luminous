import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:luminous/features/auth/presentation/pages/login_page.dart';
import 'package:luminous/features/auth/presentation/pages/register_page.dart';

import 'router_helpers.dart';

final authRoutes = [
  GoRoute(
    path: '/login',
    pageBuilder: (context, state) => fadePage(
      key: state.pageKey,
      child: LoginPage(returnTo: state.uri.queryParameters['returnTo']),
    ),
  ),
  GoRoute(
    path: '/login/oauth/wechat',
    pageBuilder: (context, state) => fadePage(
      key: state.pageKey,
      child: LoginPage(
        wechatCode: state.uri.queryParameters['code'],
        wechatState: state.uri.queryParameters['state'],
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),
  ),
  GoRoute(
    path: '/login/oauth/qq',
    pageBuilder: (context, state) => fadePage(
      key: state.pageKey,
      child: LoginPage(
        qqCode: state.uri.queryParameters['code'],
        qqState: state.uri.queryParameters['state'],
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),
  ),
  GoRoute(
    path: '/forgot-password',
    pageBuilder: (context, state) =>
        fadePage(key: state.pageKey, child: const ForgotPasswordPage()),
  ),
  GoRoute(
    path: '/register',
    pageBuilder: (context, state) =>
        fadePage(key: state.pageKey, child: const RegisterPage()),
  ),
];
