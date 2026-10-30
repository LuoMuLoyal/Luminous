import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/database/key.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/shared/domain/failure.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Opens a [DatabaseConnection] backed by an encrypted SQLite file on disk.
///
/// Used on Android, iOS, macOS, Windows, and Linux. The database file lives in
/// the app's documents directory as `luminous.db` and is encrypted with
/// SQLite3MultipleCiphers; the key is held by the platform secure store (see
/// [DatabaseKeyProvider]).
///
/// There is no plaintext fallback. When the key cannot be obtained, or the
/// bundled SQLite turns out not to be an encryption build, opening yields a
/// [LucentFailure] instead of falling back to an unencrypted file.
///
/// A database left over from before encryption was introduced is deleted rather
/// than migrated: the local store holds only disposable cache state, so
/// rebuilding is safe and avoids ever leaving a plaintext file behind.
DatabaseConnection connect() {
  return DatabaseConnection(_open());
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'luminous.db'));

    final keyProvider = DatabaseKeyProvider();
    final hadKey = await keyProvider.exists();
    final keyResult = await keyProvider.key();
    final key = keyResult.getOrElse(
      (failure) => throw _DatabaseOpenFailure(failure),
    );

    if (!hadKey && await file.exists()) {
      // No key yet but a file is present: that file predates encryption and is
      // plaintext. Delete it instead of migrating, so no plaintext survives.
      _dropLegacyDatabase(file);
    }

    return NativeDatabase.createInBackground(
      file,
      setup: (raw) {
        final engine = requireCipherEngine(raw);
        engine.match(
          (failure) => throw _DatabaseOpenFailure(failure),
          (_) {},
        );
        // Must run before any other statement touches the database.
        raw.execute('PRAGMA key = ${sqlCipherKeyExpression(key)}');
      },
    );
  });
}

/// Checks that the loaded SQLite can actually encrypt.
///
/// The `cipher` pragma exists only in SQLite3MultipleCiphers (and SQLCipher);
/// upstream SQLite rejects it. Upstream drift recommends this probe to tell
/// "the build hook bundled the encrypted library" apart from "we are running on
/// plain SQLite" — on plain SQLite `PRAGMA key` merely fails with a syntax
/// error, which is easy to mistake for a bad statement while the app goes on
/// writing health data to disk in the clear.
///
/// Returns a [LucentFailure] instead of throwing; the caller decides what to do
/// with it.
Either<LucentFailure, void> requireCipherEngine(sqlite3.Database raw) {
  try {
    raw.select('PRAGMA cipher');
    return const Right(null);
  } on sqlite3.SqliteException catch (error) {
    return Left(
      LucentFailure.unknown(
        message:
            'The bundled SQLite cannot encrypt (no `cipher` pragma). Set '
            '`hooks.user_defines.sqlite3.source: sqlite3mc` in pubspec.yaml '
            'and rebuild; never ship a build that opens the database '
            'without encryption.',
        cause: error,
      ),
    );
  }
}

/// Carries the [LucentFailure] out of drift's synchronous `setup` callback.
///
/// `setup` has no way to return a value, and the open path is already
/// `async` — routing the failure through a private exception keeps the public
/// API (`LazyDatabase` / `DatabaseConnection`) unable to throw at us.
class _DatabaseOpenFailure implements Exception {
  const _DatabaseOpenFailure(this.failure);

  final LucentFailure failure;

  @override
  String toString() => 'DatabaseOpenFailure: ${failure.message}';
}

void _dropLegacyDatabase(File file) {
  appTalker.warning(
    'connection_io: removing pre-encryption database before enabling '
    'SQLite3MultipleCiphers',
  );
  try {
    file.deleteSync();
  } on FileSystemException catch (error, stackTrace) {
    // Deleting a disposable cache file must never block startup: report and
    // continue, the pre-encryption check simply runs again next launch.
    appTalker.error(
      'connection_io: failed to remove pre-encryption database',
      error,
      stackTrace,
    );
  }
}
