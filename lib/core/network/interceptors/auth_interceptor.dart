// ignore_for_file: prefer_initializing_formals, avoid_renaming_method_parameters

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/api_paths.dart';
import 'package:luminous/core/network/envelope.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/core/network/result_code.dart';
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

  /// Auth business codes for which a token refresh can never help.
  ///
  /// Any other 401 — including envelopes carrying unknown or unrecognised
  /// codes (e.g. `tokenInvalid`-style responses) — is treated as a refresh
  /// candidate, so recoverable sessions are not force-logged-out.
  static const _nonRefreshableAuthCodes = <int>{
    // refresh 端点自身的拒绝码,出现在主请求 401 时刷新无意义。
    LucentResultCode.refreshTokenInvalid,
    // 限流不是令牌问题,刷新无法解除。
    LucentResultCode.loginRateLimited,
    // 凭据错误不是令牌过期。
    LucentResultCode.wrongPassword,
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

    final data = error.response?.data;
    final json = coerceToStringMap(data);
    final envelope = json == null
        ? null
        : LucentEnvelope<Object?>.fromJson(json, dataDecoder: (raw) => raw);
    final code = envelope?.code;

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

      final json = coerceToStringMap(response.data);
      if (json == null) {
        // 响应体为空/非对象:非认证类失败,保留会话。
        return const _RefreshTransientFailure();
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

      if (!envelope.isSuccess) {
        // 业务码非 0:仅 refreshTokenInvalid / tokenExpired 属认证失效;
        // 其余业务错误(如服务端内部错误)按临时故障处理。
        if (envelope.code == LucentResultCode.refreshTokenInvalid ||
            envelope.code == LucentResultCode.tokenExpired) {
          return const _RefreshAuthFailure();
        }
        return const _RefreshTransientFailure();
      }

      if (envelope.data == null || !envelope.data!.hasAccessToken) {
        // 成功响应但缺少 accessToken(响应体异常):按临时故障处理,保留会话。
        return const _RefreshTransientFailure();
      }

      await _sessionStore.write(envelope.data!);
      return _RefreshSuccess(envelope.data!);
    } on DioException catch (e) {
      // Log refresh failures (endpoint + status) instead of swallowing them,
      // so production issues are diagnosable. Token values are never logged.
      appTalker.error(
        'AuthInterceptor: token refresh failed: '
        'status=${e.response?.statusCode} endpoint=${e.requestOptions.uri} '
        'error=${e.message}',
      );
      // 401/403 表示刷新令牌被拒绝或无权访问:认证失效,应清会话。
      // 网络连接类、超时、5xx 等均为临时故障,保留会话。
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
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
