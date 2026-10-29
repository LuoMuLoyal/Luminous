/// Shared domain kernel: the failure vocabulary every feature's repository
/// boundary speaks.
///
/// `domain/` may not import `lib/core/**` (clean-layers R1/R2), so the failure
/// type that repository interfaces put in their `TaskEither` left slot cannot
/// live beside the wire types. It lives here instead: pure Dart, zero imports,
/// no framework and no I/O.
///
/// The `core/` files remain thin re-export façades so existing imports keep
/// working; mapping to and from the wire representation (`ProblemDetails`,
/// `LucentFailureFromWire`) stays in `core/network` and the `data/` layer.
library;

/// Failure codes for errors the **client** detects itself.
///
/// The failing layer (data service, platform client, interceptor) carries this
/// enum instead of user-visible copy; the presentation layer maps it to a
/// localized string through `ClientErrorL10n.map`, normally via
/// `userMessageFromError`.
///
/// [NetworkErrorCode] stays the vocabulary for transport failures, and
/// `LucentFailure.code` for codes the server sent. Client codes fill the third
/// gap: "the client refused before/without a server answer".
enum ClientErrorCode {
  /// The action needs a signed-in user, but the session has none.
  notSignedIn,

  /// WeChat mobile SDK login is unavailable in this build (no app id).
  wechatSdkNotConfigured,

  /// WeChat mobile SDK login is not available on this platform.
  wechatMobileUnsupported,

  /// WeChat desktop OAuth callback listener is not available on this platform.
  wechatDesktopUnsupported,

  /// `Fluwx.registerApi` returned false.
  wechatSdkRegistrationFailed,

  /// The WeChat app is not installed on the device.
  wechatNotInstalled,

  /// WeChat authorization was cancelled or reported failure.
  wechatAuthFailed,

  /// WeChat authorization could not be started.
  wechatAuthStartFailed,

  /// WeChat authorization did not complete before the deadline.
  wechatAuthTimeout,

  /// No refresh token in the store, so the session cannot be renewed.
  refreshTokenUnavailable,

  /// Avatar upload refused: the picked file is empty.
  avatarFileEmpty,

  /// Avatar upload refused: the content type is not allowed.
  avatarFileTypeUnsupported,

  /// Avatar upload refused: the file exceeds the client size limit.
  avatarFileTooLarge,

  /// The reminder group has no usable occurrence to export to the calendar.
  reminderCalendarUnavailable,

  /// The system calendar refused or could not accept the event.
  reminderCalendarWriteFailed,
}

/// Network-layer error codes used to map l10n strings in the presentation layer.
///
/// The network layer carries this enum (not hardcoded message text) when
/// throwing [LucentFailure]. The presentation layer maps it to a localized
/// string via `NetworkErrorL10n`.
enum NetworkErrorCode {
  /// A domain/business failure that is not represented by a transport error.
  businessFailure,

  /// Stream response is empty
  emptyStreamResponse,

  /// SSE payload cannot be parsed as a Map
  invalidSsePayload,

  /// Response body is empty
  emptyResponse,

  /// Connection timeout
  connectionTimeout,

  /// Request send timeout
  sendTimeout,

  /// Response receive timeout
  receiveTimeout,

  /// Server certificate validation failed
  badCertificate,

  /// Network connection failed
  connectionError,

  /// Request cancelled
  cancelled,

  /// HTTP status code error
  badResponse,

  /// Unknown network error
  unknown,
}

enum LucentFailureKind { network, authentication, business, server, unknown }

/// A normalized, actionable failure at the repository boundary.
///
/// HTTP status is retained as transport metadata. `ProblemDetails` remains
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
    this.clientErrorCode,
    this.cause,
  });

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

  factory LucentFailure.business({
    required String message,
    String? code,
    Object? cause,
  }) {
    return LucentFailure(
      kind: LucentFailureKind.business,
      message: message,
      code: code,
      cause: cause,
    );
  }

  /// A failure the client itself detected — no server code exists for it.
  ///
  /// [message] stays a developer-facing diagnostic (logs, tests); the user
  /// copy comes from [clientErrorCode] via `ClientErrorL10n.map`.
  factory LucentFailure.client({
    required ClientErrorCode clientErrorCode,
    required String message,
    LucentFailureKind kind = LucentFailureKind.business,
    NetworkErrorCode? networkErrorCode,
    Object? cause,
  }) {
    return LucentFailure(
      kind: kind,
      message: message,
      clientErrorCode: clientErrorCode,
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

  /// Set when the failure originates in this client rather than the wire.
  /// Takes precedence over [networkErrorCode] when resolving user copy.
  final ClientErrorCode? clientErrorCode;
  final Object? cause;

  bool get isTokenExpired => code == 'AUTH_TOKEN_EXPIRED';

  /// The backend error code returned when a request carries no access token the
  /// guard can accept: missing header, malformed token, or a signature that no
  /// longer verifies (`JWT_ACCESS_SECRET` rotated).
  ///
  /// Refreshable — the opaque refresh token outlives the access token, so a
  /// stored one can still renew the session (see `AuthInterceptor`).
  static const kAuthRequiredCode = 'AUTH_REQUIRED';

  bool get isAuthRequired => code == kAuthRequiredCode;

  bool get isRefreshTokenInvalid => code == 'AUTH_REFRESH_TOKEN_INVALID';

  /// The backend error code returned when an OAuth-only user has no local
  /// password and a sensitive action requires password re-authentication.
  static const kPasswordNotSetCode = 'AUTH_PASSWORD_NOT_SET';

  bool get isPasswordNotSet => code == kPasswordNotSetCode;

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
      if (clientErrorCode != null) ', clientErrorCode: $clientErrorCode',
      if (networkErrorCode != null) ', networkErrorCode: $networkErrorCode',
      ')',
    ];
    return parts.join();
  }
}
