import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router_helpers.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/customizer/presentation/pages/page.dart';

part 'routes.g.dart';

/// 编排页入口。
///
/// 一个路由服务五个 surface：`surface` 用 `SurfaceId.wireValue`
/// （`today` / `record` / …），所以 tab 页上的按钮只需把它自己的 surface
/// 带进来，不必各写一条路由。
@TypedGoRoute<CustomizeRoute>(path: '/customize/:surface')
class CustomizeRoute extends GoRouteData with $CustomizeRoute {
  const CustomizeRoute({required this.surface});

  final String surface;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    // 解析不到（手改深链、下架 surface）就回今日页——编排不存在「空页面」形态。
    final resolved = SurfaceId.fromWire(surface) ?? SurfaceId.today;
    final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;
    return sidePanelPage(
      key: state.pageKey,
      isDesktop: isDesktop,
      maxWidth: 960,
      child: CustomizerPage(surface: resolved),
    );
  }
}
