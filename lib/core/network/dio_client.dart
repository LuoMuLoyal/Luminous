// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/core/network/envelope.dart';
import 'package:luminous/core/network/result_code.dart';
import 'package:luminous/core/network/session_store.dart';

/// Luminous 对 Lucent API 客户端的统一封装入口。
///
/// 约定：
/// - 生成代码放在 `generated/lucent_api`
/// - 业务层不要直接 new 生成器里的 `LucentClient`
/// - 统一通过这里注入 baseUrl、token 和通用 Dio 行为
class LucentDioClient {
  static const String medicinesBypassCacheHeader = 'x-bypass-cache';

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
           ),
       _sessionStore = sessionStore,
       _baseUrl = baseUrl,
       _localeResolver = localeResolver,
       _onSessionExpired = onSessionExpired {
    if (httpClientAdapter != null) {
      _dio.httpClientAdapter = httpClientAdapter;
    }
    _client = LucentClient(_dio, baseUrl: baseUrl);
    _refreshDio = Dio(
      _createBaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        extraHeaders: const <String, String>{'Accept': 'application/json'},
      ),
    );
    if (httpClientAdapter != null) {
      _refreshDio.httpClientAdapter = httpClientAdapter;
    }
    _dio.interceptors.addAll(<Interceptor>[
      ...interceptors,
      ..._buildInterceptors(),
    ]);
  }

  static const Duration _defaultConnectTimeout = Duration(seconds: 10);
  static const Duration _defaultReceiveTimeout = Duration(seconds: 10);
  static const Duration _defaultSendTimeout = Duration(seconds: 10);

  final Dio _dio;
  late final LucentClient _client;
  final LucentSessionStore _sessionStore;
  final String _baseUrl;
  final String Function()? _localeResolver;
  Future<void> Function()? _onSessionExpired;
  late final Dio _refreshDio;

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

  Future<LucentSessionTokens?>? _refreshFuture;

  List<Interceptor> _buildInterceptors() {
    return <Interceptor>[
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers.putIfAbsent('Accept', () => 'application/json');
          final acceptLanguage = _localeResolver?.call().trim() ?? '';
          if (acceptLanguage.isNotEmpty) {
            options.headers['Accept-Language'] = acceptLanguage;
          }

          final skipAuthorization = options.extra['skipAuthorization'] == true;
          final alreadyHasAuthorization = options.headers.containsKey(
            'Authorization',
          );

          if (!skipAuthorization && !alreadyHasAuthorization) {
            final token = await _sessionStore.readAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final shouldRefresh = await _shouldRefresh(error);
          if (shouldRefresh) {
            final refreshedTokens = await _refreshTokens();
            if (refreshedTokens != null && refreshedTokens.hasAccessToken) {
              final retryResponse = await _retry(
                error.requestOptions,
                refreshedTokens,
              );
              handler.resolve(retryResponse);
              return;
            }
          }

          if (shouldRefresh || _isAuthFailure(error)) {
            await _sessionStore.clear();
            final onSessionExpired = _onSessionExpired;
            if (onSessionExpired != null) {
              await onSessionExpired();
            }
          }

          handler.reject(_mapToApiException(error));
        },
      ),
    ];
  }

  Dio get dio => _dio;

  LucentClient get client => _client;

  HealthApi get healthApi => _client.health;

  AccountApi get accountApi => _client.account;

  AuthApi get authApi => _client.auth;

  MedicinesApi get medicinesApi => _client.medicines;
  EnvironmentApi get environmentApi => _client.environment;
  UserHealthContextApi get userHealthContextApi => _client.userHealthContext;
  DailyRecordsApi get dailyRecordsApi => _client.dailyRecords;
  MedicineDoseLogsApi get medicineDoseLogsApi => _client.medicineDoseLogs;
  MedicineRemindersApi get medicineRemindersApi => _client.medicineReminders;
  SupportResourcesApi get supportResourcesApi => _client.supportResources;
  UserSettingsApi get userSettingsApi => _client.userSettings;
  DataExportApi get dataExportApi => _client.dataExport;
  ReportsApi get reportsApi => _client.reports;
  TodayAnalysisApi get todayAnalysisApi => _client.todayAnalysis;
  AssistantApi get assistantApi => _client.assistant;
  NotificationsApi get notificationsApi => _client.notifications;
  FilesApi get filesApi => _client.files;

  Map<String, String> medicinesHeaders({bool bypassCache = false}) {
    if (!bypassCache) {
      return const <String, String>{};
    }

    return const <String, String>{medicinesBypassCacheHeader: 'true'};
  }

  Future<void> writeSession(LucentSessionTokens tokens) {
    return _sessionStore.write(tokens);
  }

  Future<String?> readAccessToken() {
    return _sessionStore.readAccessToken();
  }

  Future<String?> readRefreshToken() {
    return _sessionStore.readRefreshToken();
  }

  Future<void> clearSession() {
    return _sessionStore.clear();
  }

  /// Callback invoked when the session can no longer be refreshed (or any 401
  /// response is received without a refreshable token). Set by the auth layer
  /// so the UI can transition to a signed-out state.
  set onSessionExpired(Future<void> Function()? callback) {
    _onSessionExpired = callback;
  }

  bool _isAuthFailure(DioException error) {
    return error.response?.statusCode == 401;
  }

  void dispose() {
    _dio.close(force: true);
    _refreshDio.close(force: true);
  }

  Future<bool> _shouldRefresh(DioException error) async {
    final requestOptions = error.requestOptions;
    if (requestOptions.extra['skipAuthRefresh'] == true) {
      return false;
    }

    if (requestOptions.extra['hasRetriedAfterRefresh'] == true) {
      return false;
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != 401) {
      return false;
    }

    final data = error.response?.data;
    final json = coerceToStringMap(data);
    final envelope = json == null
        ? null
        : LucentEnvelope<Object?>.fromJson(json, dataDecoder: (raw) => raw);
    final code = envelope?.code;

    if (code == LucentResultCode.tokenExpired) {
      final refreshToken = await _sessionStore.readRefreshToken();
      return refreshToken != null && refreshToken.isNotEmpty;
    }

    return false;
  }

  Future<LucentSessionTokens?> _refreshTokens() {
    final pending = _refreshFuture;
    if (pending != null) {
      return pending;
    }

    final future = _doRefresh();
    _refreshFuture = future;
    future.whenComplete(() => _refreshFuture = null);
    return future;
  }

  Future<LucentSessionTokens?> _doRefresh() async {
    final refreshToken = await _sessionStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _refreshDio.post<Object>(
        '/api/v1/auth/refresh',
        data: <String, String>{'refreshToken': refreshToken},
        options: Options(
          headers: _localeResolver == null
              ? null
              : <String, String>{'Accept-Language': _localeResolver.call()},
          extra: const <String, Object?>{
            'skipAuthorization': true,
            'skipAuthRefresh': true,
          },
        ),
      );

      final json = coerceToStringMap(response.data);
      if (json == null) {
        return null;
      }

      final envelope = LucentEnvelope<LucentSessionTokens>.fromJson(
        json,
        dataDecoder: (raw) {
          final dataMap = coerceToStringMap(raw) ?? const <String, dynamic>{};
          final accessToken = dataMap['accessToken']?.toString().trim() ?? '';
          final nextRefreshToken =
              dataMap['refreshToken']?.toString().trim() ?? '';
          return LucentSessionTokens(
            accessToken: accessToken,
            refreshToken: nextRefreshToken,
          );
        },
      );

      if (!envelope.isSuccess || envelope.data == null) {
        return null;
      }

      await _sessionStore.write(envelope.data!);
      return envelope.data;
    } on DioException {
      return null;
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions requestOptions,
    LucentSessionTokens tokens,
  ) {
    final nextHeaders = Map<String, dynamic>.from(requestOptions.headers);
    nextHeaders['Authorization'] = 'Bearer ${tokens.accessToken}';

    final nextExtra = Map<String, dynamic>.from(requestOptions.extra);
    nextExtra['hasRetriedAfterRefresh'] = true;

    return _dio.fetch<dynamic>(
      requestOptions.copyWith(headers: nextHeaders, extra: nextExtra),
    );
  }

  DioException _mapToApiException(DioException error) {
    final response = error.response;
    final json = coerceToStringMap(response?.data);
    final envelope = json == null
        ? null
        : LucentEnvelope<Object?>.fromJson(json, dataDecoder: (raw) => raw);
    final requestId = response?.headers.value('X-Request-Id');

    return DioException(
      requestOptions: error.requestOptions,
      response: response,
      type: error.type,
      error: LucentApiException(
        message: () {
          final env = envelope;
          if (env != null && env.message.isNotEmpty) {
            return env.message;
          }
          return _fallbackMessage(error);
        }(),
        code: envelope?.code,
        statusCode: response?.statusCode,
        requestId: requestId,
        data: json,
      ),
      stackTrace: error.stackTrace,
    );
  }

  String _fallbackMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => '连接超时，请稍后再试。',
      DioExceptionType.sendTimeout => '请求发送超时，请稍后再试。',
      DioExceptionType.receiveTimeout => '响应接收超时，请稍后再试。',
      DioExceptionType.badCertificate => '服务器证书校验失败。',
      DioExceptionType.connectionError => '网络请求失败，请检查当前连接。',
      DioExceptionType.cancel => '请求已取消。',
      DioExceptionType.badResponse => '请求失败，请稍后再试。',
      DioExceptionType.unknown => '发生了未预期的网络错误。',
    };
  }
}
