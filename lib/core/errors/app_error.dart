/// Categorization of application errors for differentiated handling.
///
/// Used by [AppError] to let callers dispatch on error kind without
/// inspecting raw codes or HTTP status codes.
enum AppErrorKind {
  /// Network connectivity issues — timeouts, connection refused, DNS failure.
  network,

  /// Authentication / authorization failures — token expired, insufficient
  /// permissions, session invalid.
  auth,

  /// Server-side errors — HTTP 5xx, internal database errors.
  server,

  /// Business logic errors — the request was valid but the server rejected
  /// it for domain-specific reasons (e.g. verification code cooldown,
  /// wrong password, conflict).
  business,

  /// Anything that doesn't fit the above categories.
  unknown,
}

/// Unified application error type.
///
/// Wraps [LucentApiException] (or any thrown object) into a structured error
/// that preserves the original exception while exposing a categorized
/// [kind] for callers to dispatch on.
///
/// Created exclusively via [LucentErrorMapper.toAppError] or manually in
/// repository catch blocks.
class AppError {
  const AppError({
    required this.message,
    this.kind = AppErrorKind.unknown,
    this.code,
    this.statusCode,
    this.requestId,
    this.cause,
  });

  /// Human-readable error message, suitable for display to the user.
  final String message;

  /// Categorized error kind for differentiated handling.
  ///
  /// See [AppErrorKind] for the full taxonomy.
  final AppErrorKind kind;

  /// Lucent envelope `code` field (e.g. `401002` for token expired).
  ///
  /// `null` when the error did not originate from a Lucent API response.
  final int? code;

  /// HTTP status code, if available.
  final int? statusCode;

  /// Lucent request ID (`X-Request-Id` header), if available.
  final String? requestId;

  /// The original thrown object, preserved for logging / crash reporting.
  final Object? cause;

  @override
  String toString() {
    final parts = <String>[
      'AppError(message: $message',
      ', kind: $kind',
      if (code != null) ', code: $code',
      if (statusCode != null) ', statusCode: $statusCode',
      if (requestId != null && requestId!.isNotEmpty) ', requestId: $requestId',
      ')',
    ];
    return parts.join();
  }
}
