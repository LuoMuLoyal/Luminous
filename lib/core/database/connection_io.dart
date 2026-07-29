import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens a [DatabaseConnection] backed by a native SQLite file on disk.
///
/// Used on Android, iOS, macOS, Windows, and Linux. The database file is
/// stored in the app's documents directory as `luminous.db`.
DatabaseConnection connect() {
  return DatabaseConnection(_open());
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'luminous.db'));
    return NativeDatabase.createInBackground(file);
  });
}
