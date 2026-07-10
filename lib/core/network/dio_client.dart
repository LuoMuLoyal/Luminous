// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/interceptors/auth_interceptor.dart';
import 'package:luminous/core/network/interceptors/error_interceptor.dart';
import 'package:luminous/core/network/interceptors/retry_interceptor.dart';
import 'package:luminous/core/network/session_store.dart';

/// Luminous 对 Lucent API 客户端的统一封装入口。
///
/// 纯 Dio 实例配置 + interceptor 注册，不包含业务逻辑。
/// 认证刷新、错误映射、重试策略分别由独立的 interceptor 处理。
class LucentDioClient {
  LucentDioClient({
    required String baseUrl,
    required LucentSessionStore sessionStore,
    String Function()? localeResolver,
    Future<void> Function()? onSessionExpired,
    Dio? dio,
    Iterable<Interceptor> interceptors = const [],
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

    _client = LucentClient(_dio, baseUrl: baseUrl);
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

    _dio.interceptors.addAll(<Interceptor>[
      ...interceptors,
      _authInterceptor,
      RetryInterceptor(dio: _dio),
      ErrorInterceptor(),
    ]);
  }

  static const Duration _defaultConnectTimeout = Duration(seconds: 10);
  static const Duration _defaultReceiveTimeout = Duration(seconds: 10);
  static const Duration _defaultSendTimeout = Duration(seconds: 10);

  final Dio _dio;
  late final LucentClient _client;
  late final Dio _refreshDio;
  late final AuthInterceptor _authInterceptor;

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

  /// Callback invoked when the session can no longer be refreshed.
  /// Delegates to [AuthInterceptor.onSessionExpired].
  set onSessionExpired(Future<void> Function()? callback) {
    _authInterceptor.onSessionExpired = callback;
  }

  void dispose() {
    _dio.close(force: true);
    _refreshDio.close(force: true);
  }
}
