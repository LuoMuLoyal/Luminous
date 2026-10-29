/// Logging seam for the `data/` layer.
///
/// `data/**` may depend on `core/network` / `core/database` / `core/storage`,
/// not on `core/logger`. Repositories need to *emit* diagnostics (a degraded
/// fetch, an ignored protocol invariant) but must not own logging
/// configuration. This file is the only logging surface they consume.
///
/// `core/logger/log_level.dart` owns the Talker singleton (settings, level
/// filtering, Sentry observer) and installs it through [setAppLogSink], so
/// there is exactly one sink and a level change at runtime reaches every call
/// site.
library;

import 'package:talker_flutter/talker_flutter.dart' as talker_pkg;

talker_pkg.Talker? _sink;

/// Installs the app-wide log sink. Called once by `core/logger/log_level.dart`.
void setAppLogSink(talker_pkg.Talker sink) {
  _sink = sink;
}

/// The app-wide log sink.
///
/// Reading it before [setAppLogSink] ran throws — logging is never silently
/// dropped.
talker_pkg.Talker get appLog =>
    _sink ??
    (throw StateError(
      'app log sink is not installed; core/logger/log_level.dart installs it',
    ));
