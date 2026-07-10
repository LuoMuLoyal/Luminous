import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart' as talker_pkg;

part 'app_logger.g.dart';

/// Application log severity levels.
///
/// Maps to [talker_pkg.Talker]'s internal log level filtering at runtime.
/// Setting a [LogLevel] suppresses all messages below that level.
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

/// Singleton [talker_pkg.Talker] instance shared by [talkerProvider] and
/// [appTalker].
///
/// Using a single backing instance ensures that runtime log-level changes
/// applied via [applyLogLevelToTalker] take effect everywhere, regardless
/// of whether the call site accesses the Talker through Riverpod or the
/// global getter.
final _globalTalker = talker_pkg.Talker(
  settings: talker_pkg.TalkerSettings(
    enabled: !kReleaseMode,
    useConsoleLogs: kDebugMode,
  ),
);

/// Global [talker_pkg.Talker] accessor for contexts that do not have a Riverpod
/// [Ref] (e.g. static utility classes, plain repository objects).
///
/// ```dart
/// appTalker.error('Something failed: $e');
/// ```
talker_pkg.Talker get appTalker => _globalTalker;

/// Riverpod provider that returns the same [_globalTalker] singleton.
///
/// Usage in widgets/providers:
/// ```dart
/// final talker = ref.read(talkerProvider);
/// talker.info('User logged in');
/// talker.error('Failed to fetch data: $e');
/// ```
///
/// In release builds, logging is disabled via [talker_pkg.TalkerSettings.enabled].
@riverpod
talker_pkg.Talker talker(Ref ref) => _globalTalker;

/// Applies a [LogLevel] to the given [talker_pkg.Talker] instance at runtime.
///
/// For [LogLevel.none], disables the Talker entirely.
/// For other levels, reconfigures the internal logger filter.
void applyLogLevelToTalker(talker_pkg.Talker talkerInstance, LogLevel level) {
  if (level == LogLevel.none) {
    talkerInstance.disable();
    return;
  }
  talkerInstance.enable();
  talkerInstance.configure(
    logger: talker_pkg.TalkerLogger(
      settings: talker_pkg.TalkerLoggerSettings(
        level: switch (level) {
          LogLevel.verbose => talker_pkg.LogLevel.verbose,
          LogLevel.info => talker_pkg.LogLevel.info,
          LogLevel.warning => talker_pkg.LogLevel.warning,
          LogLevel.error => talker_pkg.LogLevel.error,
          LogLevel.none => talker_pkg.LogLevel.error,
        },
      ),
    ),
  );
}
