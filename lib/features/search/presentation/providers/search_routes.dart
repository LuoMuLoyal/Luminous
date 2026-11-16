import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router_helpers.dart';
import 'package:luminous/features/search/presentation/pages/page.dart';

part 'search_routes.g.dart';

/// 药品搜索页的路径不属于 `medicine`：它是 search feature 的页面，路由声明
/// 跟着页面走。挂在 `/medicine/search` 下是因为入口来自用药流程，深链形态
/// 与产品语义一致，但**声明位置**必须在 search 自己这一侧——否则 medicine
/// 的路由表要 import search 的页面，那是跨 feature 的 presentation 依赖。
@TypedGoRoute<MedicineSearchRoute>(path: '/medicine/search')
class MedicineSearchRoute extends GoRouteData with $MedicineSearchRoute {
  const MedicineSearchRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const SearchPage());
  }
}
