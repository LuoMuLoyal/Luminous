import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router_helpers.dart';
import 'package:luminous/features/assistant/presentation/pages/page.dart';

part 'routes.g.dart';

@TypedGoRoute<AssistantRoute>(path: '/assistant')
class AssistantRoute extends GoRouteData with $AssistantRoute {
  const AssistantRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const AssistantPage());
  }
}
