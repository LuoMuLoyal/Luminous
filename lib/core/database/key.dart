import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luminous/core/logger/log_level.dart';

/// Owns the SQLCipher key for the local database.
///
/// The key is 32 raw bytes — the size SQLCipher expects for a 256-bit key —
/// drawn from `Random.secure()`, which is backed by the platform CSPRNG
/// (Android `SecureRandom`, Apple `SecRandomCopyBytes`, Windows
/// `BCryptGenRandom`). It is generated once per install and stored base64 in the
/// platform secure store.
///
/// The key is never written to the database, to the key-value store, or to logs.
///
/// **Failure is never downgraded to plaintext.** If the key cannot be read or
/// created, opening the database fails loudly instead of falling back to an
/// unencrypted file — a silent plaintext database is worse than an unavailable
/// one.
class DatabaseKeyProvider {
  DatabaseKeyProvider({FlutterSecureStorage? storage, Random? random})
    : _storage = storage ?? const FlutterSecureStorage(),
      _random = random ?? Random.secure();

  /// Secure-store key holding the base64-encoded SQLCipher key.
  static const String storageKey = 'luminous.db.key';

  /// Length of the raw key: SQLCipher uses 256-bit keys.
  static const int keyLength = 32;

  final FlutterSecureStorage _storage;
  final Random _random;

  /// Returns the raw database key, creating and persisting one on first use.
  ///
  /// Throws [DatabaseKeyException] when the key cannot be obtained; callers must
  /// surface that as a hard error rather than retrying with plaintext.
  Future<Uint8List> key() async {
    try {
      final existing = await _storage.read(key: storageKey);
      if (existing != null && existing.trim().isNotEmpty) {
        return base64Decode(existing);
      }
    } catch (error, stackTrace) {
      appTalker.error(
        'DatabaseKeyProvider: key read failed',
        error,
        stackTrace,
      );
      throw DatabaseKeyException('read failed', error);
    }

    try {
      final generated = _generate();
      await _storage.write(key: storageKey, value: base64Encode(generated));
      return generated;
    } catch (error, stackTrace) {
      appTalker.error(
        'DatabaseKeyProvider: key create failed',
        error,
        stackTrace,
      );
      throw DatabaseKeyException('create failed', error);
    }
  }

  /// Whether a key already exists (used to detect a fresh install).
  Future<bool> exists() async {
    try {
      final existing = await _storage.read(key: storageKey);
      return existing != null && existing.trim().isNotEmpty;
    } catch (error) {
      appTalker.warning('DatabaseKeyProvider: existence check failed: $error');
      return false;
    }
  }

  /// [keyLength] cryptographically secure random bytes.
  Uint8List _generate() {
    final bytes = Uint8List(keyLength);
    for (var i = 0; i < keyLength; i++) {
      // nextInt(256) is uniform over 0..255: a power-of-two bound, so there is
      // no modulo bias.
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }
}

/// Thrown when the database key cannot be read or created.
class DatabaseKeyException implements Exception {
  const DatabaseKeyException(this.reason, this.cause);

  final String reason;
  final Object cause;

  @override
  String toString() => 'DatabaseKeyException($reason): $cause';
}

/// Renders the raw [key] bytes as a SQLCipher `PRAGMA key` argument.
///
/// The `x'...'` form passes the bytes through verbatim, so SQLCipher uses them
/// directly as the 256-bit key. A quoted string would instead be run through
/// SQLCipher's KDF, producing different key material.
String sqlCipherKeyExpression(Uint8List key) {
  final hex = key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return "x'$hex'";
}
