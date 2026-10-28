import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:luminous/core/database/key.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens a [DatabaseConnection] backed by an encrypted SQLite file on disk.
///
/// Used on Android, iOS, macOS, Windows, and Linux. The database file lives in
/// the app's documents directory as `luminous.db` and is encrypted with
/// SQLCipher; the key is held by the platform secure store (see
/// [DatabaseKeyProvider]).
///
/// There is no plaintext fallback: if the key cannot be obtained, opening fails.
/// A database left over from before encryption was introduced is deleted rather
/// than migrated — the local store holds only disposable cache state, so
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
    final key = await keyProvider.key();

    if (!hadKey && await file.exists()) {
      // No key yet but a file is present: that file predates encryption and is
      // plaintext. Delete it instead of migrating, so no plaintext survives.
      appTalker.warning(
        'connection_io: removing pre-encryption database before enabling '
        'SQLCipher',
      );
      try {
        await file.delete();
      } catch (error, stackTrace) {
        appTalker.error(
          'connection_io: failed to remove pre-encryption database',
          error,
          stackTrace,
        );
        rethrow;
      }
    }

    return NativeDatabase.createInBackground(
      file,
      setup: (raw) {
        // Must run before any other statement touches the database.
        raw.execute('PRAGMA key = ${sqlCipherKeyExpression(key)}');
      },
    );
  });
}
