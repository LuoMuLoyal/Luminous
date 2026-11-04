// ignore_for_file: prefer_final_locals, prefer_const_constructors

import 'package:luminous/core/config/developer_settings.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/network/client/base_url.dart';
import 'package:luminous/core/network/client/dio_client.dart';
import 'package:luminous/core/network/client/session_store.dart';
import 'package:luminous/core/network/client/trace_context.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_providers.g.dart';

// ---------------------------------------------------------------------------
// Core infrastructure providers (keepAlive — singleton-like services)
// ---------------------------------------------------------------------------

/// Resolves the Lucent API base URL.
///
/// The endpoint chosen in 设置 → 高级设置 → 开发者选项 applies in **every**
/// build mode: a shipped package can be repointed at another host without a
/// rebuild (the reporter of a mis-pinned HAP can fix it in-app). A build-pinned
/// `LUCENT_BASE_URL` only decides the default when no choice is stored.
///
/// The value is normalized before it reaches Dio: a scheme-less entry such as
/// `122.9.102.50:3000` used to make `BaseOptions` throw `FormatException`,
/// which put this provider in an error state and took down every consumer
/// (the red `ProviderException` screen).
@Riverpod(keepAlive: true)
String lucentBaseUrl(Ref ref) {
  final devSettings = ref
      .watch(developerSettingsControllerProvider)
      .asData
      ?.value;
  final candidate = devSettings?.resolvedBaseUrl ?? LucentBaseUrl.value;
  return LucentBaseUrl.normalize(candidate) ?? LucentBaseUrl.fallback;
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
