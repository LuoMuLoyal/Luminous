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

/// Custom scheme registered as the deep-link fallback on both platforms.
///
/// Used when the server-side `assetlinks.json` / `apple-app-site-association`
/// files are not yet in place, so App Links / Universal Links cannot verify.
///
/// Read from `LUMINOUS_DEEP_LINK_SCHEME` rather than hardcoded: no custom scheme
/// was registered anywhere in the repo before this change (Better Auth's
/// archived `luminous://auth/callback` reference is retired and not
/// authoritative), so the final value is still a product decision.
///
/// Returns an empty string when unset; [isAcceptedDeepLink] then applies only
/// the host rule.
String get deepLinkSchemeValue =>
    EnvReader.string(EnvKey.luminousDeepLinkScheme);

/// Whether [uri] belongs to this app's deep-link domain.
///
/// A link on the configured custom scheme is always accepted:
/// `scheme://login/oauth/qq` parses with `host == 'login'`, so applying the host
/// check to it would reject the very fallback the platform declarations
/// register.
///
/// Returns `true` for http(s) links when no host is configured, so a build
/// without `LUMINOUS_DEEP_LINK_HOST` is not silently dead.
bool isAcceptedDeepLink(Uri uri, {String? host, String? scheme}) {
  final configuredScheme = scheme ?? deepLinkSchemeValue;
  if (configuredScheme.isNotEmpty && uri.scheme == configuredScheme) {
    return true;
  }

  final configuredHost = host ?? deepLinkHostValue;
  if (configuredHost.isEmpty) return true;
  return uri.host.toLowerCase() == configuredHost.toLowerCase();
}

/// The configured deep-link host.
@riverpod
String deepLinkHost(Ref ref) => deepLinkHostValue;

/// The configured custom deep-link scheme.
@riverpod
String deepLinkScheme(Ref ref) => deepLinkSchemeValue;

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
/// subscribe in one place. Links whose scheme/host are not configured are
/// dropped — see [isAcceptedDeepLink].
///
/// Consumers observe this through `ref.listen` as an `AsyncValue<Uri>`, matching
/// how the push providers in `core/push/message_handler.dart` are consumed.
@riverpod
Stream<Uri> deepLinkStream(Ref ref) {
  final source = ref.watch(deepLinkSourceProvider);
  final host = ref.watch(deepLinkHostProvider);
  final scheme = ref.watch(deepLinkSchemeProvider);

  return Stream<Uri>.multi((controller) {
    StreamSubscription<Uri>? subscription;

    void forward(Uri uri) {
      if (isAcceptedDeepLink(uri, host: host, scheme: scheme)) {
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
