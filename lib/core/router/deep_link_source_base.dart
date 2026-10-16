import 'dart:async';

/// Platform source of incoming deep links.
///
/// Decoupled from the `app_links` plugin so tests can drive the stream with a
/// fake instead of launching real native channels (the repo forbids starting
/// real device capabilities in tests).
abstract interface class DeepLinkSource {
  /// Emits when the app is already running and a link arrives.
  Stream<Uri> get uriLinkStream;

  /// The link that launched the app, or `null` when it started normally.
  Future<Uri?> getInitialLink();
}

/// Source for platforms without a native deep-link channel.
///
/// Web receives OAuth callbacks as route query parameters, and desktop builds
/// register no associated-domain or intent-filter, so both get this no-op.
final class NoopDeepLinkSource implements DeepLinkSource {
  const NoopDeepLinkSource();

  @override
  Stream<Uri> get uriLinkStream => const Stream<Uri>.empty();

  @override
  Future<Uri?> getInitialLink() async => null;
}

/// A [DeepLinkSource] driven by tests.
///
/// [emit] pushes a hot-start link; [initial] is returned by [getInitialLink]
/// to simulate a cold start.
final class FakeDeepLinkSource implements DeepLinkSource {
  FakeDeepLinkSource({Stream<Uri>? stream, this.initial})
    : _injected = stream,
      _controller = stream == null ? StreamController<Uri>.broadcast() : null;

  final Stream<Uri>? _injected;
  final StreamController<Uri>? _controller;

  /// The link returned by [getInitialLink].
  Uri? initial;

  /// Pushes [uri] to listeners, simulating a link arriving while running.
  void emit(Uri uri) => _controller?.add(uri);

  @override
  Stream<Uri> get uriLinkStream => _injected ?? _controller!.stream;

  @override
  Future<Uri?> getInitialLink() async => initial;

  void dispose() => unawaited(_controller?.close());
}
