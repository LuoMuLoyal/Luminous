import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/retry_policy.dart';
import 'package:luminous/core/network/contract/problem_details.dart';

void main() {
  const policy = RetryPolicy();

  DioException failure({
    int? statusCode,
    Object? error,
    Map<String, List<String>> headers = const {},
  }) {
    final request = RequestOptions(path: '/test');
    return DioException(
      requestOptions: request,
      type: statusCode == null
          ? DioExceptionType.connectionError
          : DioExceptionType.badResponse,
      error: error,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: request,
              statusCode: statusCode,
              headers: Headers.fromMap(headers),
            ),
    );
  }

  test('retries a GET for an allowed transient HTTP status', () {
    final request = RequestOptions(path: '/test', method: 'GET');

    expect(policy.shouldRetry(failure(statusCode: 503), request), isTrue);
  });

  test('retries a transport timeout without a response', () {
    final request = RequestOptions(path: '/test', method: 'GET');
    final error = DioException(
      requestOptions: request,
      type: DioExceptionType.transformTimeout,
    );

    expect(policy.shouldRetry(error, request), isTrue);
  });

  test('does not retry a non-idempotent write without an idempotency key', () {
    final request = RequestOptions(path: '/test', method: 'POST');

    expect(policy.shouldRetry(failure(statusCode: 503), request), isFalse);
  });

  test('allows an explicitly retried write only with an idempotency key', () {
    final request = RequestOptions(
      path: '/test',
      method: 'POST',
      extra: {'retryEnabled': true},
      headers: {'Idempotency-Key': 'idem-123'},
    );

    expect(policy.shouldRetry(failure(statusCode: 503), request), isTrue);
  });

  test('does not retry a business failure marked non-retryable', () {
    final request = RequestOptions(path: '/test', method: 'GET');
    final problem = ProblemDetails.fromJson({
      'type': 'https://api.lumos.example/problems/rate-limited',
      'title': 'Rate limited',
      'code': 'RATE_LIMITED',
      'retryable': false,
    });
    final lucentFailure = LucentFailure.fromProblemDetails(
      problem,
      statusCode: 503,
    );

    expect(
      policy.shouldRetry(
        failure(statusCode: 503, error: lucentFailure),
        request,
      ),
      isFalse,
    );
  });

  test(
    'does not expand retryable statuses because retryable is only a hint',
    () {
      final request = RequestOptions(path: '/test', method: 'GET');
      final problem = ProblemDetails.fromJson({
        'type': 'https://api.lumos.example/problems/conflict',
        'title': 'Conflict',
        'code': 'RECORD_ALREADY_EXISTS',
        'retryable': true,
      });
      final lucentFailure = LucentFailure.fromProblemDetails(
        problem,
        statusCode: 409,
      );

      expect(
        policy.shouldRetry(
          failure(statusCode: 409, error: lucentFailure),
          request,
        ),
        isFalse,
      );
    },
  );

  test('uses Retry-After delta seconds before exponential backoff', () {
    final error = failure(
      statusCode: 503,
      headers: {
        'retry-after': ['7'],
      },
    );

    expect(policy.delay(error, attempt: 0), const Duration(seconds: 7));
  });

  test('falls back to exponential backoff for a negative Retry-After', () {
    final error = failure(
      statusCode: 503,
      headers: {
        'retry-after': ['-5'],
      },
    );

    expect(policy.delay(error, attempt: 1), const Duration(milliseconds: 1000));
  });

  test('falls back to exponential backoff for a fractional Retry-After', () {
    final error = failure(
      statusCode: 503,
      headers: {
        'retry-after': ['2.5'],
      },
    );

    expect(policy.delay(error, attempt: 0), const Duration(milliseconds: 500));
  });

  test('falls back to exponential backoff for an HTTP-date Retry-After', () {
    final error = failure(
      statusCode: 503,
      headers: {
        'retry-after': ['Wed, 21 Oct 2015 07:28:00 GMT'],
      },
    );

    expect(policy.delay(error, attempt: 2), const Duration(milliseconds: 2000));
  });

  test('uses Problem Details retryAfter before exponential backoff', () {
    final problem = ProblemDetails.fromJson({
      'type': 'https://api.lumos.example/problems/upstream-unavailable',
      'title': 'Upstream unavailable',
      'code': 'UPSTREAM_UNAVAILABLE',
      'retryAfter': 4,
    });
    final lucentFailure = LucentFailure.fromProblemDetails(
      problem,
      statusCode: 503,
    );

    expect(
      policy.delay(failure(statusCode: 503, error: lucentFailure), attempt: 0),
      const Duration(seconds: 4),
    );
  });
}
