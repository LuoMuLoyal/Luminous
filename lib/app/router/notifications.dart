import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/notification/presentation/pages/detail_page.dart';
import 'package:luminous/features/notification/presentation/pages/list_page.dart';

import 'helpers.dart';

final notificationsRoutes = [
  GoRoute(
    path: AppRoutes.notifications,
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const NotificationListPage()),
    routes: [
      GoRoute(
        path: ':id',
        pageBuilder: (context, state) => slidePage(
          key: state.pageKey,
          child: NotificationDetailPage(
            notificationId: state.pathParameters['id']!,
          ),
        ),
      ),
    ],
  ),
];
