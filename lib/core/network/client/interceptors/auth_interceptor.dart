// ignore_for_file: prefer_initializing_formals, avoid_renaming_method_parameters

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/client/session_store.dart';
import 'package:luminous/core/network/contract/api_paths.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/core/network/map_utils.dart';

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

/// No refresh token is stored (for example a concurrent logout already
/// cleared the session) — the session cannot be recovered.
final class _RefreshUnavailable extends _RefreshOutcome {
  const _RefreshUnavailable();
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

  Future<_RefreshOutcome>? _refreshFuture;

  /// HTTP error of the most recent failed refresh call, kept so
  /// [refreshSession] can rethrow the real transport/server failure (status
  /// code, Problem Details body, timeout type) instead of a synthesized one.
  DioException? _lastRefreshError;

  /// Coalesced token refresh — the single entry point every refresh caller
  /// must use.
  ///
  /// The backend rotates refresh tokens with single-use semantics (the
  /// `UserSession` row is claimed by an atomic delete), so two refresh calls
  /// racing with the same stored token can never both succeed: the loser gets
  /// `AUTH_REFRESH_TOKEN_INVALID` and, on the 401 path, wipes the session of a
  /// user whose session is in fact still valid.
  ///
  /// Concurrent calls — including one from external code such as the session
  /// restore flow — share the first in-flight call instead of issuing their
  /// own request. Returns the fresh token pair (already persisted); throws the
  /// underlying [DioException] when the refresh fails so callers can map it
  /// (401/403 → definitive auth failure, transport errors → transient).
  Future<LucentSessionTokens> refreshSession() async {
    final outcome = await _refreshTokens();
    if (outcome case _RefreshSuccess(:final tokens)) {
      return tokens;
    }
    throw _refreshFailureToException(outcome);
  }

  /// Rebuilds the [DioException] a coalesced refresh failed with. Callers that
  /// did not issue the request themselves (the explicit session-restore
  /// refresh) need the original status code and body to map the failure the
  /// same way the interceptor's own 401 path does.
  DioException _refreshFailureToException(_RefreshOutcome outcome) {
    final lastError = _lastRefreshError;
    if (lastError != null) {
      return lastError;
    }
    // No HTTP error was recorded (e.g. the refresh token vanished from the
    // store before the call): report a definitive 401 so callers treat the
    // session as unrecoverable rather than retrying forever.
    final requestOptions = RequestOptions(path: LucentApiPaths.authRefresh);
    return DioException(
      requestOptions: requestOptions,
      response: Response<Object>(
        requestOptions: requestOptions,
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
      message: 'Refresh token unavailable',
      error: outcome,
    );
  }

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
        case _RefreshAuthFailure() || _RefreshUnavailable():
          // 刷新令牌过期/无效,或本地已无刷新令牌(如并发登出):会话不可恢复,
          // 清会话并通知。
          await _clearSessionAndNotify();
          handler.next(err);
          return;
        case _RefreshTransientFailure():
          // 网络/服务端临时故障:保留会话,原 401 走常规错误路径,
          // 用户不会被误登出。
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

    // Only an explicit AUTH_TOKEN_EXPIRED Problem Details code marks the
    // session as refreshable. Every other auth failure (AUTH_REQUIRED,
    // AUTH_REFRESH_TOKEN_INVALID, AUTH_WRONG_PASSWORD, plain 401/403) is
    // not a refresh candidate and falls through to the 401 session-clear
    // path below.
    LucentFailure? failure;
    try {
      failure = LucentErrorMapper.fromObject(error);
    } on FormatException {
      // SSE (ResponseType.stream) 401: response.data is a ResponseBody
      // (stream), not a Map — coerceToStringMap returns null → FormatException.
      // We cannot determine the exact Problem Details code, but the backend
      // always returns application/problem+json for 401s. Attempt refresh
      // when a refresh token is available: if the original error was
      // AUTH_TOKEN_EXPIRED the refresh will succeed; otherwise the backend
      // will reject the refresh token and we fall back to session-clear.
      // This is safe because refresh is idempotent for invalid tokens.
      if (_isAuthFailure(error) && _hasProblemJsonContentType(error)) {
        final refreshToken = await _sessionStore.readRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          return true;
        }
      }
      failure = null;
    }
    if (failure == null || !failure.isTokenExpired) {
      return false;
    }

    final refreshToken = await _sessionStore.readRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  /// Whether the response content-type is `application/problem+json`.
  bool _hasProblemJsonContentType(DioException error) {
    final contentType = error.response?.headers
        .value(Headers.contentTypeHeader)
        ?.split(';')
        .first
        .trim()
        .toLowerCase();
    return contentType == 'application/problem+json';
  }

  /// Runs [_doRefresh] at most once at a time.
  ///
  /// The async wrapper matters: an `async` function body runs synchronously up
  /// to its first `await`, so `_refreshFuture` is assigned before any caller
  /// can observe it. A non-async version would hand control back at the first
  /// `await` inside [_doRefresh] and let a second caller start its own refresh
  /// with the same still-unrotated token.
  Future<_RefreshOutcome> _refreshTokens() async {
    final pending = _refreshFuture;
    if (pending != null) {
      return await pending;
    }

    final future = _doRefresh();
    _refreshFuture = future;
    unawaited(future.whenComplete(() => _refreshFuture = null));
    return await future;
  }

  Future<_RefreshOutcome> _doRefresh() async {
    final refreshToken = await _sessionStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return const _RefreshUnavailable();
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
      _lastRefreshError = null;
      return _RefreshSuccess(tokens);
    } on DioException catch (e) {
      // Log refresh failures (endpoint + status) instead of swallowing them,
      // so production issues are diagnosable. Token values are never logged.
      appTalker.error(
        'AuthInterceptor: token refresh failed: '
        'status=${e.response?.statusCode} endpoint=${e.requestOptions.uri} '
        'error=${e.message}',
      );
      // 401/403 表示刷新令牌被拒绝或无权访问:认证失效;
      // 网络连接类、超时、5xx 等均为临时故障,保留会话。直接按状态码分类,
      // 避免畸形 refresh 错误体在此抛 FormatException 逃逸。
      _lastRefreshError = e;
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return const _RefreshAuthFailure();
      }
      return const _RefreshTransientFailure();
    } on Exception catch (e, st) {
      // e.g. session store write failures — still degrade to a transient
      // failure rather than letting the original request hang.
      appTalker.error('AuthInterceptor: token refresh failed: $e', st);
      _lastRefreshError = null;
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
