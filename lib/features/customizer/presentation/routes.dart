import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router_helpers.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/customizer/presentation/pages/page.dart';

part 'routes.g.dart';

/// 编排页入口。
///
/// 一个路由服务五个 surface。路径参数保持 `String`（go_router 只能从 URL
/// 里拿到字符串），但**调用方永远给 [SurfaceId]**：[forSurface] 接收枚举，
/// 写错的 surface 因此是编译错误，而不是运行时才回退到默认页。
@TypedGoRoute<CustomizeRoute>(path: '/customize/:surface')
class CustomizeRoute extends GoRouteData with $CustomizeRoute {
  const CustomizeRoute({required this.surface});

  /// 按枚举构造。
  ///
  /// 深链仍可能带来任意字符串，[buildPage] 负责把它解析回枚举并在看不懂时
  /// 回退到今日页。
  factory CustomizeRoute.forSurface(SurfaceId surface) =>
      CustomizeRoute(surface: surface.wireValue);

  /// 要编排的表面的 wire 值（`:surface` 路径参数）。
  ///
  /// `@TypedGoRoute` 的占位符类型由其 path 决定，所以字段必须保持 `String`；
  /// 调用方用 [forSurface] 而不是手拼字符串。
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
