import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/core/network/security_elevation_token_holder.dart';

/// State of the security elevation flow.
sealed class SecurityElevationState {
  const SecurityElevationState();

  /// No valid elevation token is available.
  bool get needsVerification => this is SecurityElevationUnverified;

  /// A valid elevation token is available.
  bool get isVerified => this is SecurityElevationVerified;
}

/// No elevation token has been obtained (or it has expired / been cleared).
class SecurityElevationUnverified extends SecurityElevationState {
  const SecurityElevationUnverified();
}

/// A valid elevation token is currently held.
class SecurityElevationVerified extends SecurityElevationState {
  const SecurityElevationVerified({required this.expiresAt});

  final DateTime expiresAt;
}

/// Controller for the security elevation lifecycle.
///
/// - [verify] calls `POST /settings/security-pin/verify` with the user's
///   6-digit PIN and stores the returned elevation token in the
///   [SecurityElevationTokenHolder] so the Dio interceptor can inject it.
/// - [clear] invalidates the token (e.g. on logout, PIN change, PIN disable).
/// - The state reflects whether a valid token is currently held.
class SecurityElevationController extends Notifier<SecurityElevationState> {
  @override
  SecurityElevationState build() {
    // Clear elevation when the auth session changes (logout / user switch).
    ref.listen(authSessionProvider, (_, session) {
      if (session.isConfirmedSignedOut) {
        _holder.clear();
        state = const SecurityElevationUnverified();
      }
    });

    return const SecurityElevationUnverified();
  }

  SecurityElevationTokenHolder get _holder =>
      ref.read(securityElevationTokenHolderProvider);

  /// Verifies the PIN and stores the elevation token.
  ///
  /// Returns `true` on success, `false` on failure (wrong PIN, network
  /// error, PIN not enabled, etc.).
  ///
  /// Uses the raw Dio instance instead of the generated API client because
  /// the backend `SecurityPinElevationResponseDto` OpenAPI schema does not
  /// include the envelope wrapper (`code`/`message`/`data`), causing the
  /// generated deserialization to fail.
  Future<bool> verify(String pin) async {
    final dio = ref.read(lucentDioClientProvider).dio;
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/user/settings/security-pin/verify',
        data: <String, dynamic>{'pin': pin},
      );
      final envelope = response.data!;
      final data = envelope['data'] as Map<String, dynamic>;
      final elevationToken = data['elevationToken'] as String;
      final expiresAtStr = data['expiresAt'] as String;
      final expiresAt =
          DateTime.tryParse(expiresAtStr) ??
          DateTime.now().add(const Duration(minutes: 15));

      _holder.set(elevationToken, expiresAt);
      state = SecurityElevationVerified(expiresAt: expiresAt);
      return true;
    } on Object {
      return false;
    }
  }

  /// Clears the elevation token.
  void clear() {
    _holder.clear();
    state = const SecurityElevationUnverified();
  }

  /// Whether a valid (non-expired) elevation token is currently held.
  bool get hasValidToken => _holder.hasValidToken;
}

final securityElevationControllerProvider =
    NotifierProvider<SecurityElevationController, SecurityElevationState>(
      SecurityElevationController.new,
    );
