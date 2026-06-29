// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/core/network/lucent_envelope.dart';
import 'package:luminous/core/network/lucent_result_code.dart';
import 'package:luminous/core/network/lucent_session_store.dart';

/// Luminous 对 Lucent OpenAPI 客户端的统一封装入口。
///
/// 约定：
/// - 生成代码放在 `packages/lucent_openapi`
/// - 业务层不要直接 new 生成器里的 `LucentOpenapi`
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
  }) : _openapi = LucentOpenapi(
         dio:
             dio ??
             Dio(
               BaseOptions(
                 baseUrl: baseUrl,
                 connectTimeout: const Duration(seconds: 10),
                 receiveTimeout: const Duration(seconds: 10),
                 sendTimeout: const Duration(seconds: 10),
                 contentType: Headers.jsonContentType,
                 responseType: ResponseType.json,
               ),
             ),
         interceptors: <Interceptor>[],
       ),
       _sessionStore = sessionStore,
       _baseUrl = baseUrl,
       _localeResolver = localeResolver,
       _onSessionExpired = onSessionExpired {
    if (httpClientAdapter != null) {
      _openapi.dio.httpClientAdapter = httpClientAdapter;
    }
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: const <String, String>{'Accept': 'application/json'},
      ),
    );
    if (httpClientAdapter != null) {
      _refreshDio.httpClientAdapter = httpClientAdapter;
    }
    _openapi.dio.interceptors.addAll(<Interceptor>[
      ...interceptors,
      ..._buildInterceptors(),
    ]);
  }

  final LucentOpenapi _openapi;
  final LucentSessionStore _sessionStore;
  final String _baseUrl;
  final String Function()? _localeResolver;
  final Future<void> Function()? _onSessionExpired;
  late final Dio _refreshDio;
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
          if (await _shouldRefresh(error)) {
            final refreshedTokens = await _refreshTokens();
            if (refreshedTokens != null && refreshedTokens.hasAccessToken) {
              final retryResponse = await _retry(
                error.requestOptions,
                refreshedTokens,
              );
              handler.resolve(retryResponse);
              return;
            }

            await _sessionStore.clear();
            if (_onSessionExpired != null) {
              await _onSessionExpired();
            }
          }

          handler.reject(_mapToApiException(error));
        },
      ),
    ];
  }

  Dio get dio => _openapi.dio;

  AppApi get appApi => _openapi.getAppApi();

  AccountApi get accountApi => _openapi.getAccountApi();

  AuthApi get authApi => _openapi.getAuthApi();

  MedicinesApi get medicinesApi => _openapi.getMedicinesApi();
  EnvironmentApi get environmentApi => _openapi.getEnvironmentApi();
  UserHealthContextApi get userHealthContextApi =>
      _openapi.getUserHealthContextApi();
  DailyRecordsApi get dailyRecordsApi => _openapi.getDailyRecordsApi();
  MedicineDoseLogsApi get medicineDoseLogsApi =>
      _openapi.getMedicineDoseLogsApi();
  MedicineRemindersApi get medicineRemindersApi =>
      _openapi.getMedicineRemindersApi();
  SupportResourcesApi get supportResourcesApi =>
      _openapi.getSupportResourcesApi();
  UserSettingsApi get userSettingsApi => _openapi.getUserSettingsApi();
  DataExportApi get dataExportApi => _openapi.getDataExportApi();
  ReportsApi get reportsApi => _openapi.getReportsApi();
  TodayAnalysisApi get todayAnalysisApi => _openapi.getTodayAnalysisApi();
  AssistantApi get assistantApi => _openapi.getAssistantApi();

  NotificationsApi get notificationsApi => _openapi.getNotificationsApi();

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

  void dispose() {
    _openapi.dio.close(force: true);
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

    return _openapi.dio.fetch<dynamic>(
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
        message: envelope?.message.isNotEmpty == true
            ? envelope!.message
            : _fallbackMessage(error),
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
