import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/customizer/presentation/routes.dart';

/// 打开某个 surface 的编排页。
///
/// 由组合根注入到 `surfaceCustomizerOpenerProvider`：tab 顶栏（`core/` 与其他
/// feature）因此不需要认识 customizer 这个 feature，也不用反向依赖它。
///
/// 已经在编排页上时直接返回：重复点标题不应该把同一个页面叠成两层。
void openSurfaceCustomizer(BuildContext context, SurfaceId surface) {
  final router = GoRouter.maybeOf(context);
  if (router == null) return;

  final location = CustomizeRoute.forSurface(surface).location;
  if (router.state.matchedLocation == location) return;

  unawaited(context.push(location));
}
