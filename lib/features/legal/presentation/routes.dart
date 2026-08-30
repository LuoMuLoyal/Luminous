import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router_helpers.dart';
import 'package:luminous/features/legal/presentation/pages/detail.dart';
import 'package:luminous/features/legal/presentation/pages/list.dart';

part 'routes.g.dart';

@TypedGoRoute<LegalListRoute>(
  path: '/legal',
  routes: [TypedGoRoute<LegalDetailRoute>(path: ':docType')],
)
class LegalListRoute extends GoRouteData with $LegalListRoute {
  const LegalListRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const LegalListPage());
  }
}

class LegalDetailRoute extends GoRouteData with $LegalDetailRoute {
  const LegalDetailRoute({required this.docType});

  final String docType;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: LegalDetailPage(docType: docType),
    );
  }
}
