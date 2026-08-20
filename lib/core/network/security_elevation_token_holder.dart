/// In-memory holder for the security elevation token.
///
/// Bridges the gap between the Riverpod-managed elevation state and the
/// singleton [LucentDioClient]. The Dio interceptor reads the current token
/// from this holder to inject the `x-security-elevation` header on every
/// request.
///
/// The token is short-lived (15 minutes) and intentionally **not** persisted
/// across app restarts — users must re-verify their PIN each session.
class SecurityElevationTokenHolder {
  SecurityElevationTokenHolder({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  String? _token;
  DateTime? _expiresAt;

  /// Returns the raw token string, or `null` if no valid token exists.
  String? get token {
    if (_token == null || _expiresAt == null) return null;
    if (!_now().isBefore(_expiresAt!)) return null;
    return _token;
  }

  /// Whether the holder currently has a non-expired token.
  bool get hasValidToken => token != null;

  /// Stores a freshly obtained elevation token.
  void set(String token, DateTime expiresAt) {
    _token = token;
    _expiresAt = expiresAt;
  }

  /// Clears the stored token (e.g. when the user logs out or the PIN is
  /// changed/disabled, which invalidates all previously issued tokens).
  void clear() {
    _token = null;
    _expiresAt = null;
  }
}
