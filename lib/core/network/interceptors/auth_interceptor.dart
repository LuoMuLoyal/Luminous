// ignore_for_file: prefer_initializing_formals, avoid_renaming_method_parameters

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/api_paths.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/core/network/session_store.dart';

/// Outcome of a token-refresh attempt.
///
/// Lets [AuthInterceptor.onError] distinguish definitive auth failures
/// (refresh token expired/invalid → clear the session) from transient
/// failures (network blips, 5xx, malformed bodies → keep the session, so a
/// temporary outage does not force-log-out the user).
sealed class _RefreshOutcome {
  const _RefreshOutcome();
}

/// Refresh succeeded with a fresh token pair.
final class _RefreshSuccess extends _RefreshOutcome {
  const _RefreshSuccess(this.tokens);

  final LucentSessionTokens tokens;
}

/// The refresh token was rejected (invalid / expired / forbidden) — the
/// session cannot be recovered and must be cleared.
final class _RefreshAuthFailure extends _RefreshOutcome {
  const _RefreshAuthFailure();
}

/// Transient failure (network, timeout, 5xx, empty/malformed body) — the
/// session may still be valid and is kept.
final class _RefreshTransientFailure extends _RefreshOutcome {
  const _RefreshTransientFailure();
}

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

  Future<_RefreshOutcome?>? _refreshFuture;

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
    if (shouldRefresh) {
      final outcome = await _refreshTokens();
      switch (outcome) {
        case _RefreshSuccess(:final tokens):
          try {
            final retryResponse = await _retry(err.requestOptions, tokens);
            handler.resolve(retryResponse);
            return;
          } on DioException catch (e) {
            // Retry 也失败:认证类(再次 401)说明会话确实无法恢复,清会话;
            // 其余(网络/5xx)保留会话,错误原样下传。
            if (_isAuthFailure(e)) {
              await _clearSessionAndNotify();
            }
            handler.next(e);
            return;
          }
        case _RefreshAuthFailure():
          // 刷新令牌过期/无效:会话不可恢复,清会话并通知。
          await _clearSessionAndNotify();
          handler.next(err);
          return;
        case _RefreshTransientFailure():
          // 网络/服务端临时故障:保留会话,原 401 走常规错误路径,
          // 用户不会被误登出。
          handler.next(err);
          return;
        case null:
          // 刷新令牌已不可用(如并发登出已清除):会话不可恢复。
          await _clearSessionAndNotify();
          handler.next(err);
          return;
      }
    }

    if (_isAuthFailure(err)) {
      await _clearSessionAndNotify();
    }

    handler.next(err);
  }

  /// Clears the local session and notifies the auth layer. The throwing UI
  /// callback must not swallow the original error — log it and fall through
  /// so `handler.next` still resolves the request.
  Future<void> _clearSessionAndNotify() async {
    await _sessionStore.clear();
    final onSessionExpired = _onSessionExpired;
    if (onSessionExpired != null) {
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

  // ── Helpers ──────────────────────────────────────────────────────────

  bool _isAuthFailure(DioException error) {
    return error.response?.statusCode == 401;
  }

  /// Problem Details codes for which a token refresh can never help.
  static const _nonRefreshableAuthCodes = <String>{
    'AUTH_REFRESH_TOKEN_INVALID',
    'AUTH_LOGIN_RATE_LIMITED',
    'AUTH_WRONG_PASSWORD',
  };

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

    final failure = LucentErrorMapper.fromObject(error);
    final code = failure.code;

    if (code != null && _nonRefreshableAuthCodes.contains(code)) {
      return false;
    }

    final refreshToken = await _sessionStore.readRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  Future<_RefreshOutcome?> _refreshTokens() {
    final pending = _refreshFuture;
    if (pending != null) {
      return pending;
    }

    final future = _doRefresh();
    _refreshFuture = future;
    unawaited(future.whenComplete(() => _refreshFuture = null));
    return future;
  }

  Future<_RefreshOutcome?> _doRefresh() async {
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

      final dataMap = coerceToStringMap(response.data);
      if (dataMap == null) {
        // 响应体为空/非对象:非认证类失败,保留会话。
        return const _RefreshTransientFailure();
      }

      final accessToken = dataMap['accessToken'];
      final nextRefreshToken = dataMap['refreshToken'];
      if (accessToken is! String ||
          nextRefreshToken is! String ||
          accessToken.trim().isEmpty ||
          nextRefreshToken.trim().isEmpty) {
        // 成功响应但缺少完整 token resource:按临时故障处理,保留会话。
        return const _RefreshTransientFailure();
      }

      final tokens = LucentSessionTokens(
        accessToken: accessToken.trim(),
        refreshToken: nextRefreshToken.trim(),
      );
      await _sessionStore.write(tokens);
      return _RefreshSuccess(tokens);
    } on DioException catch (e) {
      // Log refresh failures (endpoint + status) instead of swallowing them,
      // so production issues are diagnosable. Token values are never logged.
      appTalker.error(
        'AuthInterceptor: token refresh failed: '
        'status=${e.response?.statusCode} endpoint=${e.requestOptions.uri} '
        'error=${e.message}',
      );
      // Problem Details 401/403 表示刷新令牌被拒绝或无权访问:认证失效,
      // 网络连接类、超时、5xx 等均为临时故障,保留会话。
      final failure = LucentErrorMapper.fromObject(e);
      if (failure.statusCode == 401 || failure.statusCode == 403) {
        return const _RefreshAuthFailure();
      }
      return const _RefreshTransientFailure();
    } catch (e, st) {
      // e.g. session store write failures — still degrade to null rather
      // than letting the original request hang.
      appTalker.error('AuthInterceptor: token refresh failed: $e', st);
      return const _RefreshTransientFailure();
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
