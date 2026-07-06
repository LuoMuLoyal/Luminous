import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:luminous/features/auth/presentation/pages/login_page.dart';
import 'package:luminous/features/auth/presentation/pages/register_page.dart';

import 'router_helpers.dart';

final authRoutes = [
  GoRoute(
    path: AppRoutes.login,
    pageBuilder: (context, state) => fadePage(
      key: state.pageKey,
      child: LoginPage(returnTo: state.uri.queryParameters['returnTo']),
    ),
  ),
  GoRoute(
    path: AppRoutes.loginOauthWechat,
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
    path: AppRoutes.loginOauthQq,
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
    path: AppRoutes.forgotPassword,
    pageBuilder: (context, state) =>
        fadePage(key: state.pageKey, child: const ForgotPasswordPage()),
  ),
  GoRoute(
    path: AppRoutes.register,
    pageBuilder: (context, state) =>
        fadePage(key: state.pageKey, child: const RegisterPage()),
  ),
];
