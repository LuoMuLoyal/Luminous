import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_page.dart';
import 'package:luminous/features/auth/presentation/pages/change_email_page.dart';

import 'router_helpers.dart';

final accountRoutes = [
  GoRoute(
    path: AppRoutes.account,
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const AccountSettingsPage()),
  ),
  GoRoute(
    path: AppRoutes.accountOauthWechat,
    pageBuilder: (context, state) => slidePage(
      key: state.pageKey,
      child: AccountSettingsPage(
        wechatCode: state.uri.queryParameters['code'],
        wechatState: state.uri.queryParameters['state'],
      ),
    ),
  ),
  GoRoute(
    path: AppRoutes.accountChangeEmail,
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const ChangeEmailPage()),
  ),
];
