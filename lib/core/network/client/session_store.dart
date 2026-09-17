import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Persists the signed-in token pair.
///
/// **Invariant — the pair is stored atomically.** Both tokens live in one JSON
/// payload under a single key, never as two independent values. Access and
/// refresh tokens are consumed together by the refresh flow, so a reader that
/// observes a half-updated pair (new access token + previous refresh token)
/// makes the auth interceptor present an already-spent refresh token to the
/// backend. Lucent rotates refresh tokens with single-use semantics, so that
/// request fails with `AUTH_REFRESH_TOKEN_INVALID` and signs the user out of a
/// session that was still alive.
///
/// Legacy installs wrote the two bare tokens under separate keys; both
/// implementations keep reading that layout so existing sessions migrate in
/// place, and drop the legacy refresh key once the payload is in place.
class SharedPrefsLucentSessionStore implements LucentSessionStore {
  const SharedPrefsLucentSessionStore();

  /// Key holding the `{accessToken, refreshToken}` JSON payload.
  ///
  /// Historically held the bare access token; the payload is detected by its
  /// leading `{`, so reusing the key lets an existing install migrate in place.
  static const String payloadKey = PrefKeys.accessToken;

  /// Alias of [payloadKey], kept because callers referenced the old key name.
  static const String accessTokenKey = PrefKeys.accessToken;

  /// Legacy key that held the bare refresh token. [read] re-encodes the pair
  /// into [payloadKey] and then drops this key.
  static const String refreshTokenKey = PrefKeys.refreshToken;

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  @override
  Future<void> clear() async {
    final prefs = await _prefs();
    await prefs.remove(payloadKey);
    await prefs.remove(refreshTokenKey);
  }

  @override
  Future<LucentSessionTokens?> read() async {
    final prefs = await _prefs();
    final tokens = _readTokens(prefs);
    if (tokens == null) return null;

    // Migrate the legacy two-key layout forward *before* dropping the legacy
    // key: the bare access token sits under [payloadKey], which the new layout
    // reuses, so a dropped refresh key without a re-encoded payload would lose
    // half of the pair.
    await _migrateLegacyTokens(prefs, tokens);
    return tokens;
  }

  @override
  Future<String?> readAccessToken() async =>
      _firstNonEmpty(_readTokens(await _prefs())?.accessToken);

  @override
  Future<String?> readRefreshToken() async =>
      _firstNonEmpty(_readTokens(await _prefs())?.refreshToken);

  @override
  Future<void> write(LucentSessionTokens tokens) async {
    final prefs = await _prefs();
    // One setString = one atomic store operation for the whole pair.
    await prefs.setString(payloadKey, _encodePayload(tokens));
    await _dropLegacyRefreshToken(prefs);
  }

  /// Reads the payload, falling back to the legacy two-key layout.
  LucentSessionTokens? _readTokens(SharedPreferences prefs) {
    final stored = prefs.getString(payloadKey);
    if (stored != null && stored.trim().startsWith('{')) {
      return _decodePayload(stored);
    }

    // Legacy layout: the bare access token sat under [payloadKey] (same key)
    // and the bare refresh token under [refreshTokenKey].
    final access = _trimmed(stored);
    final refresh = _trimmed(prefs.getString(refreshTokenKey));
    if (access == null && refresh == null) return null;
    return LucentSessionTokens(
      accessToken: access ?? '',
      refreshToken: refresh ?? '',
    );
  }

  /// Re-encodes a pair that was read from the legacy layout as the single-key
  /// payload, then drops the legacy refresh key.
  Future<void> _migrateLegacyTokens(
    SharedPreferences prefs,
    LucentSessionTokens tokens,
  ) async {
    final stored = prefs.getString(payloadKey);
    final usesLegacyLayout = stored == null || !stored.trim().startsWith('{');
    if (usesLegacyLayout) {
      await prefs.setString(payloadKey, _encodePayload(tokens));
    }
    await _dropLegacyRefreshToken(prefs);
  }

  /// Drops the legacy refresh key after a successful migration. Best effort: a
  /// failure here never fails the read or write that triggered it.
  Future<void> _dropLegacyRefreshToken(SharedPreferences prefs) async {
    if (!prefs.containsKey(refreshTokenKey)) return;
    try {
      await prefs.remove(refreshTokenKey);
    } catch (error) {
      appTalker.warning('Session store: legacy key cleanup failed: $error');
    }
  }
}

class SecureLucentSessionStore implements LucentSessionStore {
  const SecureLucentSessionStore({
    FlutterSecureStorage? storage,
    SharedPrefsLucentSessionStore? fallbackStore,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _fallbackStore = fallbackStore ?? const SharedPrefsLucentSessionStore();

  final FlutterSecureStorage _storage;
  final SharedPrefsLucentSessionStore _fallbackStore;

  static const String payloadKey = SharedPrefsLucentSessionStore.payloadKey;
  static const String accessTokenKey =
      SharedPrefsLucentSessionStore.accessTokenKey;
  static const String refreshTokenKey =
      SharedPrefsLucentSessionStore.refreshTokenKey;

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
    await _storage.delete(key: refreshTokenKey);
  }

  @override
  Future<LucentSessionTokens?> read() async {
    if (_useFallback) {
      return _fallbackStore.read();
    }
    final tokens = await _readTokens();
    if (tokens == null) return null;

    // Migrate the legacy two-key layout forward *before* dropping the legacy
    // key. The payload write must land first: the bare access token is stored
    // under [payloadKey], so a failed write followed by a successful legacy-key
    // delete would lose half of the pair.
    await _migrateLegacyTokens(tokens);
    return tokens;
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
    await _dropLegacyRefreshToken();
  }

  /// Reads the payload, falling back to the legacy two-key layout.
  Future<LucentSessionTokens?> _readTokens() async {
    final stored = await _storage.read(key: payloadKey);
    final trimmed = _trimmed(stored);
    if (trimmed == null) {
      // No access token; a stray legacy refresh token still counts as the
      // "refresh token only" state the session restore flow relies on.
      final refresh = _trimmed(await _storage.read(key: refreshTokenKey));
      if (refresh == null) return null;
      return LucentSessionTokens(accessToken: '', refreshToken: refresh);
    }
    if (trimmed.startsWith('{')) {
      return _decodePayload(trimmed);
    }
    // Legacy bare access token; the refresh token lives under its own key.
    return LucentSessionTokens(
      accessToken: trimmed,
      refreshToken: _trimmed(await _storage.read(key: refreshTokenKey)) ?? '',
    );
  }

  /// Re-encodes a pair that was read from the legacy layout as the single-key
  /// payload, then drops the legacy refresh key.
  Future<void> _migrateLegacyTokens(LucentSessionTokens tokens) async {
    final stored = await _storage.read(key: payloadKey);
    final usesLegacyLayout = stored == null || !stored.trim().startsWith('{');
    if (usesLegacyLayout) {
      await _storage.write(key: payloadKey, value: _encodePayload(tokens));
    }
    await _dropLegacyRefreshToken();
  }

  /// Drops the legacy refresh key after a successful migration. Best effort: a
  /// failure here never fails the read or write that triggered it.
  Future<void> _dropLegacyRefreshToken() async {
    try {
      await _storage.delete(key: refreshTokenKey);
    } catch (error) {
      appTalker.warning('Session store: legacy key cleanup failed: $error');
    }
  }
}

/// Serializes [tokens] as the single-key session payload, trimming both values.
String _encodePayload(LucentSessionTokens tokens) {
  return jsonEncode(<String, String>{
    'accessToken': tokens.accessToken.trim(),
    'refreshToken': tokens.refreshToken.trim(),
  });
}

/// Decodes a session payload.
///
/// Returns null when [raw] is absent, empty, or syntactically invalid. A value
/// that is not a JSON object is a legacy bare access token rather than a
/// corrupted payload, so the legacy refresh token completes the pair.
LucentSessionTokens? _decodePayload(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;

  if (!text.startsWith('{')) {
    return LucentSessionTokens(accessToken: text, refreshToken: '');
  }

  Object? decoded;
  try {
    decoded = jsonDecode(text);
  } on FormatException catch (error) {
    appTalker.warning('Session store: payload decode failed: $error');
    return null;
  }
  if (decoded is! Map) return null;

  return LucentSessionTokens(
    accessToken: _trimmed(_stringOrNull(decoded['accessToken'])) ?? '',
    refreshToken: _trimmed(_stringOrNull(decoded['refreshToken'])) ?? '',
  );
}
