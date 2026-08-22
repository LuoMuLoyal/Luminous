import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/problem_details.dart';

void main() {
  test('maps Problem Details into a business LucentFailure', () {
    final failure = LucentFailure.fromProblemDetails(
      ProblemDetails.fromJson({
        'type': 'https://api.lumos.example/problems/record-conflict',
        'title': 'Record conflict',
        'detail': 'A record already exists for this date.',
        'code': 'RECORD_ALREADY_EXISTS',
        'retryable': false,
        'traceId': 'trace-123',
      }),
      statusCode: 409,
    );

    expect(failure.kind, LucentFailureKind.business);
    expect(failure.statusCode, 409);
    expect(failure.code, 'RECORD_ALREADY_EXISTS');
    expect(failure.detail, 'A record already exists for this date.');
    expect(failure.retryable, isFalse);
    expect(failure.traceId, 'trace-123');
    expect(failure.toString(), isNot(contains('requestId')));
  });

  test('classifies authentication and server failures by HTTP status', () {
    final authFailure = LucentFailure.fromProblemDetails(
      ProblemDetails.fromJson({
        'type': 'https://api.lumos.example/problems/auth/token-expired',
        'title': 'Authentication token expired',
        'code': 'AUTH_TOKEN_EXPIRED',
      }),
      statusCode: 401,
    );
    final serverFailure = LucentFailure.fromProblemDetails(
      ProblemDetails.fromJson({
        'type': 'https://api.lumos.example/problems/upstream-unavailable',
        'title': 'Upstream unavailable',
        'code': 'UPSTREAM_UNAVAILABLE',
      }),
      statusCode: 503,
    );

    expect(authFailure.kind, LucentFailureKind.authentication);
    expect(serverFailure.kind, LucentFailureKind.server);
  });

  test('works with fpdart directly at the repository boundary', () {
    const Either<LucentFailure, int> result = Right<LucentFailure, int>(1);
    final TaskEither<LucentFailure, int> task =
        TaskEither<LucentFailure, int>.right(1);

    expect(result.isRight(), isTrue);
    expect(task.run(), completion(isA<Right<LucentFailure, int>>()));
  });
}
