import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/shared/domain/failure.dart';

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
  /// A [LucentFailure] in the left slot means the key could not be obtained;
  /// callers must surface that as a hard error rather than retrying with
  /// plaintext.
  Future<Either<LucentFailure, Uint8List>> key() async {
    try {
      final existing = await _storage.read(key: storageKey);
      if (existing != null && existing.trim().isNotEmpty) {
        return Right(base64Decode(existing));
      }
    } catch (error, stackTrace) {
      appTalker.error(
        'DatabaseKeyProvider: key read failed',
        error,
        stackTrace,
      );
      return Left(
        LucentFailure.unknown(
          message: 'Database key could not be read from secure storage',
          cause: error,
        ),
      );
    }

    try {
      final generated = _generate();
      await _storage.write(key: storageKey, value: base64Encode(generated));
      return Right(generated);
    } catch (error, stackTrace) {
      appTalker.error(
        'DatabaseKeyProvider: key create failed',
        error,
        stackTrace,
      );
      return Left(
        LucentFailure.unknown(
          message: 'Database key could not be created in secure storage',
          cause: error,
        ),
      );
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
///
/// Kept for platforms/adapters that cannot speak [LucentFailure]; the
/// [DatabaseKeyProvider] API itself returns failures instead.
class DatabaseKeyException implements Exception {
  const DatabaseKeyException(this.reason, this.cause);

  final String reason;
  final Object cause;

  @override
  String toString() => 'DatabaseKeyException($reason): $cause';
}

/// Renders the raw [key] bytes as a `PRAGMA key` argument.
///
/// The `x'...'` form passes the bytes through verbatim, so the encryption engine
/// uses them directly as the 256-bit key. A quoted string would instead be run
/// through the engine's KDF, producing different key material.
///
/// Syntax-compatible with both supported engines (see `pubspec.yaml`'s
/// `hooks.user_defines.sqlite3.source`); on plain SQLite the statement does not
/// exist at all and fails with a syntax error — that means the encryption engine
/// is not built in, not that the key is wrong.
String sqlCipherKeyExpression(Uint8List key) {
  final hex = key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return "x'$hex'";
}
