import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens a [DatabaseConnection] backed by a WASM-compiled SQLite binary.
///
/// Used on web platforms (including HarmonyOS ArkWeb shell). The database
/// is persisted via the browser's Origin Private File System (OPFS) or
/// IndexedDB, depending on browser support.
///
/// Requires two static assets served from the web root:
/// - `sqlite3.wasm` — the SQLite WASM binary
/// - `drift_worker.js` — the drift web worker script
DatabaseConnection connect() {
  return DatabaseConnection(_open());
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'luminous',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    // Use the cross-thread executor when available (enables connection
    // pooling via a web worker). Falls back to a simple in-memory executor
    // for older browsers.
    return result.resolvedExecutor;
  });
}
