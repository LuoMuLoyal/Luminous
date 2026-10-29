import 'package:luminous/core/network/contract/problem_details.dart';
import 'package:luminous/shared/domain/failure.dart';

/// Wire -> [LucentFailure] translation.
///
/// [LucentFailure] is pure-Dart vocabulary: the `domain/` layer expresses its
/// repository boundaries in it, so it must not depend on RFC 9457 wire types
/// (clean-layers R1/R2). The mapping from a wire representation onto that
/// vocabulary lives here, beside the wire types themselves.
///
/// Dart extensions cannot declare constructors, so these are static functions
/// on a holder class rather than a `LucentFailure` factory.
abstract final class LucentFailureFromWire {
  const LucentFailureFromWire._();

  static LucentFailure fromProblemDetails(
    ProblemDetails problem, {
    required int statusCode,
    String? traceId,
    Object? cause,
  }) {
    return LucentFailure(
      kind: kindForStatus(statusCode),
      message: problem.detail ?? problem.title,
      type: problem.type,
      title: problem.title,
      detail: problem.detail,
      code: problem.code,
      statusCode: statusCode,
      errors: problem.errors,
      retryable: problem.retryable,
      retryAfter: problem.retryAfter,
      traceId: traceId ?? problem.traceId,
      cause: cause,
    );
  }

  static LucentFailure fromSseProblemDetails(
    SseProblemDetails problem, {
    Object? cause,
  }) {
    return LucentFailure(
      kind: kindForSseStatus(problem.status, problem.code),
      message: problem.detail,
      type: problem.type,
      title: problem.title,
      detail: problem.detail,
      code: problem.code,
      errors: problem.errors,
      retryable: problem.retryable,
      retryAfter: problem.retryAfter,
      traceId: problem.traceId,
      networkErrorCode: problem.status == SseErrorStatus.cancelled
          ? NetworkErrorCode.cancelled
          : null,
      cause: cause,
    );
  }

  /// Classifies an HTTP status into the failure kind.
  ///
  /// 401/403 -> authentication, 5xx -> server, other 4xx -> business.
  static LucentFailureKind kindForStatus(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return LucentFailureKind.authentication;
    }
    if (statusCode >= 500) return LucentFailureKind.server;
    if (statusCode >= 400) return LucentFailureKind.business;
    return LucentFailureKind.unknown;
  }

  /// Classifies an SSE error status + code into the failure kind.
  static LucentFailureKind kindForSseStatus(
    SseErrorStatus status,
    String code,
  ) {
    if (code.startsWith('AUTH_')) return LucentFailureKind.authentication;
    return switch (status) {
      SseErrorStatus.clientError => LucentFailureKind.business,
      SseErrorStatus.serverError => LucentFailureKind.server,
      SseErrorStatus.cancelled ||
      SseErrorStatus.unknown => LucentFailureKind.unknown,
      SseErrorStatus.serverShutdown => LucentFailureKind.server,
    };
  }
}
