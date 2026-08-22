import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/network/problem_details.dart';

enum LucentFailureKind { network, authentication, business, server, unknown }

/// A normalized, actionable failure at the repository boundary.
///
/// HTTP status is retained as transport metadata. [ProblemDetails] remains
/// the wire representation and is not replaced by this application type.
final class LucentFailure {
  const LucentFailure({
    required this.kind,
    this.type,
    this.title,
    this.detail,
    this.code,
    this.statusCode,
    this.errors,
    this.retryable,
    this.retryAfter,
    this.traceId,
    this.networkErrorCode,
    this.cause,
  });

  factory LucentFailure.fromProblemDetails(
    ProblemDetails problem, {
    required int statusCode,
    Object? cause,
  }) {
    return LucentFailure(
      kind: _kindForStatus(statusCode),
      type: problem.type,
      title: problem.title,
      detail: problem.detail,
      code: problem.code,
      statusCode: statusCode,
      errors: problem.errors,
      retryable: problem.retryable,
      retryAfter: problem.retryAfter,
      traceId: problem.traceId,
      cause: cause,
    );
  }

  final LucentFailureKind kind;
  final String? type;
  final String? title;
  final String? detail;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? errors;
  final bool? retryable;
  final Duration? retryAfter;
  final String? traceId;
  final NetworkErrorCode? networkErrorCode;
  final Object? cause;

  @override
  String toString() {
    final parts = <String>[
      'LucentFailure(kind: $kind',
      if (code != null) ', code: $code',
      if (statusCode != null) ', statusCode: $statusCode',
      if (traceId != null && traceId!.isNotEmpty) ', traceId: $traceId',
      if (networkErrorCode != null) ', networkErrorCode: $networkErrorCode',
      ')',
    ];
    return parts.join();
  }

  static LucentFailureKind _kindForStatus(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return LucentFailureKind.authentication;
    }
    if (statusCode >= 500) return LucentFailureKind.server;
    if (statusCode >= 400) return LucentFailureKind.business;
    return LucentFailureKind.unknown;
  }
}
