import 'package:luminous/core/network/error_code.dart';

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
    this.traceId,
    this.networkErrorCode,
    this.cause,
  });

  /// Human-readable error message, suitable for display to the user.
  ///
  /// When [networkErrorCode] is non-null, callers should prefer
  /// [NetworkErrorL10n.map] to get a localized message instead of using
  /// this field directly.
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

  /// Backend trace id (from the `traceresponse` response header), if available.
  ///
  /// Unlike [requestId], this is used to correlate client-side failures with
  /// server-side distributed traces.
  final String? traceId;

  /// Network-layer error code for l10n mapping.
  ///
  /// When non-null, the presentation layer should use
  /// [NetworkErrorL10n.map] to produce a localized message instead of
  /// relying on [message] (which may be a developer-facing string).
  final NetworkErrorCode? networkErrorCode;

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
      if (traceId != null && traceId!.isNotEmpty) ', traceId: $traceId',
      if (networkErrorCode != null) ', networkErrorCode: $networkErrorCode',
      ')',
    ];
    return parts.join();
  }
}
