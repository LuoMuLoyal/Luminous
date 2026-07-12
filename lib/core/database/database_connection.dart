import 'package:drift/drift.dart';

/// Platform-agnostic database connection factory.
///
/// This is the stub / fallback. It is overridden at compile time by either
/// [database_connection_io.dart] (native platforms) or
/// [database_connection_web.dart] (web / WASM platforms) via conditional
/// imports in `database.dart`.
DatabaseConnection connect() {
  throw UnsupportedError(
    'No database connection implementation for this platform. '
    'Ensure the correct conditional import is configured.',
  );
}
