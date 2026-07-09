import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart' as talker;

/// Application log severity levels.
///
/// Maps to [talker.Talker]'s internal log level filtering at runtime.
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

/// Singleton [talker.Talker] instance shared by [talkerProvider] and
/// [appTalker].
///
/// Using a single backing instance ensures that runtime log-level changes
/// applied via [applyLogLevelToTalker] take effect everywhere, regardless
/// of whether the call site accesses the Talker through Riverpod or the
/// global getter.
final _globalTalker = talker.Talker(
  settings: talker.TalkerSettings(
    enabled: !kReleaseMode,
    useConsoleLogs: kDebugMode,
  ),
);

/// Global [talker.Talker] accessor for contexts that do not have a Riverpod
/// [Ref] (e.g. static utility classes, plain repository objects).
///
/// ```dart
/// appTalker.error('Something failed: $e');
/// ```
talker.Talker get appTalker => _globalTalker;

/// Riverpod provider that returns the same [_globalTalker] singleton.
///
/// Usage in widgets/providers:
/// ```dart
/// final talker = ref.read(talkerProvider);
/// talker.info('User logged in');
/// talker.error('Failed to fetch data: $e');
/// ```
///
/// In release builds, logging is disabled via [talker.TalkerSettings.enabled].
final talkerProvider = Provider<talker.Talker>((ref) => _globalTalker);

/// Applies a [LogLevel] to the given [talker.Talker] instance at runtime.
///
/// For [LogLevel.none], disables the Talker entirely.
/// For other levels, reconfigures the internal logger filter.
void applyLogLevelToTalker(talker.Talker talkerInstance, LogLevel level) {
  if (level == LogLevel.none) {
    talkerInstance.disable();
    return;
  }
  talkerInstance.enable();
  talkerInstance.configure(
    logger: talker.TalkerLogger(
      settings: talker.TalkerLoggerSettings(
        level: switch (level) {
          LogLevel.verbose => talker.LogLevel.verbose,
          LogLevel.info => talker.LogLevel.info,
          LogLevel.warning => talker.LogLevel.warning,
          LogLevel.error => talker.LogLevel.error,
          LogLevel.none => talker.LogLevel.error,
        },
      ),
    ),
  );
}
