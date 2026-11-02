/// Logging seam shared by every layer.
///
/// `data/**` may depend on `core/network`, not on `core/logger`; this file is
/// the only logging surface the data layer consumes. The Talker singleton and
/// its Riverpod providers stay in `core/logger/log_level.dart`, which installs
/// the sink here through [setAppLogSink] so runtime level changes reach every
/// call site.
library;

import 'package:talker_flutter/talker_flutter.dart' as talker_pkg;

enum LogLevel {
  verbose,
  info,
  warning,
  error,
  none;

  /// Parses a string into a [LogLevel], defaulting to [info].
  static LogLevel fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'verbose' => LogLevel.verbose,
      'info' => LogLevel.info,
      'warning' => LogLevel.warning,
      'error' => LogLevel.error,
      'none' => LogLevel.none,
      _ => LogLevel.info,
    };
  }
}

talker_pkg.Talker? _sink;

/// Installs the app-wide log sink. Called once by `core/logger/log_level.dart`.
void setAppLogSink(talker_pkg.Talker sink) {
  _sink = sink;
}

/// The app-wide log sink.
///
/// Falls back to a standalone Talker until `core/logger/log_level.dart` installs
/// the real one, so diagnostics from the data layer are never dropped (and unit
/// tests that never boot the logger keep working).
talker_pkg.Talker get appLog => _sink ?? (_fallback ??= talker_pkg.Talker());

talker_pkg.Talker? _fallback;
