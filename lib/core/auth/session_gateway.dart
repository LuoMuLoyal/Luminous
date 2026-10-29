import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_snapshot.dart';
import 'package:luminous/core/errors/lucent_failure.dart';

/// The account identity and session operations core needs, expressed without
/// any feature type.
///
/// `lib/core/auth` used to import `features/auth/{domain,data}` directly, which
/// violates `core_not_import_features`. The concrete adapter lives in
/// `lib/app/auth_session_gateway.dart` (the composition root may import both
/// sides); core only ever talks to this interface.
abstract interface class AuthSessionGateway {
  /// Validates the current access token and returns the signed-in account.
  TaskEither<LucentFailure, SessionUserSnapshot> fetchAccount();

  /// Exchanges [refreshToken] for a fresh session and returns its account.
  TaskEither<LucentFailure, SessionSnapshot> refreshSession({
    required String refreshToken,
  });

  /// Revokes the remote session. The local session store is cleared by the
  /// implementation on success.
  TaskEither<LucentFailure, void> logout();
}

/// Composition-root seam: overridden in `ProviderScope` by the adapter.
///
/// Reading it without an override is a wiring bug — fail loudly instead of
/// silently reporting "signed out".
final authSessionGatewayProvider = Provider<AuthSessionGateway>((ref) {
  throw StateError(
    'authSessionGatewayProvider must be overridden by the composition root '
    '(lib/app) with the feature-backed AuthSessionGateway implementation.',
  );
});

/// Invoked after the local session state was cleared by a remote 401.
typedef SessionClearedListener = void Function();

/// DI seam used by [AuthSessionNotifier] to publish session changes outward.
class AuthSessionCallbacks {
  const AuthSessionCallbacks({this.onSignedOut});

  /// Called when an unrecoverable 401 forced the local session to be cleared.
  final SessionClearedListener? onSignedOut;
}

final authSessionCallbacksProvider = Provider<AuthSessionCallbacks>(
  (ref) => const AuthSessionCallbacks(),
);
