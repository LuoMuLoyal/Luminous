import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_page.dart';
import 'package:luminous/features/auth/presentation/pages/change_email_page.dart';

import 'router_helpers.dart';

final accountRoutes = [
  GoRoute(
    path: '/account',
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const AccountSettingsPage()),
  ),
  GoRoute(
    path: '/account/oauth/wechat',
    pageBuilder: (context, state) => slidePage(
      key: state.pageKey,
      child: AccountSettingsPage(
        wechatCode: state.uri.queryParameters['code'],
        wechatState: state.uri.queryParameters['state'],
      ),
    ),
  ),
  GoRoute(
    path: '/account/change-email',
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const ChangeEmailPage()),
  ),
];
