import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';
import 'package:luminous/core/router/deep_link_source.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deep_link.g.dart';

/// Configured deep-link host (compile-time `LUMINOUS_DEEP_LINK_HOST`).
///
/// Exposed as a plain getter as well as a provider so URI helpers stay callable
/// from non-widget code.
String get deepLinkHostValue => EnvReader.string(EnvKey.luminousDeepLinkHost);

/// Whether [uri] belongs to this app's deep-link domain.
///
/// Returns `true` when no host is configured, so a build without
/// `LUMINOUS_DEEP_LINK_HOST` still lets custom-scheme links through during
/// development.
bool isAcceptedDeepLink(Uri uri, {String? host}) {
  final configured = host ?? deepLinkHostValue;
  if (configured.isEmpty) return true;
  return uri.host.toLowerCase() == configured.toLowerCase();
}

/// The configured deep-link host.
@riverpod
String deepLinkHost(Ref ref) => deepLinkHostValue;

/// The platform deep-link source.
///
/// Web gets a no-op: OAuth callbacks there arrive as GoRouter query parameters
/// (`useOAuthCallbackHandler`) rather than through a native channel.
@riverpod
DeepLinkSource deepLinkSource(Ref ref) {
  if (kIsWeb) return const NoopDeepLinkSource();
  if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
    return const NoopDeepLinkSource();
  }
  return const NativeDeepLinkSource();
}

/// Incoming deep links, normalized into one broadcast stream.
///
/// The cold-start link is replayed once as the first event so consumers only
/// subscribe in one place. Links whose host is not the configured deep-link
/// host are dropped — see [isAcceptedDeepLink].
///
/// Consumers observe this through `ref.listen` as an `AsyncValue<Uri>`, matching
/// how the push providers in `core/push/message_handler.dart` are consumed.
@riverpod
Stream<Uri> deepLinkStream(Ref ref) {
  final source = ref.watch(deepLinkSourceProvider);
  final host = ref.watch(deepLinkHostProvider);

  return Stream<Uri>.multi((controller) {
    StreamSubscription<Uri>? subscription;

    void forward(Uri uri) {
      if (isAcceptedDeepLink(uri, host: host)) {
        controller.add(uri);
      }
    }

    unawaited(
      source.getInitialLink().then((initial) {
        if (initial != null) {
          forward(initial);
        }
        subscription = source.uriLinkStream.listen(
          forward,
          onError: controller.addError,
          onDone: controller.close,
        );
      }),
    );

    controller.onCancel = () => unawaited(subscription?.cancel());
  }).asBroadcastStream();
}
