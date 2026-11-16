import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router_helpers.dart';
import 'package:luminous/features/shell/presentation/pages/nav_customizer.dart';

part 'routes.g.dart';

/// 底部导航编排页。
///
/// 挂在 settings 之外（顶层全屏路由）：它改的是**外壳本身**，不是某一项偏好；
/// 从设置页推进来、改完返回，路径语义清楚。
@TypedGoRoute<NavCustomizeRoute>(path: '/customize/nav')
class NavCustomizeRoute extends GoRouteData with $NavCustomizeRoute {
  const NavCustomizeRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const NavCustomizerPage());
  }
}
