// ignore_for_file: prefer_initializing_formals, avoid_renaming_method_parameters

import 'package:dio/dio.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/core/network/retry_policy.dart';

/// Retry interceptor: automatically retries 5xx / timeout errors with
/// exponential backoff.
///
/// By default only GET requests are retried. A request can opt-in to retry
/// for other methods by setting `extra['retryEnabled'] = true` and providing
/// an `Idempotency-Key` header, or opt-out for GET by setting
/// `extra['retryEnabled'] = false`.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    int retries = 2,
    Set<int> retryableStatusCodes = const {408, 429, 500, 502, 503, 504},
    Duration Function(int attempt) backoff = _defaultBackoff,
  }) : _dio = dio,
       _maxRetries = retries,
       _policy = RetryPolicy(retryableStatusCodes: retryableStatusCodes),
       _backoff = backoff;

  /// Main Dio instance — used for retrying requests so they go through
  /// the full interceptor chain.
  final Dio _dio;
  final int _maxRetries;
  final RetryPolicy _policy;
  final Duration Function(int attempt) _backoff;

  static const String _retryCountKey = 'retryCount';

  /// Base backoff delay in milliseconds (doubles on every retry attempt).
  static const int _baseRetryDelayMs = 500;

  static Duration _defaultBackoff(int attempt) {
    return Duration(milliseconds: _baseRetryDelayMs * (1 << attempt));
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;

    final retryCount = requestOptions.extra[_retryCountKey] as int? ?? 0;
    if (retryCount >= _maxRetries) {
      handler.next(err);
      return;
    }

    // The ErrorInterceptor (registered after this interceptor) is what maps
    // the error into a LucentFailure; at decision time here `err.error` is
    // still null, so the policy cannot see server hints (`retryable` /
    // `retryAfter`) in the response body. Map best-effort so the policy
    // honors them, while `handler.next`/`handler.resolve` below keep using
    // the original error/response — the caller-visible mapping stays with
    // the ErrorInterceptor.
    final policyError = _withMappedFailure(err);

    if (!_policy.shouldRetry(policyError, requestOptions)) {
      handler.next(err);
      return;
    }

    // Wait before retrying (exponential backoff).
    await Future<void>.delayed(
      _policy.delay(policyError, attempt: retryCount, fallback: _backoff),
    );

    final nextExtra = Map<String, dynamic>.from(requestOptions.extra);
    nextExtra[_retryCountKey] = retryCount + 1;

    try {
      final retryResponse = await _dio.fetch<dynamic>(
        requestOptions.copyWith(extra: nextExtra),
      );
      handler.resolve(retryResponse);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Returns [err] with `error` set to the mapped [LucentFailure] when the
  /// response body is a valid Problem Details document. Malformed bodies
  /// ([FormatException]) leave the original error untouched so the decision
  /// falls back to status-code / error-type based rules.
  DioException _withMappedFailure(DioException err) {
    // Skip parsing for responses that are not Problem Details: the mapper
    // would only throw FormatException for them, so check the media type
    // first to avoid the throw/catch path on every non-contract error body.
    final response = err.response;
    if (response != null) {
      final mediaType = response.headers
          .value(Headers.contentTypeHeader)
          ?.split(';')
          .first
          .trim()
          .toLowerCase();
      if (mediaType != 'application/problem+json') {
        return err;
      }
    }
    try {
      final failure = LucentErrorMapper.fromObject(err);
      return DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: failure,
        stackTrace: err.stackTrace,
      );
    } on FormatException {
      return err;
    }
  }
}
