import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:luminous/core/router/deep_link_source_base.dart';

/// Native deep-link source backed by the `app_links` plugin.
///
/// Only compiled where `dart.library.io` is available; other targets get
/// [NoopDeepLinkSource] because deep links there arrive as route query
/// parameters instead of through a native channel.
final class NativeDeepLinkSource implements DeepLinkSource {
  const NativeDeepLinkSource();

  // `AppLinks` is a singleton (`AppLinks()` returns a shared instance), so a
  // static holder keeps the constructor const and matches the stub.
  static final AppLinks _appLinks = AppLinks();

  @override
  Stream<Uri> get uriLinkStream => _appLinks.uriLinkStream;

  @override
  Future<Uri?> getInitialLink() => _appLinks.getInitialLink();
}
