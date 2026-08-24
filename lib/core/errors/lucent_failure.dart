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
    required this.message,
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
    String? traceId,
    Object? cause,
  }) {
    return LucentFailure(
      kind: _kindForStatus(statusCode),
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

  factory LucentFailure.fromSseProblemDetails(
    SseProblemDetails problem, {
    Object? cause,
  }) {
    return LucentFailure(
      kind: _kindForSseStatus(problem.status, problem.code),
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

  factory LucentFailure.network({
    required String message,
    required NetworkErrorCode networkErrorCode,
    String? traceId,
    Object? cause,
  }) {
    return LucentFailure(
      kind: LucentFailureKind.network,
      message: message,
      traceId: traceId,
      networkErrorCode: networkErrorCode,
      cause: cause,
    );
  }

  factory LucentFailure.unknown({
    required String message,
    NetworkErrorCode networkErrorCode = NetworkErrorCode.unknown,
    String? traceId,
    Object? cause,
  }) {
    return LucentFailure(
      kind: LucentFailureKind.unknown,
      message: message,
      traceId: traceId,
      networkErrorCode: networkErrorCode,
      cause: cause,
    );
  }

  final LucentFailureKind kind;
  final String message;
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

  bool get isTokenExpired => code == 'AUTH_TOKEN_EXPIRED';

  bool get isRefreshTokenInvalid => code == 'AUTH_REFRESH_TOKEN_INVALID';

  bool get isPasswordNotSet => code == 'AUTH_PASSWORD_NOT_SET';

  bool get isNetworkConnectivityError =>
      networkErrorCode == NetworkErrorCode.connectionTimeout ||
      networkErrorCode == NetworkErrorCode.sendTimeout ||
      networkErrorCode == NetworkErrorCode.receiveTimeout ||
      networkErrorCode == NetworkErrorCode.connectionError ||
      networkErrorCode == NetworkErrorCode.badCertificate;

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

  static LucentFailureKind _kindForSseStatus(
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
