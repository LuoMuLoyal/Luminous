import 'package:dio/dio.dart';
import 'package:luminous/core/errors/lucent_failure.dart';

/// Decides whether an HTTP failure may be retried by the transport layer.
///
/// This policy is deliberately narrow: server hints never expand the set of
/// retryable statuses, and write requests require both explicit opt-in and an
/// idempotency key.
final class RetryPolicy {
  const RetryPolicy({
    this.retryableStatusCodes = const <int>{408, 429, 500, 502, 503, 504},
  });

  final Set<int> retryableStatusCodes;

  bool shouldRetry(DioException error, RequestOptions options) {
    final retryOverride = options.extra['retryEnabled'];
    if (retryOverride == false) return false;

    final method = options.method.toUpperCase();
    if (method != 'GET') {
      if (retryOverride != true || !_hasIdempotencyKey(options)) return false;
    }

    final failure = error.error;
    if (failure is LucentFailure && failure.retryable == false) {
      return false;
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      return retryableStatusCodes.contains(statusCode);
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badCertificate ||
      DioExceptionType.cancel ||
      DioExceptionType.badResponse ||
      DioExceptionType.unknown => false,
    };
  }

  Duration delay(
    DioException error, {
    required int attempt,
    Duration Function(int attempt)? fallback,
  }) {
    final failure = error.error;
    if (failure is LucentFailure && failure.retryAfter != null) {
      return failure.retryAfter!;
    }

    final retryAfterHeader = error.response?.headers.value('Retry-After');
    final retryAfterSeconds = _parseRetryAfterHeader(retryAfterHeader);
    if (retryAfterSeconds != null) {
      return Duration(seconds: retryAfterSeconds);
    }

    return fallback?.call(attempt) ??
        Duration(milliseconds: 500 * (1 << attempt));
  }

  static bool _hasIdempotencyKey(RequestOptions options) {
    return options.headers.entries.any((entry) {
      return entry.key.toLowerCase() == 'idempotency-key' &&
          entry.value.toString().trim().isNotEmpty;
    });
  }

  static int? _parseRetryAfterHeader(String? value) {
    if (value == null) return null;
    final seconds = int.tryParse(value.trim());
    if (seconds == null || seconds < 0) return null;
    return seconds;
  }
}
