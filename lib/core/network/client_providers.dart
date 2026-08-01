// ignore_for_file: prefer_final_locals, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:luminous/core/config/developer_settings.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/network/base_url.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/network/interceptors/security_elevation_interceptor.dart';
import 'package:luminous/core/network/security_elevation_token_holder.dart';
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

/// Provides the [SecurityElevationTokenHolder] — a mutable in-memory store
/// for the short-lived security elevation token. The Dio interceptor reads
/// from this holder to inject the `x-security-elevation` header.
@Riverpod(keepAlive: true)
SecurityElevationTokenHolder securityElevationTokenHolder(Ref ref) {
  return SecurityElevationTokenHolder();
}

/// Provides the [LucentDioClient] singleton — the root HTTP client for all
/// Lucent API communication.
///
/// Wires up auth interceptors, token refresh, retry, and locale resolution.
/// Disposes the underlying Dio instances when the provider is destroyed.
@Riverpod(keepAlive: true)
LucentDioClient lucentDioClient(Ref ref) {
  final tokenHolder = ref.watch(securityElevationTokenHolderProvider);
  final client = LucentDioClient(
    baseUrl: ref.watch(lucentBaseUrlProvider),
    sessionStore: ref.watch(lucentSessionStoreProvider),
    localeResolver: () =>
        (ref.read(localeControllerProvider).asData?.value ?? AppLocale.system)
            .acceptLanguage,
    interceptors: [SecurityElevationInterceptor(holder: tokenHolder)],
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
