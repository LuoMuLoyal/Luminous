import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/notification/presentation/pages/notification_detail_page.dart';
import 'package:luminous/features/notification/presentation/pages/notification_list_page.dart';

import 'router_helpers.dart';

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
