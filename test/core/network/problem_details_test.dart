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
