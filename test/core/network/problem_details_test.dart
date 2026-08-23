import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/problem_details.dart';

void main() {
  group('ProblemDetails.fromJson', () {
    test('parses the target RFC 9457 fields and extensions', () {
      final problem = ProblemDetails.fromJson({
        'type': 'https://api.lumos.example/problems/record-conflict',
        'title': 'Record conflict',
        'detail': 'A record already exists for this date.',
        'code': 'RECORD_ALREADY_EXISTS',
        'errors': {
          'date': ['already exists'],
        },
        'retryable': false,
        'retryAfter': 3,
        'traceId': '4bf92f3577b34da6a3ce929d0e0e4736',
      });

      expect(
        problem.type,
        'https://api.lumos.example/problems/record-conflict',
      );
      expect(problem.title, 'Record conflict');
      expect(problem.detail, 'A record already exists for this date.');
      expect(problem.code, 'RECORD_ALREADY_EXISTS');
      expect(problem.errors, {
        'date': ['already exists'],
      });
      expect(problem.retryable, isFalse);
      expect(problem.retryAfter, const Duration(seconds: 3));
      expect(problem.traceId, '4bf92f3577b34da6a3ce929d0e0e4736');
    });

    test('parses the SSE error event contract', () {
      final problem = SseProblemDetails.fromJson({
        'type': 'https://api.lumos.example/problems/dependency-unavailable',
        'title': 'Service temporarily unavailable',
        'detail': 'Try again later.',
        'code': 'DEPENDENCY_UNAVAILABLE',
        'retryable': true,
        'retryAfter': 5,
        'status': 'server_error',
      });

      expect(problem.code, 'DEPENDENCY_UNAVAILABLE');
      expect(problem.detail, 'Try again later.');
      expect(problem.retryable, isTrue);
      expect(problem.retryAfter, const Duration(seconds: 5));
      expect(problem.status, SseErrorStatus.serverError);
    });

    test('rejects a legacy SSE error payload', () {
      expect(
        () => SseProblemDetails.fromJson({
          'message': 'service unavailable',
          'code': 500,
          'statusCode': 503,
        }),
        throwsFormatException,
      );
    });

    test('parses an SSE error event and ignores retired noise fields', () {
      final problem = SseProblemDetails.fromJson({
        'type': 'https://api.lumos.example/problems/dependency-unavailable',
        'title': 'Service temporarily unavailable',
        'detail': 'Try again later.',
        'code': 'DEPENDENCY_UNAVAILABLE',
        'status': 'server_error',
        // Retired / noise fields must not be interpreted or re-emitted.
        'statusCode': 503,
        'requestId': 'legacy-request-id',
        'stack': 'at Server.processRequest (server.dart:123)',
        'data': {'secret': 'raw-envelope-data'},
      });

      expect(problem.status, SseErrorStatus.serverError);
      expect(problem.code, 'DEPENDENCY_UNAVAILABLE');
      expect(problem.toJson(), {
        'type': 'https://api.lumos.example/problems/dependency-unavailable',
        'title': 'Service temporarily unavailable',
        'detail': 'Try again later.',
        'code': 'DEPENDENCY_UNAVAILABLE',
        'status': 'server_error',
      });
    });

    test('rejects a numeric status instead of treating it as an HTTP code', () {
      expect(
        () => SseProblemDetails.fromJson({
          'type': 'https://api.lumos.example/problems/dependency-unavailable',
          'title': 'Service temporarily unavailable',
          'detail': 'Try again later.',
          'code': 'DEPENDENCY_UNAVAILABLE',
          'status': 503,
        }),
        throwsFormatException,
      );
    });

    test('does not expose retired status or request correlation fields', () {
      final problem = ProblemDetails.fromJson({
        'type': 'https://api.lumos.example/problems/conflict',
        'title': 'Conflict',
        'code': 'RECORD_ALREADY_EXISTS',
        'status': 409,
        'statusCode': 409,
        'requestId': 'legacy-request-id',
      });

      expect(problem.toJson(), {
        'type': 'https://api.lumos.example/problems/conflict',
        'title': 'Conflict',
        'code': 'RECORD_ALREADY_EXISTS',
      });
    });

    test('rejects the old numeric envelope instead of interpreting it', () {
      expect(
        () => ProblemDetails.fromJson({
          'code': 409001,
          'message': 'Conflict',
          'data': null,
        }),
        throwsFormatException,
      );
    });

    test('rejects missing required target fields', () {
      expect(
        () => ProblemDetails.fromJson({
          'type': 'https://api.lumos.example/problems/conflict',
          'title': 'Conflict',
        }),
        throwsFormatException,
      );
    });

    test('rejects malformed retryAfter instead of silently coercing it', () {
      expect(
        () => ProblemDetails.fromJson({
          'type': 'https://api.lumos.example/problems/conflict',
          'title': 'Conflict',
          'code': 'RECORD_ALREADY_EXISTS',
          'retryAfter': '3',
        }),
        throwsFormatException,
      );
    });
  });
}
