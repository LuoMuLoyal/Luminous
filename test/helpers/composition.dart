import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:luminous/app/composition/components/registry.dart';

import 'layout_remote.dart';

/// Component-system overrides for widget tests.
///
/// The app installs the same overrides in `main.dart` (composition root). A test
/// that renders a whole page or a section needs them too, otherwise
/// `ComponentHost` finds an empty registry and renders nothing.
///
/// 布局仓储也在这里兜底：生产装配会发 `GET /layouts`，测试里没有网络与
/// token，请求会挂着并留下未完成的 Timer（表现为「A Timer is still pending」）。
List<Override> compositionTestOverrides() => [
  ...compositionProviderOverrides(),
  fakeLayoutRepositoryOverride(),
];
