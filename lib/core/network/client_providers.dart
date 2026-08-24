// ignore_for_file: prefer_final_locals, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:luminous/core/config/developer_settings.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/network/base_url.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/core/network/trace_context.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_providers.g.dart';

// ---------------------------------------------------------------------------
// Core infrastructure providers (keepAlive — singleton-like services)
// ---------------------------------------------------------------------------

/// Resolves the Lucent API base URL.
///
/// In release mode, always uses the compile-time default. In debug mode,
/// allows runtime switching via developer settings.
@Riverpod(keepAlive: true)
String lucentBaseUrl(Ref ref) {
  if (kReleaseMode) {
    return LucentBaseUrl.value;
  }

  final devSettings = ref
      .watch(developerSettingsControllerProvider)
      .asData
      ?.value;
  if (devSettings != null) {
    return devSettings.resolvedBaseUrl;
  }
  return LucentBaseUrl.value;
}

/// Provides the [LucentSessionStore] for token persistence.
@Riverpod(keepAlive: true)
LucentSessionStore lucentSessionStore(Ref ref) {
  return const SecureLucentSessionStore();
}

/// Provides the [LucentDioClient] singleton — the root HTTP client for all
/// Lucent API communication.
///
/// Wires up auth interceptors, token refresh, retry, and locale resolution.
/// Disposes the underlying Dio instances when the provider is destroyed.
@Riverpod(keepAlive: true)
LucentDioClient lucentDioClient(Ref ref) {
  final client = LucentDioClient(
    baseUrl: ref.watch(lucentBaseUrlProvider),
    sessionStore: ref.watch(lucentSessionStoreProvider),
    localeResolver: () =>
        (ref.read(localeControllerProvider).asData?.value ?? AppLocale.system)
            .acceptLanguage,
    onTraceId: (id) {
      TraceContext.lastTraceId = id;
      ref.read(lastTraceIdProvider.notifier).update(id);
    },
  );
  ref.onDispose(client.dispose);
  return client;
}

/// Latest backend trace id, read from the Lucent `traceresponse` header.
/// Updated by the trace interceptor callback as requests complete; feature
/// code can attach this to logs / error reports to correlate with Jaeger.
@Riverpod(keepAlive: true)
class LastTraceId extends _$LastTraceId {
  @override
  String? build() => null;

  void update(String id) => state = id;
}

/// Provides the generated [LucentClient] — the single entry point for
/// all API access in feature code.
///
/// Features should use `ref.watch(lucentClientProvider).medicines` etc.
@Riverpod(keepAlive: true)
LucentClient lucentClient(Ref ref) {
  return ref.watch(lucentDioClientProvider).client;
}
