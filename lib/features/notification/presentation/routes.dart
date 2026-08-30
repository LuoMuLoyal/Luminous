import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router_helpers.dart';
import 'package:luminous/features/notification/presentation/pages/detail.dart';
import 'package:luminous/features/notification/presentation/pages/list.dart';

part 'routes.g.dart';

@TypedGoRoute<NotificationListRoute>(
  path: '/notifications',
  routes: [TypedGoRoute<NotificationDetailRoute>(path: ':id')],
)
class NotificationListRoute extends GoRouteData with $NotificationListRoute {
  const NotificationListRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const NotificationListPage());
  }
}

class NotificationDetailRoute extends GoRouteData
    with $NotificationDetailRoute {
  const NotificationDetailRoute({required this.id});

  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: NotificationDetailPage(notificationId: id),
    );
  }
}
