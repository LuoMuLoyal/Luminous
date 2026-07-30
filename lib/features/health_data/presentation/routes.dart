import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router/helpers.dart';
import 'package:luminous/features/health_data/presentation/pages/health_sync.dart';

part 'routes.g.dart';

@TypedGoRoute<HealthSyncRoute>(path: '/health-sync')
class HealthSyncRoute extends GoRouteData with $HealthSyncRoute {
  const HealthSyncRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const HealthSyncPage());
  }
}
