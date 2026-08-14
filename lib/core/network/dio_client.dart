// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/interceptors/auth_interceptor.dart';
import 'package:luminous/core/network/interceptors/envelope_interceptor.dart';
import 'package:luminous/core/network/interceptors/error_interceptor.dart';
import 'package:luminous/core/network/interceptors/retry_interceptor.dart';
import 'package:luminous/core/network/interceptors/trace_interceptor.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_dio/sentry_dio.dart';

/// Thin wrapper over the generated [LucentApi] that exposes individual API
/// clients as property getters, preserving the `.assistant`, `.medicines` etc.
/// access pattern used throughout feature datasources.
class LucentClient {
  LucentClient(this._api);

  final LucentApi _api;

  AccountApi get account => _api.getAccountApi();
  AssistantApi get assistant => _api.getAssistantApi();
  AuthApi get auth => _api.getAuthApi();
  DailyRecordsApi get dailyRecords => _api.getDailyRecordsApi();
  DataExportApi get dataExport => _api.getDataExportApi();
  EnvironmentApi get environment => _api.getEnvironmentApi();
  FilesApi get files => _api.getFilesApi();
  HealthApi get health => _api.getHealthApi();
  HealthEventsApi get healthEvents => _api.getHealthEventsApi();
  LegalDocumentsApi get legalDocuments => _api.getLegalDocumentsApi();
  MedicineDoseLogsApi get medicineDoseLogs => _api.getMedicineDoseLogsApi();
  MedicineRemindersApi get medicineReminders => _api.getMedicineRemindersApi();
  MedicinesApi get medicines => _api.getMedicinesApi();
  NotificationsApi get notifications => _api.getNotificationsApi();
  // ProductEventsApi was added via the filtered generation path, so the
  // generated LucentApi class has no getter for it yet. Constructing it from
  // the shared Dio is equivalent to the generated getters and keeps the
  // generated client untouched.
  ProductEventsApi get productEvents => ProductEventsApi(_api.dio);
  ReminderDeliveriesApi get reminderDeliveries =>
      _api.getReminderDeliveriesApi();
  ReportsApi get reports => _api.getReportsApi();
  SupportResourcesApi get supportResources => _api.getSupportResourcesApi();
  TodayAnalysisApi get todayAnalysis => _api.getTodayAnalysisApi();
  TodaySuggestionApi get todaySuggestion => _api.getTodaySuggestionApi();
  UserHealthContextApi get userHealthContext => _api.getUserHealthContextApi();
  UserSettingsApi get userSettings => _api.getUserSettingsApi();
}

/// Unified entry point for the Luminous Lucent API client.
///
/// Pure Dio instance configuration + interceptor registration; no business logic.
/// Auth refresh, error mapping, and retry strategy are handled by independent interceptors.
class LucentDioClient {
  LucentDioClient({
    required String baseUrl,
    required LucentSessionStore sessionStore,
    String Function()? localeResolver,
    Future<void> Function()? onSessionExpired,
    Dio? dio,
    Iterable<Interceptor> interceptors = const [],
    TraceInterceptor? traceInterceptor,
    void Function(String traceId)? onTraceId,
    HttpClientAdapter? httpClientAdapter,
    Duration connectTimeout = _defaultConnectTimeout,
    Duration receiveTimeout = _defaultReceiveTimeout,
    Duration sendTimeout = _defaultSendTimeout,
  }) : _dio =
           dio ??
           Dio(
             _createBaseOptions(
               baseUrl: baseUrl,
               connectTimeout: connectTimeout,
               receiveTimeout: receiveTimeout,
               sendTimeout: sendTimeout,
             ),
           ) {
    if (httpClientAdapter != null) {
      _dio.httpClientAdapter = httpClientAdapter;
    }

    _client = LucentClient(LucentApi(dio: _dio));
    final refreshDio = Dio(
      _createBaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        extraHeaders: const <String, String>{'Accept': 'application/json'},
      ),
    );
    if (httpClientAdapter != null) {
      refreshDio.httpClientAdapter = httpClientAdapter;
    }
    _refreshDio = refreshDio;

    _authInterceptor = AuthInterceptor(
      dio: _dio,
      sessionStore: sessionStore,
      refreshDio: refreshDio,
      localeResolver: localeResolver,
      onSessionExpired: onSessionExpired,
    );

    final skipInjection = _isSentryPropagatingTraceparent();
    _traceInterceptor =
        traceInterceptor ??
        TraceInterceptor(
          onTraceId: onTraceId,
          skipHeaderInjection: skipInjection,
        );
    // The refresh Dio gets its own interceptor instance so token-refresh
    // requests do not overwrite the user-visible lastTraceId (and the
    // lastTraceIdProvider / TraceContext it feeds) with their own trace ids.
    _refreshDio.interceptors.add(
      TraceInterceptor(skipHeaderInjection: skipInjection),
    );

    _dio.interceptors.addAll(<Interceptor>[
      _traceInterceptor,
      ...interceptors,
      _authInterceptor,
      RetryInterceptor(dio: _dio),
      ErrorInterceptor(),
      EnvelopeInterceptor(),
    ]);

    // Sentry distributed tracing: wraps the HTTP adapter / transformer to
    // attach tracing headers (sentry-trace/baggage, plus W3C `traceparent`
    // when options.propagateTraceparent is set) and record request spans
    // under the active route transaction. `captureFailedRequests` stays off —
    // failures are already reported via the Talker→Sentry observer and the
    // framework error handlers. Must run last, after the interceptor chain.
    _dio.addSentry(captureFailedRequests: false);
    _refreshDio.addSentry(captureFailedRequests: false);
  }

  static const Duration _defaultConnectTimeout = Duration(seconds: 10);
  static const Duration _defaultReceiveTimeout = Duration(seconds: 10);
  static const Duration _defaultSendTimeout = Duration(seconds: 10);

  final Dio _dio;
  late final LucentClient _client;
  late final Dio _refreshDio;
  late final AuthInterceptor _authInterceptor;
  late final TraceInterceptor _traceInterceptor;

  static BaseOptions _createBaseOptions({
    required String baseUrl,
    required Duration connectTimeout,
    required Duration receiveTimeout,
    required Duration sendTimeout,
    Map<String, String> extraHeaders = const <String, String>{},
  }) {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: extraHeaders,
    );
  }

  /// The underlying Dio instance. Used by SSE clients and other
  /// callers that need direct access to the configured Dio.
  Dio get dio => _dio;

  /// The generated Lucent API client.
  LucentClient get client => _client;

  /// The latest trace id seen by the trace interceptor, or null before the
  /// first request. Used for diagnostics / error reporting.
  String? get lastTraceId => _traceInterceptor.lastTraceId;

  /// Callback invoked when the session can no longer be refreshed.
  /// Delegates to [AuthInterceptor.onSessionExpired].
  set onSessionExpired(Future<void> Function()? callback) {
    _authInterceptor.onSessionExpired = callback;
  }

  void dispose() {
    _dio.close(force: true);
    _refreshDio.close(force: true);
  }

  /// Returns true when Sentry is initialized and configured to propagate
  /// W3C `traceparent` headers (`propagateTraceparent = true`).
  ///
  /// When Sentry handles traceparent injection via the `sentry_dio` adapter,
  /// the [TraceInterceptor] can skip generating its own random traceparent
  /// to avoid a wasted RNG call and a stale intermediate [lastTraceId].
  ///
  /// Uses only the public [Sentry.isEnabled] flag. `main.dart` always enables
  /// `propagateTraceparent` whenever Sentry is initialized, so the flag is
  /// equivalent here — and unlike `HubAdapter` / `Sentry.currentHub`, it is
  /// covered by the SDK's semver guarantees.
  static bool _isSentryPropagatingTraceparent() {
    try {
      return Sentry.isEnabled;
    } catch (_) {
      return false;
    }
  }
}
