import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens a [DatabaseConnection] backed by a WASM-compiled SQLite binary.
///
/// Used on web platforms (including the HarmonyOS ArkWeb shell). The database
/// is persisted via the browser's Origin Private File System (OPFS) or
/// IndexedDB, depending on browser support.
///
/// **Not encrypted.** SQLCipher applies to the native SQLite build only; the
/// WASM build has no equivalent and there is no key material to inject. Data at
/// rest on web is therefore protected by the browser's origin isolation rather
/// than by database encryption — see ADR-0006 §5, which scopes encryption to
/// native platforms.
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
