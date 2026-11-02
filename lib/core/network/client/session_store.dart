import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/storage/kv_store.dart';

class LucentSessionTokens {
  const LucentSessionTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  bool get hasAccessToken => accessToken.trim().isNotEmpty;

  bool get hasRefreshToken => refreshToken.trim().isNotEmpty;
}

abstract interface class LucentSessionStore {
  Future<LucentSessionTokens?> read();

  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> write(LucentSessionTokens tokens);

  Future<void> clear();
}

/// Returns [value] as a trimmed string only when it really is a String.
///
/// The persisted payload is JSON we wrote ourselves, but a corrupted or
/// hand-edited store can still hold a number/object under these keys; a bare
/// `as String?` would throw instead of degrading to "no token".
String? _stringOrNull(Object? value) => value is String ? value : null;

/// Trims [value]; returns null when the result is empty (or the input is null).
String? _trimmed(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? null : text;
}

/// Returns [value] unless it is null or empty.
String? _firstNonEmpty(String? value) =>
    value == null || value.isEmpty ? null : value;

/// Encodes the token pair as the single atomic payload.
///
/// Tokens are trimmed on the way in: a token wrapped in stray whitespace would
/// otherwise be sent verbatim and rejected by the backend as invalid.
String _encodePayload(LucentSessionTokens tokens) => jsonEncode({
  'accessToken': tokens.accessToken.trim(),
  'refreshToken': tokens.refreshToken.trim(),
});

/// Decodes the payload; null when it is absent or unreadable.
///
/// Trims on the way out as well, so payloads written by older builds (which did
/// not trim) still read back clean.
LucentSessionTokens? _decodePayload(String stored) {
  try {
    final map = jsonDecode(stored);
    if (map is! Map<String, dynamic>) return null;
    return LucentSessionTokens(
      accessToken: (_stringOrNull(map['accessToken']) ?? '').trim(),
      refreshToken: (_stringOrNull(map['refreshToken']) ?? '').trim(),
    );
  } catch (error) {
    appTalker.warning('Session store: payload decode failed: $error');
    return null;
  }
}

/// Key holding the `{accessToken, refreshToken}` JSON payload.
///
/// **Invariant — the pair is stored atomically.** Both tokens live in one JSON
/// payload under a single key, never as two independent values. Access and
/// refresh tokens are consumed together by the refresh flow, so a reader that
/// observes a half-updated pair (new access token + previous refresh token)
/// makes the auth interceptor present an already-spent refresh token to the
/// backend. Lucent rotates refresh tokens with single-use semantics, so that
/// request fails with `AUTH_REFRESH_TOKEN_INVALID` and signs the user out of a
/// session that was still alive.
const String kSessionPayloadKey = 'session.tokens';

/// Session store backed by the key-value store.
///
/// **Web only**: `flutter_secure_storage` has no backend there. Native
/// platforms use [SecureLucentSessionStore].
class KvStoreLucentSessionStore implements LucentSessionStore {
  const KvStoreLucentSessionStore();

  static const String payloadKey = kSessionPayloadKey;

  /// Alias of [payloadKey], kept because callers referenced the old key name.
  static const String accessTokenKey = payloadKey;

  KvStore get _store => KvStore.instance;

  @override
  Future<void> clear() async {
    await _store.remove(payloadKey);
  }

  @override
  Future<LucentSessionTokens?> read() async => _readTokens();

  @override
  Future<String?> readAccessToken() async =>
      _firstNonEmpty(_readTokens()?.accessToken);

  @override
  Future<String?> readRefreshToken() async =>
      _firstNonEmpty(_readTokens()?.refreshToken);

  @override
  Future<void> write(LucentSessionTokens tokens) async {
    // One write = one atomic store operation for the whole pair.
    await _store.set(payloadKey, _encodePayload(tokens));
  }

  LucentSessionTokens? _readTokens() {
    final stored = _trimmed(_store.getOrNull<String>(payloadKey));
    if (stored == null) return null;
    return _decodePayload(stored);
  }
}

/// Persists the signed-in token pair in the platform secure store.
///
/// iOS Keychain / Android Keystore / Windows DPAPI / Linux Secret Service. Web
/// has no backend, so it delegates to [KvStoreLucentSessionStore].
class SecureLucentSessionStore implements LucentSessionStore {
  const SecureLucentSessionStore({
    FlutterSecureStorage? storage,
    KvStoreLucentSessionStore? fallbackStore,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _fallbackStore = fallbackStore ?? const KvStoreLucentSessionStore();

  final FlutterSecureStorage _storage;
  final KvStoreLucentSessionStore _fallbackStore;

  static const String payloadKey = kSessionPayloadKey;
  static const String accessTokenKey = payloadKey;
  static const String refreshTokenKey = payloadKey;

  bool get _useFallback {
    // Web does not support flutter_secure_storage; Windows and Linux
    // are supported via DPAPI / Secret Service API since v9.0.
    return kIsWeb;
  }

  @override
  Future<void> clear() async {
    if (_useFallback) {
      await _fallbackStore.clear();
      return;
    }
    await _storage.delete(key: payloadKey);
  }

  @override
  Future<LucentSessionTokens?> read() async {
    if (_useFallback) {
      return _fallbackStore.read();
    }
    return _readTokens();
  }

  @override
  Future<String?> readAccessToken() async {
    if (_useFallback) {
      return _fallbackStore.readAccessToken();
    }
    return _firstNonEmpty((await _readTokens())?.accessToken);
  }

  @override
  Future<String?> readRefreshToken() async {
    if (_useFallback) {
      return _fallbackStore.readRefreshToken();
    }
    return _firstNonEmpty((await _readTokens())?.refreshToken);
  }

  @override
  Future<void> write(LucentSessionTokens tokens) async {
    if (_useFallback) {
      await _fallbackStore.write(tokens);
      return;
    }
    // One write = one atomic platform call for the whole pair.
    await _storage.write(key: payloadKey, value: _encodePayload(tokens));
  }

  /// Reads and decodes the stored payload; null when absent or unreadable.
  Future<LucentSessionTokens?> _readTokens() async {
    final trimmed = _trimmed(await _storage.read(key: payloadKey));
    if (trimmed == null) return null;
    return _decodePayload(trimmed);
  }
}
