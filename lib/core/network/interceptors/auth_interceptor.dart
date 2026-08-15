// ignore_for_file: prefer_initializing_formals, avoid_renaming_method_parameters

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/api_paths.dart';
import 'package:luminous/core/network/envelope.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/core/network/result_code.dart';
import 'package:luminous/core/network/session_store.dart';

/// Auth interceptor: token injection + 401 refresh + retry + session clear.
///
/// Extracted from the original `LucentDioClient._buildInterceptors()` +
/// `_shouldRefresh()` + `_refreshTokens()` + `_doRefresh()` + `_retry()`.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required LucentSessionStore sessionStore,
    required Dio refreshDio,
    String Function()? localeResolver,
    Future<void> Function()? onSessionExpired,
  }) : _dio = dio,
       _sessionStore = sessionStore,
       _refreshDio = refreshDio,
       _localeResolver = localeResolver,
       _onSessionExpired = onSessionExpired;

  /// Main Dio instance — used for retrying requests after a successful
  /// token refresh so the retried request goes through the full
  /// interceptor chain.
  final Dio _dio;

  final LucentSessionStore _sessionStore;

  /// Separate Dio instance for the refresh endpoint call, avoiding
  /// interceptor recursion.
  final Dio _refreshDio;

  final String Function()? _localeResolver;
  Future<void> Function()? _onSessionExpired;

  /// Callback invoked when the session can no longer be refreshed (or any 401
  /// response is received without a refreshable token). Set by the auth layer
  /// so the UI can transition to a signed-out state.
  set onSessionExpired(Future<void> Function()? callback) {
    _onSessionExpired = callback;
  }

  Future<LucentSessionTokens?>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
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
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final shouldRefresh = await _shouldRefresh(err);
    var currentErr = err;
    if (shouldRefresh) {
      final refreshedTokens = await _refreshTokens();
      if (refreshedTokens != null && refreshedTokens.hasAccessToken) {
        try {
          final retryResponse = await _retry(
            err.requestOptions,
            refreshedTokens,
          );
          handler.resolve(retryResponse);
          return;
        } on DioException catch (e) {
          // Retry failed — fall through to session-clear / error mapping.
          currentErr = e;
        }
      }
    }

    if (shouldRefresh || _isAuthFailure(currentErr)) {
      await _sessionStore.clear();
      final onSessionExpired = _onSessionExpired;
      if (onSessionExpired != null) {
        // A throwing UI callback must not swallow the original error — log
        // it and fall through so `handler.next` still resolves the request.
        try {
          await onSessionExpired();
        } catch (e, st) {
          appTalker.error(
            'AuthInterceptor: onSessionExpired callback failed: $e',
            st,
          );
        }
      }
    }

    handler.next(currentErr);
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  bool _isAuthFailure(DioException error) {
    return error.response?.statusCode == 401;
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
    unawaited(future.whenComplete(() => _refreshFuture = null));
    return future;
  }

  Future<LucentSessionTokens?> _doRefresh() async {
    final refreshToken = await _sessionStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _refreshDio.post<Object>(
        LucentApiPaths.authRefresh,
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
    } on DioException catch (e) {
      // Log refresh failures (endpoint + status) instead of swallowing them,
      // so production issues are diagnosable. Token values are never logged.
      appTalker.error(
        'AuthInterceptor: token refresh failed: '
        'status=${e.response?.statusCode} endpoint=${e.requestOptions.uri} '
        'error=${e.message}',
      );
      return null;
    } catch (e, st) {
      // e.g. session store write failures — still degrade to null rather
      // than letting the original request hang.
      appTalker.error('AuthInterceptor: token refresh failed: $e', st);
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
}
