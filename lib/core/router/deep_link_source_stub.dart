import 'package:luminous/core/router/deep_link_source_base.dart';

/// Stub used when no native deep-link channel is compiled in.
///
/// Keeps `NativeDeepLinkSource` resolvable on every target so call sites need
/// no conditional imports of their own.
final class NativeDeepLinkSource implements DeepLinkSource {
  const NativeDeepLinkSource();

  @override
  Stream<Uri> get uriLinkStream => const Stream<Uri>.empty();

  @override
  Future<Uri?> getInitialLink() async => null;
}
