/// Shared domain kernel: the failure vocabulary every feature's repository
/// boundary speaks.
///
/// `domain/` may not import `lib/core/**` (clean-layers R1/R2), so the failure
/// type that repository interfaces put in their `TaskEither` left slot cannot
/// live beside the wire types. It lives here instead: a pure-Dart value family
/// with no framework, no I/O and no `core/` dependency.
///
/// Mapping to and from the wire representation (`core/errors/LucentFailure`,
/// RFC 9457 `ProblemDetails`) belongs to the `data/` layer — that is the
/// anti-corruption layer's job, and `data/` is allowed to see both sides.
library;

/// A recoverable failure at a feature's repository boundary.
///
/// Sealed so consumers switch exhaustively: a new variant forces every mapping
/// site to be updated at compile time instead of silently falling through.
sealed class DomainFailure {
  const DomainFailure({this.message, this.code, this.cause});

  /// Developer-facing diagnostic (logs, tests). Never user copy — user copy is
  /// resolved in the presentation layer from [code] (see the feature's
  /// `presentation/` error mapping).
  final String? message;

  /// Stable server or client code, when one exists.
  final String? code;

  /// Underlying error, kept for logging; never rendered.
  final Object? cause;
}

/// Transport-level failure: timeouts, no connectivity, TLS, cancellation.
final class NetworkFailure extends DomainFailure {
  const NetworkFailure({
    super.message,
    super.code,
    super.cause,
    this.retryable = true,
  });

  final bool retryable;
}

/// The caller is not (or no longer) authenticated, or lacks permission.
final class AuthenticationFailure extends DomainFailure {
  const AuthenticationFailure({super.message, super.code, super.cause});
}

/// The request was understood and rejected — validation, conflict, not found.
final class BusinessFailure extends DomainFailure {
  const BusinessFailure({super.message, super.code, super.cause});
}

/// The server failed (5xx). Retrying later is reasonable.
final class ServerFailure extends DomainFailure {
  const ServerFailure({super.message, super.code, super.cause});
}

/// Unclassified failure — the caller could not determine a better variant.
final class UnknownFailure extends DomainFailure {
  const UnknownFailure({super.message, super.code, super.cause});
}
